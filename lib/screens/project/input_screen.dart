import 'package:expensetracking/screens/authentication/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expensetracking/providers/db_provider.dart';
import 'package:expensetracking/models/ProjectModel.dart';
import 'package:provider/provider.dart';

class InputProject extends StatefulWidget {
  const InputProject({Key? key}) : super(key: key);

  @override
  State<InputProject> createState() => _InputProjectState();
}

class _InputProjectState extends State<InputProject> {
  TextEditingController projectNameController = TextEditingController();
  TextEditingController projectDescriptionController = TextEditingController();
  String? _userId;

  @override
  void dispose() {
    projectNameController.dispose();
    projectDescriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _userId = context.read<DbProvider>().getUserId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white12,
        centerTitle: true,
        title: Text(
          "New Project",
          textAlign: TextAlign.center,
          style: GoogleFonts.robotoSerif(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              "Enter Project Name",
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: projectNameController,
              keyboardType: TextInputType.text,
              style: GoogleFonts.roboto(),
              maxLength: 10,
              onChanged: (value) {
                // phoneNumberController.text(value);
              },
              decoration: InputDecoration(
                hintText: "",
                counterText: "",
                filled: true,
                //fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey.shade500,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.red.shade400,
                    width: 1,
                  ),
                ),
                hintStyle: GoogleFonts.roboto(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              "Enter Project Description",
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: projectDescriptionController,
              keyboardType: TextInputType.text,
              style: GoogleFonts.roboto(),
              maxLines: 3,
              onChanged: (value) {
                // Update the description value
              },
              decoration: InputDecoration(
                hintText: "",
                filled: true,
                //fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey.shade500,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.red.shade400,
                    width: 1,
                  ),
                ),
                hintStyle: GoogleFonts.roboto(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                DbProvider dbProvider = DbProvider();
                ProjectModel project = ProjectModel(_userId);
                project.projectName = projectNameController.text;
                project.description = projectDescriptionController.text;
                project.status = "ongoing";
                project.totalAmount=0;
                project.unpaidAmount=0;
                dbProvider.saveProjectInFirestore(project);
                Navigator.pop(context);
              },
              child: Text(
                "Create new Project",
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
