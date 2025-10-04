import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';

class AccessibilityWidgets {
  static Widget buildAccessibleButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    String? semanticLabel,
    String? semanticHint,
    Color? backgroundColor,
    Color? foregroundColor,
    bool isEnabled = true,
  }) {
    return Semantics(
      label: semanticLabel ?? text,
      hint: semanticHint,
      button: true,
      enabled: isEnabled,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.spaceBlue,
          foregroundColor: foregroundColor ?? Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static Widget buildAccessibleCard({
    required Widget child,
    required String semanticLabel,
    String? semanticHint,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkSpace,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                ? AppColors.neonCyan 
                : AppColors.neonCyan.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.neonCyan.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ] : null,
          ),
          child: child,
        ),
      ),
    );
  }

  static Widget buildAccessibleProgressIndicator({
    required double value,
    required String label,
    String? semanticValue,
  }) {
    return Semantics(
      label: label,
      value: semanticValue ?? '${(value * 100).toInt()}% complete',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.midSpace,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
            minHeight: 8,
          ),
          SizedBox(height: 4),
          Text(
            '${(value * 100).toInt()}% Complete',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.neonCyan,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildAccessibleListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
    bool isSelected = false,
    String? semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel ?? '$title, $subtitle',
      button: onTap != null,
      selected: isSelected,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.neonCyan : Colors.white70,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isSelected ? AppColors.neonCyan : Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white70,
          ),
        ),
        onTap: onTap,
        selected: isSelected,
        selectedTileColor: AppColors.neonCyan.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class HighContrastMode {
  static bool _isHighContrast = false;
  
  static bool get isHighContrast => _isHighContrast;
  
  static void setHighContrast(bool value) {
    _isHighContrast = value;
  }
  
  static Color getTextColor() {
    return _isHighContrast ? Colors.white : Colors.white.withOpacity(0.9);
  }
  
  static Color getBackgroundColor() {
    return _isHighContrast ? Colors.black : AppColors.deepSpace;
  }
  
  static Color getAccentColor() {
    return _isHighContrast ? Colors.yellow : AppColors.neonCyan;
  }
  
  static Color getSuccessColor() {
    return _isHighContrast ? Colors.green : AppColors.successGreen;
  }
  
  static Color getErrorColor() {
    return _isHighContrast ? Colors.red : AppColors.errorRed;
  }
}

class ScreenReaderAnnouncements {
  static void announceStepCompletion(BuildContext context, String stepName) {
    SemanticsService.announce(
      'Step completed: $stepName',
      TextDirection.ltr,
    );
  }
  
  static void announceAchievement(BuildContext context, String achievement) {
    SemanticsService.announce(
      'Achievement unlocked: $achievement',
      TextDirection.ltr,
    );
  }
  
  static void announceProgress(BuildContext context, int current, int total) {
    SemanticsService.announce(
      'Progress: $current of $total steps completed',
      TextDirection.ltr,
    );
  }
  
  static void announceError(BuildContext context, String error) {
    SemanticsService.announce(
      'Error: $error',
      TextDirection.ltr,
    );
  }
  
  static void announceSuccess(BuildContext context, String message) {
    SemanticsService.announce(
      'Success: $message',
      TextDirection.ltr,
    );
  }
}

class FocusManagement {
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }
  
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
  
  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }
  
  static void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }
}

class AccessibilitySettings {
  static bool _isScreenReaderEnabled = false;
  static bool _isHighContrastEnabled = false;
  static double _textScaleFactor = 1.0;
  static bool _isHapticFeedbackEnabled = true;
  
  static bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  static bool get isHighContrastEnabled => _isHighContrastEnabled;
  static double get textScaleFactor => _textScaleFactor;
  static bool get isHapticFeedbackEnabled => _isHapticFeedbackEnabled;
  
  static void setScreenReaderEnabled(bool value) {
    _isScreenReaderEnabled = value;
  }
  
  static void setHighContrastEnabled(bool value) {
    _isHighContrastEnabled = value;
    HighContrastMode.setHighContrast(value);
  }
  
  static void setTextScaleFactor(double value) {
    _textScaleFactor = value.clamp(0.8, 2.0);
  }
  
  static void setHapticFeedbackEnabled(bool value) {
    _isHapticFeedbackEnabled = value;
  }
  
  static Widget buildAccessibleText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Semantics(
      label: text,
      child: Text(
        text,
        style: style?.copyWith(
          color: HighContrastMode.isHighContrast 
            ? HighContrastMode.getTextColor() 
            : style?.color,
        ),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

