import '../../domain/entities/user.dart';

/// Modelo de dados para User com serialização JSON.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.image,
    required super.accessToken,
  });

  /// Cria um [UserModel] a partir do JSON de resposta do login da DummyJSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      image: json['image'] as String,
      accessToken: json['accessToken'] as String,
    );
  }

  /// Converte para mapa JSON (para persistência local).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'image': image,
      'accessToken': accessToken,
    };
  }
}
