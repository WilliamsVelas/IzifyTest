import 'package:flutter/foundation.dart';
import 'package:izylite/core/network/enpoints.dart';
import 'package:izylite/features/sales/data/sale_report.dart';

import '../../../core/network/server_provider.dart';
import 'invoice.dart';

class SalesRepository {
  final ApiProvider _api = ApiProvider();

  Future<List<Invoice>> getSales({required int page, int limit = 15}) async {
    try {
      final response = await _api.get(
        ServerEndpoints.sell,
        queryParams: {'page': page.toString(), 'limit': limit.toString()},
      );

      if (response.isSuccess) {
        final dynamic rawData = response.data;
        List<dynamic> list;

        if (rawData is Map && rawData.containsKey('data')) {
          list = rawData['data'];
        } else if (rawData is List) {
          list = rawData;
        } else {
          list = [];
        }

        if (kDebugMode) print('✅ Procesando ${list.length} facturas');

        return list.map((json) => Invoice.fromJson(json)).toList();
      } else {
        throw Exception(response.errorDetails ?? 'Error al cargar las ventas');
      }
    } catch (e) {
      if (kDebugMode) print('🔥 Error en getSales: $e');
      rethrow;
    }
  }

  Future<bool> processSale(Map<String, dynamic> saleData) async {
    final response = await _api.post(ServerEndpoints.sell, body: saleData);

    return response.isSuccess;
  }

  Future<SalesReportResponse> getSalesReport({
    String? productId,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, String> queryParams = {};

    if (productId != null) queryParams['productId'] = productId;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _api.get(
      ServerEndpoints.generateReport,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.isSuccess) {
      final rawData = response.data['data'] ?? response.data;
      return SalesReportResponse.fromJson(rawData);
    } else {
      throw Exception(response.errorDetails ?? 'Error al obtener el reporte');
    }
  }
}
