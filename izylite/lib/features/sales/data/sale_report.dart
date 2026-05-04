class SalesReportResponse {
  final int totalLinesMatched;
  final double totalRevenue;
  final List<ReportItem> report;

  SalesReportResponse({
    required this.totalLinesMatched,
    required this.totalRevenue,
    required this.report,
  });

  factory SalesReportResponse.fromJson(Map<String, dynamic> json) {
    return SalesReportResponse(
      totalLinesMatched: json['totalLinesMatched'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      report: (json['report'] as List<dynamic>?)
          ?.map((item) => ReportItem.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class ReportItem {
  final String invoiceLineId;
  final String invoiceId;
  final DateTime? date;
  final String productId;
  final String productName;
  final int quantity;
  final double lineTotal;
  final List<String> barcodes;

  ReportItem({
    required this.invoiceLineId,
    required this.invoiceId,
    this.date,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.lineTotal,
    required this.barcodes,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      invoiceLineId: json['invoiceLineId'] ?? '',
      invoiceId: json['invoiceId'] ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      lineTotal: (json['lineTotal'] ?? 0).toDouble(),
      barcodes: (json['barcodes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}