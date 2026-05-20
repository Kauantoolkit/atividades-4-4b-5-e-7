import '../../core/network/http_client.dart';
import '../../core/errors/failure.dart';
import '../models/user_model.dart';

/// Serviço responsável pelas chamadas de autenticação na DummyJSON API.
class AuthService {
  final HttpClient _httpClient;
  static const String _baseUrl = 'https://dummyjson.com';

  AuthService({required HttpClient httpClient}) : _httpClient = httpClient;

  /// POST /auth/login
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _httpClient.post('$_baseUrl/auth/login', {
        'username': username,
        'password': password,
      });
      return UserModel.fromJson(response as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Credenciais inválidas ou erro de conexão.');
    }
  }

  /// GET /auth/me (com token)
  Future<UserModel> getMe(String token) async {
    try {
      final response = await _httpClient.getWithAuth(
        '$_baseUrl/auth/me',
        token,
      );
      final json = response as Map<String, dynamic>;
      json['accessToken'] = token;
      return UserModel.fromJson(json);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Erro ao buscar dados do usuário.');
    }
  }
}
