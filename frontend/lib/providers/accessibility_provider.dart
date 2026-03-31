import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityProvider extends ChangeNotifier {
  // --- Existing settings ---
  double _textSizeScale = 1.0;
  bool _highContrast = false;
  bool _dyslexiaFont = false;
  bool _zenMode = false;
  String _language = 'en'; // 'en', 'hi'


  // --- Disability type ---
  String _disabilityType = 'none'; // 'none', 'visual', 'deaf', 'voice'

  // --- Visual settings ---
  String _colorblindMode = 'none'; // 'none', 'protanopia', 'deuteranopia', 'tritanopia'
  bool _focusIndicators = true;

  // --- Cognitive settings ---
  double _lineSpacing = 1.5;
  double _letterSpacing = 0.0;
  bool _reducedMotion = false;

  // --- Motor settings ---
  bool _largeTouchTargets = false;
  bool _voiceNavigation = false;

  // --- Auditory settings ---
  bool _visualAlerts = false;
  bool _closedCaptions = false;
  String get language => _language;


  // --- Getters ---
  String get disabilityType => _disabilityType;
  double get textSizeScale => _textSizeScale;
  bool get highContrast => _highContrast;
  bool get dyslexiaFont => _dyslexiaFont;
  bool get zenMode => _zenMode;
  String get colorblindMode => _colorblindMode;
  bool get focusIndicators => _focusIndicators;
  double get lineSpacing => _lineSpacing;
  double get letterSpacing => _letterSpacing;
  bool get reducedMotion => _reducedMotion;
  bool get largeTouchTargets => _largeTouchTargets;
  bool get voiceNavigation => _voiceNavigation;
  bool get visualAlerts => _visualAlerts;
  bool get closedCaptions => _closedCaptions;

  AccessibilityProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _disabilityType = prefs.getString('disabilityType') ?? 'none';
    _textSizeScale = prefs.getDouble('textSizeScale') ?? 1.0;
    _highContrast = prefs.getBool('highContrast') ?? false;
    _dyslexiaFont = prefs.getBool('dyslexiaFont') ?? false;
    _zenMode = prefs.getBool('zenMode') ?? false;
    _colorblindMode = prefs.getString('colorblindMode') ?? 'none';
    _focusIndicators = prefs.getBool('focusIndicators') ?? true;
    _lineSpacing = prefs.getDouble('lineSpacing') ?? 1.5;
    _letterSpacing = prefs.getDouble('letterSpacing') ?? 0.0;
    _reducedMotion = prefs.getBool('reducedMotion') ?? false;
    _largeTouchTargets = prefs.getBool('largeTouchTargets') ?? false;
    _voiceNavigation = prefs.getBool('voiceNavigation') ?? false;
    _visualAlerts = prefs.getBool('visualAlerts') ?? false;
    _closedCaptions = prefs.getBool('closedCaptions') ?? false;
    _language = prefs.getString('language') ?? 'en';

    notifyListeners();
  }

  Future<void> _save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is double) await prefs.setDouble(key, value);
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  // --- Setters ---
  void setTextSize(double scale) {
    _textSizeScale = scale.clamp(0.8, 2.0);
    notifyListeners();
    _save('textSizeScale', _textSizeScale);
  }

  void toggleHighContrast() {
    _highContrast = !_highContrast;
    notifyListeners();
    _save('highContrast', _highContrast);
  }

  void toggleDyslexiaFont() {
    _dyslexiaFont = !_dyslexiaFont;
    notifyListeners();
    _save('dyslexiaFont', _dyslexiaFont);
  }

  void toggleZenMode() {
    _zenMode = !_zenMode;
    notifyListeners();
    _save('zenMode', _zenMode);
  }

  void setColorblindMode(String mode) {
    _colorblindMode = mode;
    notifyListeners();
    _save('colorblindMode', mode);
  }

  void toggleFocusIndicators() {
    _focusIndicators = !_focusIndicators;
    notifyListeners();
    _save('focusIndicators', _focusIndicators);
  }

  void setLineSpacing(double spacing) {
    _lineSpacing = spacing.clamp(1.0, 2.5);
    notifyListeners();
    _save('lineSpacing', _lineSpacing);
  }

  void setLetterSpacing(double spacing) {
    _letterSpacing = spacing.clamp(0.0, 3.0);
    notifyListeners();
    _save('letterSpacing', _letterSpacing);
  }

  void toggleReducedMotion() {
    _reducedMotion = !_reducedMotion;
    notifyListeners();
    _save('reducedMotion', _reducedMotion);
  }

  void toggleLargeTouchTargets() {
    _largeTouchTargets = !_largeTouchTargets;
    notifyListeners();
    _save('largeTouchTargets', _largeTouchTargets);
  }

  void toggleVoiceNavigation() {
    _voiceNavigation = !_voiceNavigation;
    notifyListeners();
    _save('voiceNavigation', _voiceNavigation);
  }

  void toggleVisualAlerts() {
    _visualAlerts = !_visualAlerts;
    notifyListeners();
    _save('visualAlerts', _visualAlerts);
  }

  void toggleClosedCaptions() {
    _closedCaptions = !_closedCaptions;
    notifyListeners();
    _save('closedCaptions', _closedCaptions);
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
    _save('language', lang);
  }

  // --- Translations Map ---
  static const Map<String, String> _hiDict = {
    'Home': 'मुख्य पृष्ठ',
    'Study Material': 'अध्ययन सामग्री',
    'AI Chatbot': 'एआई चैटबॉट',
    'Settings': 'सेटिंग्स',
    'Logout': 'लॉग आउट',
    'Notifications': 'सूचनाएं',
    'Reminders': 'रिमाइंडर',
    'Achievements': 'उपलब्धियां',
    'Welcome back': 'वापसी पर स्वागत है',
    "Ready to conquer today's goals?": 'आज के लक्ष्यों को पूरा करने के लिए तैयार हैं?',
    "Today's Goals": 'आज के लक्ष्य',
    '🎯 Goal': '🎯 लक्ष्य',
    '✅ Done': '✅ पूरा हुआ',
    '⏳ Left': '⏳ शेष',
    'Continue Lesson': 'पाठ जारी रखें',
    'Scheduled Tests & Quizzes': 'निर्धारित परीक्षण और प्रश्नोत्तरी',
    'Take Test': 'परीक्षा दें',
    'Remind Me': 'मुझे याद दिलाएं',
    'Customize your experience': 'अपना अनुभव अनुकूलित करें',
    'Account & Profile': 'खाता और प्रोफ़ाइल',
    'Email': 'ईमेल',
    'Contact': 'संपर्क',
    'Password': 'पासवर्ड',
    'Visual Accessibility': 'दृश्य पहुंच',
    'Typography': 'टंकण',
    'Audio & Voice Guidance': 'ध्वनि नेविगेशन',
    'Language / भाषा': 'भाषा / Language',
    'Downloaded Content': 'डाउनलोड की गई सामग्री',
    'App Language': 'ऐप की भाषा',
    'Zen Mode': 'ज़ेन मोड',
    'High Contrast': 'अधिक कंट्रास्ट',
    'Dyslexia-Friendly Font': 'डिस्लेक्सिया फ़ॉन्ट',
    'Text Scaling': 'टेक्स्ट का आकार',
    'Voice Navigation': 'आवाज़ से चलायें',
    'Closed Captions': 'कैप्शन दिखाएं',
    'No active reminders': 'कोई रिमाइंडर नहीं',
    'No new notifications': 'कोई नई सूचना नहीं',
  };

  String tr(String text) {
    if (_language == 'hi') {
      return _hiDict[text] ?? text;
    }
    return text;
  }

  String translate(String en, String hi) {
    return _language == 'hi' ? hi : en;
  }


  /// Apply sensible defaults based on the user's disability type.
  /// Called once during account creation.
  void applyDefaults(String type) {
    _disabilityType = type;
    _save('disabilityType', type);

    switch (type) {
      case 'visual':
        _voiceNavigation = true;
        _highContrast = true;
        _largeTouchTargets = true;
        _focusIndicators = true;
        _textSizeScale = 1.3;
        _save('voiceNavigation', true);
        _save('highContrast', true);
        _save('largeTouchTargets', true);
        _save('focusIndicators', true);
        _save('textSizeScale', 1.3);
        break;
      case 'deaf':
        _closedCaptions = true;
        _visualAlerts = true;
        _focusIndicators = true;
        _save('closedCaptions', true);
        _save('visualAlerts', true);
        _save('focusIndicators', true);
        break;
      case 'voice':
        _largeTouchTargets = true;
        _focusIndicators = true;
        _save('largeTouchTargets', true);
        _save('focusIndicators', true);
        break;
      default:
        // 'none' — keep all defaults
        break;
    }
    notifyListeners();
  }
}
