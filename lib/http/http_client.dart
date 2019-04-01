import 'dart:convert';

import 'package:api_client/http/http.dart';
import 'package:api_client/persistence/persistence.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

/// Default implementation of Http
class HttpClient implements Http {
  /// Default constructor
  HttpClient(this.baseUrl, this._persist, [this._tokenKey = 'token']);

  Future<Map<String, String>> get _headers async {
    final Map<String, String> headers = <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    final String token = await _persist.get(_tokenKey);

    if (token != null) {
      headers['Authorization'] = 'Bearer ' + token;
    }

    return headers;
  }

  /// The base of all requests.
  ///
  /// Example: if set to `http://google.com`, then a get request with url
  /// `/search` will resolve to `http://google.com/search`
  final String baseUrl;
  final Persistence _persist;

  /// The key for which, in the SharedPreferences, the token is stored
  final String _tokenKey;

  @override
  Observable<Response> get(String url) {
    return Observable<Map<String, String>>.fromFuture(_headers).flatMap(
        (Map<String, String> headers) =>
            _parseJson(http.get(baseUrl + url, headers: headers)));
  }

  @override
  Observable<Response> delete(String url) {
    return Observable<Map<String, String>>.fromFuture(_headers).flatMap(
        (Map<String, String> headers) =>
            _parseJson(http.delete(baseUrl + url, headers: headers)));
  }

  @override
  Observable<Response> post(String url, [Map<String, dynamic> body]) {
    return Observable<Map<String, String>>.fromFuture(_headers).flatMap(
        (Map<String, String> headers) => _parseJson(http.post(baseUrl + url,
            body: jsonEncode(body), headers: headers)));
  }

  @override
  Observable<Response> put(String url, [Map<String, dynamic> body]) {
    return Observable<Map<String, String>>.fromFuture(_headers).flatMap(
        (Map<String, String> headers) => _parseJson(
            http.put(baseUrl + url, body: jsonEncode(body), headers: headers)));
  }

  @override
  Observable<Response> patch(String url, [Map<String, dynamic> body]) {
    return Observable<Map<String, String>>.fromFuture(_headers).flatMap(
        (Map<String, String> headers) => _parseJson(http.patch(baseUrl + url,
            body: jsonEncode(body), headers: headers)));
  }

  Observable<Response> _parseJson(Future<http.Response> res) {
    return Observable<http.Response>.fromFuture(res).map((http.Response res) {
      Map<String, dynamic> json;
      // ensure all headers are in lowercase
      final Map<String, String> headers = res.headers.map(
          (String h, String v) => MapEntry<String, String>(h.toLowerCase(), v));

      // only decode json if response says it's json
      if (headers.containsKey('content-type') &&
          headers['content-type'].toLowerCase().contains('application/json')) {
        json = jsonDecode(res.body);
      }

      return Response(res, json);
    });
  }
}
