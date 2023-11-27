import 'dart:io';

import 'package:compare_prices/data/model/product_model.dart';
import 'package:compare_prices/data/model/supplier_model.dart';
import 'package:compare_prices/provider/product_provider.dart';
import 'package:compare_prices/provider/supplier_provider.dart';
import 'package:compare_prices/view/screen/product/add_product/success_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../provider/auth_provider.dart';

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
        title: const Text('Add Product'),
      ),
      body: FormBuilder(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      enabled:
                          context.watch<ProductProvider>().isEditingProductName,
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
              InkWell(
                onTap: () async {
                  await context.read<ProductProvider>().pickImage();
                },
                child: Stack(
                  children: [
                    Container(
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
                  ],
                ),
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
                        Row(
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
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.black),
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
                                enabled: true,
                                initialValue: productProvider.suppliersId[i]
                                        ['price']
                                    .toString(),
                                name: 'price_$i',
                                decoration: InputDecoration(
                                  labelText: 'Price',
                                  disabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black),
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
                                context
                                    .read<ProductProvider>()
                                    .removeSupplierId(
                                        context
                                            .read<ProductProvider>()
                                            .suppliersId
                                            .last,
                                        context
                                            .read<ProductProvider>()
                                            .suppliersId);
                              },
                              icon: Icon(Icons.remove_circle),
                            )
                          ],
                        ),
                      const SizedBox(height: 10),
                      if (context.watch<ProductProvider>().suppliersId.length <
                          context.watch<SupplierProvider>().suppliers.length)
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
                                context
                                    .read<ProductProvider>()
                                    .removeSupplierId(
                                        context
                                            .read<ProductProvider>()
                                            .suppliersId
                                            .last,
                                        context
                                            .read<ProductProvider>()
                                            .suppliersId);
                              },
                              icon: Icon(Icons.remove_circle),
                            )
                          ],
                        ),
                      if (context.watch<ProductProvider>().suppliersId.length <
                          context.watch<SupplierProvider>().suppliers.length)
                        MaterialButton(
                          color: Theme.of(context).colorScheme.secondary,
                          onPressed: () {
                            // Validate and save the form values
                            List<Map<String, dynamic>> list =
                                context.read<ProductProvider>().suppliersId;

                            print(list);
                            debugPrint(
                                _formKey.currentState?.instantValue.toString());
                            String? supplierId =
                                _formKey.currentState?.instantValue['supplier'];
                            String? price =
                                _formKey.currentState?.instantValue['price'];

                            if (supplierId == null || price == null) {
                              Get.snackbar(
                                "Error",
                                "Please select a supplier and a price",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                              );
                              return;
                            }
                            print(supplierId);
                            list.add({
                              "supplierId": supplierId,
                              "price": double.parse(price),
                            });
                            print(list);

                            context
                                .read<ProductProvider>()
                                .setSuppliersId(list);
                          },
                          child: const Text(
                            'Add an other Supplier',
                            style: TextStyle(color: Colors.white),
                          ),
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
    );
  }
}
