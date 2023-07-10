import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  String ucId = "";
  String name = "";
  String phone = "";
  Timestamp addedOn = Timestamp.now();

  VendorModel() {
    addedOn = Timestamp.now();
  }

  static VendorModel toObject(doc) {
    VendorModel user = VendorModel();
    user.phone = doc["phone"];
    user.addedOn = doc["addedOn"];
    user.name = doc["name"];
    user.ucId = doc["ucId"];
    return user;
  }

  Map<String, dynamic> getMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["phone"] = phone ?? "";
    map["addedOn"] = addedOn ?? Timestamp.now();
    map["name"] = name ?? "";
    map["ucId"] = ucId ?? "";
    return map;
  }
}