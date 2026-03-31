import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_log.dart';

class ApiServices {
  final String baseUrl;
  final http.Client _httpClient;

  ApiServices({required this.baseUrl, http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final Map<String, String> _defaultHeader = {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  Future<dynamic> get(String endpoints, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoints');
    AppLog.request(endpoints, method: 'GET');
    final response = await _httpClient.get(url, headers: {..._defaultHeader, ...?headers});
    return _handleResponse(response, url, endpoints);
  }

  Future<dynamic> post(String endpoints, {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoints');
    AppLog.request(endpoints, method: 'POST', body: body);
    final encodedBody = body != null ? jsonEncode(body) : null;
    final response = await _httpClient.post(url, headers: {..._defaultHeader, ...?headers}, body: encodedBody);
    return _handleResponse(response, url, endpoints);
  }

  Future<dynamic> delete(String endpoints, {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoints');
    AppLog.request(endpoints, method: 'DELETE', body: body);
    final encodedBody = body != null ? jsonEncode(body) : null;
    final response = await _httpClient.delete(url, headers: {..._defaultHeader, ...?headers}, body: encodedBody);
    return _handleResponse(response, url, endpoints);
  }

  Future<dynamic> patch(String endpoints, {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoints');
    AppLog.request(endpoints, method: 'PATCH', body: body);
    final encodedBody = body != null ? jsonEncode(body) : null;
    final response = await _httpClient.patch(url, headers: {..._defaultHeader, ...?headers}, body: encodedBody);
    return _handleResponse(response, url, endpoints);
  }

  Future<dynamic> postFormData(String endpoints, {Map<String, String>? headers, required Map<String, String> fields}) async {
    final url = Uri.parse('$baseUrl$endpoints');
    AppLog.request(endpoints, method: 'POST [form-data]', body: fields);
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({'Accept': 'application/json', ...?headers});
    request.fields.addAll(fields);
    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response, url, endpoints);
  }

  dynamic _handleResponse(http.Response response, Uri url, String endpoint) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
      AppLog.response(endpoint, decoded);
      return decoded;
    }
    AppLog.error(endpoint, response.body, statusCode: response.statusCode);
    throw HttpException(
      message: "Request failed",
      statusCode: response.statusCode,
      uri: url,
      body: response.body,
    );
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  final Uri uri;
  final String? body;

  HttpException({
    required this.message,
    required this.statusCode,
    required this.uri,
    this.body,
  });

  @override
  String toString() =>
      "HttpException(status code: $statusCode, uri: $uri, message: $message, body: $body)";
}