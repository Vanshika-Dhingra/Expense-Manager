import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracking/models/VendorModel.dart';

class ExpenseModel {
  String expenseId = "";
  String projectId = "";
  String amount = "";
  String paidBy = "";
  String paymentMode = "";
  String remarks = "";
  String vendor = "";
  String? category = "";
  Timestamp addedOn = Timestamp.now();
  DateTime? date;
  String ?isPaid="";
  String userId="";
  String? categoryId="";

  ExpenseModel() {
    addedOn = Timestamp.now();
  }

  static ExpenseModel toObject(doc) {
    ExpenseModel expense = ExpenseModel();
    expense.expenseId = doc["expenseId"];
    expense.amount = doc["amount"];
    expense.addedOn = doc["addedOn"] ?? Timestamp.now();
    expense.paidBy = doc["paidBy"];
    expense.paymentMode = doc["paymentMode"];
    expense.projectId = doc["projectId"];
    expense.remarks = doc["remarks"];
    expense.vendor = doc["vendor"];
    expense.category = doc["category"];
    expense.date = doc["date"]?.toDate();
    expense.userId=doc["userId"];
    expense.isPaid=doc["isPaid"];
    expense.categoryId=doc["categoryId"];
    return expense;
  }

  Map<String, dynamic> getMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["expenseId"] = expenseId ?? "";
    map["amount"] = amount ?? "";
    map["addedOn"] = addedOn;
    map["paidBy"] = paidBy ?? "";
    map["paymentMode"] = paymentMode ?? "";
    map["projectId"] = projectId ?? "";
    map["remarks"] = remarks ?? "";
    map["vendor"] = vendor ?? "";
    map["category"] = category??"";
    map["userId"]=userId??"";
    map["isPaid"]=isPaid??"";
    map["date"] = date != null ? Timestamp.fromDate(date!) : null;
    map["categoryId"]=categoryId??"";
    return map;
  }
}
