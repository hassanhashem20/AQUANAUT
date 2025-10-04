import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/core/providers/user_progress_provider.dart';
import 'package:nasa2/app/mission_control/nbl_traning.dart';
import 'package:nasa2/app/steps/step2.dart';
import 'package:nasa2/app/steps/step3.dart';
import 'package:nasa2/app/steps/iss_docking.dart';
import 'package:nasa2/app/steps/issi_onboarding.dart';
import 'package:nasa2/app/mission_control/mission_controle_page.dart';

class TrainingHub extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProgress = ref.watch(userProgressProvider);
    
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        title: Text('Astronaut Training Hub'),
        backgroundColor: AppColors.darkSpace,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.spaceBlue, AppColors.cosmicPurple],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Astronaut Training',
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Complete all modules to become a certified astronaut',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Progress Overview
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSpace.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: AppColors.neonCyan),
                      SizedBox(width: 8),
                      Text(
                        'Your Progress',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.neonCyan,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level ${userProgress.level}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${userProgress.xp}/${userProgress.totalXp} XP',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Missions Completed',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '${userProgress.completedMissions.length}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: userProgress.xp / userProgress.totalXp,
                    backgroundColor: AppColors.midSpace,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Training Modules Grid
            Text(
              'Training Modules',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.neonCyan,
              ),
            ),
            SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildTrainingCard(
                  context,
                  'NBL Training',
                  'Neutral Buoyancy Lab simulation',
                  Icons.water_drop,
                  AppColors.spaceBlue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NblPoolScreen()),
                  ),
                ),
                
                _buildTrainingCard(
                  context,
                  'Suit Assembly',
                  'EMU spacesuit training',
                  Icons.sports_kabaddi,
                  AppColors.successGreen,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SuitAssemblyStep2()),
                  ),
                ),
                
                _buildTrainingCard(
                  context,
                  'Pre-Breathe Protocol',
                  'Decompression prevention',
                  Icons.air,
                  AppColors.warningYellow,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PreBreatheStep(
                      onComplete: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Pre-Breathe Protocol completed!')),
                        );
                      },
                    )),
                  ),
                ),
                
                _buildTrainingCard(
                  context,
                  'ISS Docking',
                  'Space station docking',
                  Icons.rocket_launch,
                  AppColors.rocketRed,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ISSDockingAlignmentStep(
                      onDockingSuccess: () {
                        Navigator.pop(context);
                        ref.read(userProgressProvider.notifier).completeMission('iss_docking', 200);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ISS Docking completed! +200 XP')),
                        );
                      },
                    )),
                  ),
                ),
                
                _buildTrainingCard(
                  context,
                  'ISS Onboarding',
                  'Space station orientation',
                  Icons.explore,
                  AppColors.cosmicPurple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ISSOnboardingTasksStep(
                      onComplete: () {
                        Navigator.pop(context);
                        ref.read(userProgressProvider.notifier).completeMission('iss_onboarding', 150);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ISS Onboarding completed!')),
                        );
                      },
                    )),
                  ),
                ),
                
                _buildTrainingCard(
                  context,
                  'Mission Control',
                  'Classroom activities',
                  Icons.science,
                  AppColors.neonCyan,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MissionControlClassroomScreen()),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 32),
            
            // Progress Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkSpace.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: AppColors.neonCyan, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Training Progress',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.neonCyan,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Complete training modules to unlock achievements and advance your astronaut career!',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProgressItem('Modules Completed', '0/6', AppColors.successGreen),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildProgressItem('Achievements', '0', AppColors.starYellow),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkSpace.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.midSpace.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
