import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracking/models/CategoryModel.dart';
import 'package:expensetracking/screens/authentication/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expensetracking/providers/db_provider.dart';
import 'package:expensetracking/models/ProjectModel.dart';
import 'package:expensetracking/helpers/Constants.dart';

class InputCategory extends StatefulWidget {
  final String projectId;
  const InputCategory(this.projectId, {Key? key}) : super(key: key);

  @override
  State<InputCategory> createState() => _InputCategoryState();
}

class _InputCategoryState extends State<InputCategory> {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  TextEditingController projectNameController = TextEditingController();

  @override
  void dispose() {
    projectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String s = widget.projectId;
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
          "New Category",
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
              height: 16,
            ),
            Text(
              "Enter Category Name",
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 16,
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
            ElevatedButton(
              onPressed: () {
                DbProvider dbProvider = DbProvider();
                CategoryModel category = CategoryModel();
                category.projectId = s;
                category.category = projectNameController.text;
                var colRef = _firebase
                    .collection(Constants.projectCollection)
                    .doc(s)
                    .collection(Constants.categoryCollection);
                category.cid = colRef.doc().id;
                dbProvider.saveCategoryInFirestore(s, category);
                Navigator.pop(context);
              },
              child: Text(
                "Create new Category",
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
