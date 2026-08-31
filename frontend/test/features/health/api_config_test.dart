import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_app/core/api_client.dart';

void main() {
  test('ApiConfig default base URL is defined correctly', () {
    expect(ApiConfig.baseUrl, equals('http://localhost:8080/api/v1'));
  });
}
