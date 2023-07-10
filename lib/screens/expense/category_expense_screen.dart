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

class CategoryExpenseScreen extends StatefulWidget {
  final String?projectId;
  final String?categoryId;
  CategoryExpenseScreen({Key? key,@ required this.projectId,@required this.categoryId}) : super(key: key);

  @override
  State<CategoryExpenseScreen> createState() => _CategoryExpenseScreenState();
}

class _CategoryExpenseScreenState extends State<CategoryExpenseScreen> {

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
    String? s=widget.projectId;
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
          "Expenses",
          style: GoogleFonts.robotoMono(fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder(
        stream: Provider.of<DbProvider>(context).fetchExpenseByCategory(s!,widget.categoryId!),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if(snapshot.hasError) return const Center(child: Text("Error"));
          List<ExpenseModel> vendors = snapshot.data!.docs.map((e) => ExpenseModel.toObject(e.data())).toList();
          return vendors.isEmpty ? CommonClass.emptyScreen() : _showVendorList(vendors);
        },
      ),

      //bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  Widget _showVendorList(List<ExpenseModel> vendors) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ListView.builder(
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(8),
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
                      Text(
                        vendors.elementAt(index).amount ?? "",
                        style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            color: Colors.white
                        ),
                      ),
                      Text(
                        vendors.elementAt(index).vendor ?? "",
                        style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.grey.shade500
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Text(
                    vendors.elementAt(index).isPaid=='Yes'?'Paid  ':'Not Paid  ',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: vendors.elementAt(index).isPaid=='Yes'?Colors.green:Colors.red,
                    ),
                  ),
                  Text(
                    vendors.elementAt(index).remarks ?? "",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.red,
                    ),
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
                        ProjectModel? project=await dbProvider.getProjectFromDatabase(widget.projectId!);
                        project?.totalAmount=(project!.totalAmount!-double.parse(vendors.elementAt(index).amount))!;
                        if(vendors.elementAt(index).isPaid=='No'){
                          project?.unpaidAmount=(project.unpaidAmount!-double.parse(vendors.elementAt(index).amount))!;
                        }
                        dbProvider.saveProjectInFirestore(project!);
                        _userModel?.personalTotalAmount=(_userModel!.personalTotalAmount!-double.parse(vendors.elementAt(index).amount))!;
                        dbProvider.saveUserInFirestore(_userModel!);
                        dbProvider.deleteUserStats(vendors.elementAt(index).expenseId);
                        dbProvider.deleteExpense(vendors.elementAt(index).expenseId,vendors.elementAt(index).projectId);
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
