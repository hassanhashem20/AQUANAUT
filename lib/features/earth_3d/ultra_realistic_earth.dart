import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/core/debug/debug_utils.dart';

class UltraRealisticEarth extends StatefulWidget {
  const UltraRealisticEarth({Key? key}) : super(key: key);

  @override
  _UltraRealisticEarthState createState() => _UltraRealisticEarthState();
}

class _UltraRealisticEarthState extends State<UltraRealisticEarth>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _issController;
  late AnimationController _cloudController;
  
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
    
    // Earth rotation animation (24 hours = 30 seconds)
    _rotationController = AnimationController(
      duration: Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    // ISS movement animation
    _issController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    // Cloud movement animation
    _cloudController = AnimationController(
      duration: Duration(seconds: 45),
      vsync: this,
    )..repeat();
    
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
    _cloudController.dispose();
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

        await _fetchLocationName();
        
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Ultra Realistic Earth 3D', style: AppTextStyles.heading3),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 3D Earth Scene
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_rotationController, _issController, _cloudController]),
              builder: (context, child) {
                return CustomPaint(
                  size: Size(500, 500),
                  painter: UltraRealisticEarthPainter(
                    earthRotation: _rotationController.value * 2 * math.pi,
                    cloudRotation: _cloudController.value * 2 * math.pi,
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
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.satellite_alt, color: Colors.cyan, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'ISS Live Tracking',
                        style: AppTextStyles.heading2.copyWith(
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                      ),
                    )
                  else ...[
                    _buildInfoRow('Latitude', '${_issLatitude.toStringAsFixed(4)}°', Colors.white),
                    _buildInfoRow('Longitude', '${_issLongitude.toStringAsFixed(4)}°', Colors.white),
                    _buildInfoRow('Altitude', '${_issAltitude.toStringAsFixed(0)} km', Colors.green),
                    _buildInfoRow('Velocity', '27,600 km/h', Colors.orange),
                    _buildInfoRow('Location', _currentLocation, Colors.cyan),
                  ],
                ],
              ),
            ),
          ),
          
          // Controls Panel
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Ultra Realistic 3D Earth',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'High-quality 3D Earth with realistic lighting, clouds, and live ISS tracking',
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

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
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
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class UltraRealisticEarthPainter extends CustomPainter {
  final double earthRotation;
  final double cloudRotation;
  final double issLatitude;
  final double issLongitude;
  final double issAltitude;
  final double issAnimation;

  UltraRealisticEarthPainter({
    required this.earthRotation,
    required this.cloudRotation,
    required this.issLatitude,
    required this.issLongitude,
    required this.issAltitude,
    required this.issAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw stars background
    _drawStars(canvas, size);

    // Draw Earth with high quality
    _drawUltraRealisticEarth(canvas, center, radius);

    // Draw clouds
    _drawClouds(canvas, center, radius);

    // Draw ISS
    _drawISS(canvas, center, radius);

    // Draw atmosphere
    _drawAtmosphere(canvas, center, radius);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = math.Random(42);
    
    for (int i = 0; i < 3000; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final brightness = random.nextDouble();
      final starSize = 0.5 + random.nextDouble() * 2;
      
      paint.color = Colors.white.withOpacity(brightness);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  void _drawUltraRealisticEarth(Canvas canvas, Offset center, double radius) {
    // Create high-resolution Earth using multiple circles with gradients
    final earthGradient = RadialGradient(
      colors: [
        Color(0xFF1A237E), // Deep space blue
        Color(0xFF0D47A1), // Ocean blue
        Color(0xFF1976D2), // Lighter blue
        Color(0xFF42A5F5), // Light blue
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
      center: Alignment(-0.3, -0.3), // Light source position
    );

    // Main Earth sphere
    final earthPaint = Paint()
      ..shader = earthGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, earthPaint);

    // Add landmasses with realistic shapes
    _drawLandmasses(canvas, center, radius);

    // Add polar ice caps
    _drawPolarCaps(canvas, center, radius);

    // Add mountain ranges
    _drawMountainRanges(canvas, center, radius);

    // Add ocean depth variation
    _drawOceanDepth(canvas, center, radius);
  }

  void _drawLandmasses(Canvas canvas, Offset center, double radius) {
    final paint = Paint()..color = Color(0xFF2E7D32);
    
    // North America
    final naPath = Path();
    naPath.addOval(Rect.fromCenter(
      center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.1),
      width: radius * 0.4,
      height: radius * 0.3,
    ));
    canvas.drawPath(naPath, paint);

    // Europe/Africa
    final eafPath = Path();
    eafPath.addOval(Rect.fromCenter(
      center: Offset(center.dx + radius * 0.1, center.dy - radius * 0.05),
      width: radius * 0.25,
      height: radius * 0.5,
    ));
    canvas.drawPath(eafPath, paint);

    // Asia
    final asiaPath = Path();
    asiaPath.addOval(Rect.fromCenter(
      center: Offset(center.dx + radius * 0.3, center.dy - radius * 0.05),
      width: radius * 0.4,
      height: radius * 0.25,
    ));
    canvas.drawPath(asiaPath, paint);

    // Australia
    final ausPath = Path();
    ausPath.addOval(Rect.fromCenter(
      center: Offset(center.dx + radius * 0.2, center.dy + radius * 0.3),
      width: radius * 0.15,
      height: radius * 0.1,
    ));
    canvas.drawPath(ausPath, paint);

    // South America
    final saPath = Path();
    saPath.addOval(Rect.fromCenter(
      center: Offset(center.dx - radius * 0.2, center.dy + radius * 0.2),
      width: radius * 0.2,
      height: radius * 0.4,
    ));
    canvas.drawPath(saPath, paint);
  }

  void _drawPolarCaps(Canvas canvas, Offset center, double radius) {
    // North polar cap
    final northCapPaint = Paint()
      ..color = Colors.white.withOpacity(0.8);
    
    final northCapPath = Path();
    northCapPath.addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy - radius * 0.7),
      width: radius * 0.6,
      height: radius * 0.3,
    ));
    canvas.drawPath(northCapPath, northCapPaint);

    // South polar cap
    final southCapPaint = Paint()
      ..color = Colors.white.withOpacity(0.6);
    
    final southCapPath = Path();
    southCapPath.addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy + radius * 0.7),
      width: radius * 0.5,
      height: radius * 0.25,
    ));
    canvas.drawPath(southCapPath, southCapPaint);
  }

  void _drawMountainRanges(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Color(0xFF8D6E63)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Rocky Mountains
    final rockyPath = Path();
    rockyPath.moveTo(center.dx - radius * 0.4, center.dy - radius * 0.1);
    rockyPath.quadraticBezierTo(
      center.dx - radius * 0.3, center.dy - radius * 0.2,
      center.dx - radius * 0.2, center.dy - radius * 0.1,
    );
    canvas.drawPath(rockyPath, paint);

    // Himalayas
    final himalayaPath = Path();
    himalayaPath.moveTo(center.dx + radius * 0.1, center.dy - radius * 0.1);
    himalayaPath.quadraticBezierTo(
      center.dx + radius * 0.2, center.dy - radius * 0.3,
      center.dx + radius * 0.3, center.dy - radius * 0.1,
    );
    canvas.drawPath(himalayaPath, paint);
  }

  void _drawOceanDepth(Canvas canvas, Offset center, double radius) {
    final deepOceanPaint = Paint()
      ..color = Color(0xFF0D47A1).withOpacity(0.3);
    
    // Deep ocean trenches
    final trenchPath = Path();
    trenchPath.addOval(Rect.fromCenter(
      center: Offset(center.dx + radius * 0.1, center.dy + radius * 0.1),
      width: radius * 0.3,
      height: radius * 0.2,
    ));
    canvas.drawPath(trenchPath, deepOceanPaint);
  }

  void _drawClouds(Canvas canvas, Offset center, double radius) {
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.4);
    
    // Create cloud patterns
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + cloudRotation;
      final cloudX = center.dx + math.cos(angle) * radius * 1.05;
      final cloudY = center.dy + math.sin(angle) * radius * 1.05;
      
      final cloudPath = Path();
      cloudPath.addOval(Rect.fromCenter(
        center: Offset(cloudX, cloudY),
        width: radius * 0.3,
        height: radius * 0.15,
      ));
      canvas.drawPath(cloudPath, cloudPaint);
    }
  }

  void _drawISS(Canvas canvas, Offset center, double radius) {
    // Convert lat/lon to screen coordinates
    final phi = (90 - issLatitude) * math.pi / 180;
    final theta = (issLongitude + earthRotation * 360) * math.pi / 180;
    
    final issRadius = radius * 1.08;
    final x = center.dx + issRadius * math.sin(phi) * math.cos(theta);
    final y = center.dy - issRadius * math.sin(phi) * math.sin(theta);
    
    // ISS orbit trail
    final trailPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, issRadius, trailPaint);

    // ISS marker with glow
    final issSize = 6 + (issAnimation * 3);
    
    // Glow effect
    final glowPaint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);
    
    canvas.drawCircle(Offset(x, y), issSize + 4, glowPaint);
    
    // Main ISS marker
    final issPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(x, y), issSize, issPaint);
    
    // Bright center
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(x, y), issSize * 0.4, centerPaint);
  }

  void _drawAtmosphere(Canvas canvas, Offset center, double radius) {
    // Inner atmosphere
    final innerAtmospherePaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, radius * 1.02, innerAtmospherePaint);
    
    // Outer atmosphere glow
    final outerGlowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.05)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(center, radius * 1.05, outerGlowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! UltraRealisticEarthPainter ||
        oldDelegate.earthRotation != earthRotation ||
        oldDelegate.cloudRotation != cloudRotation ||
        oldDelegate.issLatitude != issLatitude ||
        oldDelegate.issLongitude != issLongitude ||
        oldDelegate.issAnimation != issAnimation;
  }
}
