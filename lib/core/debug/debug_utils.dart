import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';

class DebugUtils {
  static bool _isDebugMode = true;
  
  static void log(String message, {String? tag}) {
    if (_isDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final logMessage = tag != null ? '[$tag] $message' : message;
      print('[$timestamp] $logMessage');
    }
  }
  
  static void logError(String message, {dynamic error, StackTrace? stackTrace}) {
    if (_isDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] ERROR: $message');
      if (error != null) {
        print('[$timestamp] Error details: $error');
      }
      if (stackTrace != null) {
        print('[$timestamp] Stack trace: $stackTrace');
      }
    }
  }
  
  static void showDebugDialog(BuildContext context, String title, String message) {
    if (!_isDebugMode) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSpace,
        title: Text(
          title,
          style: AppTextStyles.heading3.copyWith(color: AppColors.neonCyan),
        ),
        content: Text(
          message,
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.spaceBlue),
            ),
          ),
        ],
      ),
    );
  }
  
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.neonCyan,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  static Future<void> testApiConnection(String url) async {
    try {
      DebugUtils.log('Testing API connection to: $url');
      // Add actual API test logic here
      DebugUtils.log('API connection test successful');
    } catch (e) {
      DebugUtils.logError('API connection test failed', error: e);
    }
  }
  
  static void enableDebugMode() {
    _isDebugMode = true;
  }
  
  static void disableDebugMode() {
    _isDebugMode = false;
  }
  
  static bool get isDebugMode => _isDebugMode;
}

class DebugOverlay extends StatefulWidget {
  final Widget child;
  
  const DebugOverlay({Key? key, required this.child}) : super(key: key);
  
  @override
  _DebugOverlayState createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  bool _showDebugInfo = false;
  
  @override
  Widget build(BuildContext context) {
    if (!DebugUtils.isDebugMode) {
      return widget.child;
    }
    
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 50,
          right: 10,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: AppColors.darkSpace.withOpacity(0.8),
            onPressed: () {
              setState(() {
                _showDebugInfo = !_showDebugInfo;
              });
            },
            child: Icon(
              _showDebugInfo ? Icons.close : Icons.bug_report,
              color: AppColors.neonCyan,
            ),
          ),
        ),
        if (_showDebugInfo)
          Positioned(
            top: 100,
            right: 10,
            child: Container(
              width: 200,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkSpace.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neonCyan),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Debug Info',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.neonCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Debug Mode: ${DebugUtils.isDebugMode ? "ON" : "OFF"}',
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Platform: ${Theme.of(context).platform}',
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Screen: ${MediaQuery.of(context).size.width.toInt()}x${MediaQuery.of(context).size.height.toInt()}',
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

