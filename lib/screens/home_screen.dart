import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../services/storage_service.dart';
import 'camera_screen.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Invoice>> _invoicesFuture;

  @override
  void initState() {
    super.initState();
    _refreshInvoices();
  }

  void _refreshInvoices() {
    setState(() {
      _invoicesFuture = StorageService.loadInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warranty Keeper (Web)'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Invoice>>(
        future: _invoicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
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

          final invoices = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
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
                    ).then((_) => _refreshInvoices()); // Refresh on return
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
          ).then((_) => _refreshInvoices()); // Refresh on return
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
