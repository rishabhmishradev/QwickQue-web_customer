import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/router.dart';
import 'services/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: QuickQueApp(),
    ),
  );
}

class QuickQueApp extends ConsumerStatefulWidget {
  const QuickQueApp({super.key});

  @override
  ConsumerState<QuickQueApp> createState() => _QuickQueAppState();
}

class _QuickQueAppState extends ConsumerState<QuickQueApp> {
  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'QuickQue',
      routerConfig: goRouter,
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
    );
  }
}
