import '../../../core/network/server_provider.dart';
import '../../../core/storage/token.dart';

class AuthRepository {
  final ApiProvider _api = ApiProvider();
  final TokenStorage _storage = TokenStorage();

  Future<String?> login(String username, String password) async {
    final response = await _api.post(
      '/auth/login',
      body: {'username': username, 'password': password},
      skipAuth: true,
    );

    if (response.isSuccess) {
      final token = response.data['token'];
      await _storage.saveToken(token);
      return null;
    } else {
      return response.errorDetails.isNotEmpty
          ? response.errorDetails
          : 'Error desconocido al iniciar sesión';
    }
  }
}
