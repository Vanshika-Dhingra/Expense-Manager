import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracking/helpers/CommonClass.dart';
import 'package:expensetracking/helpers/UIConstants.dart';
import 'package:expensetracking/helpers/Constants.dart';
import 'package:expensetracking/models/CategoryModel.dart';
import 'package:expensetracking/models/ProjectModel.dart';
import 'package:expensetracking/models/VendorModel.dart';
import 'package:expensetracking/providers/db_provider.dart';
import 'package:expensetracking/screens/singleProject/singleBar/single_bar.dart';
import 'package:expensetracking/screens/users/user_screen.dart';
import 'package:expensetracking/screens/vendor/contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:expensetracking/screens/category/input_screen.dart';
import 'package:expensetracking/screens/expense/input_screen.dart';
import 'package:expensetracking/screens/singleProject/barGraph/bar_graph.dart';

import '../category/category_screen.dart';
import '../expense/expense_screen.dart';
import 'navigation_bar.dart';
import 'package:intl/intl.dart';

class SingleProject extends StatefulWidget {
  final String? projectId;
  final String? userId;
  final String? projectModel;
  final ProjectModel? project;

  const SingleProject({Key? key, @required this.projectModel,@required this.projectId, @required this.userId,@required this.project}) : super(key: key);

  @override
  State<SingleProject> createState() => _SingleProjectScreenState();
}

class _SingleProjectScreenState extends State<SingleProject> {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  String? _userId;
  String? totalExpenses;
  double sum=0.0;
  List<double> weeklySummary = [];
  DateTime startOfWeek = DateTime.now();
  DateTime endOfWeek = DateTime.now();
  void showPreviousWeek() {
    setState(() {
      startOfWeek = startOfWeek.subtract(const Duration(days: 7));
      endOfWeek = endOfWeek.subtract(const Duration(days: 7));
    });
    calculateTotalExpenses();
  }
  void showNextWeek() {
    setState(() {
      startOfWeek = startOfWeek.add(const Duration(days: 7));
      endOfWeek = endOfWeek.add(const Duration(days: 7));
    });
    calculateTotalExpenses();
  }
  void _openVendorOptionsModal() {
    Widget container = Container(
      height: MediaQuery.of(context).size.height * 0.21,
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.padding16, vertical: UIConstants.padding12),
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(UIConstants.borderRadius16),
            topRight: Radius.circular(UIConstants.borderRadius16),
          )
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Options",
                style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 16
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 32,
                  width: 32,
                  // padding: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.all(Radius.circular(12))
                  ),
                  child: const Icon(Icons.close, size: 18,),
                ),
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: UIConstants.boxShadowDecoration,
            child: Column(
              children: [
                //CommonClass.getNavigatorRowItem(rowTitle: "Show users", icon: Icons.add),
                InkWell(
                    onTap: (){Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserScreen(widget.userId!, widget.projectId!)),
                    );},
                    child: CommonClass.getNavigatorRowItem(rowTitle: "Show Users", icon: Icons.add, isLastItem: true)
                ),
                InkWell(
                    onTap: _askPermissionForContacts,
                    child: CommonClass.getNavigatorRowItem(rowTitle: "Add Users", icon: Icons.contacts, isLastItem: true)
                ),
              ],
            ),
          )
        ],
      ),
    );
    CommonClass.openModalBottomSheet(context, child: container, enableDrag: true, isScrollControlled: true);
  }
  Future<void> _askPermissionForContacts() async {
    if (!mounted) return; // Check if the widget is still mounted

    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Navigator.pop(context);
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

  Future<void> _newProject(String s) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputCategory(s),
      ),
    );
  }

  // Future<void> _newExpense(String s) async {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => InputExpense(s),
  //     ),
  //   );
  // }
  DateTime getStartOfWeek(DateTime date) {
    int dayOfWeek = date.weekday;
    DateTime startOfWeek = date.subtract(Duration(days: dayOfWeek));
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  }

  DateTime getEndOfWeek(DateTime date) {
    int dayOfWeek = date.weekday;
    DateTime endOfWeek = date.add(Duration(days: 6 - dayOfWeek));
    return DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
  }

  void _openOptionsModal() {
    Widget container = Container(
      height: MediaQuery.of(context).size.height * 0.35,
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.padding16, vertical: UIConstants.padding12),
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(UIConstants.borderRadius16),
            topRight: Radius.circular(UIConstants.borderRadius16),
          )
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Options",
                style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 16
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 64,
                  width: 32,
                  // padding: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.all(Radius.circular(12))
                  ),
                  child: const Icon(Icons.close, size: 18,),
                ),
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: UIConstants.boxShadowDecoration,
            child: Column(
              children: [
                InkWell(
                    onTap: (){Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExpenseScreen(widget.projectId!)),
                    );},
                    child: CommonClass.getNavigatorRowItem(rowTitle: "Show Expenses", icon: Icons.add, isLastItem: true)
                ),
                InkWell(
                    onTap: (){Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CategoryScreen(widget.projectId!)),
                    );},
                    child: CommonClass.getNavigatorRowItem(rowTitle: "Show Categories", icon: Icons.category, isLastItem: true)
                ),
                // InkWell(
                //     onTap: (){Navigator.pop(context);
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => InputExpense(userId: widget.userId,projectId: widget.projectId))
                //     );},
                //     child: CommonClass.getNavigatorRowItem(rowTitle: "Add Expenses", icon: Icons.add, isLastItem: true)
                // ),
                // InkWell(
                //     onTap: (){Navigator.pop(context);
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => InputCategory(widget.projectId!)),
                //     );},
                //     child: CommonClass.getNavigatorRowItem(rowTitle: "Add Categories", icon: Icons.category, isLastItem: true)
                // ),
              ],
            ),
          )
        ],
      ),
    );
    CommonClass.openModalBottomSheet(context, child: container, enableDrag: true, isScrollControlled: true);
  }
  void calculateTotalExpenses() {
    double total = 0.0;
    for (double amount in weeklySummary) {
      total += amount;
    }
    setState(() {
      sum = total;
    });
  }
  int expenseCount = 0;

  Future<void> fetchExpenseCount() async {
    DbProvider dbProvider = DbProvider();
    // Replace 'projectId' with your actual project ID
    String? projectId = widget.project?.projectId;
    int count = await dbProvider.getExpensesWithinThreeDays(projectId!);
    setState(() {
      expenseCount = count;
    });
  }

  @override
  void initState() {
    _userId = context.read<DbProvider>().getUserId;
    DateTime now = DateTime.now();
    DateTime dateOnly = DateTime(now.year, now.month, now.day);
    startOfWeek = getStartOfWeek(now);
    //print(startOfWeek);
    endOfWeek = getEndOfWeek(now);
    //print(endOfWeek);
    calculateTotalExpenses();
    fetchExpenseCount();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.project?.projectName);
    print(widget.projectModel);
    calculateTotalExpenses();
    print(startOfWeek);
    print(endOfWeek);
    String s = widget.projectId!;
    print(weeklySummary);
    if (weeklySummary.isEmpty) {
      // Provide a default value for weeklySummary if it's empty
      weeklySummary = List<double>.filled(7, 0);
    }
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
          widget.project!.projectName,
          style: GoogleFonts.robotoMono(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<List<double>>(
            stream: context.read<DbProvider>().getWeeklySummary(s, startOfWeek, endOfWeek),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                weeklySummary = snapshot.data!;
                double total = 0.0;
                for (double amount in weeklySummary) {
                  total += amount;
                }
                  sum = total;
                return Container(
                  decoration: BoxDecoration(
                    //border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.black
                  ),
                  child: Column(
                    children: [
                       Padding(
                        padding: const EdgeInsets.only(top: 18,bottom: 5,left: 18,right: 18),
                        child: Row(
                          children: [
                            Text(
                              'Weekly Report',
                              style: GoogleFonts.robotoMono(fontWeight: FontWeight.w700,fontSize: 24),
                            ),
                            Spacer(),
                            const Text(
                              'Expenses',
                              style: TextStyle(
                                fontSize: 20,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.arrow_downward)
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 18,right: 0,bottom: 0,top: 0),
                            child: Text(
                              '${DateFormat('yyyy-MM-dd').format(startOfWeek)} - ${DateFormat('yyyy-MM-dd').format(endOfWeek)}',
                              style: const TextStyle(
                                fontSize: 16,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                           Padding(
                             padding: const EdgeInsets.only(right: 28,left: 0,top: 0,bottom: 0),
                             child: Text(
                              sum.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 16,
                                //fontWeight: FontWeight.bold,
                              ),
                          ),
                           ),
                        ],
                      ),
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Padding(
              padding: const EdgeInsets.only(left: 18,right: 18,bottom: 8,top: 8),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => showPreviousWeek(),
              ),
              IconButton(
              icon: const Icon(Icons.arrow_forward_rounded),
              onPressed: () => showNextWeek(),
              ),
              ],
              ),
              Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
              //border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(20.0),
                  color: Colors.teal
              ),
              child: SizedBox(
              height: 200,
              child: MyBarGraph(weeklySummary: weeklySummary),
              ),
              ),
              ],
              ),
              ),
              // Padding(
              // padding: const EdgeInsets.all(20.0),
              // child: Row(
              // children: [
              // Container(
              // decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(24),
              // ),
              // height: 40,
              // width: 120,
              // child: ElevatedButton(
              // onPressed: () {
              // Navigator.pop(context);
              // },
              // child: const Text('weekly'),
              // ),
              // ),
              // Container(
              // decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(24),
              // ),
              // height: 40,
              // width: 120,
              // child: ElevatedButton(
              // onPressed: () {
              // Navigator.pop(context);
              // },
              // child: const Text('monthly'),
              // ),
              // ),
              // ],
              // ),
              // ),
              ],
              ),
              Row(

                children: [
                  Container(
                    width: 220,
                    color:Colors.black,
                    child: Column(
                        children: [
                          const Text('Expenses',
                            style: TextStyle(fontSize: 18),
                          ),
                          Padding(
                          padding: const EdgeInsets.only(left: 18,right: 18,top: 10,bottom: 0),
                          child: Container(
                          padding: const EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                          //border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20.0),
                            color: Colors.grey.shade900
                          ),
                          child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          const Text(
                          'Total:',
                          style: TextStyle(fontSize: 18),
                          ),
                          Spacer(),
                          Text(
                          widget.projectModel!,
                          style: const TextStyle(fontSize: 18),
                          ),
                          ],
                          ),
                          ),
                          ),

                          // Padding(
                          //   padding: const EdgeInsets.only(left: 18,right: 18,top: 10,bottom: 0),                  child: Container(
                          // padding: const EdgeInsets.all(18.0),
                          // decoration: BoxDecoration(
                          // //border: Border.all(color: Colors.grey),
                          // borderRadius: BorderRadius.circular(20.0),
                          //   color: Colors.grey.shade900
                          // ),
                          // child: Row(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          // children: [
                          // const Text(
                          // 'week:',
                          // style: TextStyle(fontSize: 18),
                          // ),
                          // Spacer(),
                          // Text(
                          // sum.toStringAsFixed(2),
                          // style: const TextStyle(fontSize: 18),
                          // ),
                          // ],
                          // ),
                          // ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(left: 18,right: 18,top: 10,bottom: 10),                    child: Container(
                              padding: const EdgeInsets.all(18.0),
                              decoration: BoxDecoration(
                                //border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.grey.shade900
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Unpaid:',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Spacer(),
                                  Text(
                                    widget.project!.unpaidAmount!.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                    ),

                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0,right: 0,top:8,bottom: 8),
                    child: SizedBox(
                        height:100,
                        child: ExpenseBar(totalExpenses: widget.project!.totalAmount!, unpaidExpenses: widget.project!.unpaidAmount!)),
                  ),
                ],
              ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18,right: 18,top: 10,bottom: 0),
                        child: Container(
                          padding: const EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                            //border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.teal
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  expenseCount.toString(),
                                  style: GoogleFonts.openSans(fontSize: 20,color: Colors.indigo,fontWeight:FontWeight.bold),
                                ),
                              ),
                               Padding(
                                 padding: const EdgeInsets.all(8.0),
                                 child: Row(
                                   children: [
                                     Text(
                                      'expenses are due within 3 days',
                                      style: GoogleFonts.openSans(fontSize: 18),
                              ),
                                     //Spacer(),
                                     //const Icon(Icons.wallet_rounded,color: Colors.indigo,)
                                   ],
                                 ),

                               ),
                            ],
                          ),
                        ),
                      ),
              ],
              )
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 16,right: 0,bottom: 0,top: 0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Add the onPressed handler for the "Show Categories" button
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserScreen(widget.userId!, widget.projectId!)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                ),
                child:  Text("Manage Users",
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Add the onPressed handler for the "Show Categories" button
                _openOptionsModal();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.teal,
              ),
              child:  Text("Categories",
                  style:GoogleFonts.openSans(
                    fontWeight: FontWeight.bold
                  )
              ),

            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 8,right: 0,top: 8,bottom: 8),
              child: ElevatedButton(
                onPressed: () {
                  // Add the onPressed handler for the "Show Categories" button
                  _openOptionsModal();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                ),
                child:  Text("Expenses",
                    style:GoogleFonts.openSans(
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            ),
          ],
        ),
      ),

      //bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
