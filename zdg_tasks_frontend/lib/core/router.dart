import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/profile_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/petty_cash/presentation/petty_cash_form_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/requests/presentation/task_detail_screen.dart';
import '../features/requests/presentation/task_form_screen.dart';
import '../features/requests/presentation/task_list_screen.dart';
import '../features/users/presentation/users_screen.dart';
import '../shared/permissions.dart';
import '../shared/widgets/app_scaffold.dart';

part 'router.g.dart';

/// Declarative routes with role-based redirect guards reading the auth
/// provider. Guards only hide surfaces; the API is the enforcement
/// point for every permission.
@riverpod
GoRouter router(Ref ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = auth.value?.user;
      final signedIn = user != null;
      final onAuthPage = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!signedIn && !onAuthPage) return '/login';
      if (signedIn && onAuthPage) return '/';

      // Role guards for gated surfaces.
      if (signedIn) {
        if (state.matchedLocation.startsWith('/reports') && !user.canSeeReports) return '/';
        if (state.matchedLocation.startsWith('/users') && !user.canManageUsers) return '/';
        if (state.matchedLocation == '/petty-cash/new' && !user.canCreatePettyCash) return '/';
        if (state.matchedLocation == '/tasks/new' && !user.canCreateStandard) return '/tasks';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/tasks', builder: (context, state) => const TaskListScreen()),
          GoRoute(path: '/tasks/new', builder: (context, state) => const TaskFormScreen()),
          GoRoute(
            path: '/tasks/:id',
            builder: (context, state) =>
                TaskDetailScreen(taskId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(
            path: '/tasks/:id/edit',
            builder: (context, state) =>
                TaskFormScreen(taskId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(
            path: '/petty-cash/new',
            builder: (context, state) => const PettyCashFormScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
          GoRoute(path: '/users', builder: (context, state) => const UsersScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),
    ],
  );
}
