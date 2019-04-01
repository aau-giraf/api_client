import 'package:api_client/persistence/persistence_client.dart';
import 'package:flutter/services.dart';
import 'package:test_api/test_api.dart';

void main() {
  test('Should store', () async {
    const MethodChannel('plugins.flutter.io/shared_preferences')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{}; // set initial values here if desired
      }

      if (methodCall.method == 'setString') {
        // pass here
        return null;
      }
      fail('Should call setString');
    });

    const String token = 'Test Token';
    await PersistenceClient().set('token', token);
  });

  test('Should get token', () async {
    const MethodChannel('plugins.flutter.io/shared_preferences')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{}; // set initial values here if desired
      }

      if (methodCall.method == 'getString') {
        // pass here
        return null;
      }
      fail('Should call setString');
    });

    await PersistenceClient().get('token');
  });
}
