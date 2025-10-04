import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/core/debug/debug_utils.dart';

class RealisticEarth3D extends StatefulWidget {
  const RealisticEarth3D({Key? key}) : super(key: key);

  @override
  _RealisticEarth3DState createState() => _RealisticEarth3DState();
}

class _RealisticEarth3DState extends State<RealisticEarth3D>
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

  // 3D Earth parameters
  double _earthRadius = 1.0;
  double _cloudRadius = 1.02;
  List<Vector3> _earthVertices = [];
  List<Vector3> _cloudVertices = [];
  List<Vector3> _normalVectors = [];
  List<Vector3> _starPositions = [];

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
    
    _generateEarthGeometry();
    _generateStars();
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

  void _generateEarthGeometry() {
    const int segments = 64;
    const int rings = 32;
    
    _earthVertices.clear();
    _cloudVertices.clear();
    _normalVectors.clear();
    
    for (int ring = 0; ring <= rings; ring++) {
      final double v = ring / rings;
      final double phi = v * math.pi;
      
      for (int segment = 0; segment <= segments; segment++) {
        final double u = segment / segments;
        final double theta = u * 2 * math.pi;
        
        // Earth vertex
        final double x = _earthRadius * math.sin(phi) * math.cos(theta);
        final double y = _earthRadius * math.cos(phi);
        final double z = _earthRadius * math.sin(phi) * math.sin(theta);
        
        _earthVertices.add(Vector3(x, y, z));
        _normalVectors.add(Vector3(x, y, z).normalized);
        
        // Cloud vertex (slightly larger)
        final double cloudX = _cloudRadius * math.sin(phi) * math.cos(theta);
        final double cloudY = _cloudRadius * math.cos(phi);
        final double cloudZ = _cloudRadius * math.sin(phi) * math.sin(theta);
        
        _cloudVertices.add(Vector3(cloudX, cloudY, cloudZ));
      }
    }
  }

  void _generateStars() {
    final random = math.Random(42);
    _starPositions.clear();
    
    for (int i = 0; i < 2000; i++) {
      // Generate points on a sphere
      final double phi = math.acos(1 - 2 * random.nextDouble());
      final double theta = 2 * math.pi * random.nextDouble();
      
      final double radius = 50 + random.nextDouble() * 100;
      final double x = radius * math.sin(phi) * math.cos(theta);
      final double y = radius * math.cos(phi);
      final double z = radius * math.sin(phi) * math.sin(theta);
      
      _starPositions.add(Vector3(x, y, z));
    }
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
        title: Text('Realistic Earth 3D', style: AppTextStyles.heading3),
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
                  size: Size(400, 400),
                  painter: RealisticEarth3DPainter(
                    earthRotation: _rotationController.value * 2 * math.pi,
                    cloudRotation: _cloudController.value * 2 * math.pi,
                    issLatitude: _issLatitude,
                    issLongitude: _issLongitude,
                    issAltitude: _issAltitude,
                    issAnimation: _issController.value,
                    earthVertices: _earthVertices,
                    cloudVertices: _cloudVertices,
                    normalVectors: _normalVectors,
                    starPositions: _starPositions,
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
                color: Colors.black.withOpacity(0.8),
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
                color: Colors.black.withOpacity(0.8),
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
                    'Realistic 3D Earth',
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
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton('Earth', Icons.public, Colors.blue),
                      _buildControlButton('Clouds', Icons.cloud, Colors.white),
                      _buildControlButton('ISS', Icons.satellite_alt, Colors.red),
                    ],
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

  Widget _buildControlButton(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: color),
        ),
      ],
    );
  }
}

class Vector3 {
  final double x, y, z;
  
  Vector3(this.x, this.y, this.z);
  
  Vector3 operator +(Vector3 other) => Vector3(x + other.x, y + other.y, z + other.z);
  Vector3 operator -(Vector3 other) => Vector3(x - other.x, y - other.y, z - other.z);
  Vector3 operator *(double scalar) => Vector3(x * scalar, y * scalar, z * scalar);
  
  double dot(Vector3 other) => x * other.x + y * other.y + z * other.z;
  Vector3 cross(Vector3 other) => Vector3(
    y * other.z - z * other.y,
    z * other.x - x * other.z,
    x * other.y - y * other.x,
  );
  
  double get magnitude => math.sqrt(x * x + y * y + z * z);
  Vector3 get normalized => magnitude > 0 ? this * (1.0 / magnitude) : Vector3(0, 0, 0);
}

class RealisticEarth3DPainter extends CustomPainter {
  final double earthRotation;
  final double cloudRotation;
  final double issLatitude;
  final double issLongitude;
  final double issAltitude;
  final double issAnimation;
  final List<Vector3> earthVertices;
  final List<Vector3> cloudVertices;
  final List<Vector3> normalVectors;
  final List<Vector3> starPositions;

  RealisticEarth3DPainter({
    required this.earthRotation,
    required this.cloudRotation,
    required this.issLatitude,
    required this.issLongitude,
    required this.issAltitude,
    required this.issAnimation,
    required this.earthVertices,
    required this.cloudVertices,
    required this.normalVectors,
    required this.starPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width * 0.4;

    // Draw stars background
    _drawStars(canvas, size, center);

    // Draw Earth
    _drawRealisticEarth(canvas, center, scale);

    // Draw clouds
    _drawClouds(canvas, center, scale);

    // Draw ISS
    _drawISS(canvas, center, scale);

    // Draw atmosphere
    _drawAtmosphere(canvas, center, scale);
  }

  void _drawStars(Canvas canvas, Size size, Offset center) {
    final paint = Paint()..color = Colors.white;
    
    for (final star in starPositions) {
      // Rotate stars slowly
      final rotatedStar = _rotateY(star, earthRotation * 0.1);
      final screenPos = _project3D(rotatedStar, center, size.width * 0.1);
      
      if (screenPos != null) {
        final brightness = (0.5 + 0.5 * math.sin(star.x + star.y + star.z)).clamp(0.0, 1.0);
        paint.color = Colors.white.withOpacity(brightness);
        canvas.drawCircle(screenPos, 1.0, paint);
      }
    }
  }

  void _drawRealisticEarth(Canvas canvas, Offset center, double scale) {
    const int segments = 64;
    const int rings = 32;
    
    for (int ring = 0; ring < rings; ring++) {
      for (int segment = 0; segment < segments; segment++) {
        final int i = ring * (segments + 1) + segment;
        final int i1 = i;
        final int i2 = i + 1;
        final int i3 = (ring + 1) * (segments + 1) + segment;
        final int i4 = i3 + 1;
        
        if (i3 < earthVertices.length && i4 < earthVertices.length) {
          _drawEarthQuad(
            canvas, center, scale,
            earthVertices[i1], earthVertices[i2], earthVertices[i3], earthVertices[i4],
            normalVectors[i1], normalVectors[i2], normalVectors[i3], normalVectors[i4],
          );
        }
      }
    }
  }

  void _drawEarthQuad(
    Canvas canvas, Offset center, double scale,
    Vector3 v1, Vector3 v2, Vector3 v3, Vector3 v4,
    Vector3 n1, Vector3 n2, Vector3 n3, Vector3 n4,
  ) {
    // Rotate vertices
    final rv1 = _rotateY(v1, earthRotation);
    final rv2 = _rotateY(v2, earthRotation);
    final rv3 = _rotateY(v3, earthRotation);
    final rv4 = _rotateY(v4, earthRotation);
    
    final rn1 = _rotateY(n1, earthRotation);
    final rn2 = _rotateY(n2, earthRotation);
    final rn3 = _rotateY(n3, earthRotation);
    final rn4 = _rotateY(n4, earthRotation);
    
    // Project to screen
    final p1 = _project3D(rv1, center, scale);
    final p2 = _project3D(rv2, center, scale);
    final p3 = _project3D(rv3, center, scale);
    final p4 = _project3D(rv4, center, scale);
    
    if (p1 != null && p2 != null && p3 != null && p4 != null) {
      // Calculate lighting
      final lightDir = Vector3(1, 1, 1).normalized;
      final light1 = math.max(0.0, rn1.dot(lightDir));
      final light2 = math.max(0.0, rn2.dot(lightDir));
      final light3 = math.max(0.0, rn3.dot(lightDir));
      final light4 = math.max(0.0, rn4.dot(lightDir));
      
      // Calculate colors based on position and lighting
      final color1 = _getEarthColor(v1, light1);
      final color2 = _getEarthColor(v2, light2);
      final color3 = _getEarthColor(v3, light3);
      final color4 = _getEarthColor(v4, light4);
      
      // Draw quad with gradient
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p4.dx, p4.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();
      
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color1, color2, color4, color3],
        stops: [0.0, 0.33, 0.66, 1.0],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromLTRB(
          math.min(math.min(p1.dx, p2.dx), math.min(p3.dx, p4.dx)),
          math.min(math.min(p1.dy, p2.dy), math.min(p3.dy, p4.dy)),
          math.max(math.max(p1.dx, p2.dx), math.max(p3.dx, p4.dx)),
          math.max(math.max(p1.dy, p2.dy), math.max(p3.dy, p4.dy)),
        ));
      
      canvas.drawPath(path, paint);
    }
  }

  Color _getEarthColor(Vector3 position, double lighting) {
    // Convert 3D position to lat/lon
    final lat = math.asin(position.y).clamp(-math.pi/2, math.pi/2);
    final lon = math.atan2(position.z, position.x);
    
    // Determine if it's land or ocean based on simplified geography
    final isLand = _isLand(lat, lon);
    
    if (isLand) {
      // Land colors with lighting
      final baseColor = Color.lerp(
        Color(0xFF2E7D32), // Dark green
        Color(0xFF8D6E63), // Brown
        (math.sin(lat * 4) + 1) / 2,
      )!;
      
      return Color.lerp(
        baseColor,
        Colors.white,
        (1.0 - lighting) * 0.3,
      )!;
    } else {
      // Ocean colors with lighting
      final baseColor = Color.lerp(
        Color(0xFF0D47A1), // Deep blue
        Color(0xFF1976D2), // Lighter blue
        (math.sin(lat * 2) + 1) / 2,
      )!;
      
      return Color.lerp(
        baseColor,
        Colors.white,
        (1.0 - lighting) * 0.2,
      )!;
    }
  }

  bool _isLand(double lat, double lon) {
    // Simplified land detection based on latitude and longitude
    final latDeg = lat * 180 / math.pi;
    final lonDeg = lon * 180 / math.pi;
    
    // North America
    if (latDeg > 20 && latDeg < 70 && lonDeg > -170 && lonDeg < -50) return true;
    // Europe/Africa
    if (latDeg > -35 && latDeg < 70 && lonDeg > -20 && lonDeg < 40) return true;
    // Asia
    if (latDeg > 10 && latDeg < 70 && lonDeg > 40 && lonDeg < 180) return true;
    // Australia
    if (latDeg > -45 && latDeg < -10 && lonDeg > 110 && lonDeg < 160) return true;
    // South America
    if (latDeg > -55 && latDeg < 15 && lonDeg > -80 && lonDeg < -35) return true;
    
    return false;
  }

  void _drawClouds(Canvas canvas, Offset center, double scale) {
    const int segments = 32;
    const int rings = 16;
    
    for (int ring = 0; ring < rings; ring++) {
      for (int segment = 0; segment < segments; segment++) {
        final int i = ring * (segments + 1) + segment;
        final int i1 = i;
        final int i2 = i + 1;
        final int i3 = (ring + 1) * (segments + 1) + segment;
        final int i4 = i3 + 1;
        
        if (i3 < cloudVertices.length && i4 < cloudVertices.length) {
          _drawCloudQuad(
            canvas, center, scale,
            cloudVertices[i1], cloudVertices[i2], cloudVertices[i3], cloudVertices[i4],
          );
        }
      }
    }
  }

  void _drawCloudQuad(
    Canvas canvas, Offset center, double scale,
    Vector3 v1, Vector3 v2, Vector3 v3, Vector3 v4,
  ) {
    // Rotate vertices with different speed
    final rv1 = _rotateY(v1, cloudRotation);
    final rv2 = _rotateY(v2, cloudRotation);
    final rv3 = _rotateY(v3, cloudRotation);
    final rv4 = _rotateY(v4, cloudRotation);
    
    // Project to screen
    final p1 = _project3D(rv1, center, scale);
    final p2 = _project3D(rv2, center, scale);
    final p3 = _project3D(rv3, center, scale);
    final p4 = _project3D(rv4, center, scale);
    
    if (p1 != null && p2 != null && p3 != null && p4 != null) {
      // Check if quad is facing camera
      final normal = (rv2 - rv1).cross(rv3 - rv1).normalized;
      if (normal.z > 0) {
        final path = Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(p4.dx, p4.dy)
          ..lineTo(p3.dx, p3.dy)
          ..close();
        
        final paint = Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawISS(Canvas canvas, Offset center, double scale) {
    // Convert lat/lon to 3D coordinates
    final phi = (90 - issLatitude) * math.pi / 180;
    final theta = (issLongitude + earthRotation * 360) * math.pi / 180;
    
    final issRadius = 1.0 + (issAltitude / 6371.0);
    final x = issRadius * math.sin(phi) * math.cos(theta);
    final y = issRadius * math.cos(phi);
    final z = issRadius * math.sin(phi) * math.sin(theta);
    
    final issPos = Vector3(x, y, z);
    final rotatedPos = _rotateY(issPos, earthRotation);
    final screenPos = _project3D(rotatedPos, center, scale);
    
    if (screenPos != null) {
      // ISS orbit trail
      final trailPaint = Paint()
        ..color = Colors.red.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(center, scale * 1.02, trailPaint);
      
      // ISS marker with glow
      final issSize = 8 + (issAnimation * 4);
      
      // Glow effect
      final glowPaint = Paint()
        ..color = Colors.red.withOpacity(0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(screenPos, issSize + 6, glowPaint);
      
      // Main ISS marker
      final issPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(screenPos, issSize, issPaint);
      
      // Bright center
      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(screenPos, issSize * 0.3, centerPaint);
    }
  }

  void _drawAtmosphere(Canvas canvas, Offset center, double scale) {
    final atmospherePaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(center, scale * 1.05, atmospherePaint);
    
    // Outer glow
    final glowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.05)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawCircle(center, scale * 1.1, glowPaint);
  }

  Vector3 _rotateY(Vector3 v, double angle) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    return Vector3(
      v.x * cos - v.z * sin,
      v.y,
      v.x * sin + v.z * cos,
    );
  }

  Offset? _project3D(Vector3 v, Offset center, double scale) {
    // Simple perspective projection
    final distance = 3.0;
    if (v.z + distance <= 0) return null; // Behind camera
    
    final factor = distance / (v.z + distance);
    return Offset(
      center.dx + v.x * scale * factor,
      center.dy - v.y * scale * factor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! RealisticEarth3DPainter ||
        oldDelegate.earthRotation != earthRotation ||
        oldDelegate.cloudRotation != cloudRotation ||
        oldDelegate.issLatitude != issLatitude ||
        oldDelegate.issLongitude != issLongitude ||
        oldDelegate.issAnimation != issAnimation;
  }
}
