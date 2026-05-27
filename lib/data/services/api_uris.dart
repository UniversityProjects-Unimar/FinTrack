abstract final class ApiUris {
  static const String _host = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'api.fintrack.example.com',
  );

  static Uri transactions({required int userId}) {
    return Uri.https(_host, '/users/$userId/transactions');
  }

  static Uri user({required int userId}) {
    return Uri.https(_host, '/users/$userId');
  }

  static Uri usersByEmail({required String email}) {
    return Uri.https(_host, '/users', <String, String>{'email': email});
  }

  static Uri transaction({required int userId, required String id}) {
    return Uri.https(_host, '/users/$userId/transactions/$id');
  }
}
