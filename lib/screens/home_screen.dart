import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../utils/constants.dart';
import 'camera_screen.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Invoice> invoiceBox;

  @override
  void initState() {
    super.initState();
    invoiceBox = Hive.box<Invoice>('invoices');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warranty Keeper'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: invoiceBox.listenable(),
        builder: (context, Box<Invoice> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No invoices yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text('Tap + to add your first invoice'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final invoice = box.getAt(index)!;
              final expiryDate = invoice.purchaseDate.add(
                Duration(days: invoice.warrantyMonths * 30),
              );
              final daysLeft = expiryDate.difference(DateTime.now()).inDays;
              final isExpiring = daysLeft <= 30 && daysLeft >= 0;
              final isExpired = daysLeft < 0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isExpired
                        ? Colors.red
                        : isExpiring
                            ? Colors.orange
                            : Colors.green,
                    child: Icon(
                      Icons.receipt,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    invoice.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(invoice.storeName),
                      const SizedBox(height: 4),
                      Text(
                        isExpired
                            ? 'Expired ${daysLeft.abs()} days ago'
                            : 'Expires in $daysLeft days',
                        style: TextStyle(
                          color: isExpired
                              ? Colors.red
                              : isExpiring
                                  ? Colors.orange
                                  : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(invoice: invoice),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
