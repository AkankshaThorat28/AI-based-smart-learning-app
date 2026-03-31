import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'student/student_home.dart';
import 'student/study_material.dart';
import 'student/ai_chatbot.dart';
import 'student/student_settings.dart';
import 'student/achievements_screen.dart';
import 'student/profile_screen.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import '../utils/tr.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<_NavTab> _tabs = const [
    _NavTab(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavTab(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book, label: 'Study Material'),
    _NavTab(icon: Icons.smart_toy_outlined, activeIcon: Icons.smart_toy, label: 'AI Chatbot'),
    _NavTab(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
  ];

  final List<String> _reminderItems = [];

  final List<Map<String, dynamic>> _notifications = [
    {'title': 'New study material shared', 'subtitle': 'Mr. Anderson shared "Quadratic Equations"', 'icon': Icons.menu_book, 'color': const Color(0xFF1E88E5), 'time': '10m ago'},
    {'title': 'Test reminder', 'subtitle': 'Math Quiz starts in 1 hour', 'icon': Icons.assignment, 'color': const Color(0xFFE53935), 'time': '25m ago'},
    {'title': 'Achievement unlocked!', 'subtitle': 'You completed a 7-day streak 🔥', 'icon': Icons.emoji_events, 'color': const Color(0xFFFF9800), 'time': '1h ago'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: AppTheme.animDuration,
      curve: AppTheme.animCurve,
    );
  }

  void _showRemindersPanel(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonPos = button.localToGlobal(Offset.zero, ancestor: overlay);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            // Dismiss on tap outside
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              top: buttonPos.dy + button.size.height + 8,
              right: max(16.0, overlay.size.width - buttonPos.dx - button.size.width),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: min(300.0, MediaQuery.of(context).size.width - 32.0),
                  child: _DropdownPanel(
                  title: 'Reminders',
                  icon: Icons.access_time_filled_outlined,
                  accentColor: const Color(0xFF1E88E5),
                  isEmpty: _reminderItems.isEmpty,
                  emptyMessage: 'No active reminders',
                  emptyIcon: Icons.notifications_off_outlined,
                  children: _reminderItems.map((title) => _PanelItem(
                    icon: Icons.alarm,
                    color: const Color(0xFF1E88E5),
                    title: title,
                    subtitle: 'Upcoming',
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      color: AppTheme.textTertiary,
                      onPressed: () {
                        setState(() => _reminderItems.remove(title));
                        Navigator.pop(context);
                      },
                    ),
                  )).toList(),
                ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationsPanel(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonPos = button.localToGlobal(Offset.zero, ancestor: overlay);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              top: buttonPos.dy + button.size.height + 8,
              right: max(16.0, overlay.size.width - buttonPos.dx - button.size.width),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: min(300.0, MediaQuery.of(context).size.width - 32.0),
                  child: _DropdownPanel(
                  title: 'Notifications',
                  icon: Icons.notifications_none_outlined,
                  accentColor: const Color(0xFF8E24AA),
                  isEmpty: _notifications.isEmpty,
                  emptyMessage: 'No new notifications',
                  emptyIcon: Icons.notifications_off_outlined,
                  children: _notifications.map((notif) => _PanelItem(
                    icon: notif['icon'] as IconData,
                    color: notif['color'] as Color,
                    title: notif['title'] as String,
                    subtitle: notif['subtitle'] as String,
                    trailing: Text(
                      notif['time'] as String,
                      style: TextStyle(fontSize: 10, color: AppTheme.textTertiary, fontWeight: FontWeight.w500),
                    ),
                  )).toList(),
                ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StudentHome(
                    onNavigateTab: (index) => _onTabTapped(index),
                    onAddReminder: ({String? title}) {
                      setState(() {
                        _reminderItems.add(title ?? 'Reminder');
                      });
                    },
                  ),
                  const StudyMaterial(),
                  AiChatbot(),
                  StudentSettings(),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) => _buildNavItem(i)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              gradient: AppTheme.gradientPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'Saamya AI',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.3),
          ),
          const Spacer(),
          if (!Provider.of<AccessibilityProvider>(context).zenMode) ...[
            _buildHeaderIcon(
              Icons.emoji_events_rounded,
              'Achievements'.tr(context),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen()));
              },
            ),
            const SizedBox(width: 4),
          ],
          Builder(
            builder: (headerContext) => _buildHeaderIcon(
              Icons.access_time_filled_outlined,
              'Reminders'.tr(context),
              badgeCount: _reminderItems.length,
              onTap: () => _showRemindersPanel(headerContext),
            ),
          ),
          const SizedBox(width: 4),
          Builder(
            builder: (headerContext) => _buildHeaderIcon(
              Icons.notifications_none_outlined,
              'Notifications',
              badgeCount: _notifications.length,
              onTap: () => _showNotificationsPanel(headerContext),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            borderRadius: BorderRadius.circular(16),
            child: const CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.brandPrimary,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54, size: 20),
            tooltip: 'Logout',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Logout'.tr(context)),
                  content: Text('Are you sure you want to sign out?'.tr(context)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.tr(context))),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('Logout'.tr(context), style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await AuthService.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),

          const SizedBox(width: 4),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppTheme.brandPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('A', style: TextStyle(color: AppTheme.brandPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, String tooltip, {int badgeCount = 0, VoidCallback? onTap}) {
    return Semantics(
      label: tooltip,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 38, height: 38,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 22, color: AppTheme.textSecondary),
                if (badgeCount > 0)
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final tab = _tabs[index];
    final isActive = _currentIndex == index;

    return Semantics(
      label: tab.label,
      button: true,
      selected: isActive,
      child: Tooltip(
        message: tab.label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onTabTapped(index),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: AppTheme.animDuration,
              curve: AppTheme.animCurve,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.brandPrimary.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: AppTheme.animFast,
                    child: Icon(
                      isActive ? tab.activeIcon : tab.icon,
                      key: ValueKey(isActive),
                      color: isActive ? AppTheme.brandPrimary : AppTheme.textTertiary,
                      size: 24,
                      semanticLabel: tab.label.tr(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: AppTheme.animFast,
                    style: TextStyle(
                      color: isActive ? AppTheme.brandPrimary : AppTheme.textTertiary,
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    ),
                    child: Text(tab.label.tr(context)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavTab({required this.icon, required this.activeIcon, required this.label});
}

// ─── Dropdown Panel Widget ──────────────────────────────

class _DropdownPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final bool isEmpty;
  final String emptyMessage;
  final IconData emptyIcon;
  final List<Widget> children;

  const _DropdownPanel({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.isEmpty,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 380),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: accentColor),
                const SizedBox(width: 10),
                Text(title.tr(context), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const Spacer(),
                if (!isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${children.length}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accentColor),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          // Content
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(emptyIcon, size: 36, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text(emptyMessage.tr(context), style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PanelItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _PanelItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: TextStyle(fontSize: 11, color: AppTheme.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
