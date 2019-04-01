import 'package:api_client/models/enums/error_key.dart';

/// Response from Http
class ResponseModel<T> {
  /// Default constructor
  ResponseModel({this.data, this.success, this.errorKey, this.errorProperties});

  /// Construct from JSON
  ResponseModel.fromJson(Map<String, dynamic> json, this.data) {
    if (json == null) {
      throw const FormatException(
          '[ResponseModel]: Cannot instantiate from null');
    }

    success = json['success'];
    errorKey = ErrorKey.values.firstWhere(
            (ErrorKey f) => f.toString() == json['errorKey'],
        orElse: () => null);
    if (json['errorProperties'] is List) {
      errorProperties = List<String>.from(json['errorProperties']).toList();
    } else {
      // TODO(TobiasPalludan): Throw appropriate error.
    }

  }

  /// The data in the response
  T data;

  /// Whether or not the call was successful
  bool success;

  /// Which error occurred
  ErrorKey errorKey;

  /// List of the errors involved in the call
  List<String> errorProperties;
}
