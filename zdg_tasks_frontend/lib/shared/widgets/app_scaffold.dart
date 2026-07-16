import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../permissions.dart';

/// Shell around every signed-in screen: adaptive navigation whose
/// destinations are filtered by the session role (convenience only;
/// the API enforces every permission).
class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value?.user;
    if (user == null) return child;

    final destinations = <({String route, IconData icon, String label})>[
      (route: '/', icon: Icons.dashboard_outlined, label: 'Dashboard'),
      (route: '/tasks', icon: Icons.assignment_outlined, label: 'Tasks'),
      (route: '/notifications', icon: Icons.notifications_outlined, label: 'Alerts'),
      if (user.canSeeReports)
        (route: '/reports', icon: Icons.bar_chart_outlined, label: 'Reports'),
      if (user.canManageUsers)
        (route: '/users', icon: Icons.group_outlined, label: 'Users'),
      (route: '/profile', icon: Icons.person_outline, label: 'Profile'),
    ];

    final location = GoRouterState.of(context).matchedLocation;
    var selected = destinations.indexWhere(
      (d) => d.route == '/' ? location == '/' : location.startsWith(d.route),
    );
    if (selected < 0) selected = 0;

    final wide = MediaQuery.sizeOf(context).width >= 800;

    final body = wide
        ? Row(
            children: [
              NavigationRail(
                selectedIndex: selected,
                onDestinationSelected: (index) => context.go(destinations[index].route),
                labelType: NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Image.asset(
                    'assets/logos/${user.company?.code.toLowerCase() ?? 'zdg'}.png',
                    height: 48,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                destinations: [
                  for (final destination in destinations)
                    NavigationRailDestination(
                      icon: Icon(destination.icon),
                      label: Text(destination.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          )
        : child;

    return Scaffold(
      appBar: AppBar(
        title: Text('ZDG Tasks - ${user.company?.code ?? ''}'),
      ),
      body: body,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: selected,
              onDestinationSelected: (index) => context.go(destinations[index].route),
              destinations: [
                for (final destination in destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    label: destination.label,
                  ),
              ],
            ),
    );
  }
}
