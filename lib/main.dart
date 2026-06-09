import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart';
import 'widgets/global_order_overlay.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PharmaApp(),
    ),
  );
}

class PharmaApp extends StatelessWidget {
  const PharmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pharma Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      builder: (context, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            final path = appRouter.routerDelegate.currentConfiguration.uri.path;
            if (path != '/' && path != '/login' && path != '/signup' && path != '/dashboard') {
              appRouter.go('/dashboard');
            }
          },
          child: GlobalOrderOverlay(child: child!),
        );
      },
    );
  }
}
