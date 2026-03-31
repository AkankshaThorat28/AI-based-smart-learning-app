import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/accessibility_provider.dart';
import '../../theme/app_theme.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> with SingleTickerProviderStateMixin {
  String _selectedOption = '';
  Timer? _idleTimer;
  bool _hintShown = false;
  bool _showAccessibilityToolbar = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _startIdleTimer();
  }

  void _startIdleTimer() {
    _idleTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && !_hintShown && _selectedOption.isEmpty) {
        _showAIHint(
          "I noticed you're taking your time. Remember to apply the order of operations!",
          showNeedHelp: true,
        );
        setState(() => _hintShown = true);
      }
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _showAIHint(String message, {bool showNeedHelp = false}) {
    final a11y = Provider.of<AccessibilityProvider>(context, listen: false);

    // Visual alert if enabled
    if (a11y.visualAlerts) {
      HapticFeedback.heavyImpact();
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Semantics(
          label: 'AI Hint: $message',
          liveRegion: true,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy, size: 32, color: AppTheme.brandPrimary),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.5, color: AppTheme.textSecondary),
                ),
                if (showNeedHelp) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF5350),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('I need help', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Got it!'),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleAnswer(String option) {
    setState(() => _selectedOption = option);
    _idleTimer?.cancel();

    if (option == 'B') {
      // Correct — multi-modal feedback
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            liveRegion: true,
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Correct! Great job!'),
              ],
            ),
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } else if (option == 'C') {
      HapticFeedback.lightImpact();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showAIHint("Check your multiplication! 15 × 2 = 30, then add 5. The correct answer should be 35, not 40.");
        }
      });
    } else if (option == 'A') {
      HapticFeedback.lightImpact();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showAIHint("Close! You calculated x × 2 = 30 correctly, but don't forget to add 5 to the result.");
        }
      });
    } else if (option == 'D') {
      HapticFeedback.lightImpact();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showAIHint("Not quite. Remember: y = x * 2 + 5. First multiply x by 2, then add 5.");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final a11y = Provider.of<AccessibilityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Semantics(
          label: 'Go back',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            tooltip: 'Go back',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(color: AppTheme.brandPrimary, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Saamya AI', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary)),
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
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT MODULE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question 3',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Semantics(
                      label: 'Accessibility toolbar',
                      button: true,
                      child: Tooltip(
                        message: 'Accessibility tools',
                        child: InkWell(
                          onTap: () => setState(() => _showAccessibilityToolbar = !_showAccessibilityToolbar),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.brandPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.accessibility_new, size: 16, color: AppTheme.brandPrimary),
                                SizedBox(width: 4),
                                Text('Tools', style: TextStyle(fontSize: 12, color: AppTheme.brandPrimary, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Adaptive Logic tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ADAPTIVE LOGIC',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.brandPrimary, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 24),

                // Question text
                Semantics(
                  label: 'If the variable x is defined as 15, and the equation y = x * 2 + 5 is executed, what is the final value of y?',
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, height: 1.5),
                      children: const [
                        TextSpan(text: 'If the variable  '),
                        TextSpan(text: 'x ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                        TextSpan(text: 'is defined as 15, and the\n'),
                        TextSpan(text: '       y = x * 2 + 5\n', style: TextStyle(fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.w700)),
                        TextSpan(text: 'is executed, what is the final value of  '),
                        TextSpan(text: 'y', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                        TextSpan(text: ' ?'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Option Cards with Semantics
                _buildOptionCard('A', '30', false),
                _buildOptionCard('B', '35', true),
                _buildOptionCard('C', '40', false),
                _buildOptionCard('D', '25', false),

                const SizedBox(height: 120),
              ],
            ),
          ),

          // Accessibility Toolbar Overlay
          if (_showAccessibilityToolbar)
            Positioned(
              right: 16,
              top: 60,
              child: Semantics(
                label: 'Accessibility toolbar',
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ACCESSIBILITY TOOLBAR',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 12),
                        _buildToolbarItem(Icons.text_fields, 'Text Size', a11y.textSizeScale > 1.0, () {
                          a11y.setTextSize(a11y.textSizeScale == 1.0 ? 1.3 : 1.0);
                        }),
                        _buildToolbarItem(Icons.contrast, 'High Contrast', a11y.highContrast, () {
                          a11y.toggleHighContrast();
                        }),
                        _buildToolbarItem(Icons.font_download, 'Dyslexia Font', a11y.dyslexiaFont, () {
                          a11y.toggleDyslexiaFont();
                        }),
                        _buildToolbarItem(Icons.self_improvement, 'Zen Mode', a11y.zenMode, () {
                          a11y.toggleZenMode();
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Voice Input Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Say "Option A" or "Option B"...',
                        style: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
                      ),
                    ),
                    Semantics(
                      label: _isListening ? 'Stop listening' : 'Start voice input',
                      button: true,
                      child: Tooltip(
                        message: _isListening ? 'Stop listening' : 'Voice input',
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _isListening = !_isListening);
                            if (_isListening) {
                              Future.delayed(const Duration(seconds: 3), () {
                                if (mounted) setState(() => _isListening = false);
                              });
                            }
                          },
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: _isListening ? const Color(0xFFEF5350) : AppTheme.brandPrimary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (_isListening)
                                  BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 2),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return Semantics(
      label: '$label: ${active ? 'On' : 'Off'}',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: active ? AppTheme.brandPrimary.withValues(alpha: 0.15) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: active ? AppTheme.brandPrimary : AppTheme.textSecondary),
              ),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
              const Spacer(),
              if (active) const Icon(Icons.check_circle, size: 16, color: AppTheme.brandPrimary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(String letter, String value, bool isCorrect) {
    bool isSelected = _selectedOption == letter;
    bool showCorrect = isSelected && isCorrect;
    bool showWrong = isSelected && !isCorrect;

    Color borderColor = Colors.grey.shade200;
    Color bgColor = Colors.white;
    Color letterBg = Colors.grey.shade100;
    Color letterColor = AppTheme.textPrimary;

    if (showCorrect) {
      borderColor = AppTheme.successColor;
      bgColor = Colors.green.shade50;
      letterBg = AppTheme.successColor;
      letterColor = Colors.white;
    } else if (showWrong) {
      borderColor = Colors.red.shade300;
      bgColor = Colors.red.shade50;
      letterBg = Colors.red;
      letterColor = Colors.white;
    }

    return Semantics(
      label: 'Option $letter: $value${showCorrect ? ', correct' : ''}${showWrong ? ', incorrect' : ''}',
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: () => _handleAnswer(letter),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: letterBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: showWrong
                    ? const Icon(Icons.close, color: Colors.white, size: 22)
                    : showCorrect
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : Text(letter, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: letterColor)),
              ),
              const SizedBox(width: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: showWrong ? Colors.red.shade900 : AppTheme.textPrimary,
                ),
              ),
              if (showWrong) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Check your work!',
                    style: TextStyle(fontSize: 10, color: Colors.orange.shade800, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
