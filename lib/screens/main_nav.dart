import 'package:flutter/material.dart';
import '../theme/cosmic_theme.dart';
import 'home_screen.dart';
import 'chart_screen.dart';
import 'ai_screen.dart';
import 'explore_screen.dart';
import 'settings_screen.dart';
import '../state/app_state.dart';
import 'package:provider/provider.dart';

class MainNav extends StatefulWidget {
  final int initialTab;
  const MainNav({super.key, this.initialTab = 0});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void switchTo(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final chart = appState.chart;

    final screens = [
      const HomeScreen(),
      chart != null
          ? ChartScreen(birthContext: chart.context)
          : const _LoadingScreen(),
      const AiScreen(),
      const ExploreScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _CosmicNavBar(
        currentIndex: _currentIndex,
        onTap: switchTo,
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: CosmicColors.neonLavender),
  );
}

class _CosmicNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _CosmicNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.auto_awesome_outlined, Icons.auto_awesome, 'Chart'),
    (Icons.psychology_outlined, Icons.psychology, 'AI'),
    (Icons.explore_outlined, Icons.explore, 'Explore'),
    (Icons.settings_outlined, Icons.settings, 'Settings'),
  ];

  static const _colors = [
    CosmicColors.neonLavender,
    CosmicColors.neonCyan,
    CosmicColors.neonPink,
    CosmicColors.neonYellow,
    CosmicColors.textSecondary,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CosmicColors.surface,
        border: Border(
          top: BorderSide(color: CosmicColors.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final (outline, filled, label) = _items[i];
              final selected = i == currentIndex;
              final color = selected ? _colors[i] : CosmicColors.textMuted;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(selected ? filled : outline, color: color, size: 22),
                      const SizedBox(height: 3),
                      Text(label,
                          style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              letterSpacing: 0.3)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
