import 'package:api_client/persistence/persistence_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should store', () async {
    WidgetsFlutterBinding.ensureInitialized();
    //The old package is deprecated so we had to write it ourselves 
    TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
        ?.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
    (MethodCall methodCall) async {
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
    WidgetsFlutterBinding.ensureInitialized();

    //The old package is deprecated so we had to write it ourselves
    TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
        ?.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
            (MethodCall methodCall) async {
          if (methodCall.method == 'getAll') {
            return <String, dynamic>{}; // set initial values here if desired
          }

          if (methodCall.method == 'setString') {
            // pass here
            return null;
          }
          fail('Should call setString');
        });

    await PersistenceClient().get('token');
  });
}
