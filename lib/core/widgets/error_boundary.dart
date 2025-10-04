import 'package:flutter/material.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;
  final String? errorMessage;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.fallback,
    this.errorMessage,
  }) : super(key: key);

  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  String? errorDetails;

  @override
  void initState() {
    super.initState();
    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        hasError = true;
        errorDetails = details.toString();
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
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
                color: AppColors.errorRed,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.errorMessage ?? 'An unexpected error occurred. Please try again.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  hasError = false;
                  errorDetails = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.spaceBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class SafeWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final String? errorMessage;

  const SafeWidget({
    Key? key,
    required this.child,
    this.fallback,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      fallback: fallback,
      errorMessage: errorMessage,
      child: child,
    );
  }
}

