import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracking/helpers/CommonClass.dart';
import 'package:expensetracking/helpers/UIConstants.dart';
import 'package:expensetracking/helpers/Constants.dart';
import 'package:expensetracking/models/ProjectModel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers/db_provider.dart';
import '../singleProject/navigation_bar.dart';
import '../singleProject/single_project.dart';
import '../vendor/contact_screen.dart';
import 'input_screen.dart';
import 'package:intl/intl.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({Key? key}) : super(key: key);

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  String? _userId;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _newProject() async {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => const InputProject(),
    ));
  }

  @override
  void initState() {
    _userId = context.read<DbProvider>().getUserId;
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
         child:Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        flexibleSpace:Container(
          color: Colors.black,
          width: 300,
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // You can perform additional actions when the search icon is clicked
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    // Call setState() to rebuild the widget when the search query changes
                  });
                },
              ),
            ),
          ),
        ),
        bottom: const TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.person,color: Colors.teal,),
              child: Text('Personal'),
            ),
            Tab(
              icon: Icon(Icons.people,color: Colors.teal,),
              child: Text('Shared'),
            ),

          ],
        ),
      ),
      body:TabBarView(
          children: [
      StreamBuilder(
        stream: Provider.of<DbProvider>(context).fetchProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) return const Center(child: Text("Error"));
          List<ProjectModel> projects = snapshot.data!.docs
              .map((e) => ProjectModel.toObject(e.data()))
              .toList();
          return projects.isEmpty
              ? CommonClass.emptyScreen()
              : _showVendorList(projects,0);
        },
      ),
            StreamBuilder(
              stream: Provider.of<DbProvider>(context).fetchProjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) return const Center(child: Text("Error"));
                List<ProjectModel> projects = snapshot.data!.docs
                    .map((e) => ProjectModel.toObject(e.data()))
                    .toList();
                return projects.isEmpty
                    ? CommonClass.emptyScreen()
                    : _showVendorList(projects,1);
              },
            ),
      ]
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newProject,
        label: const Text("Add Project"),
        icon: const Icon(Icons.add),
      ),
      //bottomNavigationBar: const AppBottomNavigationBar(),
    )
    );
  }

  Widget _showVendorList(List<ProjectModel> projects, int isShared) {
    String searchQuery = _searchController.text.toLowerCase();

    List<ProjectModel> filteredAdminProjects = [];
    List<ProjectModel> filteredSharedProjects = [];

    if (isShared == 1) {
      filteredSharedProjects = projects
          .where((project) =>
      project.createdByUserId != _userId &&
          project.userIds.contains(_userId) &&
          project.projectName.toLowerCase().contains(searchQuery))
          .toList();
    } else {
      filteredAdminProjects = projects
          .where((project) =>
      project.createdByUserId == _userId &&
          project.projectName.toLowerCase().contains(searchQuery))
          .toList();
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount:
            isShared == 1 ? filteredSharedProjects.length : filteredAdminProjects.length,
            itemBuilder: (context, index) {
              ProjectModel project;
              if (isShared == 1) {
                project = filteredSharedProjects[index];
              } else {
                project = filteredAdminProjects[index];
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SingleProject(
                        projectModel: project.totalAmount?.toStringAsFixed(2) ?? "",
                        projectId: project.projectId ?? "",
                        userId: project.createdByUserId ?? "",
                        project: project,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 0, right: 0, top: 8, bottom: 0),
                  child: ListTile(
                    title: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20)),
                            color: Colors.grey.shade900,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    project.projectName ?? "",
                                    style: GoogleFonts.openSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Colors.white),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat('yyyy-MM-dd').format(project.createdOn.toDate()),
                                    style: GoogleFonts.openSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.white),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      project.status ?? "",
                                      style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.red),
                                    ),
                                  ),

                                  // Text(
                                  //   isShared == 1 ? 'Shared' : 'Personal',
                                  //   style: TextStyle(
                                  //     fontWeight: FontWeight.w600,
                                  //     fontSize: 16,
                                  //     color: isShared == 1 ? Colors.green : Colors.blue,
                                  //   ),
                                  // ),
                                  PopupMenuButton(
                                    itemBuilder: (context) {
                                      List<PopupMenuEntry<Object>> menuItems = [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ];

                                      if (project.status == 'ongoing') {
                                        menuItems.add(const PopupMenuItem(
                                          value: 'completed',
                                          child: Text('Mark as Completed'),
                                        ));
                                      }

                                      return menuItems;
                                    },
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        DbProvider dbProvider = DbProvider();
                                        dbProvider.deleteProject(project.projectId);
                                      } else if (value == 'completed') {
                                        DbProvider dbProvider = DbProvider();
                                        dbProvider.editProjectStatus(project.projectId);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 400,
                          decoration:  BoxDecoration(
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
                            color: Colors.grey.shade700,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              project.description ?? "",
                              style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
