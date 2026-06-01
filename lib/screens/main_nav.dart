import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/locale_service.dart';
import '../services/ui_schema.dart';
import '../theme/cosmic_theme.dart';
import '../state/app_state.dart';
import 'home_screen.dart';
import 'chart_screen.dart';
import 'ai_screen.dart';
import 'art_studio_screen.dart';
import 'explore_screen.dart';
import 'settings_screen.dart';

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
      AiScreen(onNavigateSettings: () => switchTo(5)),
      const ArtStudioScreen(),
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

  @override
  Widget build(BuildContext context) {
    final isNl = context.watch<LocaleService>().isNl;
    final tabs = [...UiSchema.instance.navTabs]
      ..sort((a, b) => a.index.compareTo(b.index));

    return Container(
      decoration: const BoxDecoration(
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
            children: tabs.map((tab) {
              final selected = tab.index == currentIndex;
              final color = selected ? tab.accent : CosmicColors.textMuted;
              final icon = selected
                  ? SchemaIcons.resolve(tab.iconFilled)
                  : SchemaIcons.resolve(tab.iconOutlined);
              final label = isNl ? tab.labelNl : tab.labelEn;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(tab.index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: 22),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
