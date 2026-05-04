import 'package:izylite/core/network/enpoints.dart';
import 'package:izylite/features/products/data/product.dart';

import '../../../core/network/server_provider.dart';

class ProductsRepository {
  final ApiProvider _api = ApiProvider();

  Future<List<Product>> getProducts({required int page, int limit = 15}) async {
    final response = await _api.get(
      ServerEndpoints.product,
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

      return list.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception(response.errorDetails ?? 'Error al cargar los productos');
    }
  }

  Future<bool> deleteProduct(String id) async {
    final response = await _api.delete('${ServerEndpoints.product}/$id');
    return response.isSuccess;
  }

  Future<bool> disableUnit(String unitId) async {
    final response = await _api.delete('${ServerEndpoints.deleteStock}$unitId');
    return response.isSuccess;
  }

  Future<List<ProductUnit>?> addUnit(String productId, String barcode) async {
    final response = await _api.post(
      '${ServerEndpoints.product}/$productId/stock',
      body: {
        'barcodes': [barcode],
      },
    );

    if (response.isSuccess) {
      final Map<String, dynamic> responseData = response.data is Map ? response.data : {};

      final List<dynamic> newUnitsRaw = responseData['newUnits'] ?? responseData['data']?['newUnits'] ?? [];

      return newUnitsRaw.map((u) => ProductUnit.fromJson(u)).toList();
    } else {
      throw Exception(response.errorDetails ?? 'Error al agregar el serial');
    }
  }

  Future<bool> createProduct(Map<String, dynamic> productData) async {
    final response = await _api.post(
      ServerEndpoints.product,
      body: productData,
    );
    return response.isSuccess;
  }

  Future<bool> updateProduct(String productId, Map<String, dynamic> productData) async {
    final response = await _api.put(
      '${ServerEndpoints.product}/$productId',
      body: productData,
    );
    return response.isSuccess;
  }
}