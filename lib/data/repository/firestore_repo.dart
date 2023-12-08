import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compare_prices/data/model/init_data_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../datasource/exception.dart';
import '../model/product_model.dart';
import '../model/supplier_model.dart';

class FirestoreRepo {
  final FirebaseFirestore _firebaseFirestore;

  FirestoreRepo(this._firebaseFirestore);

  Future<String?> createSupplier(Map<String, dynamic> datas, User user) async {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        DocumentReference ref = await _firebaseFirestore.collection("users").doc(user.uid).collection("suppliers").add(datas);
        return ref.id;
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  void updateSupplier(Map<String, dynamic> datas, User user, String supplierId) {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        _firebaseFirestore.collection("users").doc(user.uid).collection("suppliers").doc(supplierId).update(datas);
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
        _firebaseFirestore.collection("users").doc(user.uid).collection("suppliers").doc(supplierId).delete();
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  Future<List<Map<String, dynamic>>?> getSuppliers(User? user) async {
    if (user == null) {
      throw Exception("Invalid user");
    } else {
      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firebaseFirestore.collection("users").doc(user.uid).collection("suppliers").get();
        return querySnapshot.docs.map((e) {
          Map<String, dynamic> data = e.data();
          data["id"] = e.id;
          return data;
        }).toList();
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
    return null;
  }

  // method for product
  Future<String?> createProduct(Map<String, dynamic> datas, User user) async {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        DocumentReference ref = await _firebaseFirestore.collection("users").doc(user.uid).collection("products").add(datas);
        List<Map<String, dynamic>> prices = datas["prices"];
        for (Map<String, dynamic> price in prices) {
          price['createdAt'] = DateTime.now();
          addPriceHistory(user, ref.id, price['supplierId'], price['price']);
        }

        /*addPriceHistory(user, ref.id, prices);*/

        return ref.id;
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  void updateProduct(Map<String, dynamic> datas, User user, String productId, bool addHistory) async {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        if (datas["prices"] != null) {
          DocumentSnapshot oldProduct = await _firebaseFirestore.collection("users").doc(user.uid).collection("products").doc(productId).get();
          List<dynamic> oldPrices = oldProduct.get('prices');

          List<Map<String, dynamic>> newPrices = datas["prices"];

          for (int i = 0; i < newPrices.length; i++) {
            if (addHistory) {
              addPriceHistory(user, productId, newPrices[i]["supplierId"], newPrices[i]["price"]);
            }

            var old = oldPrices.firstWhere((element) => element["supplierId"] == newPrices[i]["supplierId"], orElse: () => null);

            if (old != null) {
              int index = oldPrices.indexOf(old);

              if (old["supplierId"] == newPrices[i]["supplierId"]) {
                oldPrices.elementAt(index)["price"] = newPrices[i]["price"];
              }
            } else {
              oldPrices.add(newPrices[i]);
            }
          }
        }
        _firebaseFirestore.collection("users").doc(user.uid).collection("products").doc(productId).update(datas);
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
        _firebaseFirestore.collection("users").doc(user.uid).collection("products").doc(productId).delete();
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  void deletePriceProduct(User user, String productId, Map<String, dynamic> price) {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        _firebaseFirestore.collection("users").doc(user.uid).collection("products").doc(productId).update({
          "prices": FieldValue.arrayRemove([price])
        });
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  Future<List<Map<String, dynamic>>?> getProducts(User? user) async {
    if (user == null) {
      throw Exception("Invalid user");
    } else {
      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firebaseFirestore.collection("users").doc(user.uid).collection("products").get();

        return querySnapshot.docs.map((e) {
          Map<String, dynamic> data = e.data();
          data["id"] = e.id;

          return data;
        }).toList();
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
    return null;
  }

  void addPriceHistory(User user, String productId, String supplierId, double price) {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        _firebaseFirestore.collection("users").doc(user.uid).collection("priceHistory").doc(productId).collection("prices").add({
          "supplier_id": supplierId,
          "product_id": productId,
          "price": price,
          "created_at": DateTime.now(),
        });
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  /*void updatePriceHistory(
      User user, String productId, List<Map<String, dynamic>> datas) {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        _firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .collection("priceHistory")
            .doc(productId)
            .update(
          {
            "price_history": datas,
          },
        );
        print("updatePriceHistory");
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }*/

  Future<List<Map<String, dynamic>>?> getPriceHistory(User user, String productId) async {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        DocumentSnapshot<Map<String, dynamic>> querySnapshot = await _firebaseFirestore.collection("users").doc(user.uid).collection("price_history").doc(productId).get();
        return querySnapshot.data()!["price_history"];
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  Future<List<Map<String, dynamic>>?> getSupplierPriceHistory(User? user, String supplierId) async {
    if (user == null) {
      throw Exception("Invalid user");
    } else {
      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firebaseFirestore.collection("users").doc(user.uid).collection("price_history").where("supplier_id", isEqualTo: supplierId).get();
        return querySnapshot.docs.map((e) {
          Map<String, dynamic> data = e.data();
          data["id"] = e.id;
          return data;
        }).toList();
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
    return null;
  }

  /* void deletePriceProductBySupplierId(User user, String supplierId, String productId) {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        _firebaseFirestore.collection("users").doc(user.uid).collection("products").doc(productId).get().then((value) {
          String prices = value.get('prices').toString();
          List<Map<String, dynamic>> pricesMap = List<Map<String, dynamic>>.from(value.get('prices'));
          print("deletePriceProductBySupplierId");
          print(prices.runtimeType);
          print(prices);
          print(pricesMap.runtimeType);
          print(pricesMap);
          pricesMap.removeWhere((element) => element["supplierId"] == supplierId);
          updateProduct({"prices": pricesMap}, user, productId);
        });

        */ /*.where("supplier_id", isEqualTo: supplierId)
            .where("product_id", isEqualTo: productId)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            element.reference.delete();
          });
        });*/ /*
        print("deletePriceProductBySupplierId");
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }*/

  getProductById(User user, String productId) {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        _firebaseFirestore.collection("users").doc(user.uid).collection("products").doc(productId).get().then((value) {
          return value.data();
        });
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamProductById(String productId, User user) {
    return _firebaseFirestore.collection('users').doc(user.uid).collection('products').doc(productId).snapshots();
  }

  Future<List<Map<String, dynamic>>> getHistoryByProductId(String productId, User user) async {
    List<Map<String, dynamic>> history = [];
    var datas = await _firebaseFirestore.collection("users").doc(user.uid).collection("priceHistory").doc(productId).collection("prices").get();
    datas.docs.forEach((element) {
      Map<String, dynamic> data = element.data();
      data["id"] = element.id;
      history.add(data);
    });
    return history;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamHistoryByProductId(String productId, User user) {
    return _firebaseFirestore.collection('users').doc(user.uid).collection('priceHistory').doc(productId).collection('prices').snapshots();
  }

  String getProductIdByName(String productName, User user) {
    String productId = "";
    _firebaseFirestore.collection("users").doc(user.uid).collection("products").where("name", isEqualTo: productName).get().then((value) {
      for (var element in value.docs) {
        productId = element.id;
      }
    });
    return productId;
  }

  Stream<InitDataModel> initDatas() {
    User? user = FirebaseAuth.instance.currentUser;
    /*return  Future.wait([getSuppliers(user), getProducts(user)]).then((value) {
      print("value");
      print(value);
      List<SupplierModel?> suppliers = [];
      for (var element in value[0]!) {
        suppliers.add(SupplierModel.fromJson(element));
      }
      List<ProductModel?> products = [];
      for (var element in value[1]!) {
        products.add(ProductModel.fromJson(element));
      }
      InitDataModel datas = InitDataModel(suppliers: suppliers, products: products);
      print("datas");
      print(datas);
      return datas;
    });*/

    return Stream.fromFuture(Future.wait([getSuppliers(user), getProducts(user)])).map((value) {
      try {
        print("value");
        print(value);
        List<SupplierModel?> suppliers = [];
        for (var element in value[0]!) {
          suppliers.add(SupplierModel.fromJson(element));
        }
        List<ProductModel?> products = [];
        for (var element in value[1]!) {
          products.add(ProductModel.fromJson(element));
        }
        InitDataModel datas = InitDataModel(suppliers: suppliers, products: products);
        print("datas");
        print(datas);
        return datas;
      } catch (e) {
        print(e);
        return InitDataModel(suppliers: [], products: []);
      }
    });
  }
}
