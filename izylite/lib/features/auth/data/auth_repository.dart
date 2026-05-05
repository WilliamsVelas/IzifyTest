import 'dart:developer';

import 'package:izylite/core/network/enpoints.dart';

import '../../../core/network/server_provider.dart';
import '../../../core/storage/token.dart';

class AuthRepository {
  final ApiProvider _api = ApiProvider();
  final TokenStorage _storage = TokenStorage();

  Future<String?> login(String username, String password) async {
    log('🔑 Iniciando login para: $username');

    final response = await _api.post(
      ServerEndpoints.login,
      body: {'username': username, 'password': password},
      skipAuth: true,
    );

    if (response.isSuccess) {
      final Map<String, dynamic> responseData = response.data is Map
          ? response.data
          : {};

      final String? token =
          responseData['token'] ?? responseData['data']?['token'];
      final String? username =
          responseData['user']?['username'] ??
          responseData['data']?['user']?['username'];

      if (token != null && token.isNotEmpty) {
        await _storage.saveToken(token);
        if (username != null) {
          await _storage.saveUsername(username);
        }

        return null;
      } else {
        return 'Error de servidor: No se recibió un token válido.';
      }
    } else {
      log('❌ Falló el login: ${response.errorDetails}');
      return response.errorDetails.isNotEmpty
          ? response.errorDetails
          : 'Error desconocido al iniciar sesión';
    }
  }
}
