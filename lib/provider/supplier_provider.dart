import 'package:compare_prices/data/model/supplier_model.dart';
import 'package:compare_prices/data/repository/firestore_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../data/datasource/exception.dart';
import '../data/repository/storage_repo.dart';

class SupplierProvider with ChangeNotifier {
  final FirestoreRepo _firestoreRepo;
  final StorageRepo _storageRepo;

  SupplierProvider(this._firestoreRepo, this._storageRepo);

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

  List<SupplierModel> _suppliers = [];
  List<SupplierModel> get suppliers => _suppliers;

  void setSuppliers(List<SupplierModel> suppliers) {
    _suppliers = suppliers;
    notifyListeners();
  }

  void getSuppliers(User? user) async {
    print("getSuppliers");
    setLoading(true);
    try {
      List<Map<String, dynamic>>? suppliers = await _firestoreRepo.getSuppliers(user!);
      List<SupplierModel> supplierModels = [];
      suppliers?.forEach((element) {
        print(element);
        supplierModels.add(SupplierModel.fromJson(element));
      });
      print("getSuppliers");
      setSuppliers(supplierModels);
    } on FirebaseException catch (e) {
      HandleException.handleException(e.code, message: e.message);
    }
    setLoading(false);
  }

  Future<String?> createSupplier(String supplierName, String photoUrl, User? user, List<int> color) async {
    print("createSupplier");
    print('user.uid');
    print(user!.uid);
    setLoading(true);
    try {
      Map<String, dynamic> supplier = {
        "name": supplierName,
        "photoUrl": photoUrl,
        "createdAt": DateTime.now(),
        "updatedAt": DateTime.now(),
        "color": color,
      };
      return _firestoreRepo.createSupplier(supplier, user);
      print("createSupplier");
    } on FirebaseException catch (e) {
      HandleException.handleException(e.code, message: e.message);
    }
    setLoading(false);
  }

  void updateSupplier(Map<String, dynamic> supplier, String supplierId, User? user) {
    if (user!.uid == null) {
      throw Exception("Invalid user");
    }
    print("updateSupplier");
    setLoading(true);
    try {
      supplier["updatedAt"] = DateTime.now();

      _firestoreRepo.updateSupplier(supplier, user, supplierId);
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
}
