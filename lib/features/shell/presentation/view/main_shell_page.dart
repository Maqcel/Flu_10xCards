import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:xcards/app/routing/app_router.gr.dart';
import 'package:xcards/l10n/l10n.dart';
import 'package:xcards/presentation/styles/app_dimensions.dart';

/// Shell page containing BottomNavigationBar and AutoRouter.
@RoutePage()
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _NavItem(context.l10n.dashboardTitle, Icons.home),
      _NavItem(context.l10n.learnTitle, Icons.play_circle_fill),
      _NavItem(context.l10n.statsTitle, Icons.bar_chart),
      _NavItem(context.l10n.settingsTitle, Icons.settings),
    ];

    return AutoTabsScaffold(
      routes: const [
        DashboardRoute(),
        LearningSessionRoute(),
        StatisticsRoute(),
        SettingsRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) => BottomNavigationBar(
        currentIndex: tabsRouter.activeIndex,
        onTap: tabsRouter.setActiveIndex,
        items: [
          for (final item in tabs)
            BottomNavigationBarItem(
              icon: Icon(item.icon, size: AppDimensions.iconSize24),
              label: item.label,
            ),
        ],
      ),
      floatingActionButtonBuilder: (context, tabsRouter) =>
          FloatingActionButton(
            onPressed: () => context.router.push(const GenerationRoute()),
            child: const Icon(Icons.add),
          ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
