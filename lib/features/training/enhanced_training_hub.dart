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
import 'package:nasa2/core/debug/debug_utils.dart';

class EnhancedTrainingHub extends ConsumerWidget {
  const EnhancedTrainingHub({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EnhancedTrainingHubContent(ref: ref);
  }
}

class _EnhancedTrainingHubContent extends StatefulWidget {
  final WidgetRef ref;
  
  const _EnhancedTrainingHubContent({required this.ref});

  @override
  _EnhancedTrainingHubContentState createState() => _EnhancedTrainingHubContentState();
}

class _EnhancedTrainingHubContentState extends State<_EnhancedTrainingHubContent>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProgress = widget.ref.watch(userProgressProvider);
    
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.deepSpace,
              AppColors.darkSpace,
              AppColors.midSpace,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  // Hero Header
                  SliverToBoxAdapter(
                    child: _buildHeroHeader(userProgress),
                  ),
                  
                  // Progress Section
                  SliverToBoxAdapter(
                    child: _buildProgressSection(userProgress),
                  ),
                  
                  // Training Modules Grid
                  SliverPadding(
                    padding: EdgeInsets.all(20),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildListDelegate([
                        _buildTrainingModule(
                          context,
                          title: 'NBL Training',
                          description: 'Neutral Buoyancy Lab simulation',
                          icon: Icons.water_drop,
                          color: AppColors.spaceBlue,
                          gradient: [AppColors.spaceBlue, AppColors.neonCyan],
                          onTap: () => _navigateToTraining(context, () => _NBLTrainingWrapper(
                            onComplete: () {
                              Navigator.pop(context);
                              widget.ref.read(userProgressProvider.notifier).completeMission('nbl_training', 100);
                              DebugUtils.showSuccessSnackBar(context, 'NBL Training completed! +100 XP');
                            },
                          )),
                          isCompleted: userProgress.completedMissions.contains('nbl_training'),
                          xpReward: 100,
                        ),
                        _buildTrainingModule(
                          context,
                          title: 'Suit Assembly',
                          description: 'EMU spacesuit assembly training',
                          icon: Icons.sports_kabaddi,
                          color: AppColors.neonCyan,
                          gradient: [AppColors.neonCyan, AppColors.spaceBlue],
                          onTap: () => _navigateToTraining(context, () => SuitAssemblyStep2(
                            nextStep: () {
                              Navigator.pop(context);
                              widget.ref.read(userProgressProvider.notifier).completeMission('suit_assembly', 100);
                              DebugUtils.showSuccessSnackBar(context, 'Suit Assembly completed! +100 XP');
                            },
                          )),
                          isCompleted: userProgress.completedMissions.contains('suit_assembly'),
                          xpReward: 100,
                        ),
                        _buildTrainingModule(
                          context,
                          title: 'Pre-Breathe Protocol',
                          description: 'Decompression sickness prevention',
                          icon: Icons.air,
                          color: AppColors.warningYellow,
                          gradient: [AppColors.warningYellow, AppColors.starYellow],
                          onTap: () => _navigateToTraining(context, () => PreBreatheStep(
                            onComplete: () {
                              Navigator.pop(context);
                              widget.ref.read(userProgressProvider.notifier).completeMission('pre_breathe', 75);
                              DebugUtils.showSuccessSnackBar(context, 'Pre-Breathe Protocol completed! +75 XP');
                            },
                          )),
                          isCompleted: userProgress.completedMissions.contains('pre_breathe'),
                          xpReward: 75,
                        ),
                        _buildTrainingModule(
                          context,
                          title: 'ISS Docking',
                          description: 'Space station docking procedures',
                          icon: Icons.rocket_launch,
                          color: AppColors.successGreen,
                          gradient: [AppColors.successGreen, AppColors.neonCyan],
                          onTap: () => _navigateToTraining(context, () => ISSDockingAlignmentStep(
                            onDockingSuccess: () {
                              Navigator.pop(context);
                              widget.ref.read(userProgressProvider.notifier).completeMission('iss_docking', 200);
                              DebugUtils.showSuccessSnackBar(context, 'ISS Docking completed! +200 XP');
                            },
                          )),
                          isCompleted: userProgress.completedMissions.contains('iss_docking'),
                          xpReward: 200,
                        ),
                        _buildTrainingModule(
                          context,
                          title: 'ISS Onboarding',
                          description: 'Space station orientation',
                          icon: Icons.explore,
                          color: AppColors.cosmicPurple,
                          gradient: [AppColors.cosmicPurple, AppColors.spaceBlue],
                          onTap: () => _navigateToTraining(context, () => ISSOnboardingTasksStep(
                            onComplete: () {
                              Navigator.pop(context);
                              widget.ref.read(userProgressProvider.notifier).completeMission('iss_onboarding', 150);
                              DebugUtils.showSuccessSnackBar(context, 'ISS Onboarding completed! +150 XP');
                            },
                          )),
                          isCompleted: userProgress.completedMissions.contains('iss_onboarding'),
                          xpReward: 150,
                        ),
                        _buildTrainingModule(
                          context,
                          title: 'Mission Control',
                          description: 'Classroom activities & quizzes',
                          icon: Icons.dashboard,
                          color: AppColors.starYellow,
                          gradient: [AppColors.starYellow, AppColors.warningYellow],
                          onTap: () => _navigateToTraining(context, () => _MissionControlWrapper(
                            onComplete: () {
                              Navigator.pop(context);
                              widget.ref.read(userProgressProvider.notifier).completeMission('mission_control', 125);
                              DebugUtils.showSuccessSnackBar(context, 'Mission Control completed! +125 XP');
                            },
                          )),
                          isCompleted: userProgress.completedMissions.contains('mission_control'),
                          xpReward: 125,
                        ),
                      ]),
                    ),
                  ),
                  
                  // Bottom spacing
                  SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(UserProgress userProgress) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.spaceBlue, AppColors.neonCyan],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Astronaut Training',
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Level ${userProgress.level} • ${userProgress.completedMissions.length} missions completed',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Prepare for your journey to space with comprehensive training modules designed by NASA experts.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(UserProgress userProgress) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkSpace.withOpacity(0.8),
            AppColors.midSpace.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Training Progress',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.neonCyan,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.spaceBlue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Level ${userProgress.level}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Experience Points',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${userProgress.xp}/${userProgress.totalXp} XP',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.starYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Missions',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${userProgress.completedMissions.length}/6',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: userProgress.xp / userProgress.totalXp,
              backgroundColor: AppColors.midSpace,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingModule(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
    required VoidCallback onTap,
    bool isCompleted = false,
    required int xpReward,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted 
              ? AppColors.successGreen.withOpacity(0.5)
              : color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  Spacer(),
                  if (isCompleted)
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.heading3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white70,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.stars,
                    color: AppColors.starYellow,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '+$xpReward XP',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.starYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  if (isCompleted)
                    Text(
                      'Completed',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios,
                      color: color,
                      size: 16,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTraining(BuildContext context, Widget Function() builder) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => builder(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }
}

// Wrapper classes to add completion functionality to existing screens
class _NBLTrainingWrapper extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const _NBLTrainingWrapper({required this.onComplete});

  @override
  _NBLTrainingWrapperState createState() => _NBLTrainingWrapperState();
}

class _NBLTrainingWrapperState extends State<_NBLTrainingWrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NBL Training'),
        backgroundColor: AppColors.darkSpace,
        actions: [
          TextButton(
            onPressed: () {
              widget.onComplete?.call();
            },
            child: Text(
              'Complete',
              style: TextStyle(color: AppColors.neonCyan),
            ),
          ),
        ],
      ),
      body: NblPoolScreen(),
    );
  }
}

class _MissionControlWrapper extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const _MissionControlWrapper({required this.onComplete});

  @override
  _MissionControlWrapperState createState() => _MissionControlWrapperState();
}

class _MissionControlWrapperState extends State<_MissionControlWrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mission Control'),
        backgroundColor: AppColors.darkSpace,
        actions: [
          TextButton(
            onPressed: () {
              widget.onComplete?.call();
            },
            child: Text(
              'Complete',
              style: TextStyle(color: AppColors.neonCyan),
            ),
          ),
        ],
      ),
      body: MissionControlClassroomScreen(),
    );
  }
}
