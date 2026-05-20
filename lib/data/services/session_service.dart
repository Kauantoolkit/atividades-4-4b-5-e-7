import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

/// Serviço de sessão: armazena usuário em memória + shared_preferences.
class SessionService {
  static const String _userKey = 'session_user';

  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get token => _currentUser?.accessToken;

  /// Salva o usuário na sessão.
  Future<void> saveUser(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    final userModel = UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      image: user.image,
      accessToken: user.accessToken,
    );
    await prefs.setString(_userKey, json.encode(userModel.toJson()));
  }

  /// Restaura sessão do shared_preferences. Retorna true se encontrou.
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final map = json.decode(userJson) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(map);
        return true;
      } catch (_) {
        await prefs.remove(_userKey);
      }
    }
    return false;
  }

  /// Logout: limpa memória e storage.
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
