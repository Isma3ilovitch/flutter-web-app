// No Hive annotations needed for web
class Invoice {
  String id;
  String productName;
  DateTime purchaseDate;
  int warrantyMonths;
  String storeName;
  String imagePath; // This will now be a Base64 string
  DateTime? createdAt;

  Invoice({
    required this.id,
    required this.productName,
    required this.purchaseDate,
    required this.warrantyMonths,
    required this.storeName,
    required this.imagePath,
    this.createdAt,
  });

  // --- SERIALIZATION ---
  // We need methods to convert to/from JSON for shared_preferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'purchaseDate': purchaseDate.millisecondsSinceEpoch,
      'warrantyMonths': warrantyMonths,
      'storeName': storeName,
      'imagePath': imagePath,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      productName: json['productName'],
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(json['purchaseDate']),
      warrantyMonths: json['warrantyMonths'],
      storeName: json['storeName'],
      imagePath: json['imagePath'],
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : null,
    );
  }
}
