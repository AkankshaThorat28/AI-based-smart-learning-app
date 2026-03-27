import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/accessibility_provider.dart';
import '../../utils/app_alerts.dart';
import 'study_material.dart';

class StudentSettings extends StatelessWidget {
  const StudentSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (context, a11y, _) {
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('Customize your experience', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 24),

                // ─── Account & Profile ─────────────────────────
                _buildSectionHeader('Account & Profile', Icons.person_outline),
                _buildCard([
                  _InfoTile(icon: Icons.email_outlined, label: 'Email', value: 'alex@school.edu'),
                  const Divider(height: 1),
                  _InfoTile(icon: Icons.phone_outlined, label: 'Contact', value: '+1 (555) 123-4567'),
                  const Divider(height: 1),
                  _InfoTile(icon: Icons.lock_outline, label: 'Password', value: '••••••••', trailing: TextButton(onPressed: () {
                    AppAlerts.showInfo(context, 'Password change dialog opening...');
                  }, child: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))),
                ]),
                const SizedBox(height: 24),

                // ─── Downloaded Content ───────────────────────
                _buildSectionHeader('Downloaded Content', Icons.download_done, subtitle: 'Click to view downloaded materials'),
                _buildCard([
                  _StorageTile(
                    title: 'Math — Quadratic Equations',
                    size: '2.4 MB',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MaterialDetailView(material: {
                        'title': 'Quadratic Equations Guide',
                        'subject': 'Mathematics',
                        'teacher': 'Mr. Anderson',
                        'date': 'Downloaded',
                        'color': Color(0xFF1E88E5),
                        'icon': Icons.calculate,
                        'description': 'This is the downloaded material for Quadratic Equations.',
                        'type': 'document'
                      })));
                    },
                  ),
                  const Divider(height: 1),
                  _StorageTile(
                    title: 'Physics — Newton\'s Laws',
                    size: '3.1 MB',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MaterialDetailView(material: {
                        'title': 'Newton\'s Laws of Motion',
                        'subject': 'Physics',
                        'teacher': 'Ms. Johnson',
                        'date': 'Downloaded',
                        'color': Color(0xFF43A047),
                        'icon': Icons.science,
                        'description': 'This is the downloaded material for Newton\'s Laws.',
                        'type': 'document'
                      })));
                    },
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: AppTheme.textTertiary),
                        const SizedBox(width: 8),
                        Text('Total: 5.5 MB used', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            AppAlerts.showSuccess(context, 'All offline storage cleared!');
                          },
                          child: const Text('Clear All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFD32F2F))),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                // ─── Visual Accessibility ──────────────────────
                _buildSectionHeader('Visual Accessibility', Icons.visibility_outlined),
                _buildCard([
                  _ToggleTile(
                    icon: Icons.self_improvement,
                    label: 'Zen Mode',
                    subtitle: 'Hide gamification & non-essential UI',
                    value: a11y.zenMode,
                    onChanged: (_) => a11y.toggleZenMode(),
                  ),
                  const Divider(height: 1),
                  _ToggleTile(
                    icon: Icons.contrast,
                    label: 'High Contrast',
                    subtitle: 'Increase color contrast for visibility',
                    value: a11y.highContrast,
                    onChanged: (_) => a11y.toggleHighContrast(),
                  ),
                ]),
                const SizedBox(height: 24),

                // ─── Typography ────────────────────────────────
                _buildSectionHeader('Typography', Icons.text_fields),
                _buildCard([
                  _ToggleTile(
                    icon: Icons.font_download_outlined,
                    label: 'Dyslexia-Friendly Font',
                    subtitle: 'Switch to OpenDyslexic-style font',
                    value: a11y.dyslexiaFont,
                    onChanged: (_) => a11y.toggleDyslexiaFont(),
                  ),
                  const Divider(height: 1),
                  _SliderTile(
                    icon: Icons.format_size,
                    label: 'Text Scaling',
                    value: a11y.textSizeScale,
                    min: 0.8,
                    max: 2.0,
                    displayValue: '${(a11y.textSizeScale * 100).round()}%',
                    onChanged: (v) => a11y.setTextSize(v),
                  ),
                ]),
                const SizedBox(height: 24),

                // ─── Audio & Voice ─────────────────────────────
                _buildSectionHeader('Audio & Voice Guidance', Icons.volume_up_outlined),
                _buildCard([
                  _ToggleTile(
                    icon: Icons.record_voice_over_outlined,
                    label: 'Voice Navigation',
                    subtitle: 'Navigate app using voice commands',
                    value: a11y.voiceNavigation,
                    onChanged: (_) => a11y.toggleVoiceNavigation(),
                  ),
                  const Divider(height: 1),
                  _ToggleTile(
                    icon: Icons.closed_caption_outlined,
                    label: 'Closed Captions',
                    subtitle: 'Show captions for audio content',
                    value: a11y.closedCaptions,
                    onChanged: (_) => a11y.toggleClosedCaptions(),
                  ),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.brandPrimary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.brandPrimary, letterSpacing: 0.5)),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoTile({required this.icon, required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textTertiary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({required this.icon, required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.brandPrimary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderTile({required this.icon, required this.label, required this.value, required this.min, required this.max, required this.displayValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.brandPrimary),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.brandPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(displayValue, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.brandPrimary)),
              ),
            ],
          ),
          Slider(value: value, min: min, max: max, divisions: ((max - min) * 10).round(), onChanged: onChanged),
        ],
      ),
    );
  }
}

class _StorageTile extends StatelessWidget {
  final String title;
  final String size;
  final VoidCallback onTap;

  const _StorageTile({required this.title, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.insert_drive_file_outlined, size: 20, color: AppTheme.textTertiary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    Text(size, style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFD32F2F)),
                onPressed: () {
                  AppAlerts.showSuccess(context, 'Deleted $title');
                },
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
