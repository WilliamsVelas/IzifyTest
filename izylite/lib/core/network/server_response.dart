class ServerResponse {
  final int statusCode;
  final String statusText;
  final String messageCode;
  final dynamic data;
  final String errorDetails;

  ServerResponse({
    required this.statusCode,
    required this.statusText,
    required this.messageCode,
    this.data,
    this.errorDetails = '',
  });

  bool get isSuccess =>
      statusCode >= 200 && statusCode < 300 && statusText == 'success';

  factory ServerResponse.fromJson(Map<String, dynamic> json) {
    return ServerResponse(
      statusCode: json['code'] as int? ?? 500,
      statusText: json['message'] as String? ?? 'failed',
      messageCode: json['messagecode'] as String? ?? 'UNKNOWN_CODE',
      data: json['data'],
      errorDetails: json['error']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': statusCode,
      'message': statusText,
      'messagecode': messageCode,
      'data': data,
      'error': errorDetails,
    };
  }

  static ServerResponse connectionError() {
    return ServerResponse(
      statusCode: 503,
      statusText: "failed",
      messageCode: "CONNECTION_ERROR",
      errorDetails:
          "No se pudo conectar con el servidor. Verifica tu conexión a internet.",
      data: null,
    );
  }

  static ServerResponse formatException(dynamic e) {
    return ServerResponse(
      statusCode: 400,
      statusText: "failed",
      messageCode: "PARSE_ERROR",
      errorDetails:
          "Error procesando la respuesta del servidor: ${e.toString()}",
      data: null,
    );
  }

  static ServerResponse unknownError(dynamic e) {
    return ServerResponse(
      statusCode: 500,
      statusText: "failed",
      messageCode: "UNKNOWN_CLIENT_ERROR",
      errorDetails: e.toString(),
      data: null,
    );
  }

  @override
  String toString() {
    return 'ServerResponse(statusCode: $statusCode, statusText: $statusText, messageCode: $messageCode, data: $data, errorDetails: $errorDetails)';
  }
}
