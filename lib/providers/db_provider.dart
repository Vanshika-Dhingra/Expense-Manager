import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracking/helpers/Constants.dart';
import 'package:expensetracking/models/UserModel.dart';
import 'package:expensetracking/models/UserStatsModel.dart';
import 'package:expensetracking/models/VendorModel.dart';
import 'package:expensetracking/models/CategoryModel.dart';
import 'package:expensetracking/models/ExpenseModel.dart';
import 'package:expensetracking/models/ProjectModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DbProvider extends ChangeNotifier {
  FirebaseFirestore? _firestore;
  UserModel? userModel;
  ProjectModel? projectModel;

  List<VendorModel> userVendors = [];

  DbProvider() {
    _firestore = FirebaseFirestore.instance;
  }

  UserModel get getUserModal => userModel!;
  String get getUserId => userModel!.userId;
  ProjectModel get getProjectModel=>projectModel!;
  String get getProjectId=>projectModel!.projectId;

  Future getUserFromFirestore({User? user, AuthCredential? credential}) async {
    return await _firestore?.collection(Constants.userCollection)
        .where("authId", isEqualTo: user!.uid)
        .get().then((value) {
      if(value.size == 0) {
        // Create New User
        UserModel newUser = UserModel();
        newUser.token = credential?.accessToken! ?? "";
        newUser.phone = user.phoneNumber!;
        newUser.name = "";
        newUser.authId = user.uid;
        newUser.userId = _firestore!.collection(Constants.userCollection).doc().id;
        newUser.sharedTotalAmount=0.0;
        newUser.personalTotalAmount=0.0;
        saveUserInFirestore(newUser);
        userModel = newUser;
      } else {
        userModel = UserModel.toObject(value.docs.first.data());
      }
      return userModel;
    }).catchError((error) {
      print(">>> Error while fetching data");
      print(error);
    });
  }


  Future<ProjectModel?> getProjectFromDatabase(String projectId) async {
    return await _firestore
        ?.collection(Constants.projectCollection)
        .doc(projectId)
        .get()
        .then((value) {
      if (value.exists) {
        projectModel = ProjectModel.toObject(value.data());
        return projectModel;
      } else {
        return null; // Project not found
      }
    }).catchError((error) {
      print(">>> Error while fetching project from database");
      print(error);
      return null;
    });
  }


  saveUserInFirestore(UserModel userModel) {
    _firestore?.collection(Constants.userCollection)
      .doc(userModel.userId)
      .set(userModel.getMap(), SetOptions(merge: true))
      .catchError((error) {
        print(">>> Error while writing in firestore");
        print(error.toString());
    });
  }


  saveProjectInFirestore(ProjectModel projectModel) {
    _firestore?.collection(Constants.projectCollection)
        .doc(projectModel.projectId)
        .set(projectModel.getMap(), SetOptions(merge: true))
        .catchError((error) {
      print(">>> Error while writing in firestore");
      print(error.toString());
    });
  }

  saveCategoryInFirestore(String projectId,CategoryModel categoryModel){
    _firestore?.collection(Constants.projectCollection)
        .doc(projectId).collection(Constants.categoryCollection)
        .doc(categoryModel.cid)
        .set(categoryModel.getMap(),SetOptions(merge:true))
        .catchError((error){
      print(">>> Error while writing in firestore");
      print(error.toString());
    });
  }

  saveExpenseInFirestore(String projectId,ExpenseModel expenseModel){
    _firestore?.collection(Constants.projectCollection)
        .doc(projectId).collection(Constants.expenseCollection)
        .doc(expenseModel.expenseId)
      .set(expenseModel.getMap(),SetOptions(merge:true))
      .catchError((error){
  print(">>> Error while writing in firestore");
  print(error.toString());
  });
}

  saveUserStatsInFirestore(String userId,UserStatsModel userStatsModel){
    _firestore?.collection(Constants.userCollection)
        .doc(userId).collection(Constants.userStatsCollection)
        .doc(userStatsModel.id)
        .set(userStatsModel.getMap(),SetOptions(merge:true))
        .catchError((error){
      print(">>> Error while writing in firestore");
      print(error.toString());
    });
  }

  Future<void> deleteProject(String projectId) async {
    try {
      // Delete the subcollections
      await _firestore
          ?.collection(Constants.projectCollection)
          .doc(projectId)
          .collection(Constants.expenseCollection) // Replace 'subcollections' with the actual subcollection name
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });

      await _firestore
          ?.collection(Constants.projectCollection)
          .doc(projectId)
          .collection(Constants.categoryCollection) // Replace 'subcollections' with the actual subcollection name
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });

      // Delete the project document
      await _firestore
          ?.collection(Constants.projectCollection)
          .doc(projectId)
          .delete();

      print('Project and subcollections deleted successfully');
    } catch (e) {
      print('Failed to delete project and subcollections: $e');
    }
  }


  Future<void> deleteExpense(String expenseId,String projectId) async {
    try {
      await _firestore?.collection(Constants.projectCollection).doc(projectId).collection(Constants.expenseCollection).doc(expenseId).delete();
      print('Expense deleted successfully');
    } catch (e) {
      print('Failed to delete Expense: $e');
    }
  }

  // Future<void> deleteUserStats(String expenseId) async {
  //   try {
  //     await _firestore?.collection(Constants.userCollection).doc(userModel?.userId).collection(Constants.userStatsCollection).doc(expenseId).delete();
  //     print('User Stats deleted successfully');
  //   } catch (e) {
  //     print('Failed to delete User Stats: $e');
  //   }
  // }

  Future<void> deleteUserStats(String expenseId) async {
    try {
      final userCollection = _firestore?.collection(Constants.userCollection);
      final currentUser = userModel?.userId;

      if (userCollection != null && currentUser != null) {
        final userStatsCollection = userCollection.doc(currentUser).collection(Constants.userStatsCollection);
        final userStatsQuery = userStatsCollection.where('expenseId', isEqualTo: expenseId);
        final userStatsDocs = await userStatsQuery.get();

        for (final doc in userStatsDocs.docs) {
          await doc.reference.delete();
        }

        print('User stats deleted successfully');
      } else {
        print('User or Firestore collection is null');
      }
    } catch (e) {
      print('Failed to delete User Stats: $e');
    }
  }


  Future<void> deleteCategory(String cid,String projectId) async {
    try {
      await _firestore?.collection(Constants.projectCollection).doc(projectId).collection(Constants.categoryCollection).doc(cid).delete();
      print('Expense deleted successfully');
    } catch (e) {
      print('Failed to delete Expense: $e');
    }
  }

  Future<void> editProjectStatus(String projectId) async {
    try {
      await _firestore?.collection(Constants.projectCollection).doc(projectId).update({
        'status': 'completed',
      });
      print('Project status updated successfully');
    } catch (e) {
      print('Failed to update project status: $e');
    }
  }

  Future<void> deleteUserFromProject(String projectId, String userId) async {
    try {
      // Get the project document reference
      DocumentReference<Map<String, dynamic>> projectRef = _firestore!
          .collection(Constants.projectCollection)
          .doc(projectId);

      // Retrieve the project document
      DocumentSnapshot<Map<String, dynamic>> projectSnapshot =
      await projectRef.get();

      if (!projectSnapshot.exists) {
        print("Project not found");
        return;
      }

      // Retrieve the userIds array from the project document
      List<String> userIds =
      List<String>.from(projectSnapshot.data()!['userIds']);

      // Remove the userId from the array
      userIds.remove(userId);

      //  the project document with the modified userIds array
      await projectRef.update({'userIds': userIds});

      print('User deleted from the project successfully');
    } catch (e) {
      print('Failed to delete user from the project: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchExpenseByCategory(String projectId,String categoryId) {
    return _firestore!.collection(Constants.projectCollection).doc(projectId)
        .collection(Constants.expenseCollection)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchProjects() {
    return _firestore!.collection(Constants.projectCollection)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUserVendors() {
    return _firestore!.collection(Constants.userCollection).doc(userModel!.userId)
      .collection(Constants.vendorCollection)
      .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUserStats() {
    return _firestore!
        .collection(Constants.userCollection)
        .doc(userModel!.userId)
        .collection(Constants.userStatsCollection)
        .orderBy('date', descending: true)
        .limit(3) // Add the 'limit' method to fetch only 5 items
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String,dynamic>>> fetchProjectCategories(String projectId){
    return _firestore!.collection(Constants.projectCollection)
        .doc(projectId)
        .collection(Constants.categoryCollection)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String,dynamic>>> fetchProjectExpenses(String projectId){
    return _firestore!.collection(Constants.projectCollection)
        .doc(projectId)
        .collection(Constants.expenseCollection)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String,dynamic>>> fetchCategoryProjectExpenses(String projectId,String category){
    return _firestore!.collection(Constants.projectCollection)
        .doc(projectId)
        .collection(Constants.expenseCollection)
        .where('category', isEqualTo: category)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String,dynamic>>> fetchProjectUsers(String projectId){
    return _firestore!.collection(Constants.projectCollection)
        .doc(projectId)
        .collection(Constants.expenseCollection)
        .snapshots();
  }

  Stream<double> getTotalExpenseAmount(String projectId) {
    return _firestore!
        .collection(Constants.projectCollection)
        .doc(projectId)
        .collection(Constants.expenseCollection)
        .snapshots()
        .map((querySnapshot) {
      double totalAmount = 0.0;
      for (var expenseDoc in querySnapshot.docs) {
        ExpenseModel expense = ExpenseModel.toObject(expenseDoc.data());
        double amount = double.tryParse(expense.amount) ?? 0.0;
        totalAmount += amount;
      }
      return totalAmount;
    });
  }

  Stream<double> getSharedExpensesAmount() {
    return _firestore!
        .collection(Constants.projectCollection)
        .doc(userModel?.userId)
        .collection(Constants.userStatsCollection)
        .where('isShared', isEqualTo: true) // Filter by isShared: false
        .snapshots()
        .map((querySnapshot) {
      double totalAmount = 0.0;
      for (var expenseDoc in querySnapshot.docs) {
        UserStatsModel stats = UserStatsModel.toObject(expenseDoc.data());
        double amount = double.tryParse(stats.amount) ?? 0.0;
        totalAmount += amount;
      }
      return totalAmount;
    });
  }

  Stream<double> getUnsharedExpensesAmount() {
    return _firestore!
        .collection(Constants.projectCollection)
        .doc(userModel?.userId)
        .collection(Constants.userStatsCollection)
        .where('isShared', isEqualTo: false) // Filter by isShared: false
        .snapshots()
        .map((querySnapshot) {
      double totalAmount = 0.0;
      for (var expenseDoc in querySnapshot.docs) {
        UserStatsModel stats = UserStatsModel.toObject(expenseDoc.data());
        double amount = double.tryParse(stats.amount) ?? 0.0;
        totalAmount += amount;
      }
      return totalAmount;
    });
  }

  Stream<List<double>> getWeeklySummary(String projectId, DateTime startOfWeek, DateTime endOfWeek) {
    List<String> weekdays = ['Sunday','Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    return FirebaseFirestore.instance
        .collection(Constants.projectCollection)
        .doc(projectId)
        .collection(Constants.expenseCollection)
        .where('date', isGreaterThanOrEqualTo: startOfWeek, isLessThanOrEqualTo: endOfWeek)
        .snapshots()
        .map((querySnapshot) {
      Map<String, double> expensesByDay = {};

      for (var expenseDoc in querySnapshot.docs) {
        ExpenseModel expense = ExpenseModel.toObject(expenseDoc.data());
        double amount = double.tryParse(expense.amount) ?? 0.0;
        String dayOfWeek = _getDayOfWeek(expense.date!);
        expensesByDay.update(dayOfWeek, (value) => value + amount, ifAbsent: () => amount);
      }

      // Convert the expensesByDay map to a list of double values
      List<double> weeklySummary = List.generate(7, (index) => expensesByDay[weekdays[index]] ?? 0.0);
      return weeklySummary;
    });
  }


  Future<double> getWeekExpenseAmount(String projectId,DateTime startOfWeek,DateTime endOfWeek) async {
    double totalAmount = 0.0;
    QuerySnapshot<Map<String, dynamic>> expenseSnapshot = await _firestore!
        .collection(Constants.projectCollection)
        .doc(projectId)
        .collection(Constants.expenseCollection)
        .where('date', isGreaterThanOrEqualTo: startOfWeek, isLessThanOrEqualTo: endOfWeek)
        .get();

    for (var expenseDoc in expenseSnapshot.docs) {
      ExpenseModel expense = ExpenseModel.toObject(expenseDoc.data());
      double amount = double.tryParse(expense.amount) ?? 0.0;
      totalAmount += amount;
    }

    return totalAmount;
  }


  String _getDayOfWeek(DateTime date) {
    List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[date.weekday - 1];
  }

  Future<List<UserModel>> fetchUsersByUserIds(List<String> userIds) async {
    List<UserModel> users = [];

    for (var userId in userIds) {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
      await _firestore!
          .collection(Constants.userCollection)
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        UserModel user = UserModel.toObject(userSnapshot.data());
        users.add(user);
      }
    }

    return users;
  }

  Future<List<UserModel>> fetchUsersByProjectId(String projectId) async {
    DocumentSnapshot<Map<String, dynamic>> projectSnapshot = await _firestore!
        .collection(Constants.projectCollection)
        .doc(projectId)
        .get();

    if (projectSnapshot.exists) {
      List<String> userIds = projectSnapshot.data()!['userIds'].cast<String>();

      List<UserModel> users = await fetchUsersByUserIds(userIds);

      return users;
    } else {
      return []; // Return an empty list if the project doesn't exist
    }
  }

  Future<void> updateProjectTotalAmount(String projectId, double expenseAmount) async {
    try {
      // Get the project document reference
      DocumentReference<Map<String, dynamic>> projectRef = _firestore!
          .collection(Constants.projectCollection)
          .doc(projectId);

      // Retrieve the project document
      DocumentSnapshot<Map<String, dynamic>> projectSnapshot =
      await projectRef.get();

      if (!projectSnapshot.exists) {
        print("Project not found");
        return;
      }

      // Retrieve the current totalAmount from the project document
      double currentTotalAmount = projectSnapshot.data()!['totalAmount'];
      print(currentTotalAmount);
      // Update the totalAmount with the new value
      double updatedTotalAmount = currentTotalAmount + expenseAmount;
      print(updatedTotalAmount);
      // Update the project document with the modified totalAmount
      await projectRef.update({'totalAmount': updatedTotalAmount});

      print('Project totalAmount updated successfully');
    } catch (e) {
      print('Failed to update project totalAmount: $e');
    }
  }

  Future<void> updateProjectTotalUnpaidAmount(String projectId, double expenseAmount) async {
    try {
      // Get the project document reference
      DocumentReference<Map<String, dynamic>> projectRef = _firestore!
          .collection(Constants.projectCollection)
          .doc(projectId);

      // Retrieve the project document
      DocumentSnapshot<Map<String, dynamic>> projectSnapshot =
      await projectRef.get();

      if (!projectSnapshot.exists) {
        print("Project not found");
        return;
      }

      // Retrieve the current totalAmount from the project document
      double currentTotalAmount = projectSnapshot.data()!['unpaidAmount'];
      print(currentTotalAmount);
      // Update the totalAmount with the new value
      double updatedTotalAmount = currentTotalAmount + expenseAmount;
      print(updatedTotalAmount);
      // Update the project document with the modified totalAmount
      await projectRef.update({'unpaidAmount': updatedTotalAmount});

      print('Project totalAmount updated successfully');
    } catch (e) {
      print('Failed to update project totalAmount: $e');
    }
  }

  Future<int> getExpensesWithinThreeDays(String projectId) async {
    int count = 0;
    DateTime currentDate = DateTime.now();
    DateTime threeDaysAgo = currentDate.subtract(Duration(days: 3));

    QuerySnapshot<Map<String, dynamic>> expenseSnapshot =
    await _firestore!
        .collection(Constants.projectCollection)
        .doc(projectId)
        .collection(Constants.expenseCollection)
        .get();

    for (var expenseDoc in expenseSnapshot.docs) {
      ExpenseModel expense = ExpenseModel.toObject(expenseDoc.data());
      DateTime expenseDate = expense.date ?? DateTime.now();
      if (expenseDate.isAfter(threeDaysAgo) &&
          expenseDate.isBefore(currentDate)) {
        count++;
      }
    }

    return count;
  }

}


