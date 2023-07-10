
import 'package:expensetracking/helpers/CommonClass.dart';
import 'package:expensetracking/helpers/UIConstants.dart';
import 'package:expensetracking/models/UserModel.dart';
import 'package:expensetracking/models/UserStatsModel.dart';
import 'package:expensetracking/providers/db_provider.dart';
import 'package:expensetracking/screens/singleProject/navigation_bar.dart';
import 'package:expensetracking/screens/vendor/vendor_screen.dart';
import 'package:expensetracking/screens/expense/expense_screen.dart';
import 'package:expensetracking/screens/project/project_screen.dart';
import 'package:expensetracking/screens/category/category_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  UserModel? userModel;

  @override
  void initState() {
    // TODO: implement initState
    userModel = context.read<DbProvider>().getUserModal;
  }

  void openModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.only(
              top: UIConstants.padding16,
              left: UIConstants.padding12,
              right: UIConstants.padding12,
              bottom: UIConstants.padding12),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(UIConstants.borderRadius16),
                  topRight: Radius.circular(UIConstants.borderRadius16))),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              Text(
                "Account",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(fontWeight: FontWeight.w700),
              ),
              Container(
                margin: const EdgeInsets.only(top: 24.0),
                padding: const EdgeInsets.all(UIConstants.padding12),
                decoration: UIConstants.boxShadowDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userModel!.name,
                          style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userModel!.phone,
                          style: GoogleFonts.roboto(
                              fontSize: 14, color: Colors.grey.shade600),
                        )
                      ],
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 16.0),
                decoration: UIConstants.boxShadowDecoration,
                child: Column(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProjectScreen(),
                              ));
                        },
                        child: CommonClass.getNavigatorRowItem(
                            rowTitle: "Manage Projects")),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VendorScreen(),
                              ));
                        },
                        child: CommonClass.getNavigatorRowItem(
                            rowTitle: "Manage Vendors")),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  FirebaseAuth.instance.signOut();
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: UIConstants.boxShadowDecoration,
                  child: CommonClass.getNavigatorRowItem(
                      rowTitle: "Logout", isLastItem: true),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Developed by Auribises Technologies",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                "v1.0.0",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      // appBar: AppBar(
      //   elevation: 0,
      //   title: Text(
      //     "Expense Tracker",
      //     style: GoogleFonts.robotoMono(fontWeight: FontWeight.w700),
      //   ),
      //   actions: [
      //     IconButton(
      //         onPressed: openModalBottomSheet,
      //         icon: const Icon(Icons.account_circle_outlined))
      //   ],
      // ),
      body: StreamBuilder(
        stream: Provider.of<DbProvider>(context).fetchUserStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) return const Center(child: Text("Error"));
          List<UserStatsModel> vendors = snapshot.data!.docs
              .map((e) => UserStatsModel.toObject(e.data()))
              .toList();
          return vendors.isEmpty
              ? CommonClass.emptyScreen()
              : _showVendorList(vendors);
        },
      ),
      //bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  Widget _showVendorList(List<UserStatsModel> vendors) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome Back,",
              //textAlign: TextAlign.center,
              style: GoogleFonts.openSans(fontWeight: FontWeight.w700),
            ),
            Text(
              userModel!.name,
              //textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.teal),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 150,
                  color: Colors.teal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SvgPicture.asset("assets/svg/splashscreen.svg", height: 100),
                       Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Manage Your',
                            style: GoogleFonts.openSans(
                              fontSize: 20, // Adjust the value as needed
                              fontWeight: FontWeight.bold, // Optional: Set the font weight
                              color: Colors.black
                            ),
                          ),
                          // Text(
                          //   'Your',
                          //   style: TextStyle(
                          //     fontSize: 24, // Adjust the value as needed
                          //     fontWeight: FontWeight.bold, // Optional: Set the font weight
                          //   ),
                          // ),
                          Text(
                            'Expenses',
                            style: GoogleFonts.openSans(
                              fontSize: 24, // Adjust the value as needed
                              fontWeight: FontWeight.bold, // Optional: Set the font weight
                            ),
                          ),
                        ],
                      )

                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Column(
              children: [
                 Padding(
                  padding: EdgeInsets.only(left: 8,right: 0,bottom: 8,top: 0),
                  child: Text(
                    'Your Recent Expenses are:',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 300,
                  width: 270,
                  child: ListView.builder(
                    itemCount: vendors.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          //border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.grey.shade900
                        ),
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(
                                vendors.elementAt(index).amount ?? "",
                                style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                DateFormat('yyyy-MM-dd')
                                    .format(vendors.elementAt(index).date!),
                                style: GoogleFonts.openSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8,right: 8,top: 0,bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      //border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(15.0),
                      color: Colors.teal,
                    ),
                    padding: const EdgeInsets.only(left: 8,right: 8,top: 0,bottom: 8),
                    height: 110,
                    width: 105,
                    child:  Column(
                      children: [
                        const Expanded(
                          child: Icon(Icons.people_sharp,size: 30,),
                        ),
                         Text(
                          'Shared Amount',
                            style: GoogleFonts.openSans(fontWeight: FontWeight.w700,fontSize: 10),
                        ),
                        Text(
                          userModel!.sharedTotalAmount!.toStringAsFixed(2),
                            style: GoogleFonts.openSans(fontWeight: FontWeight.w700,fontSize: 14),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    height: 110,
                    width: 105,
                    decoration: BoxDecoration(
                      //border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.teal,
                    ),
                    child:  Column(
                      children: [
                        const Expanded(
                          child: Icon(Icons.person_sharp,size: 30,),
                        ),
                        Text(
                          'Personal Amount',
                          style: GoogleFonts.openSans(fontWeight: FontWeight.w700,fontSize: 10),
                        ),
                        Text(
                          userModel!.personalTotalAmount!.toStringAsFixed(2),
                          style: GoogleFonts.openSans(fontWeight: FontWeight.w700,fontSize: 14),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        // const Text(
        //   'Total User Expenses in Shared Projects',
        //   style: TextStyle(
        //     fontSize: 16,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        // Text(
        //   '${userModel?.sharedTotalAmount}',
        //   style: const TextStyle(
        //     fontSize: 20,
        //     color: Colors.white,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        // const SizedBox(height: 8),
        // const Text(
        //   'Total User Expenses in Personal Projects',
        //   style: TextStyle(
        //     fontSize: 16,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        // Text(
        //   '${userModel?.personalTotalAmount}',
        //   style: const TextStyle(
        //     fontSize: 20,
        //     color: Colors.white,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
      ]),
    );
  }
}
