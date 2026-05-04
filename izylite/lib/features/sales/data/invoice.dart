import 'invoice_lines.dart';

class Invoice {
  final String id;
  final String invoiceNumber;
  final String clientName;
  final double totalAmount;
  final DateTime date;
  final List<InvoiceLine> lines;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientName,
    required this.totalAmount,
    required this.date,
    required this.lines,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawLines = json['lines'] ?? [];
    final linesList = rawLines.map((lineJson) => InvoiceLine.fromJson(lineJson)).toList();

    return Invoice(
      id: json['_id']?.toString() ?? '',
      invoiceNumber: json['invoice_number']?.toString() ?? 'S/N',
      clientName: json['client_name']?.toString() ?? 'Cliente General',
      totalAmount: (json['total_amount'] as num? ?? json['total'] as num? ?? 0).toDouble(),
      date: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lines: linesList,
    );
  }
}
