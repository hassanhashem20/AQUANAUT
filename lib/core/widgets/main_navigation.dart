import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/core/providers/user_progress_provider.dart';
import 'package:nasa2/app/mission_control/mission_controle_page.dart';
import 'package:nasa2/app/docking/issi_view.dart';

class MainNavigation extends ConsumerStatefulWidget {
  final int initialIndex;
  
  const MainNavigation({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home,
      activeIcon: Icons.home,
      label: 'Home',
      page: HomePage(),
    ),
    NavigationItem(
      icon: Icons.school,
      activeIcon: Icons.school,
      label: 'Training',
      page: Container(
        decoration: BoxDecoration(
          gradient: AppColors.spaceGradient,
        ),
        child: Center(
          child: Text(
            'Training Module',
            style: AppTextStyles.heading1,
          ),
        ),
      ),
    ),
    NavigationItem(
      icon: Icons.satellite_alt,
      activeIcon: Icons.satellite_alt,
      label: 'ISS',
      page: CupolaExperience(),
    ),
    NavigationItem(
      icon: Icons.science,
      activeIcon: Icons.science,
      label: 'Mission Control',
      page: MissionControlClassroomScreen(),
    ),
    NavigationItem(
      icon: Icons.person,
      activeIcon: Icons.person,
      label: 'Profile',
      page: ProfilePage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _fabController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProgress = ref.watch(userProgressProvider);
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _navigationItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkSpace.withOpacity(0.95),
              AppColors.deepSpace,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isActive = index == _currentIndex;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabTapped(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isActive 
                                    ? AppColors.neonCyan.withOpacity(0.2)
                                    : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isActive ? item.activeIcon : item.icon,
                                  color: isActive 
                                    ? AppColors.neonCyan 
                                    : Colors.white54,
                                  size: 24,
                                ),
                              ),
                              // Progress indicator for training tab
                              if (index == 1 && userProgress.completedMissions.isNotEmpty)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.successGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            item.label,
                            style: AppTextStyles.caption.copyWith(
                              color: isActive 
                                ? AppColors.neonCyan 
                                : Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 1 ? _buildTrainingFAB() : null,
    );
  }

  Widget _buildTrainingFAB() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to current training step
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Container(
                decoration: BoxDecoration(
                  gradient: AppColors.spaceGradient,
                ),
                child: Center(
                  child: Text(
                    'Training Module',
                    style: AppTextStyles.heading1,
                  ),
                ),
              ),
            ),
          );
        },
        backgroundColor: AppColors.spaceBlue,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: Icon(Icons.play_arrow),
        label: Text('Continue Training'),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });
}

// Placeholder pages - these would be your actual page implementations
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.spaceGradient,
      ),
      child: Center(
        child: Text(
          'Home Page',
          style: AppTextStyles.heading1,
        ),
      ),
    );
  }
}

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProgress = ref.watch(userProgressProvider);
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.spaceGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Progress',
                style: AppTextStyles.heading1,
              ),
              SizedBox(height: 24),
              
              // Level and XP
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
                        Icon(Icons.star, color: AppColors.starYellow, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Level ${userProgress.level}',
                          style: AppTextStyles.heading3,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Experience Points: ${userProgress.xp}/${userProgress.xpForNextLevel}',
                      style: AppTextStyles.bodyLarge,
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: userProgress.progressToNextLevel,
                      backgroundColor: AppColors.midSpace,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Achievements
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkSpace.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emoji_events, color: AppColors.starYellow, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Achievements',
                          style: AppTextStyles.heading3,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (userProgress.achievements.isEmpty)
                      Text(
                        'Complete training modules to unlock achievements!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white54,
                        ),
                      )
                    else
                      ...userProgress.achievements.map((achievement) => 
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: AppColors.successGreen, size: 20),
                              SizedBox(width: 12),
                              Text(achievement, style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Training Sessions
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkSpace.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.spaceBlue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school, color: AppColors.spaceBlue, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Training Statistics',
                          style: AppTextStyles.heading3,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sessions Completed: ${userProgress.trainingSessionsCompleted}',
                      style: AppTextStyles.bodyLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Missions Completed: ${userProgress.completedMissions.length}',
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
