import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatsModel {
  String id="";
  String userId = "";
  String expenseId = "";
  String amount = "";
  DateTime? date;
  String projectId="";
  Timestamp createdOn = Timestamp.now();
  bool isShared=false;

  UserStatsModel() {
    createdOn = Timestamp.now();
  }

  static UserStatsModel toObject(doc) {
    UserStatsModel user = UserStatsModel();
    user.id=doc["id"];
    user.userId = doc["userId"];
    user.expenseId = doc["expenseId"];
    user.createdOn = doc["createdOn"];
    user.date = doc["date"]?.toDate();
    user.amount = doc["amount"];
    user.projectId = doc["projectId"];
    user.isShared=doc["isShared"];
    return user;
  }

  Map<String, dynamic> getMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["id"]=id??"";
    map["expenseId"] = expenseId ?? "";
    map["amount"] = amount ?? "";
    map["createdOn"] = createdOn ?? Timestamp.now();
    map["projectId"] = projectId ?? "";
    map["userId"] = userId ?? "";
    map["isShared"]=isShared??false;
    map["date"] = date != null ? Timestamp.fromDate(date!) : null;
    return map;
  }
}