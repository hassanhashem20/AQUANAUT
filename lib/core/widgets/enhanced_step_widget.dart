import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/core/providers/user_progress_provider.dart';

class EnhancedStepWidget extends ConsumerStatefulWidget {
  final int stepNumber;
  final int totalSteps;
  final String title;
  final String description;
  final Widget content;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onSkip;
  final bool canSkip;
  final bool isCompleted;
  final String? nextButtonText;
  final String? previousButtonText;
  final Widget? customActions;
  final bool showProgress;
  final bool enableHapticFeedback;

  const EnhancedStepWidget({
    Key? key,
    required this.stepNumber,
    required this.totalSteps,
    required this.title,
    required this.description,
    required this.content,
    this.onNext,
    this.onPrevious,
    this.onSkip,
    this.canSkip = true,
    this.isCompleted = false,
    this.nextButtonText,
    this.previousButtonText,
    this.customActions,
    this.showProgress = true,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  ConsumerState<EnhancedStepWidget> createState() => _EnhancedStepWidgetState();
}

class _EnhancedStepWidgetState extends ConsumerState<EnhancedStepWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: (widget.stepNumber - 1) / widget.totalSteps,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _slideController.forward();
    _fadeController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    
    // Add XP for completing step
    ref.read(userProgressProvider.notifier).addXP(50);
    
    widget.onNext?.call();
  }

  void _handlePrevious() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onPrevious?.call();
  }

  void _handleSkip() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onSkip?.call();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.stepNumber - 1) / widget.totalSteps;
    
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            if (widget.showProgress) _buildProgressHeader(progress),
            
            // Main content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step indicator
                        _buildStepIndicator(),
                        
                        SizedBox(height: 24),
                        
                        // Title and description
                        _buildHeader(),
                        
                        SizedBox(height: 32),
                        
                        // Content
                        widget.content,
                        
                        SizedBox(height: 32),
                        
                        // Actions
                        _buildActions(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(double progress) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkSpace,
            AppColors.deepSpace,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: AppColors.midSpace,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                minHeight: 6,
              );
            },
          ),
          
          SizedBox(height: 12),
          
          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${widget.stepNumber} of ${widget.totalSteps}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neonCyan,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(widget.totalSteps, (index) {
        final stepNum = index + 1;
        final isCompleted = stepNum < widget.stepNumber;
        final isCurrent = stepNum == widget.stepNumber;
        
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            height: 4,
            decoration: BoxDecoration(
              color: isCompleted 
                ? AppColors.successGreen 
                : isCurrent 
                  ? AppColors.neonCyan 
                  : AppColors.midSpace,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.spaceBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.spaceBlue),
              ),
              child: Text(
                '${widget.stepNumber}',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.spaceBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.title,
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        Text(
          widget.description,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Custom actions
        if (widget.customActions != null) ...[
          widget.customActions!,
          SizedBox(height: 16),
        ],
        
        // Navigation buttons
        Row(
          children: [
            // Previous button
            if (widget.onPrevious != null)
              Expanded(
                child: OutlinedButton(
                  onPressed: _handlePrevious,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.neonCyan,
                    side: BorderSide(color: AppColors.neonCyan),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, size: 20),
                      SizedBox(width: 8),
                      Text(
                        widget.previousButtonText ?? 'Previous',
                        style: AppTextStyles.buttonText,
                      ),
                    ],
                  ),
                ),
              ),
            
            if (widget.onPrevious != null) SizedBox(width: 16),
            
            // Next button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: widget.isCompleted ? _handleNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isCompleted 
                    ? AppColors.spaceBlue 
                    : AppColors.midSpace,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: widget.isCompleted ? 8 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.nextButtonText ?? 'Next Step',
                      style: AppTextStyles.buttonText.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // Skip button
        if (widget.canSkip && widget.onSkip != null) ...[
          SizedBox(height: 12),
          TextButton(
            onPressed: _handleSkip,
            child: Text(
              'Skip this step',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white54,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
