import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EducatorDashboard extends StatelessWidget {
  const EducatorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.purple.shade700, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saamya AI', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary)),
                Text(
                  'ST. CALLISTUS ACADEMY',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textTertiary, letterSpacing: 1),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Semantics(
            label: 'Notifications',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: AppTheme.textSecondary),
              tooltip: 'Notifications',
              onPressed: () {},
            ),
          ),
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
            // Morning Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'MORNING SUMMARY',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.brandPrimary, letterSpacing: 0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Hello, Dr. Sarah.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Your class is performing 12% above average today. Most students are currently focused on "Neural Networks Basics".',
                style: TextStyle(color: AppTheme.textSecondary, height: 1.5, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Assign Lesson', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Message Class', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: '28 active students',
                      child: _buildStatCard(Icons.people_outline, '28', 'ACTIVE STUDENTS', AppTheme.brandPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Semantics(
                      label: '84% average progress',
                      child: _buildStatCard(Icons.show_chart, '84%', 'AVG. PROGRESS', Colors.purple),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ─── Intervention Alerts ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Action Items',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            _buildInterventionAlert(
              context,
              name: 'Jordan Diaz',
              message: 'Has missed 3 audio-based quizzes. Suggest turning on closed captions or offering a text-based alternative.',
              severity: 'high',
              action: 'Enable Captions',
            ),
            const SizedBox(height: 8),
            _buildInterventionAlert(
              context,
              name: 'Alex Martinez',
              message: 'Lingering on quiz questions for 5+ minutes. May benefit from AI hints being enabled.',
              severity: 'medium',
              action: 'Enable Hints',
            ),
            const SizedBox(height: 28),

            // Class Roster
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Class Roster', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  Semantics(
                    button: true,
                    label: 'View all students',
                    child: InkWell(
                      onTap: () {},
                      child: const Text('View All', style: TextStyle(color: AppTheme.brandPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildStudentRow('Alex M.', 'Logic Gates & Circuits', 65, 'ATTENTION REQUIRED', true),
                  const SizedBox(height: 10),
                  _buildStudentRow('Maya C.', 'Natural Language Processing', 92, 'ON TRACK', false),
                  const SizedBox(height: 10),
                  _buildStudentRow('Jordan T.', 'Logic Gates & Circuits', 40, 'ON TRACK', false),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ─── Accessibility Health Dashboard ────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.accessibility_new, color: AppTheme.brandPrimary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('Accessibility Health', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    // Feature usage stats
                    _buildA11yStatRow(Icons.volume_up, 'Audio Description', 18, AppTheme.brandPrimary),
                    const SizedBox(height: 16),
                    _buildA11yStatRow(Icons.menu_book, 'EasyRead Mode', 10, Colors.orange),
                    const SizedBox(height: 16),
                    _buildA11yStatRow(Icons.contrast, 'High Contrast', 7, Colors.purple),
                    const SizedBox(height: 16),
                    _buildA11yStatRow(Icons.font_download, 'Dyslexia Font', 5, AppTheme.successColor),
                    const SizedBox(height: 16),
                    _buildA11yStatRow(Icons.text_fields, 'Text Scaling', 12, const Color(0xFFFF8F00)),
                    const SizedBox(height: 16),
                    _buildA11yStatRow(Icons.record_voice_over, 'Voice Navigation', 3, Colors.teal),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.brandPrimary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '"Visual learners in your class have increased engagement by 15% since enabling multi-modal content."',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ─── Global Overrides ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text('Class Overrides', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.admin_panel_settings, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text('Push Settings to Class', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Override accessibility settings for all students in this class.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildOverrideChip('Dyslexia Font', Icons.font_download),
                        _buildOverrideChip('High Contrast', Icons.contrast),
                        _buildOverrideChip('Large Text', Icons.text_fields),
                        _buildOverrideChip('Captions On', Icons.closed_caption),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Upcoming Deadlines
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Upcoming Deadlines', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 16),
                    _buildDeadlineRow(Icons.quiz, 'Quiz 4: Machine Learning Ethics', 'Tomorrow'),
                    const SizedBox(height: 12),
                    _buildDeadlineRow(Icons.rocket_launch, 'Project: AI for Social Good', 'Oct 14'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ─── Stat Card ───────────────────────────────────────────
  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1)),
        ],
      ),
    );
  }

  // ─── Intervention Alert ──────────────────────────────────
  Widget _buildInterventionAlert(BuildContext context, {
    required String name,
    required String message,
    required String severity,
    required String action,
  }) {
    final isHigh = severity == 'high';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Semantics(
        label: 'Alert for $name: $message',
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHigh ? Colors.red.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHigh ? Colors.red.shade200 : Colors.orange.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isHigh ? Icons.warning_amber : Icons.info_outline,
                    color: isHigh ? Colors.red.shade700 : Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isHigh ? Colors.red.shade900 : Colors.orange.shade900,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isHigh ? Colors.red.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      severity.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isHigh ? Colors.red.shade700 : Colors.orange.shade700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.auto_fix_high, size: 16),
                  label: Text(action, style: const TextStyle(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isHigh ? Colors.red.shade700 : Colors.orange.shade700,
                    side: BorderSide(color: isHigh ? Colors.red.shade300 : Colors.orange.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Student Row ─────────────────────────────────────────
  Widget _buildStudentRow(String name, String lesson, int score, String status, bool attention) {
    return Semantics(
      label: '$name. Lesson: $lesson. Score: $score%. Status: $status',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.shade50,
              child: Icon(Icons.person, color: Colors.blue.shade300, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(width: 4),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
                        tooltip: 'More options for $name',
                        onPressed: () {},
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: attention ? Colors.red.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: attention ? Colors.red : AppTheme.successColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Lesson: $lesson', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Text(
              '$score%',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: attention ? Colors.red : AppTheme.brandPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── A11y Stat Row ───────────────────────────────────────
  Widget _buildA11yStatRow(IconData icon, String label, int studentCount, Color color) {
    return Semantics(
      label: '$label: used by $studentCount students',
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$studentCount students',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Override Chip ───────────────────────────────────────
  Widget _buildOverrideChip(String label, IconData icon) {
    return Semantics(
      button: true,
      label: 'Push $label to all students',
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Deadline Row ────────────────────────────────────────
  Widget _buildDeadlineRow(IconData icon, String title, String date) {
    return Semantics(
      label: '$title. Due: $date',
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
          Text(date, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
        ],
      ),
    );
  }
}
