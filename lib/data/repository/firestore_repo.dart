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
        List<Map<String, dynamic>> prices = datas["prices"];
        print("createProduct");
        print(prices);
        for (Map<String, dynamic> price in prices) {
          print(price);
          price['createdAt'] = DateTime.now();
          addPriceHistory(user, ref.id, price['supplierId'], price['price']);
        }
        print(prices);

        /*addPriceHistory(user, ref.id, prices);*/

        return ref.id;
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  void updateProduct(
      Map<String, dynamic> datas, User user, String productId) async {
    print("updateProduct repo");
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        if (datas["prices"] != null) {
          print("updateProduct repo prices");
          print(datas["prices"]);
          DocumentSnapshot oldProduct = await _firebaseFirestore
              .collection("users")
              .doc(user.uid)
              .collection("products")
              .doc(productId)
              .get();
          List<dynamic> oldPrices =
          oldProduct.get('prices');
          print("oldPrices");
          print(oldPrices);
          List<Map<String, dynamic>> newPrices = datas["prices"];
          for(int i =0; i<newPrices.length; i++){
            addPriceHistory(user, productId, newPrices[i]["supplierId"], newPrices[i]["price"]);
            print('oldSupplierId = ${oldPrices[i]["supplierId"]}');
            print('newSupplierId = ${newPrices[i]["supplierId"]}');
            var old = oldPrices.firstWhere((element) => element["supplierId"] == newPrices[i]["supplierId"], orElse: () => null);
            print(old);

            if(old != null){
              int index = oldPrices.indexOf(old);
              print(old);
              print(old["supplierId"] == newPrices[i]["supplierId"]);
              if(old["supplierId"] == newPrices[i]["supplierId"]){
                oldPrices.elementAt(index)["price"] = newPrices[i]["price"];
              }
            }else{

          oldPrices.add(newPrices[i]);

            }
          }


          print("test");
          print(oldPrices);
          datas["prices"] = oldPrices;



          // merge old prices with new prices

        }
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

  void addPriceHistory(
      User user, String productId, String supplierId, double price) {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        _firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .collection("priceHistory")
            .doc(productId)
            .collection("prices")
            .add({
          "supplier_id": supplierId,
          "product_id": productId,
          "price": price,
          "created_at": DateTime.now(),
        });
        print("addPriceHistory");
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

  Future<List<Map<String, dynamic>>?> getPriceHistory(
      User user, String productId) async {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        DocumentSnapshot<Map<String, dynamic>> querySnapshot =
            await _firebaseFirestore
                .collection("users")
                .doc(user.uid)
                .collection("price_history")
                .doc(productId)
                .get();
        print("getPriceHistory");
        return querySnapshot.data()!["price_history"];
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  Future<List<Map<String, dynamic>>?> getSupplierPriceHistory(
      User user, String supplierId) async {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await _firebaseFirestore
                .collection("users")
                .doc(user.uid)
                .collection("price_history")
                .where("supplier_id", isEqualTo: supplierId)
                .get();
        print("getSupplierPriceHistory");
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

  void deletePriceProductBySupplierId(
      User user, String supplierId, String productId) {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        _firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .collection("products")
            .doc(productId)
            .get()
            .then((value) {
          String prices = value.get('prices').toString();
          List<Map<String, dynamic>> pricesMap =
              List<Map<String, dynamic>>.from(value.get('prices'));
          print("deletePriceProductBySupplierId");
          print(prices.runtimeType);
          print(prices);
          print(pricesMap.runtimeType);
          print(pricesMap);
          pricesMap
              .removeWhere((element) => element["supplierId"] == supplierId);
          updateProduct({"prices": pricesMap}, user, productId);
        });

        /*.where("supplier_id", isEqualTo: supplierId)
            .where("product_id", isEqualTo: productId)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            element.reference.delete();
          });
        });*/
        print("deletePriceProductBySupplierId");
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }

  getProductById(User user, String productId) {
    if (user.uid == null) {
      throw Exception("Invalid user");
    } else {
      try {
        _firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .collection("products")
            .doc(productId)
            .get()
            .then((value) {
          print("getProductById");
          print(value.data());
          return value.data();
        });
      } on FirebaseException catch (e) {
        HandleException.handleException(e.code, message: e.message);
      }
    }
  }
}
