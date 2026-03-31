import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';

extension TranslateExtension on String {
  String tr(BuildContext context) {
    try {
      return Provider.of<AccessibilityProvider>(context, listen: true).tr(this);
    } catch (_) {
      return this;
    }
  }
}
