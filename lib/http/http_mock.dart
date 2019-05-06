import 'package:api_client/http/http.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// HTTP Method
// ignore: public_member_api_docs
enum Method { get, post, put, delete, patch }

/// A call to the Http
class Call {
  /// Default constructor
  Call(this.method, this.url, [this.body]) {
    flush = PublishSubject<dynamic>();
  }

  /// Which method was used
  final Method method;

  /// Body of the request
  final dynamic body;

  /// What url was the call made on
  final String url;

  /// Flush results
  PublishSubject<dynamic> flush; // ignore: close_sinks
}

/// Flush results to test
class Flusher {
  /// Default constructor
  Flusher(this._call);

  Call _call;

  /// Flush a body to our listener
  ///
  /// [response] The response to flush
  void flush(dynamic response) {
    _call.flush.add(response);
  }

  /// Send an exception to our listener
  ///
  /// [exception] The exception to send
  void throwError(Exception exception) {
    _call.flush.add(exception);
  }
}

/// Mocking class for HttpClient
class HttpMock implements Http {
  final List<Call> _calls = <Call>[];

  /// Ensure that there are no requests that are not already expected
  void verify() {
    if (_calls.isNotEmpty) {
      throw Exception('Expected no requests, found: \n' +
          _calls.map((Call call) => '[${call.method}] ${call.url}').join('\n'));
    }
  }

  /// Expect a request with the given method and url.
  ///
  /// [method] One of delete, get, patch, post, or put.
  /// [url] The url that is expected
  Flusher expectOne({Method method, @required String url, dynamic body}) {
    final int index = _calls.indexWhere((Call call) =>
        call.url == url &&
        (method == null || method == call.method) &&
        (body == null || body == call.body));

    if (index == -1) {
      throw Exception('Expected [$method] $url, found none');
    }

    final Call call = _calls[index];
    _calls.removeAt(index);
    return Flusher(call);
  }

  /// Ensure that no request with the given method and url is send
  ///
  /// [method] One of delete, get, patch, post, or put.
  /// [url] The url that not expected
  void expectNone({Method method, @required String url}) {
    for (Call call in _calls) {
      if (call.url == url && (method == null || method == call.method)) {
        throw Exception('Found [$method] $url, expected none');
      }
    }
  }

  @override
  Observable<Response> delete(String url, {bool raw = false}) {
    return _reqToRes(Method.delete, url);
  }

  @override
  Observable<Response> get(String url, {bool raw = false}) {
    return _reqToRes(Method.get, url);
  }

  @override
  Observable<Response> patch(String url, [dynamic body]) {
    return _reqToRes(Method.patch, url, body);
  }

  @override
  Observable<Response> post(String url, [dynamic body]) {
    return _reqToRes(Method.post, url, body);
  }

  @override
  Observable<Response> put(String url, [dynamic body]) {
    return _reqToRes(Method.put, url, body);
  }

  Observable<Response> _reqToRes(Method method, String url, [dynamic body]) {
    final Call call = Call(method, url, body);
    _calls.add(call);

    return call.flush.map((dynamic response) {
      if (response is Exception) {
        throw response;
      }

      return Response(null, response);
    });
  }
}
