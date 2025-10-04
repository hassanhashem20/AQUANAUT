import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';

enum ErrorType {
  network,
  data,
  validation,
  permission,
  unknown,
}

class AppError {
  final String message;
  final String? details;
  final ErrorType type;
  final DateTime timestamp;
  final String? action;

  AppError({
    required this.message,
    this.details,
    required this.type,
    DateTime? timestamp,
    this.action,
  }) : timestamp = timestamp ?? DateTime.now();

  String get userFriendlyMessage {
    switch (type) {
      case ErrorType.network:
        return 'Unable to connect to the internet. Please check your connection and try again.';
      case ErrorType.data:
        return 'There was a problem loading the data. Please try again.';
      case ErrorType.validation:
        return 'Please check your input and try again.';
      case ErrorType.permission:
        return 'Permission denied. Please enable the required permissions in settings.';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  String get technicalMessage {
    return details ?? message;
  }
}

class ErrorHandler {
  static void showErrorSnackBar(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getErrorIcon(error.type),
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error.userFriendlyMessage,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (error.details != null) ...[
              SizedBox(height: 4),
              Text(
                error.details!,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
        backgroundColor: _getErrorColor(error.type),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static void showErrorDialog(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSpace,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              _getErrorIcon(error.type),
              color: _getErrorColor(error.type),
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Error',
              style: AppTextStyles.heading3.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error.userFriendlyMessage,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
              ),
            ),
            if (error.details != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.midSpace,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error.details!,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white70,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (onDismiss != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss();
              },
              child: Text(
                'Dismiss',
                style: AppTextStyles.buttonText.copyWith(
                  color: Colors.white54,
                ),
              ),
            ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getErrorColor(error.type),
                foregroundColor: Colors.white,
              ),
              child: Text('Retry'),
            ),
        ],
      ),
    );
  }

  static void showSuccessMessage(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static void showInfoMessage(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.spaceBlue,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static void showLoadingDialog(
    BuildContext context,
    String message,
  ) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSpace,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.neonCyan,
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return AppColors.warningYellow;
      case ErrorType.data:
        return AppColors.errorRed;
      case ErrorType.validation:
        return AppColors.warningYellow;
      case ErrorType.permission:
        return AppColors.rocketRed;
      case ErrorType.unknown:
        return AppColors.errorRed;
    }
  }

  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.data:
        return Icons.error_outline;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.permission:
        return Icons.block;
      case ErrorType.unknown:
        return Icons.error;
    }
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;
  final Function(AppError)? onError;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.fallback,
    this.onError,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  AppError? _error;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleError(details.exception, details.stack);
    };
  }

  void _handleError(dynamic exception, StackTrace? stackTrace) {
    final error = AppError(
      message: exception.toString(),
      details: stackTrace?.toString(),
      type: ErrorType.unknown,
    );

    setState(() {
      _error = error;
    });

    widget.onError?.call(error);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallback ?? _buildErrorWidget();
    }
    return widget.child;
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.spaceGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorRed,
            ),
            SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTextStyles.heading2.copyWith(
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We\'re sorry, but something unexpected happened.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.spaceBlue,
                foregroundColor: Colors.white,
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
