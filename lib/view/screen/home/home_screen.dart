import 'package:compare_prices/provider/product_provider.dart';
import 'package:compare_prices/view/base/charts/line-chart/line_chart_widget.dart';
import 'package:compare_prices/view/screen/product/product_screen.dart';
import 'package:compare_prices/view/screen/supplier/supplier_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  SearchController controller = SearchController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthenticationProvider>().init();
      context.read<SupplierProvider>().getSuppliers(context.read<AuthenticationProvider>().user!);
      context.read<ProductProvider>().getProducts(context.read<AuthenticationProvider>().user!).whenComplete(() {
        String productName = context.read<ProductProvider>().products.first.name;
        print("productName");
        print(productName);
        controller.text = productName;
        String productId = context.read<ProductProvider>().products.first.id;
        User? user = context.read<AuthenticationProvider>().user;
        print("productId");
        print(productId);
        print("user");
        print(user);
      });
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
                  MaterialPageRoute(builder: (context) => const SupplierScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Products'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductScreen()),
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              height: 60,
              child: SearchAnchor.bar(
                isFullScreen: true,
                suggestionsBuilder: (context, query) {
                  return context
                      .read<ProductProvider>()
                      .products
                      .where((element) => element.name.contains(query.text))
                      .map((e) => ListTile(
                            dense: true,
                            visualDensity: const VisualDensity(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: const BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            title: Text(e.name),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                e.photoUrl,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            onTap: () {
                              // close the search bar
                              controller.closeView(e.name);
                            },
                          ))
                      .toList();
                },
                searchController: controller,
              ),
            ),
            Container(
              child: LineChartSample1(
                productName: controller.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
