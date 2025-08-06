import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../utils/constants.dart';

class DetailsScreen extends StatelessWidget {
  final Invoice invoice;

  const DetailsScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final expiryDate = invoice.purchaseDate.add(
      Duration(days: invoice.warrantyMonths * 30),
    );
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    final isExpired = daysLeft < 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(invoice.imagePath),
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            
            // Product name
            _buildDetailCard(
              title: 'Product',
              value: invoice.productName,
              icon: Icons.shopping_bag,
            ),
            const SizedBox(height: 16),
            
            // Purchase date
            _buildDetailCard(
              title: 'Purchase Date',
              value: DateFormat('dd MMM yyyy').format(invoice.purchaseDate),
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            
            // Warranty period
            _buildDetailCard(
              title: 'Warranty Period',
              value: '${invoice.warrantyMonths} months',
              icon: Icons.access_time,
            ),
            const SizedBox(height: 16),
            
            // Store name
            _buildDetailCard(
              title: 'Store',
              value: invoice.storeName,
              icon: Icons.store,
            ),
            const SizedBox(height: 16),
            
            // Expiry date
            _buildDetailCard(
              title: 'Expiry Date',
              value: DateFormat('dd MMM yyyy').format(expiryDate),
              icon: Icons.event,
              valueColor: isExpired ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 16),
            
            // Days left
            _buildDetailCard(
              title: 'Warranty Status',
              value: isExpired
                  ? 'Expired ${daysLeft.abs()} days ago'
                  : '$daysLeft days remaining',
              icon: isExpired ? Icons.error : Icons.check_circle,
              valueColor: isExpired ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String value,
    required IconData icon,
    Color valueColor = Colors.black,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              invoice.delete();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
