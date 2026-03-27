import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/accessibility_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              'Settings',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ],
        ),
      ),
      body: Consumer<AccessibilityProvider>(
        builder: (context, a11y, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              // Profile header
              _buildProfileHeader(context),
              const SizedBox(height: 24),

              // ── Visual Accessibility ──
              _buildSectionHeader(context, Icons.visibility, 'Visual', 'Low vision, blindness, colorblindness'),
              const SizedBox(height: 12),
              _buildSliderTile(
                context: context,
                icon: Icons.text_fields,
                title: 'Text Size',
                subtitle: '${(a11y.textSizeScale * 100).toInt()}% — Scale text for readability',
                value: a11y.textSizeScale,
                min: 0.8,
                max: 2.0,
                divisions: 12,
                onChanged: a11y.setTextSize,
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.contrast,
                title: 'High Contrast',
                subtitle: 'Black & white for maximum clarity',
                value: a11y.highContrast,
                onChanged: (_) => a11y.toggleHighContrast(),
              ),
              _buildDropdownTile(
                context: context,
                icon: Icons.palette_outlined,
                title: 'Colorblind Mode',
                subtitle: 'Adjust colors for color vision deficiency',
                value: a11y.colorblindMode,
                items: const {
                  'none': 'Off',
                  'protanopia': 'Protanopia (Red-blind)',
                  'deuteranopia': 'Deuteranopia (Green-blind)',
                  'tritanopia': 'Tritanopia (Blue-blind)',
                },
                onChanged: (v) => a11y.setColorblindMode(v ?? 'none'),
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.center_focus_strong,
                title: 'Focus Indicators',
                subtitle: 'Visible outline on selected elements',
                value: a11y.focusIndicators,
                onChanged: (_) => a11y.toggleFocusIndicators(),
              ),
              const SizedBox(height: 28),

              // ── Cognitive Accessibility ──
              _buildSectionHeader(context, Icons.psychology, 'Cognitive', 'ADHD, dyslexia, autism support'),
              const SizedBox(height: 12),
              _buildSwitchTile(
                context: context,
                icon: Icons.font_download_outlined,
                title: 'Dyslexia-Friendly Font',
                subtitle: 'Switch to Lexend for easier reading',
                value: a11y.dyslexiaFont,
                onChanged: (_) => a11y.toggleDyslexiaFont(),
              ),
              _buildSliderTile(
                context: context,
                icon: Icons.format_line_spacing,
                title: 'Line Spacing',
                subtitle: '${a11y.lineSpacing.toStringAsFixed(1)}× — Space between lines',
                value: a11y.lineSpacing,
                min: 1.0,
                max: 2.5,
                divisions: 15,
                onChanged: a11y.setLineSpacing,
              ),
              _buildSliderTile(
                context: context,
                icon: Icons.space_bar,
                title: 'Letter Spacing',
                subtitle: '${a11y.letterSpacing.toStringAsFixed(1)}px — Space between characters',
                value: a11y.letterSpacing,
                min: 0.0,
                max: 3.0,
                divisions: 6,
                onChanged: a11y.setLetterSpacing,
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.self_improvement,
                title: 'Zen Mode',
                subtitle: 'Hide streaks, badges & social features',
                value: a11y.zenMode,
                onChanged: (_) => a11y.toggleZenMode(),
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.motion_photos_off,
                title: 'Reduced Motion',
                subtitle: 'Pause all animations and transitions',
                value: a11y.reducedMotion,
                onChanged: (_) => a11y.toggleReducedMotion(),
              ),
              const SizedBox(height: 28),

              // ── Motor Accessibility ──
              _buildSectionHeader(context, Icons.accessibility_new, 'Motor', 'Tremors, limited dexterity'),
              const SizedBox(height: 12),
              _buildSwitchTile(
                context: context,
                icon: Icons.touch_app,
                title: 'Large Touch Targets',
                subtitle: 'Increase button sizes to 48×48 minimum',
                value: a11y.largeTouchTargets,
                onChanged: (_) => a11y.toggleLargeTouchTargets(),
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.record_voice_over,
                title: 'Voice Navigation',
                subtitle: 'Control the app with voice commands',
                value: a11y.voiceNavigation,
                onChanged: (_) => a11y.toggleVoiceNavigation(),
              ),
              const SizedBox(height: 28),

              // ── Auditory Accessibility ──
              _buildSectionHeader(context, Icons.hearing, 'Auditory', 'Deafness, hard of hearing'),
              const SizedBox(height: 12),
              _buildSwitchTile(
                context: context,
                icon: Icons.flash_on,
                title: 'Visual Alerts',
                subtitle: 'Flash and banner for audio notifications',
                value: a11y.visualAlerts,
                onChanged: (_) => a11y.toggleVisualAlerts(),
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.closed_caption,
                title: 'Closed Captions',
                subtitle: 'Show captions for all audio/video',
                value: a11y.closedCaptions,
                onChanged: (_) => a11y.toggleClosedCaptions(),
              ),
              const SizedBox(height: 28),

              // ── App Info ──
              _buildSectionHeader(context, Icons.info_outline, 'About', 'App information'),
              const SizedBox(height: 12),
              _buildInfoTile(context, 'Version', '1.0.0'),
              _buildInfoTile(context, 'Accessibility Standard', 'WCAG 2.1 AA'),
              const SizedBox(height: 120),
            ],
          );
        },
      ),
    );
  }

  // ─── Profile Header ──────────────────────────────────────
  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alex Martinez',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                ),
                SizedBox(height: 2),
                Text(
                  'Grade 8 · Personalization Settings',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ──────────────────────────────────────
  Widget _buildSectionHeader(BuildContext context, IconData icon, String title, String subtitle) {
    return Semantics(
      header: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.brandPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.brandPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Switch Tile ─────────────────────────────────────────
  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Semantics(
      toggled: value,
      label: '$title. $subtitle',
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: value
              ? AppTheme.brandPrimary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value
                ? AppTheme.brandPrimary.withValues(alpha: 0.2)
                : Colors.grey.shade200,
          ),
        ),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          secondary: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value
                  ? AppTheme.brandPrimary.withValues(alpha: 0.15)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: value ? AppTheme.brandPrimary : AppTheme.textSecondary,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ─── Slider Tile ─────────────────────────────────────────
  Widget _buildSliderTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Semantics(
      label: '$title. $subtitle',
      slider: true,
      value: value.toStringAsFixed(1),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dropdown Tile ───────────────────────────────────────
  Widget _buildDropdownTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Semantics(
      label: '$title. Currently set to ${items[value]}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: value != 'none'
              ? AppTheme.brandPrimary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value != 'none'
                ? AppTheme.brandPrimary.withValues(alpha: 0.2)
                : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: value != 'none'
                        ? AppTheme.brandPrimary.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: value != 'none' ? AppTheme.brandPrimary : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(12),
                  items: items.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value, style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Info tile ───────────────────────────────────────────
  Widget _buildInfoTile(BuildContext context, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppTheme.textPrimary)),
          Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
