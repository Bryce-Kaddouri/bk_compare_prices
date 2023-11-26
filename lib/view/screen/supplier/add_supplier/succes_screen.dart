import 'package:compare_prices/data/repository/storage_repo.dart';
import 'package:compare_prices/view/screen/supplier/supplier_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/auth_provider.dart';
import '../../../../provider/supplier_provider.dart';

class SuccessScreen extends StatelessWidget {
  String supplierId;
  SuccessScreen({Key? key, required this.supplierId}) : super(key: key);

  final StorageRepo _storageRepo = StorageRepo(FirebaseStorage.instance);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            StreamBuilder(
              stream: _storageRepo.uploadImage(
                  "users/${context.read<AuthenticationProvider>().user!.uid}/suppliers/${supplierId}.png",
                  context.read<SupplierProvider>().imageFile!),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    print("waiting");
                    return Text("waiting");
                    break;
                  case ConnectionState.active:
                    print("active");

                    switch (snapshot.data!.state) {
                      case TaskState.running:
                        double progress = snapshot.data!.bytesTransferred /
                            snapshot.data!.totalBytes;
                        print(progress);
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              LinearProgressIndicator(
                                value: progress,
                              ),
                              Spacer(),
                              Text("Downloading..."),
                              Spacer(),
                              Text('${(progress * 100).toStringAsFixed(2)} %'),
                              Spacer(),
                            ],
                          ),
                        );
                      case TaskState.success:
                        snapshot.data!.ref.getDownloadURL().then(
                          (String value) {
                            print("success");
                            print(value);
                            context.read<SupplierProvider>().updateSupplier(
                              {
                                "photoUrl": value,
                              },
                              supplierId,
                              context.read<AuthenticationProvider>().user,
                            );
                            context.read<SupplierProvider>().setImageFile(null);
                          },
                        );
                        // Handle successful uploads on complete
                        // ...
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text("success"),
                              Spacer(),
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 100,
                              ),
                              Spacer(),
                              MaterialButton(
                                color: Theme.of(context).colorScheme.secondary,
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SupplierScreen(),
                                    ),
                                  );
                                },
                                child: const Text("Return to Supplier"),
                              ),
                              Spacer(),
                            ],
                          ),
                        );
                      default:
                        return Container();
                    }

                    break;
                  case ConnectionState.done:
                    print("done");
                    return Text("done");
                    break;
                  default:
                    return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
