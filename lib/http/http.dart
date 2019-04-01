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
}

/// Http interface
abstract class Http {
  /// Makes an GET request to the specified [url]
  Observable<Response> get(String url);

  /// Makes an DELETE request to the specified [url]
  Observable<Response> delete(String url);

  /// Makes an POST request to the specified [url], with the given [body]
  Observable<Response> post(String url, [Map<String, dynamic> body]);

  /// Makes an PUT request to the specified [url], with the given [body]
  Observable<Response> put(String url, [Map<String, dynamic> body]);

  /// Makes an PATCH request to the specified [url], with the given [body]
  Observable<Response> patch(String url, [Map<String, dynamic> body]);
}
