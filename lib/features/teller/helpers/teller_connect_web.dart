import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

void launchTellerConnect({
  required String appId,
  required void Function(String enrollmentId, String accessToken) onSuccess,
  String environment = 'development',
  void Function(String message)? onError,
}) {
  final JSAny tellerConnectValue = web.window['TellerConnect'];
  if (tellerConnectValue.isUndefinedOrNull ||
      !tellerConnectValue.isA<JSObject>()) {
    throw StateError(
      'Teller Connect script is missing. Ensure connect.js is loaded in web/index.html.',
    );
  }
  final JSObject tellerConnect = tellerConnectValue as JSObject;

  final JSObject options = JSObject()
    ..['applicationId'] = appId.toJS
    ..['environment'] = environment.toJS
    ..['onSuccess'] = ((JSAny? payload) {
      final String? enrollmentId = _readNestedString(payload, const <String>[
        'enrollment',
        'id',
      ]);
      final String? accessToken = _readPropertyString(payload, 'accessToken');

      if (enrollmentId == null || accessToken == null) {
        onError?.call('Received invalid enrollment data from Teller Connect.');
        return;
      }

      onSuccess(enrollmentId, accessToken);
    }).toJS
    ..['onExit'] = (() {
      onError?.call('Teller Connect was canceled.');
    }).toJS;

  final JSAny? handlerValue = tellerConnect.callMethod<JSAny?>(
    'setup'.toJS,
    options,
  );

  if (handlerValue.isUndefinedOrNull || !handlerValue!.isA<JSObject>()) {
    throw StateError('Unable to initialize Teller Connect.');
  }

  (handlerValue as JSObject).callMethod<JSAny?>('open'.toJS);
}

String? _readNestedString(JSAny? value, List<String> path) {
  JSAny? current = value;

  for (final String segment in path) {
    if (current.isUndefinedOrNull || !current!.isA<JSObject>()) {
      return null;
    }
    current = (current as JSObject)[segment];
  }

  return _toDartString(current);
}

String? _readPropertyString(JSAny? value, String property) {
  if (value.isUndefinedOrNull || !value!.isA<JSObject>()) {
    return null;
  }

  return _toDartString((value as JSObject)[property]);
}

String? _toDartString(JSAny? value) {
  if (value.isUndefinedOrNull) {
    return null;
  }

  if (value.isA<JSString>()) {
    final String text = (value as JSString).toDart.trim();
    return text.isEmpty ? null : text;
  }

  final Object? dartValue = value.dartify();
  if (dartValue is String) {
    final String text = dartValue.trim();
    return text.isEmpty ? null : text;
  }

  final String text = '$dartValue'.trim();
  return text.isEmpty ? null : text;
}
