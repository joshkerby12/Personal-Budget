void launchTellerConnect({
  required String appId,
  required void Function(String enrollmentId, String accessToken) onSuccess,
  String environment = 'development',
  void Function(String message)? onError,
}) {
  throw UnsupportedError('Teller Connect is only available on web.');
}
