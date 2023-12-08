import 'package:compare_prices/data/model/product_model.dart';
import 'package:compare_prices/data/model/supplier_model.dart';

class InitDataModel {
  final List<SupplierModel?> suppliers;
  final List<ProductModel?> products;

  InitDataModel({
    required this.suppliers,
    required this.products,
  });

  factory InitDataModel.fromJson(Map<String, dynamic> json) => InitDataModel(
        suppliers: List<SupplierModel?>.from(json["suppliers"].map((x) => SupplierModel.fromJson(x))),
        products: List<ProductModel?>.from(json["products"].map((x) => ProductModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "suppliers": List<dynamic>.from(suppliers.map((x) => x!.toJson())),
        "products": List<dynamic>.from(products.map((x) => x!.toJson())),
      };

  @override
  String toString() {
    return 'InitDataModel(suppliers: $suppliers, products: $products)';
  }
}
