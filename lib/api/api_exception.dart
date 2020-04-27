import 'package:api_client/http/http.dart';
import 'package:api_client/models/enums/error_key.dart';

/// Represents an exception from an API call
class ApiException implements Exception {
  /// Create an API exception, when f.x success was false, and errorKey was set
  ApiException(this.response) {
    errorKey = ErrorKey.values.firstWhere(
        (ErrorKey f) => f.toString() == 'ErrorKey.' + response.json['errorKey'],
        orElse: () => null);

    if (response.json['message']) {
      errorMessage = response.json['message'].toString();
    } else {
      errorMessage = 'Something went wrong.';
    }
    
    if (response.json['details']) {
      errorDetails = response.json['details'];
    } else {
      errorDetails = '';
    }
  }

  /// Response involved in the exception
  final Response response;

  /// The error key derived from the response
  ErrorKey errorKey = ErrorKey.NoError;

  /// List of the errors involved in the call
  String errorMessage;

  /// The details of the error that happened, most of the time it is empty
  String errorDetails;

  @override
  String toString() => '[ApiException]: ${response.json['errorKey']}';
}
