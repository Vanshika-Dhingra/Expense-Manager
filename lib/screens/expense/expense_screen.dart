import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracking/helpers/CommonClass.dart';
import 'package:expensetracking/helpers/UIConstants.dart';
import 'package:expensetracking/helpers/Constants.dart';
import 'package:expensetracking/models/ExpenseModel.dart';
import 'package:expensetracking/models/ProjectModel.dart';
import 'package:expensetracking/models/VendorModel.dart';
import 'package:expensetracking/providers/db_provider.dart';
import 'package:expensetracking/screens/category/category_screen.dart';
import 'package:expensetracking/screens/vendor/contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:expensetracking/screens/expense/input_screen.dart';

import '../../models/UserModel.dart';
import '../category/input_screen.dart';
import '../singleProject/navigation_bar.dart';
import 'package:intl/intl.dart';


class ExpenseScreen extends StatefulWidget {
  String projectId;
   ExpenseScreen(this.projectId,{Key? key}) : super(key: key);

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {

  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  String? _userId;
  UserModel? _userModel;
  //ProjectModel? _project;

  void _openProjectOptionsModal(String s) {
    Widget container = Container(
      height: MediaQuery.of(context).size.height * 0.21,
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.padding16, vertical: UIConstants.padding12),
      decoration: const BoxDecoration(
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
                InkWell(
                    onTap:()=>_newProject(s),
                    child: CommonClass.getNavigatorRowItem(rowTitle: "Create New Expense", icon: Icons.add, isLastItem: true)
                ),
              ],
            ),
          )
        ],
      ),
    );
    CommonClass.openModalBottomSheet(context, child: container, enableDrag: true, isScrollControlled: true);
  }

  void _openCategoryOptionsModal(String s) {
    Widget container = Container(
      height: MediaQuery.of(context).size.height * 0.21,
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.padding16, vertical: UIConstants.padding12),
      decoration: const BoxDecoration(
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
                InkWell(
                    onTap: ()=>_newProject(s),
                    child: CommonClass.getNavigatorRowItem(rowTitle: "Create New Category", icon: Icons.add, isLastItem: true)
                ),
              ],
            ),
          )
        ],
      ),
    );
    CommonClass.openModalBottomSheet(context, child: container, enableDrag: true, isScrollControlled: true);
  }

  Future<void> _newProject(String s) async {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) =>  InputExpense(userId: _userId, projectId: widget.projectId),
    ));
  }

  @override
  void initState() {
    _userId = context.read<DbProvider>().getUserId;
    _userModel=context.read<DbProvider>().getUserModal;
    //_project=context.read<DbProvider>().getProjectModel;
  }

  @override
  Widget build(BuildContext context) {
    String s=widget.projectId;
    return DefaultTabController(
        length: 2,
    child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        bottom: const TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.check,color: Colors.teal,),
              child: Text('Paid'),
            ),
            Tab(
              icon: Icon(Icons.close_rounded,color: Colors.teal,),
              child: Text('Not Paid'),
            ),

          ],
        ),
        // automaticallyImplyLeading: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Expenses",
          style: GoogleFonts.robotoMono(fontWeight: FontWeight.w700),
        ),
      ),
      body:
       TabBarView(
          children: [
      StreamBuilder(
        stream: Provider.of<DbProvider>(context).fetchProjectExpenses(s),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if(snapshot.hasError) return const Center(child: Text("Error"));
          List<ExpenseModel> vendors = snapshot.data!.docs.map((e) => ExpenseModel.toObject(e.data())).toList();
          return vendors.isEmpty ? CommonClass.emptyScreen() : _showVendorList(vendors,1);
        },
      ),
            StreamBuilder(
              stream: Provider.of<DbProvider>(context).fetchProjectExpenses(s),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if(snapshot.hasError) return const Center(child: Text("Error"));
                List<ExpenseModel> vendors = snapshot.data!.docs.map((e) => ExpenseModel.toObject(e.data())).toList();
                return vendors.isEmpty ? CommonClass.emptyScreen() : _showVendorList(vendors,0);
              },
            ),
      ]),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () => _newProject(s),
            label: const Text("Add Expense"),
            icon: const Icon(Icons.attach_money),
          ),
        ],
      ),
      //bottomNavigationBar: const AppBottomNavigationBar(),
    )
    );
  }

  Widget _showVendorList(List<ExpenseModel> vendors, int isPaid) {
    final filteredVendors = vendors.where((vendor) => vendor.isPaid == (isPaid == 1 ? 'Yes' : 'No')).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: filteredVendors.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.grey.shade900,
            ),
            child: ListTile(
              title: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0,right:0,top:0,bottom: 8),
                        child: Text(
                          filteredVendors[index].remarks ?? "",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        filteredVendors[index].vendor ?? "",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    children: [
                      Text(
                        filteredVendors[index].amount ?? "",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          fontSize: 19,
                          color: Colors.white,
                        ),

                      ),
                      Text(
                        'due on : ${DateFormat('yyyy-MM-dd').format(filteredVendors[index].date!)}',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) {
                      List<PopupMenuEntry<Object>> menuItems = [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                      return menuItems;
                    },
                    onSelected: (value) async {
                      if (value == 'delete') {
                        DbProvider dbProvider = DbProvider();
                        ProjectModel? project = await dbProvider.getProjectFromDatabase(widget.projectId);
                        project?.totalAmount = (project!.totalAmount! - double.parse(filteredVendors[index].amount))!;
                        if (filteredVendors[index].isPaid == 'No') {
                          project?.unpaidAmount = (project.unpaidAmount! - double.parse(filteredVendors[index].amount))!;
                        }
                        dbProvider.saveProjectInFirestore(project!);
                        _userModel?.personalTotalAmount = (_userModel!.personalTotalAmount! - double.parse(filteredVendors[index].amount))!;
                        dbProvider.saveUserInFirestore(_userModel!);
                        dbProvider.deleteUserStats(filteredVendors[index].expenseId);
                        dbProvider.deleteExpense(filteredVendors[index].expenseId, filteredVendors[index].projectId);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
