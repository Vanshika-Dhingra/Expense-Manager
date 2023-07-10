import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracking/helpers/CommonClass.dart';
import 'package:expensetracking/helpers/UIConstants.dart';
import 'package:expensetracking/helpers/Constants.dart';
import 'package:expensetracking/models/ExpenseModel.dart';
import 'package:expensetracking/models/UserModel.dart';
import 'package:expensetracking/models/VendorModel.dart';
import 'package:expensetracking/providers/db_provider.dart';
import 'package:expensetracking/screens/category/category_screen.dart';
import 'package:expensetracking/screens/vendor/contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:expensetracking/screens/expense/input_screen.dart';

import '../category/input_screen.dart';
import '../singleProject/navigation_bar.dart';

class UserScreen extends StatefulWidget {
  String createdUserId;
  String projectId;
  UserScreen(this.createdUserId,this.projectId,{Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {

  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  String? _userId;
  List<UserModel>users=[];

  Future<void> _askPermissionForContacts() async {
    if (!mounted) return; // Check if the widget is still mounted

    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      //Navigator.pop(context);
      CommonClass.openModalBottomSheet(context, child: ContactScreen(), enableDrag: false, isScrollControlled: true, isDismissible: false)
          .then((value) {
        if (!mounted) return; // Check if the widget is still mounted

        print(value);
        if (value == null) return;
        var colRef = _firebase.collection(Constants.userCollection);
        colRef.where('phone', isEqualTo: value['phone']).get().then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            // Phone number already exists, retrieve the userId
            var existingUser = querySnapshot.docs[0];
            var existingUserId = existingUser.id;

            // Update project's userIds with the existing userId
            var projectRef = _firebase.collection('projects').doc(widget.projectId);
            projectRef.update({
              'userIds': FieldValue.arrayUnion([existingUserId])
            }).then((_) {
              print('Updated project with existing userId');
            }).catchError((error) {
              print('Error updating project: $error');
            });
          }
          else
          {
            print('user does not exist');
          }
        });
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }


  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    String message = "";
    switch(permissionStatus) {
      case PermissionStatus.permanentlyDenied: {
        message = "Contact data not available on device";
        break;
      }
      case PermissionStatus.denied: {
        message = "Access to contact data denied";
        break;
      }
      default: {
        message = "Something went wrong please try again";
      }
    }
    CommonClass.openErrorDialog(context: context, message: message, isPermissionError: true);
  }

  @override
  void initState() {
    _userId = context.read<DbProvider>().getUserId;
  }

  @override
  Widget build(BuildContext context) {
    String s=widget.projectId;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Users",
          style: GoogleFonts.robotoMono(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<List<UserModel>>(
          future: context.read<DbProvider>().fetchUsersByProjectId(s),
          builder: (context,snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              users = snapshot.data!;
              return   Column(
                children: [
                  _showVendorList(users)
                ],
              );
            }}
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _askPermissionForContacts,
        label: const Text("Add User"),
        icon: const Icon(Icons.add),
      ),
      //bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  Widget _showVendorList(List<UserModel> vendors) {
    return Expanded(

      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView.builder(
          itemCount: vendors.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                //border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.grey.shade900
              ),
              child: ListTile(
                title: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              vendors.elementAt(index).name ?? "",
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                  color: Colors.white
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                vendors.elementAt(index).userId==widget.createdUserId?'admin':'',
                                style: GoogleFonts.roboto(
                                    fontSize: 20,
                                    color: Colors.green
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          vendors.elementAt(index).phone ?? "",
                          style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.grey.shade500
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) {
                        List<PopupMenuEntry<Object>> menuItems = [

                        ];
                        if (_userId == widget.createdUserId && vendors.elementAt(index).userId!=widget.createdUserId) {
                          menuItems.add(const PopupMenuItem(
                            value: 'makeAdmin',
                            child: Text('Make Admin'),
                          ));
                        }
                        if (_userId == widget.createdUserId) {
                          menuItems.add(const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),);
                        }
                        return menuItems;
                      },
                      onSelected: (value) {
                        if (value == 'delete') {
                          DbProvider dbProvider = DbProvider();
                          dbProvider.deleteUserFromProject(widget.projectId,vendors.elementAt(index).userId);
                        }
                        if (value == 'makeAdmin') {
                          DbProvider dbProvider = DbProvider();
                          //dbProvider.deleteUserFromProject(widget.projectId,vendors.elementAt(index).userId);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
