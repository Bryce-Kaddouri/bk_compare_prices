import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierModel {
  String id;
  String name;
  String photoUrl;
  DateTime createdAt;
  DateTime updatedAt;

  SupplierModel({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    print("SupplierModel.fromJson");
    print(json);
    Timestamp createdAt = json["createdAt"];
    Timestamp updatedAt = json["updatedAt"];
    DateTime createdAtDate = createdAt.toDate();
    DateTime updatedAtDate = updatedAt.toDate();
    return SupplierModel(
      id: json["id"],
      name: json["name"],
      photoUrl: json["photoUrl"],
      createdAt: createdAtDate,
      updatedAt: updatedAtDate,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "photoUrl": photoUrl,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
