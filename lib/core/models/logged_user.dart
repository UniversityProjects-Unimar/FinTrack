class LoggedUser {
  const LoggedUser({
    required this.id,
    required this.email,
    this.name,
    this.token,
  });

  final int id;
  final String email;
  final String? name;
  final String? token;
}
