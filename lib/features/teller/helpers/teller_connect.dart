import 'teller_connect_stub.dart'
    if (dart.library.html) 'teller_connect_web.dart'
    as impl;

void launchTellerConnect({
  required String appId,
  required void Function(String enrollmentId, String accessToken) onSuccess,
  String environment = 'development',
  void Function(String message)? onError,
}) {
  impl.launchTellerConnect(
    appId: appId,
    onSuccess: onSuccess,
    environment: environment,
    onError: onError,
  );
}
