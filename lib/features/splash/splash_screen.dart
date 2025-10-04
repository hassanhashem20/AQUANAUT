import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), widget.onComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.spaceGradient,
        ),
        child: Stack(
          children: [
            // Animated stars background
            ...List.generate(50, (index) {
              return Positioned(
                left: (index * 37) % MediaQuery.of(context).size.width,
                top: (index * 53) % MediaQuery.of(context).size.height,
                child: Container(
                  width: 2,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .fadeIn(duration: 1000.ms)
                    .then()
                    .fadeOut(duration: 1000.ms),
              );
            }),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rocket Icon
                  Icon(
                    Icons.rocket_launch,
                    size: 120,
                    color: AppColors.neonCyan,
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .then()
                      .shake(hz: 2, duration: 400.ms),
                  
                  SizedBox(height: 40),
                  
                  // App Title
                  Text(
                    'AQUANAUT',
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 48,
                      color: AppColors.neonCyan,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    'Astronaut Training Experience',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.starYellow,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 800.ms),
                  
                  SizedBox(height: 60),
                  
                  // Loading indicator
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.midSpace,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 900.ms, duration: 600.ms),
                  
                  SizedBox(height: 16),
                  
                  Text(
                    'Initializing Mission Control...',
                    style: AppTextStyles.caption,
                  )
                      .animate()
                      .fadeIn(delay: 1200.ms, duration: 600.ms),
                ],
              ),
            ),
            
            // NASA Badge
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'NASA SPACE APPS CHALLENGE 2025',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ISS 25th Anniversary',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ).animate().fadeIn(delay: 1500.ms, duration: 600.ms),
            ),
          ],
        ),
      ),
    );
  }
}
