import 'package:fin_track/core/di/service_locator.dart';
import 'package:fin_track/core/router/app_router.dart';
import 'package:fin_track/features/autenticacao/state/auth_provider.dart';
import 'package:fin_track/features/catalogo/state/preferences_provider.dart';
import 'package:fin_track/features/catalogo/state/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider<TransactionsProvider>.value(
          value: getIt<TransactionsProvider>(),
        ),
        ChangeNotifierProvider<PreferencesProvider>.value(
          value: getIt<PreferencesProvider>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final prefs = context.watch<PreferencesProvider>();
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'FinTrack',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: prefs.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
