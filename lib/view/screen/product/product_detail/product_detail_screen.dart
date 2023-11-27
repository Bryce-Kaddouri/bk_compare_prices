import 'package:compare_prices/data/model/supplier_model.dart';
import 'package:compare_prices/provider/supplier_provider.dart';
import 'package:compare_prices/view/screen/product/product_detail/edit_product/edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helper/date_helper.dart';
import '../../../../provider/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  String productId;
  ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      print(widget.productId);
      print("initState");
      print(context.read<ProductProvider>().products);
      print(context.read<SupplierProvider>().suppliers);

      /*context
          .read<ProductProvider>()
          .getProductDetail(context.read<AuthenticationProvider>().user!, widget.productId);*/
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProductScreen(
                    productId: widget.productId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Consumer2<SupplierProvider, ProductProvider>(
              builder: (context, supplierProvider, productProvider, child) {
                final product = productProvider.products
                    .firstWhere((element) => element.id == widget.productId);
                final suppliers = supplierProvider.suppliers;

                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: product.prices.length,
                  itemBuilder: (context, index) {
                    SupplierModel supplier = suppliers.firstWhere((element) =>
                        element.id == product.prices[index].supplierId);

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 96,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                supplier.photoUrl,
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
                                '${product.prices.elementAt(index).price} €',

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
                                      supplier.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.copyWith(fontSize: 24),
                                    ),
                                    Spacer(),
                                    Text(
                                      product.createdAt
                                              .isBefore(product.createdAt)
                                          ? "Created at: ${DateHelper.getFormattedDate(product.createdAt)}"
                                          : "Updated at: ${DateHelper.getFormattedDate(product.updatedAt)}",
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
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
