import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/session_service.dart';
import '../../domain/entities/user.dart';

/// Tela de perfil do usuário autenticado (GET /auth/me).
class ProfilePage extends StatefulWidget {
  final AuthService authService;
  final SessionService sessionService;

  const ProfilePage({
    super.key,
    required this.authService,
    required this.sessionService,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  User? _user;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      final token = widget.sessionService.token;
      if (token == null) {
        setState(() { _error = 'Sessão expirada.'; _isLoading = false; });
        return;
      }
      final user = await widget.authService.getMe(token);
      setState(() { _user = user; _isLoading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Failure: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.orange[400]),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadProfile,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _buildProfile(context),
    );
  }

  Widget _buildProfile(BuildContext context) {
    final user = _user!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(radius: 60, backgroundImage: NetworkImage(user.image)),
          const SizedBox(height: 20),
          Text(user.fullName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('@${user.username}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(user.email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('ID'),
                    subtitle: Text('#${user.id}'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
