import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_view.dart';
import 'departments_view.dart';
import 'stores_list_view.dart';
import 'profile_tab.dart';
import 'messages_tab.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';

class MainScaffold extends StatefulWidget {
  final int initialTab;
  const MainScaffold({super.key, this.initialTab = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  static const _tabCount = 5;

  late int _currentIndex;
  late final Set<int> _visitedTabs;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab.clamp(0, _tabCount - 1);
    _visitedTabs = {_currentIndex};
  }

  @override
  void didUpdateWidget(MainScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _currentIndex = widget.initialTab.clamp(0, _tabCount - 1);
      _visitedTabs.add(_currentIndex);
    }
  }

  static const _navItems = [
    _NavSpec(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavSpec(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Categories'),
    _NavSpec(Icons.local_shipping_outlined, Icons.local_shipping_rounded, 'Deliveries'),
    _NavSpec(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Messages'),
    _NavSpec(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final auth = context.watch<AuthProvider>();
    final authKey = auth.currentUser?.id ?? 'guest';

    Widget pageFor(int i) {
      switch (i) {
        case 0:
          return const UserHomeView();
        case 1:
          return const DepartmentsView();
        case 2:
          return const StoresListView(rootTab: true);
        case 3:
          return MessagesTab(key: ValueKey('messages-$authKey'));
        case 4:
          return ProfileTab(key: ValueKey('profile-$authKey'));
        default:
          return const SizedBox.shrink();
      }
    }

    final pages = List<Widget>.generate(
      _tabCount,
      (i) => _visitedTabs.contains(i)
          ? pageFor(i)
          : const SizedBox.shrink(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (market.loadError != null)
            Material(
              color: Colors.red.shade700,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        market.loadError!,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () => market.refresh(),
                      child: const Text('Retry',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          if (market.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.primary,
              backgroundColor: Colors.transparent,
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              return Expanded(child: _navItem(i, _navItems[i]));
            }),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, _NavSpec spec) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() {
        _currentIndex = index;
        _visitedTabs.add(index);
      }),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              selected ? spec.activeIcon : spec.icon,
              size: 24,
              color: selected ? AppColors.primary : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            spec.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? AppColors.primary : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavSpec {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavSpec(this.icon, this.activeIcon, this.label);
}
