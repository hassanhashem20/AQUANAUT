import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';

class AnimatedSpaceBackground extends StatefulWidget {
  final Widget child;
  final int starCount;

  const AnimatedSpaceBackground({
    Key? key,
    required this.child,
    this.starCount = 100,
  }) : super(key: key);

  @override
  State<AnimatedSpaceBackground> createState() => _AnimatedSpaceBackgroundState();
}

class _AnimatedSpaceBackgroundState extends State<AnimatedSpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat();

    stars = List.generate(
      widget.starCount,
      (index) => Star.random(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.spaceGradient,
          ),
        ),
        // Animated Stars
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: StarFieldPainter(stars, _controller.value),
              size: Size.infinite,
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  factory Star.random() {
    final random = math.Random();
    return Star(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: random.nextDouble() * 2 + 1,
      speed: random.nextDouble() * 0.5 + 0.1,
      opacity: random.nextDouble() * 0.7 + 0.3,
    );
  }
}

class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animation;

  StarFieldPainter(this.stars, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var star in stars) {
      final dx = star.x * size.width;
      final dy = (star.y * size.height + (animation * star.speed * size.height)) % size.height;
      
      paint.color = Colors.white.withOpacity(star.opacity);
      canvas.drawCircle(Offset(dx, dy), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) => true;
}
