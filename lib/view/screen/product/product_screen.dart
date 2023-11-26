import 'package:compare_prices/helper/date_helper.dart';
import 'package:compare_prices/provider/product_provider.dart';
import 'package:compare_prices/view/screen/product/add_product/add_product_screen.dart';
import 'package:compare_prices/view/screen/product/product_detail/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/auth_provider.dart';
import '../home/home_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      context
          .read<ProductProvider>()
          .getProducts(context.read<AuthenticationProvider>().user!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen())),
            ),
          ),
          centerTitle: true,
          title: const Text('My Products'),
        ),
        body: Consumer<ProductProvider>(
          builder: (context, watch, child) {
            final productList = context.watch<ProductProvider>().products;
            print(productList);
            if (productList.isEmpty) {
              return const Center(
                child: Text("No Product Found"),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              productId: productList[index].id,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 96,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                productList[index].photoUrl,
                                height: 80.0,
                                width: 80.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              height: 100,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              alignment: Alignment.center,
                              child: Text(
                                // display the lowest price
                                productList[index].prices.isEmpty
                                    ? "No Price"
                                    : '${productList[index].prices.reduce((a, b) => a.price < b.price ? a : b).price.toString()} €',

                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.copyWith(
                                      fontSize: 24,
                                      color: Colors.green,
                                    ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      productList[index].name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.copyWith(fontSize: 24),
                                    ),
                                    Spacer(),
                                    Text(
                                      productList[index].createdAt.isBefore(
                                              productList[index].createdAt)
                                          ? "Created at: ${DateHelper.getFormattedDate(productList[index].createdAt)}"
                                          : "Updated at: ${DateHelper.getFormattedDate(productList[index].updatedAt)}",
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuButton(itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  child: Text("Edit"),
                                  value: "edit",
                                ),
                                PopupMenuItem(
                                  child: Text("Delete"),
                                  value: "delete",
                                ),
                              ];
                            })
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddProductScreen()),
            );
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ));
  }
}
