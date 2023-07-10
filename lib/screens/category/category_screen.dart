import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracking/helpers/CommonClass.dart';
import 'package:expensetracking/helpers/UIConstants.dart';
import 'package:expensetracking/helpers/Constants.dart';
import 'package:expensetracking/models/CategoryModel.dart';
import 'package:expensetracking/models/VendorModel.dart';
import 'package:expensetracking/providers/db_provider.dart';
import 'package:expensetracking/screens/expense/category_expense_screen.dart';
import 'package:expensetracking/screens/vendor/contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:expensetracking/screens/category/input_screen.dart';
import 'package:expensetracking/screens/expense/input_screen.dart';
import 'package:expensetracking/screens/singleProject/pieChart/pie_chart.dart';

import '../expense/expense_screen.dart';
import '../singleProject/navigation_bar.dart';

class CategoryScreen extends StatefulWidget {
  final String projectId;
  const CategoryScreen(this.projectId, {Key? key}) : super(key: key);
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {

  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  String? _userId;

  void _openProjectOptionsModal(String s) {
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
      builder: (context) =>  InputCategory(s),
    ));
  }

  @override
  void initState() {
    _userId = context.read<DbProvider>().getUserId;
  }

  @override
  Widget build(BuildContext context) {
    String s = widget.projectId;
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
          "Categories",
          style: GoogleFonts.robotoMono(fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder(
        stream: Provider.of<DbProvider>(context).fetchProjectCategories(s),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if(snapshot.hasError) return const Center(child: Text("Error"));
          List<CategoryModel> categories = snapshot.data!.docs.map((e) => CategoryModel.toObject(e.data())).toList();
          return categories.isEmpty ? CommonClass.emptyScreen() : _showVendorList(categories);
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _newProject(s),
            label: const Text("Add Category"),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      //bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  Widget _showVendorList(List<CategoryModel> vendors) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          //child: const PieChartSample2(),
        ),
        Expanded(
        child: ListView.builder(
          itemCount: vendors.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CategoryExpenseScreen(projectId: widget.projectId, categoryId: vendors.elementAt(index).cid)
                    ),
                  );
                },
             child: Column(
              children: [
                Container(
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
                        Text(
                          vendors.elementAt(index).category ?? "",
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white
                          ),
                        ),
                        const Spacer(),
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
                          onSelected: (value) {
                            if (value == 'delete') {
                              DbProvider dbProvider = DbProvider();
                              dbProvider.deleteCategory(vendors.elementAt(index).cid,vendors.elementAt(index).projectId);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            );
          },
        ),
    ),
      ],
    );
  }
}
