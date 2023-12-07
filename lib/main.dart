import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compare_prices/provider/auth_provider.dart';
import 'package:compare_prices/provider/product_provider.dart';
import 'package:compare_prices/provider/supplier_provider.dart';
import 'package:compare_prices/theme/light_theme.dart';
import 'package:compare_prices/view/screen/auth/signin/signin_screen.dart';
import 'package:compare_prices/view/screen/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'data/repository/auth_repo.dart';
import 'data/repository/firestore_repo.dart';
import 'data/repository/storage_repo.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AuthenticationProvider>(
      create: (_) => AuthenticationProvider(AuthRepo(auth)),
    ),
    ChangeNotifierProvider<SupplierProvider>(
      create: (_) => SupplierProvider(FirestoreRepo(firestore), StorageRepo(storage)),
    ),
    ChangeNotifierProvider<ProductProvider>(
      create: (_) => ProductProvider(FirestoreRepo(firestore), StorageRepo(storage)),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BK Compare Prices',
      theme: lightTheme,
      home: StreamBuilder<User?>(
        stream: context.watch<AuthenticationProvider>().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return SignInScreen();
          } else {
            return const HomeScreen();
          }
        },
      ),
    );
  }
}
