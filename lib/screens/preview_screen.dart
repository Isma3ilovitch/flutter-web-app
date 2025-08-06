import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html; // To display image
import '../models/invoice_model.dart';
import '../services/storage_service.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath; // Now a Base64 string
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

  void _saveInvoice() async {
    if (_formKey.currentState!.validate()) {
      final invoice = Invoice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: _productController.text,
        purchaseDate: _selectedDate ?? DateTime.now(),
        warrantyMonths: int.tryParse(_warrantyController.text) ?? 12,
        storeName: _storeController.text,
        imagePath: widget.imagePath, // Save Base64 string
        createdAt: DateTime.now(),
      );

      await StorageService.addInvoice(invoice);

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
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
              // Display Base64 image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.imagePath,
                  width: double.infinity,
                  height: 300, // Larger for web
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 100);
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _productController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter product name' : null,
              ),
              const SizedBox(height: 16),
              
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
                validator: (value) => value!.isEmpty ? 'Please select purchase date' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _warrantyController,
                decoration: const InputDecoration(
                  labelText: 'Warranty (months)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter warranty period';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _storeController,
                decoration: const InputDecoration(
                  labelText: 'Store Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter store name' : null,
              ),
              const SizedBox(height: 32),
              
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
