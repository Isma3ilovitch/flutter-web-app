import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice_model.dart';

class StorageService {
  static const String _invoicesKey = 'invoices_list';

  // Save the entire list of invoices
  static Future<void> saveInvoices(List<Invoice> invoices) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert list of objects to list of JSON strings
    List<String> jsonList = invoices.map((invoice) => jsonEncode(invoice.toJson())).toList();
    await prefs.setStringList(_invoicesKey, jsonList);
  }

  // Load the entire list of invoices
  static Future<List<Invoice>> loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_invoicesKey);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    // Convert list of JSON strings back to list of objects
    return jsonList.map((jsonString) => Invoice.fromJson(jsonDecode(jsonString))).toList();
  }

  // Add a single new invoice to the list
  static Future<void> addInvoice(Invoice newInvoice) async {
    final invoices = await loadInvoices();
    invoices.add(newInvoice);
    await saveInvoices(invoices);
  }

  // Delete an invoice by its ID
  static Future<void> deleteInvoice(String id) async {
    final invoices = await loadInvoices();
    invoices.removeWhere((invoice) => invoice.id == id);
    await saveInvoices(invoices);
  }
}
