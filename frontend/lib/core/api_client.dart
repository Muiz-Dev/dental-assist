import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );
}

class ApiClient {
  final http.Client client;

  ApiClient({http.Client? client}) : this.client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String path) async {
    final response = await client.get(Uri.parse('${ApiConfig.baseUrl}$path'));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('GET $path failed with status ${response.statusCode}: ${response.body}');
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('POST $path failed with status ${response.statusCode}: ${response.body}');
  }
}
