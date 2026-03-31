import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class BlindDashboardScreen extends StatefulWidget {
  const BlindDashboardScreen({super.key});

  @override
  State<BlindDashboardScreen> createState() => _BlindDashboardScreenState();
}

class _BlindDashboardScreenState extends State<BlindDashboardScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';
  bool _isSpeaking = false;
  String _userName = 'User';

  final String _lessonText =
      "Today's topic is Artificial Intelligence in Healthcare. AI is used in medical imaging, drug discovery, and personalized medicine.";
  final String _sceneDescription =
      "Image description: A well-lit hospital room where a doctor is showing a patient an AI-generated 3D scan of their lungs on a tablet. The scan is highlighted in blue and green, indicating healthy tissue.";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTts();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await AuthService.getUserName();
    if (mounted) setState(() => _userName = name);
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
    
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _handleTopHalfTap() async {
    HapticFeedback.heavyImpact();
    if (_isSpeaking) {
      await _flutterTts.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      await _flutterTts.speak("Hi $_userName, " + _lessonText);
    }
  }

  Future<void> _handleBottomHalfTap() async {
    HapticFeedback.heavyImpact();
    if (_isSpeaking) {
      await _flutterTts.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      await _flutterTts.speak("Scene Description: " + _sceneDescription);
    }
  }

  Future<void> _handleLongPress() async {
    HapticFeedback.vibrate();
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('onStatus: $val'),
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {
            if (mounted) {
              setState(() {
                _lastWords = val.recognizedWords;
              });
            }
            if (val.finalResult) {
              await _flutterTts.speak("Let me think...");
              try {
                final userId = await AuthService.getUserId();
                final reply = await ApiService.sendChatMessage(
                  userId: userId,
                  userName: _userName,
                  message: _lastWords,
                  disabilityMode: 'blind',
                  context: 'Blind Student Dashboard',
                );
                await _flutterTts.speak(reply);
              } catch (e) {
                await _flutterTts.speak("Sorry, I encountered an error connecting to the AI.");
              }
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ----------------- TOP HALF -----------------
                Expanded(
                  flex: 1,
                  child: Semantics(
                    button: true,
                    label: "Hi $_userName, Tap to listen to today's lesson",
                    child: GestureDetector(
                      onTap: _handleTopHalfTap,
                      onLongPress: _handleLongPress,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFF000080), // Deep Navy Blue
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.volume_up,
                                      size: 64, color: Colors.white),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Hi $_userName,\nTap for Lesson",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (_isSpeaking) ...[
                                    const SizedBox(height: 16),
                                    const Text(
                                      "Speaking...",
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 16),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Divider
                Container(height: 4, color: Colors.white),

                // ----------------- BOTTOM HALF -----------------
                Expanded(
                  flex: 1,
                  child: Semantics(
                    button: true,
                    label: "AI Audio Scene Description. Also long press to speak.",
                    child: GestureDetector(
                      onTap: _handleBottomHalfTap,
                      onLongPress: _handleLongPress,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFF004D40), // Deep Teal
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isListening ? Icons.mic : Icons.image_search,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Tap for AI Scene Description\n\nLong Press to Speak",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Massive Logout Button for Blind Users
            Positioned(
              top: 0,
              right: 0,
              child: Semantics(
                button: true,
                label: "Logout from Saamya AI",
                child: GestureDetector(
                  onTap: () async {
                    HapticFeedback.vibrate();
                    await AuthService.logout();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                      ),
                    ),
                    child: const Icon(Icons.logout, color: Colors.white, size: 40),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
