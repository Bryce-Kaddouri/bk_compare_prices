import 'dart:io';

import 'package:compare_prices/provider/product_provider.dart';
import 'package:compare_prices/provider/supplier_provider.dart';
import 'package:compare_prices/view/screen/product/add_product/success_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../provider/auth_provider.dart';

class AddProductScreen extends StatefulWidget {
  AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.reset();

      context
          .read<SupplierProvider>()
          .getSuppliers(context.read<AuthenticationProvider>().user!);
      context.read<ProductProvider>().reset();


    });
  }

  @override
  Widget build(BuildContext context) {
    print(context.read<ProductProvider>().suppliersId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'product_name',
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                InkWell(
                  onTap: () async {
                    await context.read<ProductProvider>().pickImage();
                  },
                  child: Container(
                    height: 300,
                    width: 300,
                    padding: const EdgeInsets.all(16),
                    child: context.watch<ProductProvider>().imageFile == null
                        ? const Icon(Icons.add_a_photo)
                        : kIsWeb
                            ? Image.network(context
                                .watch<ProductProvider>()
                                .imageFile!
                                .path)
                            : Image.file(File(context
                                .watch<ProductProvider>()
                                .imageFile!
                                .path)),
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
                                            .name)
                                        /* Text(context
                                        .watch<SupplierProvider>()
                                        .suppliers
                                        .firstWhere((element) =>
                                            element.id ==
                                            productProvider.suppliersId[i]
                                                ['supplierId'])
                                        .name),*/
                                        )
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Supplier ${i + 1}',
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
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
                                  enabled: false,
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
                                /*selectedItemBuilder: (
                                context,
                              ) {
                                return context
                                    .watch<SupplierProvider>()
                                    .suppliers
                                    .where((element) => context
                                        .read<ProductProvider>()
                                        .suppliersId
                                        .contains(element.id))
                                    .map((e) => Text(
                                          'test',
                                          style: TextStyle(color: Colors.black),
                                        ))
                                    .toList();
                              },*/
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
                        if (context
                                .watch<ProductProvider>()
                                .suppliersId
                                .length <
                            context.watch<SupplierProvider>().suppliers.length -
                                1)
                          MaterialButton(
                            color: Theme.of(context).colorScheme.secondary,
                            onPressed: () {
                              // Validate and save the form values
                              List<Map<String, dynamic>> list =
                                  context.read<ProductProvider>().suppliersId;

                              print(list);
                              debugPrint(_formKey.currentState?.instantValue
                                  .toString());
                              String? supplierId = _formKey
                                  .currentState?.instantValue['supplier'];
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

                MaterialButton(
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    // Validate and save the form values
                    if (_formKey.currentState!.saveAndValidate()) {
                      debugPrint(_formKey.currentState?.value.toString());
                      if (context.read<ProductProvider>().imageFile == null) {
                        Get.snackbar(
                          "Error",
                          "Please select an image",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                        );
                        return;
                      } else {
                        List<Map<String, dynamic>> list =
                            context.read<ProductProvider>().suppliersId;
                        String? supplierId =
                            _formKey.currentState?.instantValue['supplier'];
                        String? price =
                            _formKey.currentState?.instantValue['price'];
                        list.add({
                          "supplierId": supplierId,
                          "price": double.parse(price!),
                        });
                        context
                            .read<ProductProvider>()
                            .createProduct(
                                _formKey.currentState?.value['product_name'],
                                '',
                                list,
                                context.read<AuthenticationProvider>().user)
                            .then(
                              (value) => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SuccessScreen(
                                          productId: value!,
                                        )),
                              ),
                            );
                      }
                      /* context
                        .read<ProductProvider>()
                        .createProduct(
                            _formKey.currentState?.value['product_name'],
                            '',
                            context.read<AuthenticationProvider>().user)
                        .then((value) => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SuccessScreen(
                                        productId: value!,
                                      )),
                            ));*/
                    }
                  },
                  child: context.watch<ProductProvider>().isLoading
                      ? Container(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ))
                      : const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
