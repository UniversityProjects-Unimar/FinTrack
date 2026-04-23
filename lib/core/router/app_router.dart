import 'package:fin_track/features/autenticacao/presentation/screens/login_screen.dart';
import 'package:fin_track/features/catalogo/presentation/screens/home_screen.dart';
import 'package:fin_track/features/catalogo/presentation/screens/new_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _abas = [
  _ConfiguracaoAba(rotaInicial: '/home', icone: Icons.home, rotulo: 'Resumo'),
  _ConfiguracaoAba(
    rotaInicial: '/transacoes/nova',
    icone: Icons.add_circle,
    rotulo: 'Nova',
  ),
];

class _ConfiguracaoAba {
  final String rotaInicial;
  final IconData icone;
  final String rotulo;

  const _ConfiguracaoAba({
    required this.rotaInicial,
    required this.icone,
    required this.rotulo,
  });
}

class AuthState extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void login() {
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}

class AppRouter {
  static final AuthState auth = AuthState();

  static final GoRouter router = GoRouter(
    refreshListenable: auth,
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = auth.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      if (isLoggedIn && isGoingToLogin) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _TelaBase(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transacoes/nova',
                builder: (context, state) => const NewTransactionScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _TelaBase extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _TelaBase({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (indice) {
          navigationShell.goBranch(
            indice,
            initialLocation: indice == navigationShell.currentIndex,
          );
        },
        items: _abas
            .map(
              (aba) => BottomNavigationBarItem(
                icon: Icon(aba.icone),
                label: aba.rotulo,
              ),
            )
            .toList(),
      ),
    );
  }
}
