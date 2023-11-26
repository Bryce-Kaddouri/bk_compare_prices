class ProductModel {
  String id;
  String name;
  String photoUrl;
  DateTime createdAt;
  DateTime updatedAt;
  List<PriceModel> prices;

  ProductModel({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.prices,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json["id"],
        name: json["name"],
        photoUrl: json["photoUrl"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        prices: List<PriceModel>.from(
            json["prices"].map((x) => PriceModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "photoUrl": photoUrl,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "prices": List<dynamic>.from(prices.map((x) => x.toJson())),
      };
}

class PriceModel {
  String supplierId;
  double price;

  PriceModel({
    required this.supplierId,
    required this.price,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) => PriceModel(
        supplierId: json["supplierId"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "supplierId": supplierId,
        "price": price,
      };
}
