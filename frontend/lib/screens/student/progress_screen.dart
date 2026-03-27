import 'package:flutter/material.dart';
import 'dart:math';
import '../../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              'Progress',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Overall Progress Ring
            _buildOverallProgressCard(context),
            const SizedBox(height: 20),

            // Learning Velocity Chart
            _buildLearningVelocityCard(context),
            const SizedBox(height: 20),

            // Subject Breakdown
            _buildSubjectBreakdown(context),
            const SizedBox(height: 20),

            // Milestones
            _buildMilestonesCard(context),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ─── Overall Progress ────────────────────────────────────
  Widget _buildOverallProgressCard(BuildContext context) {
    return Semantics(
      label: 'Overall progress: 72% complete. 18 of 25 modules finished.',
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Progress ring
            SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                painter: _ProgressRingPainter(0.72),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '72%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Complete',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '18 of 25 modules completed',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '7 modules remaining',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Learning Velocity ───────────────────────────────────
  Widget _buildLearningVelocityCard(BuildContext context) {
    final data = [
      {'day': 'Mon', 'value': 0.6},
      {'day': 'Tue', 'value': 0.8},
      {'day': 'Wed', 'value': 0.45},
      {'day': 'Thu', 'value': 0.9},
      {'day': 'Fri', 'value': 0.7},
      {'day': 'Sat', 'value': 0.3},
      {'day': 'Sun', 'value': 0.55},
    ];

    // Patterns for colorblind support
    final patterns = [
      _BarPattern.solid,
      _BarPattern.diagonal,
      _BarPattern.dots,
      _BarPattern.horizontal,
      _BarPattern.solid,
      _BarPattern.diagonal,
      _BarPattern.dots,
    ];

    return Semantics(
      label: 'Learning velocity chart showing daily study minutes this week',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Learning Velocity',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '+12% this week',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Bar chart with patterns and data labels
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(data.length, (i) {
                  final val = data[i]['value'] as double;
                  final day = data[i]['day'] as String;
                  final minutes = (val * 30).toInt();
                  return Expanded(
                    child: Semantics(
                      label: '$day: $minutes minutes',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Data label on top of bar
                            Text(
                              '${minutes}m',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Bar with pattern
                            Flexible(
                              child: Container(
                                width: double.infinity,
                                height: val * 120,
                                decoration: BoxDecoration(
                                  color: AppTheme.brandPrimary,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: _PatternPainter(patterns[i]),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              day,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Subject Breakdown ───────────────────────────────────
  Widget _buildSubjectBreakdown(BuildContext context) {
    final subjects = [
      {'name': 'Science & Nature', 'progress': 0.85, 'color': AppTheme.successColor, 'icon': Icons.eco},
      {'name': 'Mathematics', 'progress': 0.72, 'color': AppTheme.brandPrimary, 'icon': Icons.calculate},
      {'name': 'Technology', 'progress': 0.60, 'color': const Color(0xFFFF8F00), 'icon': Icons.computer},
      {'name': 'Creative Arts', 'progress': 0.45, 'color': const Color(0xFF7B1FA2), 'icon': Icons.palette},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subject Breakdown',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...subjects.map((s) {
            final progress = s['progress'] as double;
            final name = s['name'] as String;
            final color = s['color'] as Color;
            final icon = s['icon'] as IconData;
            return Semantics(
              label: '$name: ${(progress * 100).toInt()}% complete',
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              // Data label — not just color
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Milestones ──────────────────────────────────────────
  Widget _buildMilestonesCard(BuildContext context) {
    final milestones = [
      {'title': 'First Lesson Completed', 'date': 'Sep 1', 'done': true},
      {'title': '7-Day Streak', 'date': 'Sep 8', 'done': true},
      {'title': '10 Modules Complete', 'date': 'Sep 20', 'done': true},
      {'title': 'Perfect Quiz Score', 'date': 'Oct 2', 'done': true},
      {'title': 'All Science Modules', 'date': 'In progress', 'done': false},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Milestones',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...milestones.map((m) {
            final done = m['done'] as bool;
            return Semantics(
              label: '${m['title']}: ${done ? 'Completed on ${m['date']}' : m['date']}',
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: done
                            ? AppTheme.successColor.withValues(alpha: 0.15)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        done ? Icons.check : Icons.flag_outlined,
                        size: 16,
                        color: done ? AppTheme.successColor : AppTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        m['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: done ? AppTheme.textPrimary : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      m['date'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: done ? AppTheme.textSecondary : AppTheme.brandPrimary,
                        fontWeight: done ? FontWeight.w400 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Custom Painters ─────────────────────────────────────────

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  _ProgressRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

enum _BarPattern { solid, diagonal, dots, horizontal }

class _PatternPainter extends CustomPainter {
  final _BarPattern pattern;
  _PatternPainter(this.pattern);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    switch (pattern) {
      case _BarPattern.solid:
        break;
      case _BarPattern.diagonal:
        for (double y = -size.width; y < size.height + size.width; y += 8) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y + size.width), paint);
        }
        break;
      case _BarPattern.dots:
        final dotPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;
        for (double x = 4; x < size.width; x += 8) {
          for (double y = 4; y < size.height; y += 8) {
            canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
          }
        }
        break;
      case _BarPattern.horizontal:
        for (double y = 4; y < size.height; y += 6) {
          canvas.drawLine(Offset(2, y), Offset(size.width - 2, y), paint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
