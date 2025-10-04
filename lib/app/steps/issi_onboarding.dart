import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/core/providers/user_progress_provider.dart';

class ISSOnboardingTasksStep extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  
  const ISSOnboardingTasksStep({Key? key, this.onComplete}) : super(key: key);

  @override
  ConsumerState<ISSOnboardingTasksStep> createState() => _ISSOnboardingTasksStepState();
}

class _ISSOnboardingTasksStepState extends ConsumerState<ISSOnboardingTasksStep> {
  final List<String> tasks = [
    'Inspection: Tighten loose panel',
    'Plant Growth Check: Monitor plant module',
    'Communications: Send status to Mission Control',
  ];

  Set<int> completedTasks = Set(); // store indexes of completed tasks
  bool allTasksCompleted = false;

  void _completeTask(int index) {
    setState(() {
      completedTasks.add(index);
    });
    
    // Add XP for completing task
    ref.read(userProgressProvider.notifier).addXP(25);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tasks[index]} completed! +25 XP'),
        backgroundColor: AppColors.successGreen,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Check if all tasks are completed
    if (completedTasks.length == tasks.length && !allTasksCompleted) {
      setState(() {
        allTasksCompleted = true;
      });
      
      // Add bonus XP and unlock achievement
      ref.read(userProgressProvider.notifier).addXP(100);
      ref.read(userProgressProvider.notifier).unlockAchievement('ISS Onboarding Complete');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All tasks completed! +100 Bonus XP! Achievement unlocked!'),
          backgroundColor: AppColors.starYellow,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Call completion callback
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        title: Text('ISS Onboarding Tasks'),
        backgroundColor: AppColors.darkSpace,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSpace.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment_turned_in, color: AppColors.neonCyan),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Onboarding Progress',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: completedTasks.length / tasks.length,
                          backgroundColor: AppColors.midSpace,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${completedTasks.length}/${tasks.length} tasks completed',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Tasks list
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final isCompleted = completedTasks.contains(index);
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Card(
                      color: AppColors.darkSpace.withOpacity(0.8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isCompleted 
                            ? AppColors.successGreen.withOpacity(0.5)
                            : AppColors.midSpace.withOpacity(0.5),
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isCompleted ? AppColors.successGreen : AppColors.neonCyan,
                        ),
                        title: Text(
                          tasks[index],
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: isCompleted ? null : () => _completeTask(index),
                          child: Text(isCompleted ? 'Completed' : 'Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCompleted 
                              ? AppColors.midSpace 
                              : AppColors.spaceBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Completion message
            if (allTasksCompleted)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.successGreen),
                ),
                child: Row(
                  children: [
                    Icon(Icons.celebration, color: AppColors.successGreen),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Congratulations! You have successfully completed ISS Onboarding!',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.successGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
