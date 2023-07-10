import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracking/helpers/CommonClass.dart';
import 'package:expensetracking/helpers/UIConstants.dart';
import 'package:expensetracking/helpers/Constants.dart';
import 'package:expensetracking/models/VendorModel.dart';
import 'package:expensetracking/providers/db_provider.dart';
import 'package:expensetracking/screens/vendor/contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({Key? key}) : super(key: key);

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {

  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  String? _userId;

  void _openVendorOptionsModal() {
    Widget container = Container(
      height: MediaQuery.of(context).size.height * 0.21,
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.padding16, vertical: UIConstants.padding12),
      decoration: const BoxDecoration(
        color: Colors.white,
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
                CommonClass.getNavigatorRowItem(rowTitle: "Create New Vendor", icon: Icons.add),
                InkWell(
                    onTap: _askPermissionForContacts,
                    child: CommonClass.getNavigatorRowItem(rowTitle: "From Contacts", icon: Icons.contacts, isLastItem: true)
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
    PermissionStatus permissionStatus = await _getContactPermission();
    if(permissionStatus == PermissionStatus.granted) {
      Navigator.pop(context);
      CommonClass.openModalBottomSheet(context, child: ContactScreen(), enableDrag: false, isScrollControlled: true, isDismissible: false)
        .then((value) {
          print(value);
          if(value == null) return;
          var colRef = _firebase.collection(Constants.userCollection).doc(_userId).collection(Constants.vendorCollection);
          value["ucId"] = colRef.doc().id;
          //print(value);
          CommonClass().showLoadingErrorModalBottomSheet(context);
          colRef.doc(value["ucId"]).set(value)
            .then((value) => Navigator.pop(context));
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
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Vendors",
          style: GoogleFonts.robotoMono(fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder(
        stream: Provider.of<DbProvider>(context).fetchUserVendors(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if(snapshot.hasError) return const Center(child: Text("Error"));
          List<VendorModel> vendors = snapshot.data!.docs.map((e) => VendorModel.toObject(e.data())).toList();
          return vendors.isEmpty ? CommonClass.emptyScreen() : _showVendorList(vendors);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openVendorOptionsModal,
        label: const Text("Add Vendor"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _showVendorList(List<VendorModel> vendors) {
    return ListView.builder(
      itemCount: vendors.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            vendors.elementAt(index).name ?? "",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black
            ),
          ),
          subtitle: Text(
            vendors.elementAt(index).phone ?? "",
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.grey.shade500
            ),
          ),
        );
      },
    );
  }
}
