import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/platform/live_activity_service.dart';
import 'package:mimio/core/platform/siri_sync_service.dart';
import 'package:mimio/core/platform/widget_sync_service.dart';
import 'package:mimio/core/storage/token_storage.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/auth/login_screen.dart';
import 'package:mimio/features/auth/register_screen.dart';
import 'package:mimio/features/providers.dart';
import 'package:mimio/features/ai/ai_plan_screen.dart';
import 'package:mimio/features/focus/focus_screen.dart';
import 'package:mimio/features/profile/profile_screen.dart';
import 'package:mimio/features/timeline/home_screen.dart';
import 'package:mimio/features/web/web_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  for (final locale in ['tr_TR', 'en_US', 'es_ES', 'fr_FR', 'de_DE']) {
    await initializeDateFormatting(locale);
  }
  await WidgetSyncService.initialize();
  await LiveActivityService.instance.initialize();
  final existingToken = await TokenStorage().getToken();
  await SiriSyncService.syncCredentials(token: existingToken);
  runApp(const ProviderScope(child: MimioApp()));
}

class MimioApp extends ConsumerWidget {
  const MimioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final lang = ref.watch(appLanguageProvider).valueOrNull ?? 'tr';

    return MaterialApp.router(
      title: 'Mimio',
      theme: MimioTheme.light,
      locale: Locale(lang),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/home',
        builder: (_, __) => const WebShell(child: HomeScreen()),
      ),
      GoRoute(path: '/focus', builder: (_, __) => const FocusScreen()),
      GoRoute(path: '/ai', builder: (_, __) => const AiPlanScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
});
