import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teste_flutter/database/storage_helper.dart';
import 'package:teste_flutter/firebase_options.dart';
import 'package:teste_flutter/providers/auth_provider.dart';
import 'package:teste_flutter/screens/lista_imoveis_screen.dart';
import 'package:teste_flutter/screens/login_screen.dart';
import 'package:teste_flutter/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar Analytics
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  
  await StorageHelper.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ImobiBrasil',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioAsync = ref.watch(usuarioProvider);

    return usuarioAsync.when(
      data: (usuario) {
        if (usuario != null) {
          return const ListaImoveisScreen();
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const LoginScreen(),
    );
  }
}

