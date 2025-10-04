import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// Bubble class definition remains unchanged
class Bubble {
  double x;
  double y;
  double size;
  Color color;
  double speed;

  Bubble(this.x, this.y, this.size, this.color, this.speed);
}

class PreBreatheStep extends StatefulWidget {
  final VoidCallback onComplete;
  const PreBreatheStep({Key? key, required this.onComplete}) : super(key: key);

  @override
  _PreBreatheStepState createState() => _PreBreatheStepState();
}

class _PreBreatheStepState extends State<PreBreatheStep>
    with SingleTickerProviderStateMixin {
  static const int totalSeconds = 5; // Short for demo
  int remainingSeconds = totalSeconds;
  Timer? countdownTimer;
  bool completeEnabled = false;

  late AnimationController _controller;

  List<Bubble> nitrogenBubbles = [];
  List<Bubble> oxygenBubbles = [];
  Random random = Random();

  // Bubble center for astronaut
  final double astronautCenterX = 0.5;
  final double astronautCenterY = 0.55;

  String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(_updateBubbles)
          ..repeat();
    _initBubbles();
  }

  void _initBubbles() {
    // Nitrogen bubbles start at astronaut center, direction upwards
    for (int i = 0; i < 15; i++) {
      nitrogenBubbles.add(
        Bubble(
          astronautCenterX,
          astronautCenterY,
          10 + random.nextDouble() * 12,
          Colors.red,
          0.012 + random.nextDouble() * 0.007,
        ),
      );
    }

    // Oxygen bubbles start from bottom, moving toward astronaut
    for (int i = 0; i < 10; i++) {
      oxygenBubbles.add(
        Bubble(
          random.nextDouble(), // Random X position at bottom
          0.95, // Start from bottom
          8 + random.nextDouble() * 10,
          Colors.blue,
          0.008 + random.nextDouble() * 0.005,
        ),
      );
    }
  }

  void _updateBubbles() {
    setState(() {
      // Update nitrogen bubbles (leaving body)
      for (var b in nitrogenBubbles) {
        // Move bubbles upward with a small horizontal jitter
        b.y -= b.speed * (0.8 + random.nextDouble() * 0.3);
        b.x += (random.nextDouble() - 0.5) * 0.01;
        // Reset bubbles if offscreen
        if (b.y < 0.05) {
          b.x = astronautCenterX;
          b.y = astronautCenterY;
        }
      }

      // Update oxygen bubbles (entering body)
      for (var b in oxygenBubbles) {
        // Move bubbles toward astronaut center
        double targetX = astronautCenterX;
        double targetY = astronautCenterY;

        // Calculate direction vector
        double dx = targetX - b.x;
        double dy = targetY - b.y;
        double distance = sqrt(dx * dx + dy * dy);

        // Normalize and apply speed
        if (distance > 0.02) {
          b.x += (dx / distance) * b.speed;
          b.y += (dy / distance) * b.speed;
        } else {
          // Reset oxygen bubble when it reaches astronaut
          b.x = random.nextDouble();
          b.y = 0.95;
        }
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds == 0) {
        setState(() {
          completeEnabled = true;
        });
        countdownTimer?.cancel();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Step 3: Pre-Breathe Protocol',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        Text(
          'Breathing pure oxygen to flush nitrogen from your bloodstream to prevent decompression sickness before a spacewalk.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            children: [
              // Astronaut
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/astronaut_icon.png",
                  width: 100,
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),
              // Bubbles
              Positioned.fill(
                child: CustomPaint(
                  painter: BubblePainter(nitrogenBubbles, oxygenBubbles),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Text(
          'Mission Timer:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.blueGrey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            formatDuration(remainingSeconds),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlueAccent,
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          completeEnabled
              ? 'Pre-breathe complete! Ready for next step.'
              : 'Pre-breathe in progress...',
          style: TextStyle(
            fontSize: 16,
            color: completeEnabled ? Colors.greenAccent : Colors.orangeAccent,
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: completeEnabled ? widget.onComplete : null,
          child: Text('Complete Pre-Breathe'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
}

class BubblePainter extends CustomPainter {
  final List<Bubble> nitrogenBubbles;
  final List<Bubble> oxygenBubbles;

  BubblePainter(this.nitrogenBubbles, this.oxygenBubbles);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw oxygen bubbles first (so they appear behind nitrogen bubbles)
    for (var b in oxygenBubbles) {
      final paint = Paint()..color = b.color.withOpacity(0.7);
      canvas.drawCircle(
        Offset(b.x * size.width, b.y * size.height),
        b.size,
        paint,
      );
    }

    // Draw nitrogen bubbles
    for (var b in nitrogenBubbles) {
      final paint = Paint()..color = b.color.withOpacity(0.7);
      canvas.drawCircle(
        Offset(b.x * size.width, b.y * size.height),
        b.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
