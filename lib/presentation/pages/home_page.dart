import 'package:flutter/material.dart';
import '../../data/services/session_service.dart';
import '../viewmodels/product_viewmodel.dart';
import '../../../main.dart';

/// Tela inicial da aplicação.
/// Exibe nome do usuário autenticado e botão de logout.
class HomePage extends StatelessWidget {
  final ProductViewModel viewModel;
  final SessionService sessionService;

  const HomePage({
    super.key,
    required this.viewModel,
    required this.sessionService,
  });

  @override
  Widget build(BuildContext context) {
    final user = sessionService.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja de Produtos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(user.image),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await sessionService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.store_rounded,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                user != null ? 'Bem-vindo, ${user.firstName}!' : 'Bem-vindo!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Explore nossos produtos e marque seus favoritos.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    viewModel.loadProducts();
                    Navigator.pushNamed(context, AppRoutes.products);
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Ver Produtos'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
