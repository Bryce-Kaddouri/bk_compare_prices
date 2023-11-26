import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../datasource/exception.dart';

class FirestoreRepo {
  final FirebaseFirestore _firebaseFirestore;

  FirestoreRepo(this._firebaseFirestore);

  Future<String?> createSupplier(Map<String, dynamic> datas, User user) async {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        DocumentReference ref = await _firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .collection("suppliers")
            .add(datas);
        print("createSupplier");
        return ref.id;
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  void updateSupplier(
      Map<String, dynamic> datas, User user, String supplierId) {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        _firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .collection("suppliers")
            .doc(supplierId)
            .update(datas);
        print("updateSupplier");
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  void deleteSupplier(User user, String supplierId) {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        _firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .collection("suppliers")
            .doc(supplierId)
            .delete();
        print("deleteSupplier");
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  Future<List<Map<String, dynamic>>?> getSuppliers(User user) async {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await _firebaseFirestore
                .collection("users")
                .doc(user.uid)
                .collection("suppliers")
                .get();
        print("getSuppliers");
        return querySnapshot.docs.map((e) {
          Map<String, dynamic> data = e.data();
          data["id"] = e.id;
          print(data);
          return data;
        }).toList();
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  // method for product
  Future<String?> createProduct(Map<String, dynamic> datas, User user) async {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        DocumentReference ref = await _firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .collection("products")
            .add(datas);
        print("createProduct");
        return ref.id;
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  void updateProduct(Map<String, dynamic> datas, User user, String productId) {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        _firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .collection("products")
            .doc(productId)
            .update(datas);
        print("updateProduct");
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  void deleteProduct(User user, String productId) {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        _firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .collection("products")
            .doc(productId)
            .delete();
        print("deleteProduct");
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  Future<List<Map<String, dynamic>>?> getProducts(User user) async {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await _firebaseFirestore
                .collection("users")
                .doc(user.uid)
                .collection("products")
                .get();
        print("getProducts");
        return querySnapshot.docs.map((e) {
          Map<String, dynamic> data = e.data();
          data["id"] = e.id;
          print(data);
          return data;
        }).toList();
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }
}
