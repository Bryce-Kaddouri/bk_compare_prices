import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String id;
  String name;
  String photoUrl;
  DateTime createdAt;
  DateTime updatedAt;
  List<PriceModel> prices;
  List<PriceModelHistory>? pricesHistory = [];

  ProductModel({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.prices,
    this.pricesHistory,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    Timestamp createdAt = json["createdAt"];
    Timestamp updatedAt = json["updatedAt"];
    json["createdAt"] = createdAt.toDate();
    json["updatedAt"] = updatedAt.toDate();
    return ProductModel(
      id: json["id"],
      name: json["name"],
      photoUrl: json["photoUrl"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      prices: List<PriceModel>.from(json["prices"].map((x) => PriceModel.fromJson(x))),
    );
  }

  factory ProductModel.fromDocument(DocumentSnapshot json) => ProductModel(
        id: json.id,
        name: json["name"],
        photoUrl: json["photoUrl"],
        // timestamp to date
        createdAt: DateTime.parse(json["createdAt"].toDate().toString()),
        updatedAt: DateTime.parse(json["updatedAt"].toDate().toString()),
        prices: List<PriceModel>.from(json["prices"].map((x) => PriceModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "photoUrl": photoUrl,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "prices": List<dynamic>.from(prices.map((x) => x.toJson())),
      };

  // method to set PriceHistory
  void setPriceHistory(List<PriceModelHistory> pricesHistory) {
    this.pricesHistory = pricesHistory;
  }
}

class PriceModel {
  String supplierId;
  double price;
  bool isEditing = false;

  PriceModel({
    required this.supplierId,
    required this.price,
    this.isEditing = false,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) => PriceModel(
        supplierId: json["supplierId"],
        price: json["price"],
        isEditing: false,
      );

  // method to set isEditing
  void setIsEditing(bool isEditing) {
    this.isEditing = isEditing;
  }

  Map<String, dynamic> toJson() => {
        "supplierId": supplierId,
        "price": price,
      };
}

class PriceModelHistory {
  String productId;
  String supplierId;
  double price;
  DateTime createdAt;

  PriceModelHistory({
    required this.productId,
    required this.supplierId,
    required this.price,
    required this.createdAt,
  });

  factory PriceModelHistory.fromJson(Map<String, dynamic> json) => PriceModelHistory(
        productId: json["product_id"],
        supplierId: json["supplier_id"],
        price: json["price"],
        createdAt: DateTime.parse(json["created_at"].toDate().toString()),
      );

  /* Map<String, dynamic> toJson() => {
        "supplierId": supplierId,
        "price": price,
        "createdAt": createdAt.toIso8601String(),
      };*/
}
