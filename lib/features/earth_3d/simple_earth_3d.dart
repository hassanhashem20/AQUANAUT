import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/core/debug/debug_utils.dart';

class SimpleEarth3D extends StatefulWidget {
  const SimpleEarth3D({Key? key}) : super(key: key);

  @override
  _SimpleEarth3DState createState() => _SimpleEarth3DState();
}

class _SimpleEarth3DState extends State<SimpleEarth3D>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _issController;
  
  // ISS Data
  double _issLatitude = 0.0;
  double _issLongitude = 0.0;
  double _issAltitude = 420.0;
  String _currentLocation = "Loading...";
  bool _isLoading = true;
  Timer? _issUpdateTimer;

  @override
  void initState() {
    super.initState();
    
    // Earth rotation animation
    _rotationController = AnimationController(
      duration: Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    // ISS movement animation
    _issController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    _fetchISSData();
    
    // Update ISS position every 10 seconds
    _issUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchISSData();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _issController.dispose();
    _issUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchISSData() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.wheretheiss.at/v1/satellites/25544'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _issLatitude = data['latitude']?.toDouble() ?? 0.0;
          _issLongitude = data['longitude']?.toDouble() ?? 0.0;
          _issAltitude = data['altitude']?.toDouble() ?? 420.0;
          _isLoading = false;
        });

        // Fetch location name
        await _fetchLocationName();
        
        // Animate ISS movement
        _issController.forward().then((_) {
          _issController.reset();
        });
        
        DebugUtils.log('ISS position updated: Lat $_issLatitude, Lon $_issLongitude');
      } else {
        DebugUtils.logError('Failed to load ISS position', 
            error: 'Status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      DebugUtils.logError('Error fetching ISS data', error: e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLocationName() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$_issLatitude&longitude=$_issLongitude&localityLanguage=en'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _currentLocation = data['principalSubdivision'] ??
              data['locality'] ??
              'Ocean';
        });
      }
    } catch (e) {
      DebugUtils.logError('Error fetching location', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        title: Text('Live ISS 3D Tracker', style: AppTextStyles.heading3),
        backgroundColor: AppColors.darkSpace,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 3D Earth with ISS
          Center(
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(300, 300),
                  painter: Earth3DPainter(
                    earthRotation: _rotationController.value * 2 * math.pi,
                    issLatitude: _issLatitude,
                    issLongitude: _issLongitude,
                    issAltitude: _issAltitude,
                    issAnimation: _issController.value,
                  ),
                );
              },
            ),
          ),
          
          // ISS Info Panel
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSpace.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.satellite_alt, color: AppColors.neonCyan),
                      SizedBox(width: 8),
                      Text(
                        'ISS Live Data',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.neonCyan,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                      ),
                    )
                  else ...[
                    _buildInfoRow('Latitude', '${_issLatitude.toStringAsFixed(2)}°'),
                    _buildInfoRow('Longitude', '${_issLongitude.toStringAsFixed(2)}°'),
                    _buildInfoRow('Altitude', '${_issAltitude.toStringAsFixed(0)} km'),
                    _buildInfoRow('Location', _currentLocation),
                  ],
                ],
              ),
            ),
          ),
          
          // Controls
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSpace.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.spaceBlue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '3D Earth Controls',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.spaceBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The Earth rotates automatically. The red dot shows the ISS position.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class Earth3DPainter extends CustomPainter {
  final double earthRotation;
  final double issLatitude;
  final double issLongitude;
  final double issAltitude;
  final double issAnimation;

  Earth3DPainter({
    required this.earthRotation,
    required this.issLatitude,
    required this.issLongitude,
    required this.issAltitude,
    required this.issAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Draw stars background
    _drawStars(canvas, size);

    // Draw Earth
    _drawEarth(canvas, center, radius);

    // Draw ISS
    _drawISS(canvas, center, radius);

    // Draw orbit ring
    _drawOrbitRing(canvas, center, radius);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    final random = math.Random(42); // Fixed seed for consistent stars

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 2 + 0.5;
      
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  void _drawEarth(Canvas canvas, Offset center, double radius) {
    // Earth shadow (for 3D effect)
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawCircle(
      Offset(center.dx + 5, center.dy + 5),
      radius,
      shadowPaint,
    );

    // Earth gradient
    final earthGradient = RadialGradient(
      colors: [
        Color(0xFF4A90E2), // Ocean blue
        Color(0xFF2E7D32), // Land green
        Color(0xFF8D6E63), // Mountain brown
      ],
      stops: [0.0, 0.6, 1.0],
    );

    final earthPaint = Paint()
      ..shader = earthGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, earthPaint);

    // Earth continents (simplified)
    _drawContinents(canvas, center, radius);

    // Earth atmosphere
    final atmospherePaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius + 5, atmospherePaint);
  }

  void _drawContinents(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;

    // Simplified continent shapes
    final path = Path();
    
    // North America
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.2),
      width: radius * 0.4,
      height: radius * 0.3,
    ));
    
    // Europe/Africa
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx + radius * 0.1, center.dy - radius * 0.1),
      width: radius * 0.3,
      height: radius * 0.5,
    ));
    
    // Asia
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx + radius * 0.3, center.dy - radius * 0.1),
      width: radius * 0.4,
      height: radius * 0.3,
    ));

    canvas.drawPath(path, paint);
  }

  void _drawISS(Canvas canvas, Offset center, double radius) {
    // Convert lat/lon to screen coordinates
    final phi = (90 - issLatitude) * math.pi / 180;
    final theta = (issLongitude + earthRotation * 360) * math.pi / 180;

    final x = center.dx + (radius + 20) * math.sin(phi) * math.cos(theta);
    final y = center.dy - (radius + 20) * math.sin(phi) * math.sin(theta);

    // ISS orbit trail
    final trailPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius + 20, trailPaint);

    // ISS marker with animation
    final issPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final issSize = 6 + (issAnimation * 2);
    canvas.drawCircle(Offset(x, y), issSize, issPaint);

    // ISS glow effect
    final glowPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(Offset(x, y), issSize + 3, glowPaint);
  }

  void _drawOrbitRing(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius + 20, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! Earth3DPainter ||
        oldDelegate.earthRotation != earthRotation ||
        oldDelegate.issLatitude != issLatitude ||
        oldDelegate.issLongitude != issLongitude ||
        oldDelegate.issAnimation != issAnimation;
  }
}

