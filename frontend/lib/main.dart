import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/accessibility_provider.dart';
import 'providers/language_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/create_account_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (context, a11y, child) {
        return MaterialApp(
          title: 'Saamya AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(
            isHighContrast: a11y.highContrast,
            isDyslexiaFont: a11y.dyslexiaFont,
            textScale: a11y.textSizeScale,
            lineSpacing: a11y.lineSpacing,
            letterSpacing: a11y.letterSpacing,
            focusIndicators: a11y.focusIndicators,
            largeTouchTargets: a11y.largeTouchTargets,
          ),
          home: const CreateAccountScreen(),
        );
      },
    );
  }
}
