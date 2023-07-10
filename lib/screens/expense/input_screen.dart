import 'dart:core';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracking/models/ExpenseModel.dart';
import 'package:expensetracking/models/UserModel.dart';
import 'package:expensetracking/models/UserStatsModel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expensetracking/helpers/Constants.dart';
import 'package:expensetracking/providers/db_provider.dart';
import 'package:provider/provider.dart';

class Category {
  final String categoryId;
  final String category;

  Category(this.categoryId, this.category);
}

const List<String> list = <String>['Yes','No'];

class InputExpense extends StatefulWidget {
  final String?projectId;
  final String?userId;

  const InputExpense({@required this.userId,@required this.projectId,Key? key}) : super(key: key);

  @override
  State<InputExpense> createState() => _InputExpenseState();
}

class _InputExpenseState extends State<InputExpense> {
  String? _userId;
  UserModel?userModel;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  TextEditingController amountController = TextEditingController();
  TextEditingController paidByController = TextEditingController();
  TextEditingController paymentModeController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TextEditingController vendorController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    paidByController.dispose();
    paymentModeController.dispose();
    remarksController.dispose();
    vendorController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    userModel=context.read<DbProvider>().getUserModal;
    _userId = context.read<DbProvider>().getUserId;
    String? s = widget.projectId;
    fetchOptionsFromFirestore(s!);
  }

  Category? selectedOption;
  String? selectedOption1;
  List<String> dropdownOptions1 = [];
  DateTime? selectedDate;

  List<Category> dropdownOptions = [];
  Future<void> fetchOptionsFromFirestore(String s) async {
  QuerySnapshot<Map<String, dynamic>> snapshot =
  await FirebaseFirestore.instance
      .collection(Constants.projectCollection)
      .doc(s)
      .collection(Constants.categoryCollection)
      .get();

  List<Category> options = snapshot.docs.map((doc) {
  String categoryId = doc.id;
  String category = doc.get('category') as String;
  return Category(categoryId, category);
  }).toList();

  setState(() {
  dropdownOptions = options;
  });
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Initial date value
      firstDate: DateTime(2000), // Minimum date value
      lastDate: DateTime(2100), // Maximum date value
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked; // Update the selectedDate variable
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? s = widget.projectId;
    ExpenseModel expense = ExpenseModel();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white12,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "New Expense",
          textAlign: TextAlign.center,
          style: GoogleFonts.robotoSerif(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (lyContext, constraint) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraint.minHeight),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Enter Amount",
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.roboto(),
                    maxLength: 10,
                    onChanged: (value) {
                      // amountController.text = value;
                    },
                    decoration: InputDecoration(
                      hintText: "",
                      counterText: "",
                      filled: true,
                      //fillColor: Colors.white,
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(8),
                      // ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
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
                    "Enter Paid by",
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: paidByController,
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.roboto(),
                    maxLength: 10,
                    onChanged: (value) {
                      // paidByController.text = value;
                    },
                    decoration: InputDecoration(
                      hintText: "",
                      counterText: "",
                      filled: true,
                      //fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
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
                    "Enter Payment Mode",
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: paymentModeController,
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.roboto(),
                    maxLength: 10,
                    onChanged: (value) {
                      // paymentModeController.text = value;
                    },
                    decoration: InputDecoration(
                      hintText: "",
                      counterText: "",
                      filled: true,
                      //fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
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
                    "Enter Remarks",
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: remarksController,
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.roboto(),
                    maxLength: 10,
                    onChanged: (value) {
                      // remarksController.text = value;
                    },
                    decoration: InputDecoration(
                      hintText: "",
                      counterText: "",
                      filled: true,
                      //fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
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
                    "Enter Vendor",
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: vendorController,
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.roboto(),
                    maxLength: 10,
                    onChanged: (value) {
                      // vendorController.text = value;
                    },
                    decoration: InputDecoration(
                      hintText: "",
                      counterText: "",
                      filled: true,
                      //fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
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
                  DropdownButton<Category>(
                    value: selectedOption,
                    hint: const Text('Select a category'),
                    onChanged: (Category? newValue) {
                      setState(() {
                        selectedOption = newValue!;
                        expense.category = newValue.category!;
                        print('Selected option 1: ${expense.category}');
                        print('Selected option 2: $selectedOption');
                      });
                    },
                    items: dropdownOptions.map((Category option) {
                      return DropdownMenuItem<Category>(
                        value: option,
                        child: Text(option.category),
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    value: selectedOption1,
                    hint: const Text('select is paid or not'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedOption1 = newValue!;
                      });
                    },
                      items: list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Visibility(
                    visible: selectedOption1 == 'No',
                    replacement: Container(),
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            _selectDate(context); // Function to open the date picker
                          },
                          child: const Text('Select Date'),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(selectedDate != null ? selectedDate.toString() : 'No date selected'),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      DbProvider dbProvider = DbProvider();
                      print('Selected option 3: $selectedOption');
                      expense.category = selectedOption?.category;
                      print('Selected option 4: ${expense.category}');
                      expense.date = selectedDate ?? DateTime.now();
                      expense.amount = amountController.text;
                      expense.paidBy = paidByController.text;
                      expense.paymentMode = paymentModeController.text;
                      expense.remarks = remarksController.text;
                      expense.vendor = vendorController.text;
                      expense.userId=_userId!;
                      var colRef = _firebase.collection(Constants.projectCollection).doc(s).collection(Constants.expenseCollection);
                      expense.expenseId = colRef.doc().id;
                      expense.projectId = s!;
                      expense.isPaid=selectedOption1;
                      expense.categoryId=selectedOption?.categoryId;
                      dbProvider.saveExpenseInFirestore(s, expense);
                      UserStatsModel userStatsModel=UserStatsModel();
                      userStatsModel.userId=_userId!;
                      userStatsModel.projectId=s;
                      userStatsModel.amount=amountController.text;
                      userStatsModel.expenseId=expense.expenseId;
                      userStatsModel.date=expense.date;
                      userStatsModel.isShared=_userId==widget.userId?false:true;
                      var colRef1 = _firebase.collection(Constants.userCollection).doc(_userId).collection(Constants.userStatsCollection);
                      //print(userModel?.sharedTotalAmount && userStatsModel.isShared==true);
                      dbProvider.updateProjectTotalAmount(s, double.parse(expense.amount));
                      if(expense.isPaid=='No')
                        {
                          dbProvider.updateProjectTotalUnpaidAmount(s, double.parse(expense.amount));
                        }
                      if (userModel != null && userStatsModel.isShared==true) {
                        userModel?.sharedTotalAmount = ((userModel?.sharedTotalAmount)! + double.parse(expense.amount))!;
                      }
                      if (userModel != null && userStatsModel.isShared==false) {
                        userModel?.personalTotalAmount = ((userModel?.personalTotalAmount)! + double.parse(expense.amount))!;
                      }
                      dbProvider.saveUserInFirestore(userModel!);
                      userStatsModel.id=colRef1.doc().id;
                      dbProvider.saveUserStatsInFirestore(_userId!, userStatsModel);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Create new expense",
                      style: GoogleFonts.openSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
