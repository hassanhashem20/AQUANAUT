import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/core/providers/user_progress_provider.dart';
import 'package:nasa2/app/mission_control/mission_controle_page.dart';
import 'package:nasa2/app/docking/issi_view.dart';
import 'package:nasa2/app/mission_control/nbl_traning.dart';
import 'package:nasa2/app/steps/step2.dart';
import 'package:nasa2/app/steps/step3.dart';
import 'package:nasa2/app/steps/iss_docking.dart';
import 'package:nasa2/app/steps/issi_onboarding.dart';
import 'package:nasa2/features/earth_3d/google_earth_quality.dart';
import 'package:nasa2/features/ai_chat/ai_chat_page.dart';
import 'package:nasa2/features/settings/settings_screen.dart';
import 'package:nasa2/features/training/enhanced_training_hub.dart';
import 'package:nasa2/core/widgets/error_boundary.dart';

class MainAppNavigation extends ConsumerStatefulWidget {
  final int initialIndex;
  
  const MainAppNavigation({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  ConsumerState<MainAppNavigation> createState() => _MainAppNavigationState();
}

class _MainAppNavigationState extends ConsumerState<MainAppNavigation>
    with TickerProviderStateMixin {
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
      page: EnhancedTrainingHub(),
    ),
    NavigationItem(
      icon: Icons.satellite_alt,
      activeIcon: Icons.satellite_alt,
      label: 'ISS',
      page: CupolaExperience(),
    ),
        NavigationItem(
          icon: Icons.public,
          activeIcon: Icons.public,
          label: 'Earth 3D',
          page: GoogleEarthQuality(),
        ),
    NavigationItem(
      icon: Icons.psychology,
      activeIcon: Icons.psychology,
      label: 'AI Chat',
      page: AIChatPage(),
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
        children: _navigationItems.map((item) => SafeWidget(
          child: item.page,
          errorMessage: 'Failed to load ${item.label}. Please try again.',
        )).toList(),
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
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _navigationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isActive = index == _currentIndex;
                  
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => _onTabTapped(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isActive 
                            ? AppColors.neonCyan.withOpacity(0.2)
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                Icon(
                                  isActive ? item.activeIcon : item.icon,
                                  color: isActive 
                                    ? AppColors.neonCyan 
                                    : Colors.white54,
                                  size: 20,
                                ),
                                // Progress indicator for training tab
                                if (index == 1 && userProgress.completedMissions.isNotEmpty)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      width: 6,
                                      height: 6,
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
                                fontSize: 9,
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
      ),
      floatingActionButton: _currentIndex == 1 ? _buildTrainingFAB() : null,
    );
  }

  Widget _buildTrainingFAB() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton.extended(
        onPressed: () {
          _showTrainingOptions();
        },
        backgroundColor: AppColors.spaceBlue,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: Icon(Icons.play_arrow),
        label: Text('Start Training'),
      ),
    );
  }

  void _showTrainingOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSpace,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Training Module',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.neonCyan,
              ),
            ),
            SizedBox(height: 24),
            _buildTrainingOption(
              'NBL Training',
              'Neutral Buoyancy Lab training',
              Icons.water_drop,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NblPoolScreen()),
              ),
            ),
            _buildTrainingOption(
              'Suit Assembly',
              'EMU spacesuit assembly training',
              Icons.sports_kabaddi,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SuitAssemblyStep2()),
              ),
            ),
            _buildTrainingOption(
              'Pre-Breathe Protocol',
              'Decompression sickness prevention',
              Icons.air,
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
            _buildTrainingOption(
              'ISS Docking',
              'Space station docking procedures',
              Icons.rocket_launch,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ISSDockingAlignmentStep()),
              ),
            ),
            _buildTrainingOption(
              'ISS Onboarding',
              'Space station orientation',
              Icons.explore,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ISSOnboardingTasksStep()),
              ),
            ),
            _buildTrainingOption(
              'Destiny Lab',
              'Laboratory module training',
              Icons.science,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.spaceGradient,
                  ),
                  child: Center(
                    child: Text(
                      'Destiny Lab Module',
                      style: AppTextStyles.heading1,
                    ),
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingOption(String title, String description, IconData icon, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.neonCyan),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white70,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: AppColors.midSpace.withOpacity(0.5),
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

// Home Page
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.spaceGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to AQUANAUT',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.neonCyan,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your journey to becoming an astronaut starts here',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 32),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTextStyles.heading3.copyWith(
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
        child: _buildQuickActionCard(
          'Start Training',
          Icons.school,
          AppColors.spaceBlue,
          () {
            // Navigate to training hub with proper context
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EnhancedTrainingHub(),
                settings: RouteSettings(name: '/training'),
              ),
            );
          },
        ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      'Live ISS',
                      Icons.satellite_alt,
                      AppColors.neonCyan,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CupolaExperience()),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                        child: _buildQuickActionCard(
                          'Earth 3D',
                          Icons.public,
                          AppColors.successGreen,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GoogleEarthQuality()),
                          ),
                        ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      'AI Assistant',
                      Icons.psychology,
                      AppColors.cosmicPurple,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AIChatPage()),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkSpace.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Training Page
class TrainingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.spaceGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Astronaut Training',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.neonCyan,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Complete all modules to become a certified astronaut',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 32),
              
              // Training Modules
              _buildTrainingModule(
                'NBL Training',
                'Neutral Buoyancy Lab training simulation',
                Icons.water_drop,
                AppColors.spaceBlue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NblPoolScreen()),
                ),
              ),
              
              _buildTrainingModule(
                'Suit Assembly',
                'EMU spacesuit assembly training',
                Icons.sports_kabaddi,
                AppColors.successGreen,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SuitAssemblyStep2()),
                ),
              ),
              
              _buildTrainingModule(
                'Pre-Breathe Protocol',
                'Decompression sickness prevention',
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
              
              _buildTrainingModule(
                'ISS Docking',
                'Space station docking procedures',
                Icons.rocket_launch,
                AppColors.rocketRed,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ISSDockingAlignmentStep()),
                ),
              ),
              
              _buildTrainingModule(
                'ISS Onboarding',
                'Space station orientation',
                Icons.explore,
                AppColors.cosmicPurple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ISSOnboardingTasksStep()),
                ),
              ),
              
              _buildTrainingModule(
                'Destiny Lab',
                'Laboratory module training',
                Icons.science,
                AppColors.neonCyan,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.spaceGradient,
                    ),
                    child: Center(
                      child: Text(
                        'Destiny Lab Module',
                        style: AppTextStyles.heading1,
                      ),
                    ),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingModule(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white70,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: AppColors.neonCyan, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: AppColors.darkSpace.withOpacity(0.8),
      ),
    );
  }
}

// Profile Page
class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProgress = ref.watch(userProgressProvider);
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.spaceGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Progress',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.neonCyan,
                ),
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
              
              // Settings
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
                        Icon(Icons.settings, color: AppColors.spaceBlue, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Settings',
                          style: AppTextStyles.heading3,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.tune, color: AppColors.neonCyan),
                      title: Text('App Settings', style: AppTextStyles.bodyLarge),
                      trailing: Icon(Icons.arrow_forward_ios, color: AppColors.neonCyan, size: 16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsScreen()),
                      ),
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
