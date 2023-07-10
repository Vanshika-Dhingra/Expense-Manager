import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracking/models/UserModel.dart';
import 'package:uuid/uuid.dart';

class ProjectModel {
  String projectId = "";
  String projectName = "";
  Timestamp createdOn = Timestamp.now();
  String? createdByUserId = "";
  List<String> userIds = []; // Array of userIds
  String? status="";
  String? description="";
  double?totalAmount=0;
  double?unpaidAmount=0;

  ProjectModel(String? currentUserId) {
    createdOn = Timestamp.now();
    createdByUserId = currentUserId;
    projectId = const Uuid().v4();
    if (currentUserId != null) {
      userIds.add(currentUserId);
    }
  }

  static ProjectModel toObject(doc) {
    String? currentUserId = "your_current_user_id";
    ProjectModel project = ProjectModel(currentUserId);
    project.description=doc["description"];
    project.projectName = doc["projectName"];
    project.createdOn = doc["createdOn"];
    project.projectId = doc["projectId"];
    project.createdByUserId = doc["createdByUserId"];
    project.status=doc["status"];
    project.userIds = List<String>.from(doc["userIds"] ?? []); // Convert dynamic list to List<String>
    project.totalAmount=doc["totalAmount"];
    project.unpaidAmount=doc["unpaidAmount"];
    return project;
  }

  Map<String, dynamic> getMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["projectName"] = projectName ?? "";
    map["createdOn"] = createdOn ?? Timestamp.now();
    map["projectId"] = projectId ?? "";
    map["status"]=status??"";
    map["createdByUserId"] = createdByUserId ?? "";
    map["userIds"] = userIds ?? []; // Add the userIds array to the map
    map["description"]=description??"";
    map["totalAmount"]=totalAmount??0.0;
    map["unpaidAmount"]=unpaidAmount??0.0;
    // Convert the list of ExpenseModel objects to a list of maps
    return map;
  }
}
