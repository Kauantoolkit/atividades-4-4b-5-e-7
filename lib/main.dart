import 'package:flutter/material.dart';

import 'core/network/http_client.dart';
import 'data/services/auth_service.dart';
import 'data/services/session_service.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/datasources/product_cache_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/entities/product.dart';
import 'presentation/viewmodels/product_viewmodel.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/product_page.dart';
import 'presentation/pages/product_detail_page.dart';
import 'presentation/pages/product_form_page.dart';
import 'presentation/pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Nomes das rotas nomeadas da aplicação.
abstract class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const products = '/products';
  static const productDetail = '/product/detail';
  static const productForm = '/product/form';
  static const profile = '/profile';
}

/// Widget principal da aplicação que configura a injeção de dependência.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ProductViewModel _viewModel;
  late final AuthService _authService;
  late final SessionService _sessionService;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    // Configura injeção de dependência (DI manual)
    final httpClient = HttpClient();
    final remoteDatasource = ProductRemoteDatasource(httpClient: httpClient);
    final cacheDatasource = ProductCacheDatasource();
    final repository = ProductRepositoryImpl(
      remoteDatasource: remoteDatasource,
      cacheDatasource: cacheDatasource,
    );
    _viewModel = ProductViewModel(repository: repository);
    _authService = AuthService(httpClient: httpClient);
    _sessionService = SessionService();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final hasSession = await _sessionService.restoreSession();
    if (mounted) {
      setState(() => _checkingSession = false);
      if (hasSession) {
        _viewModel.loadProducts();
      }
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Determina a tela inicial com base no estado de sessão.
  Widget _getHomePage() {
    if (_checkingSession) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_sessionService.isLoggedIn) {
      return HomePage(viewModel: _viewModel, sessionService: _sessionService);
    }
    return LoginPage(authService: _authService, sessionService: _sessionService);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Produtos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _getHomePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute(
              builder: (_) => LoginPage(
                authService: _authService,
                sessionService: _sessionService,
              ),
              settings: settings,
            );
          case AppRoutes.home:
            return MaterialPageRoute(
              builder: (_) => HomePage(
                viewModel: _viewModel,
                sessionService: _sessionService,
              ),
              settings: settings,
            );
          case AppRoutes.products:
            return MaterialPageRoute(
              builder: (_) => ProductPage(
                viewModel: _viewModel,
                sessionService: _sessionService,
              ),
              settings: settings,
            );
          case AppRoutes.productDetail:
            final product = settings.arguments;
            if (product is! Product) {
              return MaterialPageRoute(
                builder: (_) => HomePage(
                  viewModel: _viewModel,
                  sessionService: _sessionService,
                ),
                settings: settings,
              );
            }
            return MaterialPageRoute(
              builder: (_) => ProductDetailPage(
                product: product,
                viewModel: _viewModel,
              ),
              settings: settings,
            );
          case AppRoutes.productForm:
            return MaterialPageRoute(
              builder: (_) => ProductFormPage(viewModel: _viewModel),
              settings: settings,
            );
          case AppRoutes.profile:
            return MaterialPageRoute(
              builder: (_) => ProfilePage(
                authService: _authService,
                sessionService: _sessionService,
              ),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (_) => LoginPage(
                authService: _authService,
                sessionService: _sessionService,
              ),
              settings: settings,
            );
        }
      },
    );
  }
}
