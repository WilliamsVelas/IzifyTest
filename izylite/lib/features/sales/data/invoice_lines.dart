class InvoiceLine {
  final String id;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final List<String> barcodes;

  InvoiceLine({
    required this.id,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.barcodes,
  });

  factory InvoiceLine.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawBarcodes = json['barcodes'] ?? [];
    final barcodesList = rawBarcodes.map((b) => b.toString()).toList();
    final calculatedQuantity = barcodesList.length;

    return InvoiceLine(
      id: json['_id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? 'Producto',
      unitPrice: (json['unitPrice'] as num? ?? 0).toDouble(),
      quantity: calculatedQuantity > 0
          ? calculatedQuantity
          : (json['quantity'] as num? ?? 1).toInt(),
      lineTotal: (json['lineTotal'] as num? ?? 0).toDouble(),
      barcodes: barcodesList,
    );
  }
}
