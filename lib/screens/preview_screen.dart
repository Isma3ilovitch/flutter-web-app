import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../utils/constants.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> extractedData;

  const PreviewScreen({
    super.key,
    required this.imagePath,
    required this.extractedData,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late final TextEditingController _productController;
  late final TextEditingController _dateController;
  late final TextEditingController _warrantyController;
  late final TextEditingController _storeController;
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController(
      text: widget.extractedData['product'] ?? '',
    );
    _dateController = TextEditingController(
      text: widget.extractedData['date'] ?? '',
    );
    _warrantyController = TextEditingController(
      text: widget.extractedData['warranty']?.toString() ?? '',
    );
    _storeController = TextEditingController(
      text: widget.extractedData['store'] ?? '',
    );
    
    // Try to parse the date
    if (widget.extractedData['date'] != null) {
      try {
        _selectedDate = DateFormat('dd/MM/yyyy').parse(widget.extractedData['date']);
      } catch (e) {
        _selectedDate = null;
      }
    }
  }

  @override
  void dispose() {
    _productController.dispose();
    _dateController.dispose();
    _warrantyController.dispose();
    _storeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _saveInvoice() {
    if (_formKey.currentState!.validate()) {
      final invoice = Invoice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: _productController.text,
        purchaseDate: _selectedDate ?? DateTime.now(),
        warrantyMonths: int.tryParse(_warrantyController.text) ?? 12,
        storeName: _storeController.text,
        imagePath: widget.imagePath,
        createdAt: DateTime.now(),
      );

      final box = Hive.box<Invoice>('invoices');
      box.add(invoice);

      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveInvoice,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invoice image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(widget.imagePath),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              
              // Product name
              TextFormField(
                controller: _productController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Purchase date
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Purchase Date',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select purchase date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Warranty period
              TextFormField(
                controller: _warrantyController,
                decoration: const InputDecoration(
                  labelText: 'Warranty (months)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter warranty period';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Store name
              TextFormField(
                controller: _storeController,
                decoration: const InputDecoration(
                  labelText: 'Store Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter store name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveInvoice,
                  child: const Text('Save Invoice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
