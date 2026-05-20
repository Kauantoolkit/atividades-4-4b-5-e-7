import 'package:flutter/material.dart';
import '../../data/services/session_service.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_tile.dart';
import '../../domain/entities/product.dart';
import '../../../main.dart';

/// Pagina principal que exibe a lista de produtos.
/// Usa ValueListenableBuilder para observar mudancas de estado do ViewModel.
/// Stateful para auto-load on init.
class ProductPage extends StatefulWidget {
  /// O ViewModel que gerencia o estado do produto.
  final ProductViewModel viewModel;

  /// Servico de sessao para exibir dados do usuario.
  final SessionService sessionService;

  /// Cria uma ProductPage com o ViewModel informado.
  const ProductPage({
    super.key,
    required this.viewModel,
    required this.sessionService,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    // Auto-load products on page enter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadProducts(maxRetries: 2);
    });
  }

  /// Mostra dialogo de confirmacao para deletar produto.
  void _showDeleteDialog(
    BuildContext context,
    Product product,
    ProductViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 32),
        title: const Text('Confirmar exclusao'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deseja realmente excluir "${product.title}"?'),
            const SizedBox(height: 8),
            Text(
              'Esta acao nao pode ser desfeita.',
              style: TextStyle(color: colorScheme.error, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteProduct(product.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Produto excluido!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Produtos',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Voltar',
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Imagem do usuario no AppBar
          if (widget.sessionService.currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    widget.sessionService.currentUser!.image,
                  ),
                ),
              ),
            ),
          // Botao de filtro de favoritos
          ValueListenableBuilder(
            valueListenable: widget.viewModel.state,
            builder: (context, state, child) {
              return IconButton(
                onPressed: () => widget.viewModel.toggleFavoritesFilter(),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    state.showOnlyFavorites
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(state.showOnlyFavorites),
                    color: state.showOnlyFavorites
                        ? Colors.redAccent
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                tooltip: state.showOnlyFavorites
                    ? 'Mostrar todos'
                    : 'Filtrar favoritos',
              );
            },
          ),
          // Contador de favoritos
          ValueListenableBuilder(
            valueListenable: widget.viewModel.state,
            builder: (context, state, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.favoriteCount}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: widget.viewModel.state,
        builder: (context, state, child) {
          // Exibe indicador de carregamento
          if (state.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Carregando produtos...',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Exibe mensagem de erro - enhanced for network/cache
          if (state.error != null) {
            final errorContainsNetwork =
                state.error!.contains('523') ||
                state.error!.contains('network') ||
                state.error!.contains('unavailable');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withAlpha(80),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        errorContainsNetwork
                            ? Icons.wifi_off_rounded
                            : Icons.error_outline_rounded,
                        size: 48,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: () =>
                              widget.viewModel.loadProducts(maxRetries: 3),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Tentar Novamente'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () =>
                              widget.viewModel.loadProducts(maxRetries: 0),
                          icon: const Icon(Icons.folder_outlined),
                          label: const Text('Ver Local'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          // Lista de produtos filtrada
          final products = state.filteredProducts;

          // Exibe mensagem quando nao ha produtos (apos filtro)
          if (products.isEmpty) {
            if (state.showOnlyFavorites) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withAlpha(100),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Nenhum produto favoritado',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toque no coracao para favoritar',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withAlpha(150),
                          ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonalIcon(
                      onPressed: () => widget.viewModel.toggleFavoritesFilter(),
                      icon: const Icon(Icons.list_rounded),
                      label: const Text('Mostrar todos'),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(100),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nenhum produto encontrado',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => widget.viewModel.loadProducts(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Carregar produtos'),
                  ),
                ],
              ),
            );
          }

          // Grid de produtos
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onLongPress: () =>
                    _showDeleteDialog(context, product, widget.viewModel),
                child: ProductTile(
                  product: product,
                  onFavoriteToggle: () =>
                      widget.viewModel.toggleFavorite(product.id),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.productDetail,
                      arguments: product,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// FAB Novo Produto (prioridade)
          FloatingActionButton.extended(
            heroTag: 'new_product',
            onPressed: () {
              widget.viewModel.setSelectedProduct(null);
              Navigator.pushNamed(context, AppRoutes.productForm);
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Novo'),
            tooltip: 'Criar novo produto',
            elevation: 2,
          ),
          const SizedBox(height: 12),

          /// FAB Refresh (secundario)
          FloatingActionButton.small(
            heroTag: 'refresh',
            onPressed: () => widget.viewModel.loadProducts(maxRetries: 1),
            tooltip: 'Atualizar',
            elevation: 1,
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: colorScheme.onSurfaceVariant,
            child: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}
