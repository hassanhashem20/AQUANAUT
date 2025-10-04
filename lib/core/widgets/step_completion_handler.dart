import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/core/providers/user_progress_provider.dart';

class StepCompletionHandler {
  static void handleStepCompletion(
    BuildContext context,
    WidgetRef ref,
    String missionId,
    int xpReward,
    String missionName,
    {String? achievementId}
  ) {
    // Add XP and complete mission
    ref.read(userProgressProvider.notifier).addXP(xpReward);
    ref.read(userProgressProvider.notifier).completeMission(missionId, xpReward);
    
    // Unlock achievement if provided
    if (achievementId != null) {
      ref.read(userProgressProvider.notifier).unlockAchievement(achievementId);
    }
    
    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSpace,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.successGreen),
          ),
          title: Row(
            children: [
              Icon(Icons.celebration, color: AppColors.successGreen, size: 32),
              SizedBox(width: 12),
              Text(
                'Mission Complete!',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                missionName,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stars, color: AppColors.starYellow),
                        SizedBox(width: 8),
                        Text(
                          '+$xpReward XP',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.starYellow,
                          ),
                        ),
                      ],
                    ),
                    if (achievementId != null) ...[
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events, color: AppColors.cosmicPurple),
                          SizedBox(width: 8),
                          Text(
                            'Achievement Unlocked!',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.cosmicPurple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to training hub
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.spaceBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Continue Training'),
            ),
          ],
        );
      },
    );
  }
  
  static void showProgressUpdate(
    BuildContext context,
    String message,
    {Color? backgroundColor}
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppColors.successGreen,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

