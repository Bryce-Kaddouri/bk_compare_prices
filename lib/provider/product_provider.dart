import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compare_prices/data/model/product_model.dart';
import 'package:compare_prices/data/repository/firestore_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../data/datasource/exception.dart';
import '../data/repository/storage_repo.dart';

class ProductProvider with ChangeNotifier {
  final FirestoreRepo _firestoreRepo;
  final StorageRepo _storageRepo;

  ProductProvider(this._firestoreRepo, this._storageRepo);

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  XFile? _imageFile;

  XFile? get imageFile => _imageFile;

  void setImageFile(XFile? imageFile) {
    _imageFile = imageFile;
    notifyListeners();
  }

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  void setProducts(List<ProductModel> products) {
    _products = products;
    notifyListeners();
  }

  List<Map<String, dynamic>> _suppliersId = [];
  List<Map<String, dynamic>> get suppliersId => _suppliersId;

  void setSuppliersId(List<Map<String, dynamic>> suppliersData) {
    _suppliersId = suppliersData;
    notifyListeners();
  }

  bool _isEditingProductName = false;
  bool get isEditingProductName => _isEditingProductName;

  void setIsEditingProductName(bool isEditingProductName) {
    _isEditingProductName = isEditingProductName;
    notifyListeners();
  }

  bool _isEditingProductPhoto = false;
  bool get isEditingProductPhoto => _isEditingProductPhoto;

  void setIsEditingProductPhoto(bool isEditingProductPhoto) {
    _isEditingProductPhoto = isEditingProductPhoto;
    notifyListeners();
  }

  bool _isAddingPrice = false;
  bool get isAddingPrice => _isAddingPrice;

  void setIsAddingPrice(bool isAddingPrice) {
    _isAddingPrice = isAddingPrice;
    notifyListeners();
  }

  ProductModel? _selectedProduct;
  ProductModel? get selectedProduct => _selectedProduct;

  void setSelectedProduct(ProductModel? selectedProduct) {
    _selectedProduct = selectedProduct;
    List<PriceModel> prices = selectedProduct!.prices;
    List<Map<String, dynamic>> suppliersId = [];
    for (int i = 0; i < prices.length; i++) {
      String supplierId = prices[i].supplierId;
      double price = prices[i].price;
      suppliersId.add({"supplierId": supplierId, "price": price, "isEditing": false});
    }
    setSuppliersId(suppliersId);
    notifyListeners();
  }

  void resetSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamProductById(String productId, User? user) {
    return _firestoreRepo.streamProductById(productId, user!);
  }

  Future<void> getProducts(User? user) async {
    setLoading(true);
    try {
      List<Map<String, dynamic>>? products = await _firestoreRepo.getProducts(user!);
      List<ProductModel> productModels = [];
      products?.forEach((element) async {
        Timestamp createdAt = element["createdAt"];
        Timestamp updatedAt = element["updatedAt"];
        element["createdAt"] = createdAt.toDate();
        element["updatedAt"] = updatedAt.toDate();
        print(element);
        ProductModel model = ProductModel.fromJson(element);
        List<PriceModelHistory> pricesHistory = [];

        var datas = await getHistoryByProductId(
          element["id"],
          user,
        );
        for (var history in datas) {
          pricesHistory.add(history);
        }
        model.setPriceHistory(pricesHistory);
        productModels.add(model);
      });

      setProducts(productModels);
    } on FirebaseException catch (e) {
      HandleException.handleException(e.code, message: e.message);
    }
    setLoading(false);
  }

  void getProductById(User? user, String productId) async {
    setLoading(true);
    try {
      Map<String, dynamic>? product = await _firestoreRepo.getProductById(user!, productId);
      Timestamp createdAt = product!["createdAt"];
      Timestamp updatedAt = product["updatedAt"];
      product["createdAt"] = createdAt.toDate();
      product["updatedAt"] = updatedAt.toDate();
      print("getProductById");
      print(product);
      ProductModel productModel = ProductModel.fromJson(product);

      List<Map<String, dynamic>> lst = [];

      for (int i = 0; i < productModel.prices.length; i++) {
        String supplierId = productModel.prices[i].supplierId;
        double price = productModel.prices[i].price;
        lst.add({"supplierId": supplierId, "price": price, "isEditing": false});
      }
      print(productModel);
      setSelectedProduct(selectedProduct);
      setSuppliersId(lst);
      notifyListeners();
    } on FirebaseException catch (e) {
      HandleException.handleException(e.code, message: e.message);
    }
    setLoading(false);
  }

  void setIsEditingPrice(bool isEditingPrice, int index) {
    _suppliersId[index]["isEditing"] = isEditingPrice;
    notifyListeners();
  }

  Future<String?> createProduct(String productName, String photoUrl, List<Map<String, dynamic>> prices, User? user) async {
    print("createSupplier");
    print('user.uid');
    print(user!.uid);
    setLoading(true);
    try {
      Map<String, dynamic> product = {
        "name": productName,
        "photoUrl": photoUrl,
        "createdAt": DateTime.now(),
        "updatedAt": DateTime.now(),
        "prices": prices,
      };
      return _firestoreRepo.createProduct(product, user);
      print("createSupplier");
    } on FirebaseException catch (e) {
      HandleException.handleException(e.code, message: e.message);
    }
    setLoading(false);
  }

  void updateProduct(Map<String, dynamic> product, String productId, User? user, bool addHistory) {
    if (user!.uid == null) {
      throw Exception("Invalid user");
    }
    print("updateSupplier");
    setLoading(true);
    try {
      product["updatedAt"] = DateTime.now();

      print(product["prices"]);

      _firestoreRepo.updateProduct(product, user, productId, addHistory);
      print("updateSupplier");
    } on FirebaseException catch (e) {
      HandleException.handleException(e.code, message: e.message);
    }
    setLoading(false);
  }

  pickImage() {
    ImagePicker _picker = ImagePicker();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () async {
                Get.back();
                XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
                setImageFile(imageFile);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  Get.back();
                  XFile? imageFile = await _picker.pickImage(source: ImageSource.camera);
                  setImageFile(imageFile);
                },
              ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  void reset() {
    _imageFile = null;
    _isLoading = false;
    _suppliersId = [];
    notifyListeners();
  }

  void removeSupplierId(Map<String, dynamic> last, List<Map<String, dynamic>> suppliersData) {
    suppliersData.remove(last);
    setSuppliersId(suppliersData);
    notifyListeners();
  }

  void deletePriceProductBySupplierId(User? user, String productId, PriceModel priceModel) {
    if (user!.uid == null) {
      throw Exception("Invalid user");
    }
    print("deletePriceProductBySupplierId");
    setLoading(true);
    try {
      _firestoreRepo.deletePriceProduct(user, productId, priceModel.toJson());
      print("deletePriceProductBySupplierId");
    } on FirebaseException catch (e) {
      HandleException.handleException(e.code, message: e.message);
    }
    setLoading(false);
  }

  // method to get product History by product id
  Future<List<PriceModelHistory>> getHistoryByProductId(String productId, User? user) async {
    List<Map<String, dynamic>> datas = await _firestoreRepo.getHistoryByProductId(productId, user!);
    List<PriceModelHistory> priceModelHistory = [];
    for (var element in datas) {
      print(element);
      priceModelHistory.add(PriceModelHistory.fromJson(element));
    }

    print("priceModelHistory");
    print(priceModelHistory);
    return priceModelHistory;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamHistoryByProductId(String productId, User? user) {
    if (user == null) {
      return Stream.empty();
    } else {
      print('stream history');
      print(productId);
      print(user.uid);
      return _firestoreRepo.streamHistoryByProductId(productId, user);
    }

    /*return _firestoreRepo.streamHistoryByProductId(productId, user!);*/
  }

  String getProductIdByProductName(String productName, User user) {
    return _firestoreRepo.getProductIdByName(productName, user);
  }
}
