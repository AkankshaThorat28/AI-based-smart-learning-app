import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/accessibility_provider.dart';
import '../../theme/app_theme.dart';
import 'lesson_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  Widget build(BuildContext context) {
    final a11y = Provider.of<AccessibilityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.brandPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'Elevate AI',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.textPrimary),
            ),
          ],
        ),
        actions: [
          Semantics(
            label: 'Settings',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
              tooltip: 'Settings',
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome + Tools Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WELCOME BACK, ALEX',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  _buildToolsButton(context),
                ],
              ),
            ),

            // Big heading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Ready to grow\ntoday?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Current Lesson Card
            _buildCurrentLessonCard(context),
            const SizedBox(height: 24),

            // Daily Goal
            _buildDailyGoalSection(context),
            const SizedBox(height: 20),

            // ─── Zen Mode: hide streak, badges, social ───
            if (!a11y.zenMode) ...[
              _buildLearningStreakCard(context),
              const SizedBox(height: 20),
            ],

            // Offline Lessons
            _buildOfflineLessonsCard(context),
            const SizedBox(height: 20),

            // Upcoming Assessment
            _buildUpcomingAssessmentCard(context),
            const SizedBox(height: 28),

            // Personalized section — hidden in zen mode
            if (!a11y.zenMode) ...[
              _buildPersonalizedSection(context),
            ],

            const SizedBox(height: 120),
          ],
        ),
      ),
      // Mic FAB
      floatingActionButton: Semantics(
        label: 'Voice command',
        button: true,
        child: FloatingActionButton(
          heroTag: 'student_mic_fab',
          tooltip: 'Voice command',
          onPressed: () {
            HapticFeedback.lightImpact();
          },
          backgroundColor: AppTheme.brandPrimary,
          child: const Icon(Icons.mic, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildToolsButton(BuildContext context) {
    final a11y = Provider.of<AccessibilityProvider>(context);
    return Semantics(
      label: 'Accessibility tools',
      button: true,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (ctx) => _buildAccessibilitySheet(ctx, a11y),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              const Text(
                'TOOLS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              Row(
                children: [
                  _toolIcon(Icons.text_fields, a11y.textSizeScale > 1.0),
                  _toolIcon(Icons.contrast, a11y.highContrast),
                  _toolIcon(Icons.font_download_outlined, a11y.dyslexiaFont),
                  _toolIcon(Icons.self_improvement, a11y.zenMode),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolIcon(IconData icon, bool active) {
    return ExcludeSemantics(
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: active ? AppTheme.brandPrimary.withValues(alpha: 0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: active ? AppTheme.brandPrimary : Colors.grey),
      ),
    );
  }

  Widget _buildAccessibilitySheet(BuildContext ctx, AccessibilityProvider prov) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accessibility Tools',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Larger Text'),
            subtitle: const Text('Increase text size for readability'),
            value: prov.textSizeScale > 1.0,
            onChanged: (_) => prov.setTextSize(prov.textSizeScale == 1.0 ? 1.3 : 1.0),
            secondary: const Icon(Icons.text_fields),
          ),
          SwitchListTile(
            title: const Text('High Contrast'),
            subtitle: const Text('Black & white for visual clarity'),
            value: prov.highContrast,
            onChanged: (_) => prov.toggleHighContrast(),
            secondary: const Icon(Icons.contrast),
          ),
          SwitchListTile(
            title: const Text('Dyslexia Font'),
            subtitle: const Text('Use Lexend font for easier reading'),
            value: prov.dyslexiaFont,
            onChanged: (_) => prov.toggleDyslexiaFont(),
            secondary: const Icon(Icons.font_download_outlined),
          ),
          SwitchListTile(
            title: const Text('Zen Mode'),
            subtitle: const Text('Hide streaks, badges & social features'),
            value: prov.zenMode,
            onChanged: (_) => prov.toggleZenMode(),
            secondary: const Icon(Icons.self_improvement),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCurrentLessonCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Semantics(
        label: 'Current lesson: Introduction to Ecosystems, Module 4: Sustainable Balance. Tap to resume.',
        button: true,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LessonScreen()));
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                      SizedBox(width: 6),
                      Text(
                        'CURRENT LESSON',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Introduction to\nEcosystems',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Module 4: Sustainable Balance',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'RESUME',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16, color: AppTheme.textPrimary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyGoalSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Semantics(
        label: 'Daily goal: 12 of 20 minutes reading completed. 8 minutes left.',
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DAILY GOAL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '20 mins reading',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: 12 / 20,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brandPrimary),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '12',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                          ),
                          Text('/20 min', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    children: [
                      TextSpan(text: "You're doing great! Only "),
                      TextSpan(
                        text: '8 minutes',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      TextSpan(text: '\nleft to hit your target.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningStreakCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Semantics(
        label: 'Learning streak: 14 days. 5 of 7 days completed this week.',
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bar_chart, color: AppTheme.textPrimary, size: 24),
              ),
              const SizedBox(height: 12),
              const Text(
                'Learning Streak',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                '14 Days',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  return Semantics(
                    label: 'Day ${i + 1}: ${i < 5 ? 'completed' : 'not yet'}',
                    child: Container(
                      width: 32,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i < 5 ? AppTheme.brandPrimary : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineLessonsCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Semantics(
        label: 'Offline lessons: 3 modules ready for your commute.',
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.download_for_offline, color: AppTheme.textPrimary, size: 24),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Offline Lessons',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3 modules ready for your morning commute.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Semantics(
                      button: true,
                      label: 'Manage downloads',
                      child: InkWell(
                        onTap: () {},
                        child: const Text(
                          'Manage Downloads >',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.brandPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ExcludeSemantics(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.cloud_download, color: AppTheme.brandPrimary, size: 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingAssessmentCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Semantics(
        label: 'Upcoming assessment: Ecological Networks, Friday 10:00 AM. In 2 days.',
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFEF5350)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcoming\nAssessment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ecological Networks -\nFriday, 10:00 AM',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      'IN',
                      style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '2d',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalizedSection(BuildContext context) {
    final courses = [
      {'category': 'SCIENCE', 'title': 'Bio-Diversity Basics', 'time': '15 min', 'color': AppTheme.brandPrimary, 'bgColor': const Color(0xFF1A237E)},
      {'category': 'LOGIC', 'title': 'Spatial Thinking', 'time': '10 min', 'color': const Color(0xFFE53935), 'bgColor': const Color(0xFF37474F)},
      {'category': 'CREATIVITY', 'title': 'Visual Storytelling', 'time': '25 min', 'color': AppTheme.successColor, 'bgColor': const Color(0xFFBF360C)},
      {'category': 'TECH', 'title': 'Neural Networks 101', 'time': '20 min', 'color': const Color(0xFFFF8F00), 'bgColor': const Color(0xFF263238)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personalized for you',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              Semantics(
                button: true,
                label: 'View all courses',
                child: InkWell(
                  onTap: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: AppTheme.brandPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...courses.map((c) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Semantics(
            label: '${c['category']} course: ${c['title']}. Duration: ${c['time']}.',
            button: true,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: c['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image area with alt text
                    Semantics(
                      image: true,
                      label: '${c['title']} course thumbnail',
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: (c['bgColor'] as Color).withValues(alpha: 0.8),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Center(
                          child: Icon(Icons.image, size: 48, color: Colors.white.withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['category'] as String,
                            style: TextStyle(
                              color: c['color'] as Color,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.white.withValues(alpha: 0.6)),
                              const SizedBox(width: 4),
                              Text(
                                c['time'] as String,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }
}
