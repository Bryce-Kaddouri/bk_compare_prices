import 'dart:io';

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
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      context.read<ProductProvider>().reset();

      context
          .read<SupplierProvider>()
          .getSuppliers(context.read<AuthenticationProvider>().user!);
      final product = context
          .read<ProductProvider>()
          .products
          .firstWhere((element) => element.id == widget.productId);
      List<Map<String, dynamic>> list = [];
      product.prices.forEach((element) {
        list.add({
          "supplierId": element.supplierId,
          "price": element.price,
          "isEditing": false,
        });
      });
      context.read<ProductProvider>().setSuppliersId(list);
      print(context.read<ProductProvider>().suppliersId);
    });
  }

  @override
  Widget build(BuildContext context) {
    print(context.read<ProductProvider>().suppliersId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const ProductScreen())),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FormBuilderTextField(
                        enabled: context
                            .watch<ProductProvider>()
                            .isEditingProductName,
                        initialValue: context
                            .watch<ProductProvider>()
                            .products
                            .firstWhere(
                                (element) => element.id == widget.productId)
                            .name,
                        name: 'product_name',
                        decoration:
                            const InputDecoration(labelText: 'Product Name'),
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
                          context
                              .read<ProductProvider>()
                              .setIsEditingProductName(false);
                        },
                        icon: const Icon(Icons.cancel),
                      ),
                      visible:
                          context.watch<ProductProvider>().isEditingProductName,
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<ProductProvider>().setIsEditingProductName(
                            !context
                                .read<ProductProvider>()
                                .isEditingProductName);
                        print('save product name');
                      },
                      icon: Icon(
                          context.watch<ProductProvider>().isEditingProductName
                              ? Icons.save
                              : Icons.edit),
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
                          ? Image.network(context
                              .watch<ProductProvider>()
                              .products
                              .firstWhere(
                                  (element) => element.id == widget.productId)
                              .photoUrl)
                          : kIsWeb
                              ? Image.network(context
                                  .watch<ProductProvider>()
                                  .imageFile!
                                  .path)
                              : Image.file(
                                  File(context
                                      .watch<ProductProvider>()
                                      .imageFile!
                                      .path),
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
                            if (context.read<ProductProvider>().imageFile ==
                                null) {
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
                                          builder: (context) =>
                                              EditProductScreen(
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
                          child: context.watch<ProductProvider>().imageFile ==
                                  null
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
                Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    print(productProvider.suppliersId);

                    return Column(
                      children: [
                        for (int i = 0;
                            i < productProvider.suppliersId.length;
                            i++)
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
                                        value: productProvider.suppliersId[i]
                                            ['supplierId'],
                                        child: Text(context
                                            .watch<SupplierProvider>()
                                            .suppliers
                                            .firstWhere((element) =>
                                                element.id ==
                                                productProvider.suppliersId[i]
                                                    ['supplierId'])
                                            .name),
                                      ),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Supplier ${i + 1}',
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                    ]),
                                    initialValue: productProvider.suppliersId[i]
                                        ['supplierId'],
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  height: 50,
                                  child: FormBuilderTextField(
                                    enabled: context
                                        .read<ProductProvider>()
                                        .suppliersId[i]['isEditing'],
                                    initialValue: productProvider.suppliersId[i]
                                            ['price']
                                        .toString(),
                                    name: 'price_$i',
                                    decoration: InputDecoration(
                                      labelText: 'Price',
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                                    context
                                        .read<ProductProvider>()
                                        .setIsEditingPrice(
                                            !context
                                                .read<ProductProvider>()
                                                .suppliersId[i]['isEditing'],
                                            i);
                                    if (!context
                                        .read<ProductProvider>()
                                        .suppliersId[i]['isEditing']) {
                                      print('save price');
                                      User? user = context
                                          .read<AuthenticationProvider>()
                                          .user;
                                      String productId = widget.productId;
                                      String supplierId = context
                                          .read<ProductProvider>()
                                          .suppliersId[i]['supplierId'];
                                      double initialPrice = context
                                          .read<ProductProvider>()
                                          .suppliersId[i]['price'];
                                      double price = double.parse(_formKey
                                          .currentState!
                                          .instantValue['price_$i']);
                                      if (initialPrice != price) {
                                        context
                                            .read<ProductProvider>()
                                            .updateProduct(
                                                {
                                              "prices": [
                                                {
                                                  "supplierId": supplierId,
                                                  "price": price,
                                                },
                                              ],
                                            },
                                                productId,
                                                context
                                                    .read<
                                                        AuthenticationProvider>()
                                                    .user!);
                                      }
                                      print(user);
                                      print(productId);
                                      print(supplierId);
                                      print(initialPrice);
                                      print(price);
                                    }
                                  },
                                  icon: Icon(context
                                          .read<ProductProvider>()
                                          .suppliersId[i]['isEditing']
                                      ? Icons.save
                                      : Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    /* context
                                        .read<ProductProvider>()
                                        .setIsEditingPrice(
                                        !context
                                            .read<ProductProvider>()
                                            .suppliersId[i]['isEditing'],
                                        i);*/
                                    Get.dialog(
                                      AlertDialog(
                                        title: const Text("Delete"),
                                        content: const Text(
                                            "Are you sure you want to delete this price for this supplier ?"),
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
                                              User? user = context
                                                  .read<
                                                      AuthenticationProvider>()
                                                  .user;
                                              String productId = widget
                                                  .productId; //context.read<ProductProvider>().products.firstWhere((element) => element.id == widget.productId).id;
                                              String supplierId = context
                                                  .read<ProductProvider>()
                                                  .suppliersId[i]['supplierId'];
                                              print(user);
                                              print(productId);
                                              print(supplierId);

                                              context
                                                  .read<ProductProvider>()
                                                  .deletePriceProductBySupplierId(
                                                      user,
                                                      widget.productId,
                                                      context
                                                              .read<
                                                                  ProductProvider>()
                                                              .suppliersId[i]
                                                          ['supplierId']);
                                              Get.back();
                                              List<Map<String, dynamic>> list =
                                                  context
                                                      .read<ProductProvider>()
                                                      .suppliersId;
                                              list.removeAt(i);
                                              list.forEach((element) {
                                                element['isEditing'] = false;
                                              });
                                              context
                                                  .read<ProductProvider>()
                                                  .setSuppliersId(list);
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
                        if (context
                                    .watch<ProductProvider>()
                                    .suppliersId
                                    .length <
                                context
                                    .watch<SupplierProvider>()
                                    .suppliers
                                    .length &&
                            context.watch<ProductProvider>().isAddingPrice ==
                                false)
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
                                        .where((element) => !context
                                            .read<ProductProvider>()
                                            .suppliersId
                                            .map((e) => e['supplierId'])
                                            .toList()
                                            .contains(element.id))
                                        .map((e) => DropdownMenuItem(
                                              value: e.id,
                                              child: Text(
                                                e.name,
                                                style: TextStyle(
                                                    color: Colors.black),
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
                                  decoration:
                                      const InputDecoration(labelText: 'Price'),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.numeric(),
                                  ]),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  List<Map<String, dynamic>> list = context
                                      .read<ProductProvider>()
                                      .suppliersId;
                                  List<Map<String, dynamic>> datas = [];
                                  String? supplierId = _formKey
                                      .currentState?.instantValue['supplier'];
                                  String? price = _formKey
                                      .currentState?.instantValue['price'];
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
                                    datas.add({
                                      "supplierId": supplierId,
                                      "price": double.parse(price),
                                    });
                                    print(datas);
                                    context
                                        .read<ProductProvider>()
                                        .updateProduct(
                                            {
                                          "prices": datas,
                                        },
                                            widget.productId,
                                            context
                                                .read<AuthenticationProvider>()
                                                .user!);
                                    print(datas);
                                    datas.forEach((element) {
                                      element['isEditing'] = false;
                                    });
                                    context
                                        .read<ProductProvider>()
                                        .setSuppliersId(datas);
                                    _formKey.currentState?.reset();
                                    context
                                        .read<ProductProvider>()
                                        .setIsAddingPrice(false);
                                  }
                                },
                                icon: Icon(Icons.save),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 10),
                // button to add an other supplier for this product
              ],
            ),
          ),
        ),
      ),
    );
  }
}
