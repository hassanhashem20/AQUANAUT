import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:nasa2/app/docking/destinyLab.dart';
import 'package:nasa2/app/docking/docking.dart';
import 'package:nasa2/app/docking/issi_view.dart';
import 'package:nasa2/app/steps/iss_docking.dart';
import 'package:nasa2/app/steps/issi_onboarding.dart';
import 'package:nasa2/app/steps/step2.dart';
import 'package:nasa2/app/steps/step3.dart';
import 'package:nasa2/app/steps/step4.dart';
import 'package:nasa2/core/theme/app_theme.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/features/splash/splash_screen.dart';
import 'package:nasa2/features/main_app/main_app_navigation.dart';
import 'package:nasa2/core/debug/debug_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable debug mode
  DebugUtils.enableDebugMode();
  DebugUtils.log('App starting...');
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.deepSpace,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(ProviderScope(child: ZeroGExplorerApp()));
}

class ZeroGExplorerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AQUANAUT',
      theme: AppTheme.darkTheme,
      home: SplashScreenWrapper(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onComplete: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainAppNavigation()),
        );
      },
    );
  }
}

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
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
            // Animated background stars
            ...List.generate(100, (index) {
              return Positioned(
                left: (index * 37) % MediaQuery.of(context).size.width,
                top: (index * 53) % MediaQuery.of(context).size.height,
                child: Container(
                  width: 1 + (index % 3),
                  height: 1 + (index % 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6 + (index % 4) * 0.1),
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                    .fadeIn(duration: 2000.ms, delay: (index * 50).ms)
                    .then()
                    .fadeOut(duration: 2000.ms),
              );
            }),
            
            // Main content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo/icon
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.neonCyan.withOpacity(0.3),
                                      AppColors.spaceBlue.withOpacity(0.1),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.neonCyan.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.rocket_launch,
                                  size: 60,
                                  color: AppColors.neonCyan,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40),
                    
                    // Main title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'AQUANAUT',
                          style: AppTextStyles.heading1.copyWith(
                            fontSize: 48,
                            color: AppColors.neonCyan,
                            letterSpacing: 3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Subtitle
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'Astronaut Training Experience',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.starYellow,
                            fontSize: 18,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40),
                    
                    // Question
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.darkSpace.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
                          ),
                          child: Text(
                            'DO YOU WANT TO BE AN ASTRONAUT?',
                            style: AppTextStyles.heading3.copyWith(
                              fontSize: 22,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Description
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'Experience astronaut training from NASA\'s Neutral Buoyancy Lab to the International Space Station.',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 60),
                    
                    // Action buttons
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            // Primary button
                            Container(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => NBLTrainingScreen(),
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
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.spaceBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: AppColors.spaceBlue.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.school, size: 24),
                                    SizedBox(width: 12),
                                    Text(
                                      'YES - Train Me!',
                                      style: AppTextStyles.buttonText.copyWith(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Secondary button
                            Container(
                              width: double.infinity,
                              height: 60,
                              child: OutlinedButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => CupolaExperience(),
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
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.neonCyan,
                                  side: BorderSide(color: AppColors.neonCyan, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.satellite_alt, size: 24),
                                    SizedBox(width: 12),
                                    Text(
                                      'NO - Skip to ISS',
                                      style: AppTextStyles.buttonText.copyWith(
                                        fontSize: 18,
                                        color: AppColors.neonCyan,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40),
                    
                    // NASA badge
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.darkSpace.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
                          ),
                          child: Text(
                            'NASA SPACE APPS CHALLENGE 2025',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 12,
                              color: Colors.white70,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NBLTrainingScreen extends StatefulWidget {
  @override
  _NBLTrainingScreenState createState() => _NBLTrainingScreenState();
}

class _NBLTrainingScreenState extends State<NBLTrainingScreen> {
  int step = 1;
  final int totalSteps = 7;

  String? nasaImageUrl;
  bool isLoadingImage = true;
  final String apiQuery = "Neutral Buoyancy Lab";

  @override
  void initState() {
    super.initState();
    fetchNasaImage();
  }

  Future<void> fetchNasaImage() async {
    final Uri url = Uri.https('images-api.nasa.gov', '/search', {
      'q': apiQuery,
      'media_type': 'image',
      'page': '1',
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['collection']?['items'];
        if (items != null && items.isNotEmpty) {
          final firstItem = items[0];
          final links = firstItem['links'];
          if (links != null && links.isNotEmpty) {
            setState(() {
              nasaImageUrl = links[0]['href'];
              isLoadingImage = false;
            });
          }
        } else {
          setState(() {
            isLoadingImage = false;
          });
          print("No images found for query");
        }
      } else {
        setState(() {
          isLoadingImage = false;
        });
        print("NASA API error: HTTP ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoadingImage = false;
      });
      print("Error fetching NASA image: $e");
    }
  }

  void nextStep() {
    if (step < totalSteps) {
      setState(() => step++);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LaunchSequenceScreen()),
      );
    }
  }

  Widget buildNeutralBuoyancyStep(
    BuildContext context,
    Function nextStep,
    Function skipChallenge,
  ) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 570),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Color(0xFF181f28),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Color(0xFFace4ff), width: 1.5),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome to NASA's Neutral Buoyancy Lab",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 14),
              if (isLoadingImage)
                CircularProgressIndicator(color: Colors.cyanAccent)
              else if (nasaImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    nasaImageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'No image available',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              SizedBox(height: 16),
              Text(
                "NASA Neutral Buoyancy Lab",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFace4ff),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "The Neutral Buoyancy Lab is a massive 6.2 million gallon pool where astronauts train for spacewalks.",
                style: TextStyle(color: Colors.white.withOpacity(.85)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 7),
              Text(
                "Your mission: Learn how astronauts achieve ",
                style: TextStyle(
                  color: Colors.white.withOpacity(.95),
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "neutral buoyancy",
                      style: TextStyle(
                        color: Color(0xFFace4ff),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: " – floating neither up nor down in the water.",
                      style: TextStyle(color: Colors.white.withOpacity(.95)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 7),
              Text(
                "Experience authentic NASA training procedures!",
                style: TextStyle(
                  color: Color(0xFFF9DC6B),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 17),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => nextStep(),
                    child: Text('Begin NBL Training Protocol'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Color(0xFF2e53e1),
                      ),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                  ),
                  SizedBox(width: 18),
                  OutlinedButton(
                    onPressed: () => skipChallenge(),
                    child: Text('Skip to Weight Challenge'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(fontWeight: FontWeight.w500),
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

  // Include your other step widgets here (SuitAssemblyStep2, PreBreatheStep, etc...)

  Widget stepContent() {
    switch (step) {
      case 1:
        return buildNeutralBuoyancyStep(context, nextStep, () {
          setState(() {
            step = 4; // Skip to weight adjustment challenge
          });
        });
      case 2:
        return SuitAssemblyStep2(nextStep: nextStep);
      case 3:
        return PreBreatheStep(onComplete: nextStep);
      case 4:
        return CableConnectionWidget(onComplete: nextStep);
      case 5:
        return MissionSequenceWidget(onComplete: nextStep);
      case 6:
        return DestinyLabOnboarding(onComplete: nextStep);
      case 7:
        return CupolaExperience();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NBL Training Protocol - Step $step')),
      body: Padding(padding: EdgeInsets.all(24), child: stepContent()),
    );
  }
}

class LaunchSequenceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simplified launch sequence and ISS docking placeholders
    return Scaffold(
      appBar: AppBar(title: Text('Launch Sequence')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Launching to the International Space Station...',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(value: 0.7),
            SizedBox(height: 20),
            Text('Altitude: 24,800 km'),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                final dockingSuccess = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => ISSDockingAlignmentStep()),
                );
                if (dockingSuccess == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ISSOnboardingTasksStep()),
                  );
                }
              },
              child: Text('Proceed to ISS Docking'),
            ),
          ],
        ),
      ),
    );
  }
}

// class ISSDirectScreen extends StatelessWidget {
//   const ISSDirectScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Direct to ISS')),
//       body: Center(
//         child: Text(
//           'Welcome directly aboard the International Space Station!',
//           style: TextStyle(fontSize: 20),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
