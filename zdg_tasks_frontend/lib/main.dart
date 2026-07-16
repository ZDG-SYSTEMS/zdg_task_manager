import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/push_service.dart';
import 'core/router.dart';
import 'core/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Best-effort: push stays silent until Firebase is configured for
  // the platform; email and in-app records carry every event anyway.
  await PushService.initialize();

  runApp(const ProviderScope(child: ZdgTasksApp()));
}

class ZdgTasksApp extends ConsumerWidget {
  const ZdgTasksApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ZDG Tasks',
      theme: appTheme,
      routerConfig: router,
    );
  }
}
