import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/providers/admin_providers.dart';
import 'core/theme/admin_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase init check: $e");
  }
  runApp(const ProviderScope(child: PortfolioAdminApp()));
}

class PortfolioAdminApp extends ConsumerWidget {
  const PortfolioAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Portfolio Admin CMS',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.darkTheme,
      home: authState.when(
        data: (user) => user != null ? const DashboardScreen() : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AdminTheme.primary)),
        ),
        error: (err, stack) => const DashboardScreen(),
      ),
    );
  }
}
