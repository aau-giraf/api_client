import 'dart:async';

import 'package:api_client/api/status_api.dart';
import 'package:connectivity/connectivity.dart';

class ConnectivityApi {
  /// Default constructor
  ConnectivityApi(this._status) : _connectivity = Connectivity();
  /// Constructor with custom connectivity object
  ConnectivityApi.withConnectivity(this._status, this._connectivity);

  final StatusApi _status;
  final Connectivity _connectivity;
  final Duration _successConnectivityDuration = const Duration(seconds: 10);
  final Duration _failureConnectivityDuration = const Duration(seconds: 5);
  final StreamController<bool> _hasConnection = StreamController<bool>();

  Stream<bool> get connectivityStream => _hasConnection.stream;
  bool _lastStatus = true;
  DateTime _timeOfLastCheck = DateTime(0);

  Future<bool> check() async {
    final Duration diff = DateTime.now().difference(_timeOfLastCheck);
    if (_lastStatus && diff < _successConnectivityDuration ||
        !_lastStatus && diff < _failureConnectivityDuration) {
      return _lastStatus;
    }

    if (await _connectivity.checkConnectivity() == ConnectivityResult.none) {
      _updateCheckValues(false);
      return false;
    }

    final Completer<bool> completer = Completer<bool>();
    _status.status().listen((bool status) {
      _updateCheckValues(status);
      completer.complete(status);
    }).onError((Object error) {
      _updateCheckValues(false);
      completer.complete(false);
    });
    Future.wait(<Future<bool>>[completer.future]);
    return completer.future;
  }

  void _updateCheckValues(bool value) {
    if (_lastStatus != (_lastStatus = value)) {
      _hasConnection.add(value);
    }
    _timeOfLastCheck = DateTime.now();
  }
}