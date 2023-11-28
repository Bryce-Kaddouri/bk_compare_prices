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
    notifyListeners();
  }

  void resetSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }




  void getProducts(User? user) async {
    setLoading(true);
    try {
      List<Map<String, dynamic>>? products =
          await _firestoreRepo.getProducts(user!);
      List<ProductModel> productModels = [];
      products?.forEach((element) {
        Timestamp createdAt = element["createdAt"];
        Timestamp updatedAt = element["updatedAt"];
        element["createdAt"] = createdAt.toDate();
        element["updatedAt"] = updatedAt.toDate();
        print(element);
        productModels.add(ProductModel.fromJson(element));
      });
      print("getproducts");
      print(productModels);
      setProducts(productModels);

    } on FirebaseException catch (e) {
      HandleException.handleException(e.code, message: e.message);
    }
    setLoading(false);
  }

  void getProductById(User? user, String productId) async {
    setLoading(true);
    try {
      Map<String, dynamic>? product =
          await _firestoreRepo.getProductById(user!, productId);
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

  Future<String?> createProduct(String productName, String photoUrl,
      List<Map<String, dynamic>> prices, User? user) async {
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

  void updateProduct(
      Map<String, dynamic> product, String productId, User? user) {
    if (user!.uid == null) {
      throw Exception("Invalid user");
    }
    print("updateSupplier");
    setLoading(true);
    try {
      product["updatedAt"] = DateTime.now();

      print(product["prices"]);

      _firestoreRepo.updateProduct(product, user, productId);
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
                XFile? imageFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                setImageFile(imageFile);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  Get.back();
                  XFile? imageFile =
                      await _picker.pickImage(source: ImageSource.camera);
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

  void removeSupplierId(
      Map<String, dynamic> last, List<Map<String, dynamic>> suppliersData) {
    suppliersData.remove(last);
    setSuppliersId(suppliersData);
    notifyListeners();
  }

  void deletePriceProductBySupplierId(
      User? user, String productId, String supplierId) {
    if (user!.uid == null) {
      throw Exception("Invalid user");
    }
    print("deletePriceProductBySupplierId");
    setLoading(true);
    try {
      _firestoreRepo.deletePriceProductBySupplierId(
          user, supplierId, productId);
      print("deletePriceProductBySupplierId");
    } on FirebaseException catch (e) {
      HandleException.handleException(e.code, message: e.message);
    }
    setLoading(false);
  }
}
