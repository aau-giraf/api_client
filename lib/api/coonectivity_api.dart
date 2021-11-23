import 'dart:async';

import 'package:api_client/api/status_api.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';

class ConnectivityApi {
  /// Default constructor
  ConnectivityApi(this.status);

  final StatusApi status;
  DateTime _timeSinceLastCheck = new DateTime(0);
  bool _lastStatus = null;
  final _checkSuccessConnectivityDuration = new Duration(seconds: 10);
  static StreamController<bool> controller = StreamController<bool>.broadcast();


  Future<bool> check() async {
    if (_lastStatus != null && _timeSinceLastCheck
        .difference(DateTime.now()) < _checkSuccessConnectivityDuration) {
      return _lastStatus;
    }

    final ConnectivityResult connectivity = await Connectivity()
        .checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      _lastStatus = false;
      controller.add(_lastStatus);
      return false;
    }

    final Completer<bool> completer = Completer<bool>();
    status.status().listen((bool status) {
      _lastStatus = true;
      completer.complete(status);
      controller.add(_lastStatus);
    }).onError((Object error){
      _lastStatus = false;
      completer.complete(false);
    });
    Future.wait(<Future<bool>>[completer.future]);
    return completer.future;
  }

}