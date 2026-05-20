/// Entidade imutável representando um usuário autenticado.
class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String image;
  final String accessToken;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.accessToken,
  });

  String get fullName => '$firstName $lastName';
}
