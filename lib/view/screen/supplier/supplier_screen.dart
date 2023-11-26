import 'package:compare_prices/helper/date_helper.dart';
import 'package:compare_prices/provider/auth_provider.dart';
import 'package:compare_prices/view/screen/supplier/add_supplier/add_supplier_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/supplier_provider.dart';
import '../home/home_screen.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      context
          .read<SupplierProvider>()
          .getSuppliers(context.read<AuthenticationProvider>().user!);
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
          title: const Text('My Supplier'),
        ),
        body: Consumer<SupplierProvider>(
          builder: (context, watch, child) {
            final supplierList = context.watch<SupplierProvider>().suppliers;
            print(supplierList);
            if (supplierList.isEmpty) {
              return const Center(
                child: Text("No Supplier"),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: supplierList.length,
                itemBuilder: (context, index) {
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
                              supplierList[index].photoUrl,
                              height: 80.0,
                              width: 80.0,
                              fit: BoxFit.cover,
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
                                    supplierList[index].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        ?.copyWith(fontSize: 24),
                                  ),
                                  Spacer(),
                                  Text(
                                    supplierList[index].createdAt.isBefore(
                                            supplierList[index].createdAt)
                                        ? "Created at: ${DateHelper.getFormattedDate(supplierList[index].createdAt)}"
                                        : "Updated at: ${DateHelper.getFormattedDate(supplierList[index].updatedAt)}",
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
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddSupplierScreen()),
            );
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ));
  }
}
