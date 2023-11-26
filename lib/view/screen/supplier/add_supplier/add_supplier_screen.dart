import 'dart:io';

import 'package:compare_prices/provider/supplier_provider.dart';
import 'package:compare_prices/view/screen/supplier/add_supplier/succes_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../../../provider/auth_provider.dart';

class AddSupplierScreen extends StatelessWidget {
  AddSupplierScreen({super.key});

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Supplier'),
      ),
      body: FormBuilder(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'supplier_name',
                decoration: const InputDecoration(labelText: 'Supplier Name'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              InkWell(
                onTap: () async {
                  await context.read<SupplierProvider>().pickImage();
                },
                child: Container(
                  height: 300,
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  child: context.watch<SupplierProvider>().imageFile == null
                      ? const Icon(Icons.add_a_photo)
                      : kIsWeb
                          ? Image.network(
                              context.watch<SupplierProvider>().imageFile!.path)
                          : Image.file(File(context
                              .watch<SupplierProvider>()
                              .imageFile!
                              .path)),
                ),
              ),
              const SizedBox(height: 10),
              MaterialButton(
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  // Validate and save the form values
                  if (_formKey.currentState!.saveAndValidate()) {
                    debugPrint(_formKey.currentState?.value.toString());
                    context
                        .read<SupplierProvider>()
                        .createSupplier(
                            _formKey.currentState?.value['supplier_name'],
                            '',
                            context.read<AuthenticationProvider>().user)
                        .then((value) => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SuccessScreen(
                                        supplierId: value!,
                                      )),
                            ));
                    /* Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SuccessScreen(
                                supplierName: _formKey
                                    .currentState?.value['supplier_name'],
                              )),
                    );*/
                  }
                },
                child: context.watch<SupplierProvider>().isLoading
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
    );
  }
}
