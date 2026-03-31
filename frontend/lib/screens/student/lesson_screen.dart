import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../theme/app_theme.dart';
import 'assessment_screen.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool isEasyReadMode = false;
  bool isLoadingEasyRead = false;
  bool isAudioPlaying = false;
  bool isDeafAssistOn = false;
  double audioProgress = 0.0;

  final FlutterTts flutterTts = FlutterTts();

  final String standardText =
      '''An ecosystem is a geographic area where plants, animals, and other organisms, as well as weather and landscape, work together to form a bubble of life. Ecosystems contain biotic or living, parts, as well as abiotic factors, or nonliving parts.

Biotic factors include plants, animals, and other organisms. Abiotic factors include rocks, temperature, and humidity. Every factor in an ecosystem depends on every other factor, either directly or indirectly. A change in the temperature of an ecosystem will often affect what plants will grow there, for instance.''';

  final String simplifiedText =
      '''An ecosystem is a place where living things and non-living things work together.

Living things (biotic) include:
• Plants
• Animals

Non-living things (abiotic) include:
• Rocks
• Weather (like rain and sun)

Everything in an ecosystem is connected. For example, if it gets too hot, some plants might not grow!''';

  final String sectionTwoText =
      '''Ecosystems can be very large or very small. Tide pools, the stuck-together pools of water left by the ocean when the tide goes out, are complete, tiny ecosystems. Tide pools contain seaweed, a type of algae, which uses photosynthesis to create food.''';

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _toggleEasyRead() async {
    setState(() => isLoadingEasyRead = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      isEasyReadMode = !isEasyReadMode;
      isLoadingEasyRead = false;
    });
  }

  void _toggleAudio() async {
    if (isAudioPlaying) {
      await flutterTts.stop();
      setState(() => isAudioPlaying = false);
    } else {
      setState(() => isAudioPlaying = true);
      await flutterTts.speak(isEasyReadMode ? simplifiedText : standardText);
      flutterTts.setCompletionHandler(() {
        if (mounted) setState(() => isAudioPlaying = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: const BoxDecoration(
                color: AppTheme.brandPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'Saamya AI',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary),
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
        ],
      ),
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category tag
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 8),
                  child: Text(
                    'SCIENCE & NATURE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.brandPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'What are\nEcosystems?',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // EasyRead Mode Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Semantics(
                    label: 'EasyRead Mode: ${isEasyReadMode ? 'On' : 'Off'}. Simplifies complex terms.',
                    toggled: isEasyReadMode,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isEasyReadMode
                            ? AppTheme.brandPrimary.withValues(alpha: 0.08)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isEasyReadMode
                              ? AppTheme.brandPrimary.withValues(alpha: 0.3)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.menu_book, size: 20, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'EasyRead Mode',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                Text(
                                  'Simplifying complex terms',
                                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: isEasyReadMode ? 'Turn off EasyRead' : 'Turn on EasyRead',
                            child: InkWell(
                              onTap: _toggleEasyRead,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.brandPrimary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isEasyReadMode ? 'Turn Off' : 'Turn On',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
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
                const SizedBox(height: 24),

                // Main lesson text
                if (isLoadingEasyRead)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildLessonText(context),
                  ),
                const SizedBox(height: 24),

                // Forest Image with alt text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Semantics(
                    image: true,
                    label: 'Illustration of a temperate forest ecosystem showing trees, moss, and filtered sunlight demonstrating biotic and abiotic factors.',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade800,
                              Colors.green.shade600,
                              Colors.brown.shade400,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(painter: _ForestPainter()),
                            ),
                            Center(
                              child: Icon(
                                Icons.park,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Visual Breakdown caption
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.visibility, color: AppTheme.brandPrimary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Visual Breakdown',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppTheme.brandPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This temperate forest shows the interaction between the water (abiotic), the sunlight (abiotic), and the dense trees and moss (biotic) that thrive in this specific temperature range.',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Section 2
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'The Delicate Balance',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    sectionTwoText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Take Assessment button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AssessmentScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Take Assessment', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Deaf Assist PiP Window
          if (isDeafAssistOn)
            Positioned(
              right: 16,
              bottom: 120,
              child: Semantics(
                label: 'Sign language interpreter window. Currently signing lesson content.',
                child: Container(
                  width: 90,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                      ),
                    ],
                    border: Border.all(color: AppTheme.brandPrimary, width: 2),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sign_language, size: 40, color: AppTheme.brandPrimary),
                      SizedBox(height: 6),
                      Text(
                        'Signing...',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Sticky bottom media bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Audio progress bar
                    if (isAudioPlaying)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Semantics(
                          label: 'Audio playing',
                          child: LinearProgressIndicator(
                            value: null,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brandPrimary),
                            minHeight: 3,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        // Play/pause button (≥44x44)
                        Semantics(
                          label: isAudioPlaying ? 'Pause audio' : 'Play audio',
                          button: true,
                          child: InkWell(
                            onTap: _toggleAudio,
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: AppTheme.brandPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isAudioPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Listen to Lesson',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              Text(
                                isAudioPlaying ? 'Playing...' : 'Tap play to listen',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        // Deaf Assist toggle
                        Semantics(
                          label: 'Deaf Assist: ${isDeafAssistOn ? 'On' : 'Off'}',
                          toggled: isDeafAssistOn,
                          child: Column(
                            children: [
                              const Text(
                                'Deaf Assist',
                                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                              Switch(
                                value: isDeafAssistOn,
                                onChanged: (val) => setState(() => isDeafAssistOn = val),
                              ),
                            ],
                          ),
                        ),
                        // Voice input mic (≥44x44)
                        Semantics(
                          label: 'Voice input',
                          button: true,
                          child: Tooltip(
                            message: 'Voice input',
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                              },
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: AppTheme.brandPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.mic, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildLessonText(BuildContext context) {
    final text = isEasyReadMode ? simplifiedText : standardText;
    final parts = text.split('ecosystem');
    if (parts.length <= 1) {
      return Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppTheme.textSecondary,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppTheme.textSecondary,
        ),
        children: [
          for (int i = 0; i < parts.length; i++) ...[
            TextSpan(text: parts[i]),
            if (i < parts.length - 1)
              TextSpan(
                text: 'ecosystem',
                style: TextStyle(
                  color: AppTheme.brandPrimary,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.brandPrimary.withValues(alpha: 0.4),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// Forest painter
class _ForestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final darkGreen = Paint()
      ..color = Colors.green.shade900.withValues(alpha: 0.6);
    final medGreen = Paint()
      ..color = Colors.green.shade700.withValues(alpha: 0.4);

    for (double x = 30; x < size.width; x += 60) {
      canvas.drawRect(
        Rect.fromLTWH(x, size.height * 0.5, 8, size.height * 0.5),
        Paint()..color = Colors.brown.shade700.withValues(alpha: 0.3),
      );
      canvas.drawCircle(Offset(x + 4, size.height * 0.4), 25, darkGreen);
      canvas.drawCircle(Offset(x + 14, size.height * 0.35), 20, medGreen);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
