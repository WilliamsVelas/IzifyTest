import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../storage/token.dart';
import 'server_response.dart';

class ApiProvider {
  final TokenStorage _tokenStorage = TokenStorage();

  static const String _baseUrl = 'http://192.168.0.2:3000';

  static const Map<String, String> _baseHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _getHeaders({bool skipAuth = false}) async {
    final headers = {..._baseHeaders};

    if (!skipAuth) {
      final token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  ServerResponse _formatResponse(http.Response resp, String method, Uri uri) {
    if (kDebugMode) {
      print("✅ [$method] RESPONSE [${resp.statusCode}] $uri");
      print("📦 BODY: ${resp.body}");
    }

    try {
      final String responseBodyString = utf8.decode(resp.bodyBytes);
      final dynamic jsonResponse = jsonDecode(responseBodyString);
      return ServerResponse.fromJson(jsonResponse);
    } catch (e) {
      return ServerResponse.formatException(e);
    }
  }

  Future<ServerResponse> get(
      String endpoint, {
        Map<String, dynamic>? queryParams,
        bool skipAuth = false,
      }) async {
    try {
      Uri uri = Uri.parse('$_baseUrl$endpoint');

      if (queryParams != null && queryParams.isNotEmpty) {
        final stringQuery = queryParams.map((k, v) => MapEntry(k, v.toString()));
        uri = uri.replace(queryParameters: stringQuery);
      }

      final headers = await _getHeaders(skipAuth: skipAuth);

      if (kDebugMode) print("🚀 [GET] REQ: $uri");

      final response = await http.get(uri, headers: headers);

      return _formatResponse(response, 'GET', uri);
    } on SocketException {
      if (kDebugMode) print("❌ [GET] ERROR: Sin conexión al servidor");
      return ServerResponse.connectionError();
    } catch (e) {
      if (kDebugMode) print("❌ [GET] ERROR DESCONOCIDO: $e");
      return ServerResponse.unknownError(e);
    }
  }

  Future<ServerResponse> post(
      String endpoint, {
        required Map<String, dynamic> body,
        bool skipAuth = false,
      }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders(skipAuth: skipAuth);

      if (kDebugMode) print("🚀 [POST] REQ: $uri \nPAYLOAD: $body");

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      return _formatResponse(response, 'POST', uri);
    } on SocketException {
      if (kDebugMode) print("❌ [POST] ERROR: Sin conexión al servidor");
      return ServerResponse.connectionError();
    } catch (e) {
      if (kDebugMode) print("❌ [POST] ERROR DESCONOCIDO: $e");
      return ServerResponse.unknownError(e);
    }
  }

  Future<ServerResponse> put(
      String endpoint, {
        required Map<String, dynamic> body,
        bool skipAuth = false,
      }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders(skipAuth: skipAuth);

      if (kDebugMode) print("🚀 [PUT] REQ: $uri \nPAYLOAD: $body");

      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      return _formatResponse(response, 'PUT', uri);
    } on SocketException {
      if (kDebugMode) print("❌ [PUT] ERROR: Sin conexión");
      return ServerResponse.connectionError();
    } catch (e) {
      if (kDebugMode) print("❌ [PUT] ERROR DESCONOCIDO: $e");
      return ServerResponse.unknownError(e);
    }
  }

  Future<ServerResponse> delete(
      String endpoint, {
        bool skipAuth = false,
      }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders(skipAuth: skipAuth);

      if (kDebugMode) print("🚀 [DELETE] REQ: $uri");

      final response = await http.delete(uri, headers: headers);

      return _formatResponse(response, 'DELETE', uri);
    } on SocketException {
      if (kDebugMode) print("❌ [DELETE] ERROR: Sin conexión");
      return ServerResponse.connectionError();
    } catch (e) {
      if (kDebugMode) print("❌ [DELETE] ERROR DESCONOCIDO: $e");
      return ServerResponse.unknownError(e);
    }
  }
}