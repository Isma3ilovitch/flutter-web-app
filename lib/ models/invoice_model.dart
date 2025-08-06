import 'package:hive/hive.dart';

part 'invoice_model.g.dart'; // Generated file

@HiveType(typeId: 0)
class Invoice extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  late String productName;
  
  @HiveField(2)
  late DateTime purchaseDate;
  
  @HiveField(3)
  late int warrantyMonths;
  
  @HiveField(4)
  late String storeName;
  
  @HiveField(5)
  late String imagePath;
  
  @HiveField(6)
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
}
