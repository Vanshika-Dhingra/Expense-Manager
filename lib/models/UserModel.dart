import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String userId = "";
  String authId = "";
  String name = "";
  String phone = "";
  String token = "";
  Timestamp createdOn = Timestamp.now();
  num?sharedTotalAmount=0.0;
  num?personalTotalAmount=0.0;

  UserModel() {
    createdOn = Timestamp.now();
  }

  static UserModel toObject(doc) {
    UserModel user = UserModel();
    user.phone = doc["phone"];
    user.authId = doc["authId"];
    user.createdOn = doc["createdOn"];
    user.name = doc["name"];
    user.userId = doc["userId"];
    user.token = doc["token"];
    user.sharedTotalAmount=doc["sharedTotalAmount"];
    user.personalTotalAmount=doc["personalTotalAmount"];
    return user;
  }

  Map<String, dynamic> getMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["phone"] = phone ?? "";
    map["authId"] = authId ?? "";
    map["createdOn"] = createdOn ?? Timestamp.now();
    map["name"] = name ?? "";
    map["userId"] = userId ?? "";
    map["token"] = token ?? "";
    map["sharedTotalAmount"]=sharedTotalAmount??0.0;
    map["personalTotalAmount"]=personalTotalAmount??0.0;
    return map;
  }
}