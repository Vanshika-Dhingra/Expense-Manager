import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracking/models/ExpenseModel.dart';

class CategoryModel {
  String cid = "";
  String category = "";
  Timestamp addedOn = Timestamp.now();
  String projectId="";

  CategoryModel() {
    addedOn = Timestamp.now();
  }

  static CategoryModel toObject(doc) {
    CategoryModel user = CategoryModel();
    user.category = doc["category"];
    user.addedOn = doc["addedOn"];
    user.cid = doc["cid"];
    user.projectId=doc["projectId"];
    return user;
  }

  Map<String, dynamic> getMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["category"] = category ?? "";
    map["addedOn"] = addedOn ?? Timestamp.now();
    map["cid"] = cid ?? "";
    map["projectId"]=projectId??"";
    return map;
  }
}
