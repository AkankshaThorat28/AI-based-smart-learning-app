import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/accessibility_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alerts.dart';
import 'study_material.dart';
import 'take_test_screen.dart';
import '../../services/auth_service.dart';
import '../../utils/tr.dart';

class StudentHome extends StatefulWidget {
  final ValueChanged<int> onNavigateTab;
  final void Function({String? title}) onAddReminder;
  const StudentHome({super.key, required this.onNavigateTab, required this.onAddReminder});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _streakController;
  late Animation<double> _streakBounce;

  String _studentName = 'User';
  final double _goalProgress = 0.375; // 45min / 120min
  final int _streakDays = 7;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _progressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _progressAnimation = Tween<double>(begin: 0, end: _goalProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward();

    _streakController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _streakBounce = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _streakController, curve: Curves.elasticOut),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _streakController.forward();
    });
  }

  Future<void> _loadUser() async {
    final name = await AuthService.getUserName();
    if (mounted) setState(() => _studentName = name);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _streakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a11y = context.watch<AccessibilityProvider>();
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 24),
            if (!a11y.zenMode) ...[
              _buildGoalsCard(),
              const SizedBox(height: 20),
            ],
            _buildContinueLessonCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Scheduled Tests & Quizzes'),
            const SizedBox(height: 12),
            _buildScheduledTests(),
            if (!a11y.zenMode) ...[
              const SizedBox(height: 24),
              _buildStreakWidget(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'Welcome back'.tr(context)}, $_studentName 👋',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text(
                "Ready to conquer today's goals?".tr(context),
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.brandPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Mar 27',
            style: TextStyle(color: AppTheme.brandPrimary, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.gradientCard,
        borderRadius: BorderRadius.circular(AppTheme.cardRadiusLg),
        boxShadow: [
          BoxShadow(color: AppTheme.brandPrimary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Goals".tr(context), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                const SizedBox(height: 12),
                _buildGoalRow('🎯 Goal'.tr(context), '2 hours'),
                const SizedBox(height: 6),
                _buildGoalRow('✅ Done'.tr(context), '45 mins'),
                const SizedBox(height: 6),
                _buildGoalRow('⏳ Left'.tr(context), '1h 15m'),
              ],
            ),
          ),
          const SizedBox(width: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 90, height: 90,
                child: CustomPaint(
                  painter: _CircularProgressPainter(
                    progress: _progressAnimation.value,
                    strokeWidth: 8,
                    bgColor: Colors.white24,
                    fgColor: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }

  Widget _buildContinueLessonCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const MaterialDetailView(
              material: {
                'title': 'Introduction to Algebra',
                'subject': 'Mathematics',
                'teacher': 'Mr. Anderson',
                'date': 'Mar 24',
                'color': Color(0xFF1E88E5),
                'icon': Icons.calculate,
                'isNew': false,
                'description': 'Algebra is a branch of mathematics dealing with symbols and the rules for manipulating those symbols. This lesson covers variables, expressions, and solving basic equations.',
              },
            ),
          ));
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientSubtle,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: AppTheme.brandPrimary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Continue Lesson'.tr(context), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.brandPrimary, letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    const Text('Introduction to Algebra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text('Chapter 3 • 60% completed', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title.tr(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary));
  }

  Widget _buildScheduledTests() {
    final tests = [
      {'title': 'Math Quiz', 'date': 'Available Now', 'time': 'Takes ~20 mins', 'color': const Color(0xFF1E88E5), 'isLive': true},
      {'title': 'Science Test', 'date': 'Apr 1', 'time': '2:00 PM', 'color': const Color(0xFF43A047), 'isLive': false},
      {'title': 'English Essay', 'date': 'Apr 3', 'time': '9:00 AM', 'color': const Color(0xFFFF7043), 'isLive': false},
    ];

    return SizedBox(
      height: 140,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: tests.length,
          separatorBuilder: (a, b) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final test = tests[index];
            return AnimatedContainer(
              duration: AppTheme.animDuration,
              width: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(color: (test['color'] as Color).withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (test['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(test['date'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: test['color'] as Color)),
                  ),
                  const SizedBox(height: 10),
                  Text(test['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  Text(test['time'] as String, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const Spacer(),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        if (test['isLive'] == true) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => TakeTestScreen(title: test['title'] as String),
                          ));
                        } else {
                          widget.onAddReminder(title: test['title'] as String);
                          AppAlerts.showSuccess(context, 'Reminder set for ${test['title']}');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: test['color'] as Color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      child: Text(test['isLive'] == true ? 'Take Test'.tr(context) : 'Remind Me'.tr(context)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStreakWidget() {
    return ScaleTransition(
      scale: _streakBounce,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_streakDays Day Streak!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFE65100))),
                const Text('Keep it up — you\'re on fire!', style: TextStyle(fontSize: 12, color: Color(0xFFBF360C))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color bgColor;
  final Color fgColor;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = fgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) => oldDelegate.progress != progress;
}
