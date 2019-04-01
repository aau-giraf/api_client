import 'package:api_client/http/http.dart';
import 'package:api_client/models/enums/error_key.dart';

/// Represents an exception from an API call
class ApiException implements Exception {
  /// Create an API exception, when f.x success was false, and errorKey was set
  ApiException(this.response) {
    errorKey = ErrorKey.values.firstWhere(
        (ErrorKey f) => f.toString() == 'ErrorKey.' + response.json['errorKey'],
        orElse: () => null);

    if (response.json['errorProperties'] is List) {
      errorProperties =
          List<String>.from(response.json['errorProperties']).toList();
    } else {
      // TODO(TobiasPalludan): Throw appropriate error.
    }
  }

  /// Response involved in the exception
  final Response response;

  /// The error key derived from the response
  ErrorKey errorKey = ErrorKey.NoError;

  /// List of the errors involved in the call
  List<String> errorProperties = <String>[];

  @override
  String toString() => '[ApiException]: ${response.json['errorKey']}';
}
