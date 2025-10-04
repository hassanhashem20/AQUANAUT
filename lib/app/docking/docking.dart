import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MissionSequenceWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const MissionSequenceWidget({super.key, required this.onComplete});

  @override
  State<MissionSequenceWidget> createState() => _MissionSequenceWidgetState();
}

enum MissionPhase {
  ReadyToLaunch,
  Countdown,
  Launching,
  OrbitInsertion,
  Complete,
}

class _MissionSequenceWidgetState extends State<MissionSequenceWidget>
    with SingleTickerProviderStateMixin {
  MissionPhase _phase = MissionPhase.ReadyToLaunch;
  int _countdown = 10;
  double _rocketPosition = 0.0;
  double _orbitProgress = 0.0;

  Timer? _countdownTimer;
  Timer? _launchTimer;
  Timer? _orbitTimer;

  late AnimationController _particleController;
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    )..addListener(_updateParticles);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _launchTimer?.cancel();
    _orbitTimer?.cancel();
    _particleController.dispose();
    super.dispose();
  }

  void _updateParticles() {
    setState(() {
      // Update existing particles
      _particles.removeWhere((particle) => particle.life <= 0);
      for (var particle in _particles) {
        particle.x += particle.vx;
        particle.y += particle.vy;
        particle.life--;
        particle.size *= 0.95;
      }

      // Add new particles during launch
      if (_phase == MissionPhase.Launching && _particles.length < 50) {
        _addParticles();
      }
    });
  }

  void _addParticles() {
    final random = Random();
    for (int i = 0; i < 3; i++) {
      _particles.add(
        Particle(
          x: 0.5 + (random.nextDouble() - 0.5) * 0.1,
          y: 0.7 - _rocketPosition * 0.6,
          vx: (random.nextDouble() - 0.5) * 0.02,
          vy: random.nextDouble() * 0.03 + 0.02,
          size: 5 + random.nextDouble() * 10,
          life: 20 + random.nextInt(30),
        ),
      );
    }
  }

  void _startCountdown() {
    setState(() {
      _phase = MissionPhase.Countdown;
      _countdown = 10;
    });
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _startLaunch();
      }
    });
  }

  void _startLaunch() {
    setState(() {
      _phase = MissionPhase.Launching;
      _rocketPosition = 0.0;
      _particles.clear();
    });
    _particleController.repeat();

    _launchTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        _rocketPosition += 0.02;
        if (_rocketPosition >= 1.0) {
          _rocketPosition = 1.0;
          timer.cancel();
          _startOrbitInsertion();
        }
      });
    });
  }

  void _startOrbitInsertion() {
    setState(() {
      _phase = MissionPhase.OrbitInsertion;
      _orbitProgress = 0.0;
      _particles.clear();
    });
    _particleController.stop();

    _orbitTimer = Timer.periodic(Duration(milliseconds: 40), (timer) {
      setState(() {
        _orbitProgress += 0.01;
        if (_orbitProgress >= 1.0) {
          _orbitProgress = 1.0;
          timer.cancel();
          _completeMission();
        }
      });
    });
  }

  void _completeMission() {
    setState(() {
      _phase = MissionPhase.Complete;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              "3. Rocket Launch Sequence",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),

            // Content area
            Expanded(child: _buildPhaseContent()),

            // Progress indicator for orbit phase
            if (_phase == MissionPhase.OrbitInsertion) ...[
              SizedBox(height: 20),
              LinearProgressIndicator(
                value: _orbitProgress,
                backgroundColor: Colors.grey[800],
                color: Colors.lightBlueAccent,
                minHeight: 8,
              ),
              SizedBox(height: 10),
              Text(
                "Orbit Insertion: ${(_orbitProgress * 100).toInt()}%",
                style: TextStyle(color: Colors.white70),
              ),
            ],

            // Action button
            if (_phase == MissionPhase.ReadyToLaunch) ...[
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: Size(200, 50),
                ),
                onPressed: _startCountdown,
                child: Text("Start Countdown", style: TextStyle(fontSize: 18)),
              ),
            ] else if (_phase == MissionPhase.Complete) ...[
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(200, 50),
                ),
                onPressed: widget.onComplete,
                child: Text(
                  "Continue to Next Mission",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseContent() {
    switch (_phase) {
      case MissionPhase.ReadyToLaunch:
        return _buildReadyScreen();
      case MissionPhase.Countdown:
        return _buildCountdownScreen();
      case MissionPhase.Launching:
        return _buildLaunchScreen();
      case MissionPhase.OrbitInsertion:
        return _buildOrbitScreen();
      case MissionPhase.Complete:
        return _buildCompleteScreen();
    }
  }

  Widget _buildReadyScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.rocket_launch, size: 80, color: Colors.orange),
        SizedBox(height: 20),
        Text(
          "Launch Sequence Ready",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        SizedBox(height: 15),
        Text(
          "Prepare for rocket launch to orbit.\n"
          "The sequence includes:\n\n"
          "• 10-second countdown\n"
          "• Rocket launch with engine effects\n"
          "• Orbit insertion and space view",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildCountdownScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "LAUNCH IN",
            style: TextStyle(
              fontSize: 24,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "$_countdown",
            style: TextStyle(
              fontSize: 72,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          if (_countdown <= 3)
            Text(
              "ENGINES IGNITED",
              style: TextStyle(
                fontSize: 18,
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLaunchScreen() {
    return Stack(
      children: [
        // Particles (fire/smoke)
        CustomPaint(painter: ParticlePainter(_particles), size: Size.infinite),

        // Rocket
        Align(
          alignment: Alignment(0, 0.7 - _rocketPosition * 1.4),
          child: Icon(Icons.rocket, size: 60, color: Colors.white),
        ),

        // Status text
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "🚀 LAUNCH!",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Altitude: ${(_rocketPosition * 300).toInt()} km",
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                Text(
                  "Velocity: ${(10000 + _rocketPosition * 25000).toInt()} km/h",
                  style: TextStyle(fontSize: 16, color: Colors.white60),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrbitScreen() {
    return Stack(
      children: [
        // Space background with Earth curvature
        CustomPaint(painter: SpacePainter(_orbitProgress), size: Size.infinite),

        // Status text
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ORBIT INSERTION",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Achieving stable orbit...",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              SizedBox(height: 10),
              Text(
                "Altitude: 400 km",
                style: TextStyle(fontSize: 16, color: Colors.white60),
              ),
              Text(
                "Orbital Velocity: 28,000 km/h",
                style: TextStyle(fontSize: 16, color: Colors.white60),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, size: 80, color: Colors.green),
        SizedBox(height: 20),
        Text(
          "Launch Sequence Complete!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 15),
        Text(
          "✓ Countdown completed\n"
          "✓ Rocket launched successfully\n"
          "✓ Orbit insertion achieved\n"
          "✓ Mission objectives met",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  Color _getBackgroundColor() {
    switch (_phase) {
      case MissionPhase.ReadyToLaunch:
      case MissionPhase.Countdown:
        return Colors.grey[900]!;
      case MissionPhase.Launching:
        return Colors.blue[900]!;
      case MissionPhase.OrbitInsertion:
      case MissionPhase.Complete:
        return Colors.black;
    }
  }
}

class Particle {
  double x, y;
  double vx, vy;
  double size;
  int life;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.life,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint =
          Paint()
            ..color = Colors.orange.withOpacity(particle.life / 50.0)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SpacePainter extends CustomPainter {
  final double progress;

  SpacePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw stars
    final random = Random(42); // Fixed seed for consistent stars
    final starPaint = Paint()..color = Colors.white;

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5;
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // Draw Earth curvature
    final earthPaint =
        Paint()
          ..color = Colors.blue[800]!
          ..style = PaintingStyle.fill;

    final earthPath =
        Path()
          ..moveTo(0, size.height)
          ..quadraticBezierTo(
            size.width / 2,
            size.height * (1.0 - progress * 0.3),
            size.width,
            size.height,
          )
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();

    canvas.drawPath(earthPath, earthPaint);

    // Draw Earth details
    final landPaint =
        Paint()
          ..color = Colors.green[800]!
          ..style = PaintingStyle.fill;

    final landPath =
        Path()
          ..moveTo(size.width * 0.3, size.height)
          ..quadraticBezierTo(
            size.width * 0.5,
            size.height * (0.95 - progress * 0.2),
            size.width * 0.7,
            size.height,
          );

    canvas.drawPath(landPath, landPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
