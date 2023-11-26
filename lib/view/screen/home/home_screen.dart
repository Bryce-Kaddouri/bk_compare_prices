import 'package:compare_prices/view/screen/product/product_screen.dart';
import 'package:compare_prices/view/screen/supplier/supplier_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/auth_provider.dart';
import '../../../provider/supplier_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      context.read<AuthenticationProvider>().init();
      context
          .read<SupplierProvider>()
          .getSuppliers(context.read<AuthenticationProvider>().user!);
      context
          .read<SupplierProvider>()
          .getSuppliers(context.read<AuthenticationProvider>().user!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Suppliers'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SupplierScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Products'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProductScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                context.read<AuthenticationProvider>().signOut();
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        automaticallyImplyLeading: false,
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Welcome to Home Screen',
            ),
          ],
        ),
      ),
    );
  }
}
