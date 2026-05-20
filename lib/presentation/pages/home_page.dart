import 'package:flutter/material.dart';
import '../../data/services/session_service.dart';
import '../viewmodels/product_viewmodel.dart';
import '../../../main.dart';

/// Tela inicial da aplicacao.
/// Exibe nome do usuario autenticado e botao de logout.
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Loja de Produtos',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
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
            icon: const Icon(Icons.logout_rounded),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Hero illustration area
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 72,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 36),

              // Greeting
              Text(
                user != null ? 'Ola, ${user.firstName}!' : 'Bem-vindo!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Explore nossos produtos e marque seus favoritos.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Main action button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    viewModel.loadProducts();
                    Navigator.pushNamed(context, AppRoutes.products);
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 22),
                  label: const Text(
                    'Ver Produtos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Secondary action
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.profile),
                  icon: const Icon(Icons.person_outline_rounded, size: 22),
                  label: const Text(
                    'Meu Perfil',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Info cards row
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.favorite_rounded,
                      iconColor: Colors.redAccent,
                      label: 'Favoritos',
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.local_shipping_outlined,
                      iconColor: colorScheme.primary,
                      label: 'Entrega rapida',
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.verified_outlined,
                      iconColor: Colors.green,
                      label: 'Qualidade',
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final ColorScheme colorScheme;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
