import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

/// Response from HTTP
class Response {
  /// Default constructor
  Response(this.response, this.json);

  /// The HTTP response from the client
  final http.Response response;

  /// Parsed JSON response
  final Map<String, dynamic> json;

  /// HTTP StatusCode
  int statusCode() => response.statusCode;

  /// Check if response is a successful one, or errorneous one
  bool success() => response.statusCode < 300;
}

/// Http interface
abstract class Http {
  /// Makes an GET request to the specified [url]
  Stream<Response> get(String url);

  /// Makes an DELETE request to the specified [url]
  Stream<Response> delete(String url);

  /// Makes an POST request to the specified [url], with the given [body]
  Stream<Response> post(String url, [dynamic body]);

  /// Makes an PUT request to the specified [url], with the given [body]
  Stream<Response> put(String url, [dynamic body]);

  /// Makes an PATCH request to the specified [url], with the given [body]
  Stream<Response> patch(String url, [dynamic body]);
}
