import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageRepo {
  final FirebaseStorage _firebaseStorage;

  StorageRepo(this._firebaseStorage);

  Stream<TaskSnapshot> uploadImage(String path, XFile file) async* {
    print("uploadImage");
    print(path);
    print(file.path);
    SettableMetadata metadata = SettableMetadata(
      contentType: 'image/jpeg',
    );

    try {
      Reference ref = _firebaseStorage.ref();
      ref = ref.child(path);
      print("ref");
      print(ref);
      late UploadTask uploadTask;
      print("uploadTask");
      print('XFile file');
      print(file);
      print('file.path');
      print(file.path);
      if (kIsWeb) {
        print("kIsWeb");
        dynamic data = await file.readAsBytes();
        print(data);
        uploadTask = ref.putData(data, metadata);
      } else {
        uploadTask = ref.putFile(File(file.path));
      }

      print("uploadTask");

      yield* uploadTask.snapshotEvents;

/*
      uploadTask = ref.putFile(file);
*/
      /*if (kIsWeb) {
       */ /* print("kIsWeb");
        dynamic blob = await file.readAsBytes();
        print(data);
        uploadTask = ref.putBlob(data, metadata)
      } else {
        uploadTask = ref.putFile(file);
      }*/
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }
}
