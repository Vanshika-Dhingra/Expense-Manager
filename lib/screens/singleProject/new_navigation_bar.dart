import 'package:expensetracking/screens/project/project_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:expensetracking/screens/home.dart';


class BottomAppbarFABScreen extends StatefulWidget {
  @override
  _BottomAppbarFABScreenState createState() => _BottomAppbarFABScreenState();
}

class _BottomAppbarFABScreenState extends State<BottomAppbarFABScreen> {

  int _currentIndex = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _sheetOpen = false;

  List<Widget> _screensArray = <Widget>[
    Center(child: Text('Success'),),
    HomeScreen(),
    ProjectScreen(),
  ];
  List<String> _titles = <String>["Profile", "Expense Tracker", "Projects"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                _titles[_currentIndex],
                style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white
                ),
              ),
            ],
          ),
          actions: [
            _currentIndex == 0 || _currentIndex == 1 ? IconButton(
              icon: Icon(Icons.search_outlined, size: 32, color: Colors.black),
              onPressed: () {},
            ) : SizedBox(),
            _currentIndex == 0 || _currentIndex == 1 ? IconButton(
              icon: Icon(Icons.notifications_none_outlined, size: 32,
                  color: Colors.black),
              onPressed: () {},
            ) : SizedBox(),
            _currentIndex == 2 ? IconButton(
              icon: Icon(Icons.filter_list, size: 32, color: Colors.black),
              onPressed: () {},
            ) : SizedBox(),
            _currentIndex == 3 ? IconButton(
              icon: Icon(
                  Icons.settings_outlined, size: 32, color: Colors.black),
              onPressed: () {},
            ) : SizedBox(),
          ],

          elevation: 0,
        ),
        body: _screensArray[_currentIndex],
        // floatingActionButton: Builder(
        //   builder: (context) => _sheetOpen ? SizedBox() : FloatingActionButton(
        //     onPressed: () {
        //       // _showModalBottomSheet();
        //       setState(() {
        //         _sheetOpen = !_sheetOpen;
        //       });
        //       _showBottomSheet(context);
        //     },
        //     child: Icon(Icons.add, size: 32,),
        //     clipBehavior: Clip.hardEdge,
        //   ),
        // ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Container(
              height: 70,
              margin: EdgeInsets.only(left: 12, right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentIndex = 0;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.person,
                            size: 32,
                            color: _currentIndex == 0 ? Colors.teal : Colors
                                .white,
                          ),
                          Text(
                            'Profile',
                            style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: _currentIndex == 0
                                    ? Colors.teal
                                    : Colors.white
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.home,
                            size: 32,
                            color: _currentIndex == 1 ? Colors.teal : Colors
                                .white,
                          ),
                          Text(
                            'Home',
                            style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: _currentIndex == 1
                                    ? Colors.teal
                                    : Colors.white
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentIndex = 2;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.explore,
                            size: 32,
                            color: _currentIndex == 2 ? Colors.teal : Colors
                                .white,
                          ),
                          Text(
                            'Projects',
                            style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: _currentIndex == 2
                                    ? Colors.teal
                                    : Colors.white
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
          ),
        )
    );
  }
}
