import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';

class SimpleEarthViewer extends StatefulWidget {
  @override
  _SimpleEarthViewerState createState() => _SimpleEarthViewerState();
}

class _SimpleEarthViewerState extends State<SimpleEarthViewer>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _issController;
  
  // ISS Data
  double _issLatitude = 0.0;
  double _issLongitude = 0.0;
  double _issAltitude = 420.0;
  double _issVelocity = 27600.0;
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
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _issLatitude = data['latitude']?.toDouble() ?? 0.0;
            _issLongitude = data['longitude']?.toDouble() ?? 0.0;
            _issAltitude = data['altitude']?.toDouble() ?? 420.0;
            _issVelocity = data['velocity']?.toDouble() ?? 27600.0;
            _isLoading = false;
          });
          
          // Animate ISS movement
          _issController.forward().then((_) {
            _issController.reset();
          });
          
          // Get location name
          _getLocationName(_issLatitude, _issLongitude);
        }
      }
    } catch (e) {
      print('Error fetching ISS data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getLocationName(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lng&localityLanguage=en',
        ),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _currentLocation = data['city']?.toString() ?? 
                             data['locality']?.toString() ?? 
                             data['principalSubdivision']?.toString() ?? 
                             'International Waters';
          });
        }
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        title: Text('Live ISS Tracking - Earth View'),
        backgroundColor: AppColors.darkSpace,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchISSData,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated background stars
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return CustomPaint(
                painter: StarsPainter(_rotationController.value),
                size: Size.infinite,
              );
            },
          ),
          
          // Main content
          Column(
            children: [
              // ISS Information Panel
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkSpace.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.satellite_alt, color: AppColors.neonCyan, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'International Space Station',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.neonCyan,
                          ),
                        ),
                        if (_isLoading) ...[
                          SizedBox(width: 8),
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.neonCyan,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Currently over: $_currentLocation',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDataItem(
                            'Altitude',
                            '${_issAltitude.toStringAsFixed(1)} km',
                            Icons.height,
                          ),
                        ),
                        Expanded(
                          child: _buildDataItem(
                            'Velocity',
                            '${_issVelocity.toStringAsFixed(0)} km/h',
                            Icons.speed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Earth visualization
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: EarthPainter(
                              issLatitude: _issLatitude,
                              issLongitude: _issLongitude,
                              earthRotation: _rotationController.value * 2 * math.pi,
                            ),
                            child: Container(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              // ISS Position Indicator
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkSpace.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.successGreen, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'ISS Position',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Latitude',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '${_issLatitude.toStringAsFixed(4)}°',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Longitude',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '${_issLongitude.toStringAsFixed(4)}°',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Loading indicator
          if (_isLoading)
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkSpace.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.neonCyan,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading ISS data...',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.midSpace.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.starYellow, size: 16),
              SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
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

class StarsPainter extends CustomPainter {
  final double animationValue;

  StarsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent stars
    
    for (int i = 0; i < 200; i++) {
      final x = (random.nextDouble() * size.width) % size.width;
      final y = (random.nextDouble() * size.height) % size.height;
      final opacity = (0.3 + 0.7 * (0.5 + 0.5 * math.sin(animationValue * 2 + i * 0.1))).clamp(0.0, 1.0);
      
      canvas.drawCircle(
        Offset(x, y),
        1.0 + random.nextDouble() * 1.5,
        Paint()
          ..color = Colors.white.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) => true;
}

class EarthPainter extends CustomPainter {
  final double issLatitude;
  final double issLongitude;
  final double earthRotation;

  EarthPainter({
    required this.issLatitude,
    required this.issLongitude,
    required this.earthRotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.4;
    
    // Draw Earth
    _drawEarth(canvas, center, radius);
    
    // Draw continents
    _drawContinents(canvas, center, radius);
    
    // Draw ISS
    _drawISS(canvas, center, radius);
    
    // Draw orbit
    _drawOrbit(canvas, center, radius);
  }

  void _drawEarth(Canvas canvas, Offset center, double radius) {
    // Earth gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = RadialGradient(
      colors: [
        Color(0xFF4A90E2), // Ocean blue
        Color(0xFF2E5B8A), // Darker blue
        Color(0xFF1A3A5C), // Deep blue
      ],
      stops: [0.0, 0.7, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(rect);
    
    canvas.drawCircle(center, radius, paint);
    
    // Add atmosphere glow
    final glowPaint = Paint()
      ..color = Color(0xFF4A90E2).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(center, radius + 2, glowPaint);
  }

  void _drawContinents(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Color(0xFF8B4513) // Brown for continents
      ..style = PaintingStyle.fill;

    // Simplified continent shapes
    final continentPaths = _getContinentPaths(center, radius);
    
    for (final path in continentPaths) {
      canvas.drawPath(path, paint);
    }
  }

  List<Path> _getContinentPaths(Offset center, double radius) {
    final paths = <Path>[];
    
    // North America
    final northAmerica = Path();
    northAmerica.moveTo(center.dx - radius * 0.3, center.dy - radius * 0.2);
    northAmerica.lineTo(center.dx - radius * 0.1, center.dy - radius * 0.3);
    northAmerica.lineTo(center.dx + radius * 0.1, center.dy - radius * 0.2);
    northAmerica.lineTo(center.dx + radius * 0.05, center.dy + radius * 0.1);
    northAmerica.lineTo(center.dx - radius * 0.2, center.dy + radius * 0.05);
    northAmerica.close();
    paths.add(northAmerica);
    
    // Europe/Africa
    final europeAfrica = Path();
    europeAfrica.moveTo(center.dx - radius * 0.1, center.dy - radius * 0.3);
    europeAfrica.lineTo(center.dx + radius * 0.1, center.dy - radius * 0.2);
    europeAfrica.lineTo(center.dx + radius * 0.15, center.dy + radius * 0.2);
    europeAfrica.lineTo(center.dx - radius * 0.05, center.dy + radius * 0.3);
    europeAfrica.close();
    paths.add(europeAfrica);
    
    // Asia
    final asia = Path();
    asia.moveTo(center.dx + radius * 0.1, center.dy - radius * 0.2);
    asia.lineTo(center.dx + radius * 0.4, center.dy - radius * 0.1);
    asia.lineTo(center.dx + radius * 0.35, center.dy + radius * 0.15);
    asia.lineTo(center.dx + radius * 0.15, center.dy + radius * 0.2);
    asia.close();
    paths.add(asia);
    
    return paths;
  }

  void _drawISS(Canvas canvas, Offset center, double radius) {
    // Convert lat/lng to screen coordinates
    final phi = (90 - issLatitude) * (math.pi / 180);
    final theta = (issLongitude + 180) * (math.pi / 180);
    final issRadius = radius + 20; // ISS orbit height
    
    final x = center.dx + issRadius * math.sin(phi) * math.cos(theta);
    final y = center.dy + issRadius * math.cos(phi);
    
    // Draw ISS
    final issPaint = Paint()
      ..color = AppColors.neonCyan
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(x, y), 4, issPaint);
    
    // Draw ISS trail
    final trailPaint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(Offset(x, y), 8, trailPaint);
  }

  void _drawOrbit(Canvas canvas, Offset center, double radius) {
    final orbitPaint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawCircle(center, radius + 20, orbitPaint);
  }

  @override
  bool shouldRepaint(EarthPainter oldDelegate) {
    return oldDelegate.issLatitude != issLatitude ||
           oldDelegate.issLongitude != issLongitude ||
           oldDelegate.earthRotation != earthRotation;
  }
}
