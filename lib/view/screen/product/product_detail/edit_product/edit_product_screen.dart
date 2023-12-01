import 'dart:io';

import 'package:compare_prices/data/model/product_model.dart';
import 'package:compare_prices/provider/product_provider.dart';
import 'package:compare_prices/provider/supplier_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../provider/auth_provider.dart';
import '../../add_product/success_screen.dart';
import '../../product_screen.dart';

class EditProductScreen extends StatefulWidget {
  String productId;
  EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  List<bool> lstIsEditing = [];
  final _formKey = GlobalKey<FormBuilderState>();
  bool isEditingProductName = false;

  void loadData() {
    print("initState");
    context.read<ProductProvider>().reset();

    context.read<SupplierProvider>().getSuppliers(context.read<AuthenticationProvider>().user!);
    context.read<ProductProvider>().getProductById(context.read<AuthenticationProvider>().user!, widget.productId);
    print('selected product');
    print(context.read<ProductProvider>().selectedProduct);
    List<PriceModel> prices = context.read<ProductProvider>().selectedProduct!.prices;
    List<Map<String, dynamic>> list = [];
    for (var element in prices) {
      lstIsEditing.add(false);
      print(element);
    }

    /* List<Map<String, dynamic>> list = [];
    for (var element in product.prices) {
      list.add({
        "supplierId": element.supplierId,
        "price": element.price,
        "isEditing": false,
      });
    }
    context.read<ProductProvider>().setSuppliersId(list);*/
    print(context.read<ProductProvider>().products);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
/*
      loadData();
*/
      context.read<ProductProvider>().reset();

      context.read<SupplierProvider>().getSuppliers(context.read<AuthenticationProvider>().user!);
      User? user = context.read<AuthenticationProvider>().user;
      context.read<ProductProvider>().streamProductById(widget.productId, user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProductScreen())),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: context.read<ProductProvider>().streamProductById(widget.productId, context.read<AuthenticationProvider>().user),
          builder: (context, snapshot) {
            print('snapshot');
            print(snapshot.data);
            ProductModel? product = snapshot.data == null ? null : ProductModel.fromDocument(snapshot.data!);
            if (product == null) {
              return const Center(
                child: Text("No Product Found"),
              );
            } else {
              List<PriceModel> prices = product.prices;
              for (int i = 0; i < prices.length; i++) {
                lstIsEditing.add(false);
              }
            }
            return FormBuilder(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderTextField(
                            enabled: isEditingProductName,
                            initialValue: product!.name,
                            name: 'product_name',
                            decoration: const InputDecoration(labelText: 'Product Name'),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Visibility(
                          child: IconButton(
                            onPressed: () {
                              print('cancel');
                              setState(() {
                                isEditingProductName = !isEditingProductName;
                              });
                            },
                            icon: const Icon(Icons.cancel),
                          ),
                          visible: isEditingProductName,
                        ),
                        IconButton(
                          onPressed: () {
                            if (isEditingProductName) {
                              User? user = context.read<AuthenticationProvider>().user;
                              String productId = widget.productId;
                              String productName = _formKey.currentState!.instantValue['product_name'];
                              if (productName != product.name) {
                                context.read<ProductProvider>().updateProduct({
                                  "name": productName,
                                }, productId, context.read<AuthenticationProvider>().user!, false);
                              }
                            }
                            setState(() {
                              isEditingProductName = !isEditingProductName;
                            });
                          },
                          icon: Icon(isEditingProductName ? Icons.save : Icons.edit),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          height: 300,
                          width: 300,
                          padding: const EdgeInsets.all(16),
                          child: context.watch<ProductProvider>().imageFile == null
                              ? Image.network(context.watch<ProductProvider>().selectedProduct!.photoUrl)
                              : kIsWeb
                                  ? Image.network(context.watch<ProductProvider>().imageFile!.path)
                                  : Image.file(
                                      File(context.watch<ProductProvider>().imageFile!.path),
                                    ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            height: 50,
                            width: 284,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: InkWell(
                              onTap: () {
                                if (context.read<ProductProvider>().imageFile == null) {
                                  context.read<ProductProvider>().pickImage();
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SuccessScreen(
                                        productId: widget.productId,
                                        onDone: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditProductScreen(
                                                productId: widget.productId,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: context.watch<ProductProvider>().imageFile == null
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt),
                                        const SizedBox(width: 10),
                                        Text("Change Photo"),
                                      ],
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.save),
                                        const SizedBox(width: 10),
                                        Text("Save Photo"),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        for (int i = 0; i < product.prices.length; i++)
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: FormBuilderDropdown(
                                    enabled: false,
                                    name: 'supplier_$i',
                                    items: [
                                      DropdownMenuItem(
                                        value: product.prices[i].supplierId,
                                        child: Text(context.watch<SupplierProvider>().suppliers.firstWhere((element) => element.id == product.prices[i].supplierId).name),
                                      ),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Supplier ${i + 1}',
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Colors.black),
                                      ),
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                    ]),
                                    initialValue: product.prices[i].supplierId,
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  height: 50,
                                  child: FormBuilderTextField(
                                    enabled: lstIsEditing[i],
                                    initialValue: product.prices[i].price.toString(),
                                    name: 'price_$i',
                                    decoration: InputDecoration(
                                      labelText: 'Price',
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.black),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.numeric(),
                                    ]),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    print('edit price');
                                    if (lstIsEditing[i]) {
                                      Get.dialog(
                                        AlertDialog(
                                          title: const Text("Add To History"),
                                          content: const Text("Do you want to add this price to the history ?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                print('dont have to add on history');

                                                User? user = context.read<AuthenticationProvider>().user;
                                                String productId = widget.productId;
                                                String supplierId = product.prices[i].supplierId;
                                                double initialPrice = product.prices[i].price;
                                                double price = double.parse(_formKey.currentState!.instantValue['price_$i']);
                                                if (initialPrice != price) {
                                                  context.read<ProductProvider>().updateProduct({
                                                    "prices": [
                                                      {
                                                        "supplierId": supplierId,
                                                        "price": price,
                                                      },
                                                    ],
                                                  }, productId, context.read<AuthenticationProvider>().user!, false);
                                                }
                                                Get.back();
                                              },
                                              child: const Text("No"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                print('have to add on history');

                                                User? user = context.read<AuthenticationProvider>().user;
                                                String productId = widget.productId;
                                                String supplierId = product.prices[i].supplierId;
                                                double initialPrice = product.prices[i].price;
                                                double price = double.parse(_formKey.currentState!.instantValue['price_$i']);
                                                if (initialPrice != price) {
                                                  context.read<ProductProvider>().updateProduct({
                                                    "prices": [
                                                      {
                                                        "supplierId": supplierId,
                                                        "price": price,
                                                      },
                                                    ],
                                                  }, productId, context.read<AuthenticationProvider>().user!, true);
                                                }
                                                Get.back();
                                              },
                                              child: const Text("Yes"),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    setState(() {
                                      lstIsEditing[i] = !lstIsEditing[i];
                                    });
                                  },
                                  icon: Icon(lstIsEditing[i] ? Icons.save : Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Get.dialog(
                                      AlertDialog(
                                        title: const Text("Delete"),
                                        content: const Text("Are you sure you want to delete this price for this supplier ?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              /*context
                                                  .read<ProductProvider>()
                                                  .removeSupplierId(
                                                      context
                                                          .read<ProductProvider>()
                                                          .suppliersId[i],
                                                      context
                                                          .read<ProductProvider>()
                                                          .suppliersId);*/
                                              User? user = context.read<AuthenticationProvider>().user;

                                              context.read<ProductProvider>().deletePriceProductBySupplierId(user, widget.productId, product.prices[i]);
                                              Get.back();
                                            },
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        if (product.prices.length < context.watch<SupplierProvider>().suppliers.length && product.isAddingPrice == false)
                          Row(
                            children: [
                              Expanded(
                                child: FormBuilderDropdown(
                                  name: 'supplier',
                                  initialValue: null,
                                  items: [
                                    ...context
                                        .watch<SupplierProvider>()
                                        .suppliers
                                        .where((element) => !product.prices.map((e) => e.supplierId).toList().contains(element.id))
                                        /* !context.read<ProductProvider>().suppliersId.map((e) => e['supplierId']).toList().contains(element.id))*/
                                        .map((e) => DropdownMenuItem(
                                              value: e.id,
                                              child: Text(
                                                e.name,
                                                style: TextStyle(color: Colors.black),
                                              ),
                                            ))
                                        .toList()
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Supplier',
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                  ]),
                                ),
                              ),
                              Container(
                                width: 100,
                                height: 50,
                                child: FormBuilderTextField(
                                  initialValue: null,
                                  name: 'price',
                                  decoration: const InputDecoration(labelText: 'Price'),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.numeric(),
                                  ]),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  print('add price for a new supplier');

                                  String? supplierId = _formKey.currentState?.instantValue['supplier'];
                                  String? price = _formKey.currentState?.instantValue['price'];
                                  print(supplierId);
                                  print(price);
                                  if (supplierId == null || price == null) {
                                    Get.snackbar(
                                      "Error",
                                      "Please select a supplier and a price",
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                      margin: const EdgeInsets.all(16),
                                    );
                                  } else {
                                    print('add price');
                                    Map<String, dynamic> last = {
                                      'prices': [
                                        {
                                          "supplierId": _formKey.currentState?.instantValue['supplier'],
                                          "price": double.parse(_formKey.currentState?.instantValue['price']),
                                        }
                                      ]
                                    };
                                    print(last);
                                    print(context.read<AuthenticationProvider>().user!);
                                    context.read<ProductProvider>().updateProduct(last, widget.productId, context.read<AuthenticationProvider>().user!, true);
                                    _formKey.currentState?.reset();
                                  }
                                },
                                icon: Icon(Icons.save),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    // button to add an other supplier for this product
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
