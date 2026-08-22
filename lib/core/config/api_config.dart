class ApiConfig {
  // Use String.fromEnvironment to allow injecting URL at build time
  static const String _envUrl = String.fromEnvironment('BACKEND_URL');
  static const String _cloudUrl = 'https://3.111.59.7.sslip.io/api/v1/';

  static String get baseUrl {
    if (_envUrl.isNotEmpty) {
      return _envUrl.endsWith('/') ? _envUrl : '$_envUrl/';
    }
    return _cloudUrl;
  }
}
