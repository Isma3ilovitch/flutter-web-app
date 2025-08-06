import 'dart:core';

class DataParser {
  static Map<String, dynamic> parseInvoiceData(String text) {
    final Map<String, dynamic> result = {};
    
    // Extract product name
    final productPattern = RegExp(
      r'(?:Product|Item|Description)[:\s]+(.*?)(?:\n|$)',
      caseSensitive: false,
    );
    final productMatch = productPattern.firstMatch(text);
    if (productMatch != null) {
      result['product'] = productMatch.group(1)?.trim() ?? '';
    }
    
    // Extract purchase date
    final datePattern = RegExp(
      r'(?:Date|Purchase|Invoice Date)[:\s]+(\d{1,2}[/-]\d{1,2}[/-]\d{4})',
      caseSensitive: false,
    );
    final dateMatch = datePattern.firstMatch(text);
    if (dateMatch != null) {
      result['date'] = dateMatch.group(1)?.trim() ?? '';
    }
    
    // Extract warranty period
    final warrantyPattern = RegExp(
      r'(?:Warranty|Guarantee)[:\s]+(\d+)\s*(years?|months?)',
      caseSensitive: false,
    );
    final warrantyMatch = warrantyPattern.firstMatch(text);
    if (warrantyMatch != null) {
      final value = int.parse(warrantyMatch.group(1)!);
      final unit = warrantyMatch.group(2)!.toLowerCase();
      result['warranty'] = unit.startsWith('year') ? value * 12 : value;
    }
    
    // Extract store name
    final storePattern = RegExp(
      r'(?:Store|Merchant|Retailer)[:\s]+(.*?)(?:\n|$)',
      caseSensitive: false,
    );
    final storeMatch = storePattern.firstMatch(text);
    if (storeMatch != null) {
      result['store'] = storeMatch.group(1)?.trim() ?? '';
    }
    
    return result;
  }
}
