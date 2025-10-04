import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/core/debug/debug_utils.dart';

class GoogleEarthQuality extends StatefulWidget {
  const GoogleEarthQuality({Key? key}) : super(key: key);

  @override
  _GoogleEarthQualityState createState() => _GoogleEarthQualityState();
}

class _GoogleEarthQualityState extends State<GoogleEarthQuality>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _cloudController;
  late AnimationController _issController;
  
  // ISS Data
  Map<String, dynamic>? _issData;
  Timer? _issUpdateTimer;
  
  // High-quality Earth geometry
  final double _earthRadius = 1.0;
  final int _segments = 128; // Much higher for smooth sphere
  List<vm.Vector3> _earthVertices = [];
  List<vm.Vector3> _normalVectors = [];
  List<List<int>> _earthFaces = [];
  List<Color> _vertexColors = [];
  List<vm.Vector2> _textureCoords = [];
  
  // Cloud layer
  final double _cloudRadius = 1.02;
  List<vm.Vector3> _cloudVertices = [];
  List<List<int>> _cloudFaces = [];
  List<Color> _cloudColors = [];
  
  // Atmosphere
  final double _atmosphereRadius = 1.15;
  List<vm.Vector3> _atmosphereVertices = [];
  List<List<int>> _atmosphereFaces = [];
  
  // Lighting
  late vm.Vector3 _lightDirection;
  
  // Camera
  double _cameraDistance = 3.0;
  double _cameraLatitude = 0.0;
  double _cameraLongitude = 0.0;
  
  // Interaction
  bool _isDragging = false;
  Offset _lastPanPosition = Offset.zero;
  
  @override
  void initState() {
    super.initState();
    // Initialize light direction
    final light = vm.Vector3(1.0, 0.5, 0.3);
    light.normalize();
    _lightDirection = light;
    
    _initializeAnimations();
    _initGeometry();
    _fetchISSData();
    _startISSTimer();
  }
  
  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
    
    _cloudController = AnimationController(
      duration: const Duration(seconds: 120),
      vsync: this,
    )..repeat();
    
    _issController = AnimationController(
      duration: const Duration(seconds: 90),
      vsync: this,
    )..repeat();
  }
  
  void _initGeometry() {
    _initEarthGeometry();
    _initCloudGeometry();
    _initAtmosphereGeometry();
  }
  
  void _initEarthGeometry() {
    _earthVertices.clear();
    _normalVectors.clear();
    _earthFaces.clear();
    _vertexColors.clear();
    _textureCoords.clear();
    
    // Generate high-resolution sphere vertices
    for (int lat = 0; lat <= _segments; lat++) {
      final theta = lat * math.pi / _segments;
      final sinTheta = math.sin(theta);
      final cosTheta = math.cos(theta);
      
      for (int lon = 0; lon <= _segments; lon++) {
        final phi = lon * 2 * math.pi / _segments;
        final sinPhi = math.sin(phi);
        final cosPhi = math.cos(phi);
        
        final x = _earthRadius * cosPhi * sinTheta;
        final y = _earthRadius * cosTheta;
        final z = _earthRadius * sinPhi * sinTheta;
        
        _earthVertices.add(vm.Vector3(x, y, z));
        final normal = vm.Vector3(x, y, z);
        normal.normalize();
        _normalVectors.add(normal);
        
        // Texture coordinates
        _textureCoords.add(vm.Vector2(
          lon / _segments,
          lat / _segments,
        ));
        
        // Generate realistic colors based on position
        _vertexColors.add(_getRealisticEarthColor(theta, phi));
      }
    }
    
    // Generate faces
    for (int lat = 0; lat < _segments; lat++) {
      for (int lon = 0; lon < _segments; lon++) {
        final first = lat * (_segments + 1) + lon;
        final second = first + _segments + 1;
        
        _earthFaces.add([first, second, first + 1]);
        _earthFaces.add([second, second + 1, first + 1]);
      }
    }
  }
  
  void _initCloudGeometry() {
    _cloudVertices.clear();
    _cloudFaces.clear();
    _cloudColors.clear();
    
    for (int lat = 0; lat <= _segments; lat++) {
      final theta = lat * math.pi / _segments;
      final sinTheta = math.sin(theta);
      final cosTheta = math.cos(theta);
      
      for (int lon = 0; lon <= _segments; lon++) {
        final phi = lon * 2 * math.pi / _segments;
        final sinPhi = math.sin(phi);
        final cosPhi = math.cos(phi);
        
        final x = _cloudRadius * cosPhi * sinTheta;
        final y = _cloudRadius * cosTheta;
        final z = _cloudRadius * sinPhi * sinTheta;
        
        _cloudVertices.add(vm.Vector3(x, y, z));
        
        // Cloud density based on position
        final cloudDensity = _getCloudDensity(theta, phi);
        _cloudColors.add(Colors.white.withOpacity(cloudDensity * 0.6));
      }
    }
    
    // Generate cloud faces
    for (int lat = 0; lat < _segments; lat++) {
      for (int lon = 0; lon < _segments; lon++) {
        final first = lat * (_segments + 1) + lon;
        final second = first + _segments + 1;
        
        _cloudFaces.add([first, second, first + 1]);
        _cloudFaces.add([second, second + 1, first + 1]);
      }
    }
  }
  
  void _initAtmosphereGeometry() {
    _atmosphereVertices.clear();
    _atmosphereFaces.clear();
    
    for (int lat = 0; lat <= _segments; lat++) {
      final theta = lat * math.pi / _segments;
      final sinTheta = math.sin(theta);
      final cosTheta = math.cos(theta);
      
      for (int lon = 0; lon <= _segments; lon++) {
        final phi = lon * 2 * math.pi / _segments;
        final sinPhi = math.sin(phi);
        final cosPhi = math.cos(phi);
        
        final x = _atmosphereRadius * cosPhi * sinTheta;
        final y = _atmosphereRadius * cosTheta;
        final z = _atmosphereRadius * sinPhi * sinTheta;
        
        _atmosphereVertices.add(vm.Vector3(x, y, z));
      }
    }
    
    // Generate atmosphere faces
    for (int lat = 0; lat < _segments; lat++) {
      for (int lon = 0; lon < _segments; lon++) {
        final first = lat * (_segments + 1) + lon;
        final second = first + _segments + 1;
        
        _atmosphereFaces.add([first, second, first + 1]);
        _atmosphereFaces.add([second, second + 1, first + 1]);
      }
    }
  }
  
  Color _getRealisticEarthColor(double theta, double phi) {
    // Convert to latitude/longitude
    final lat = (theta - math.pi / 2) * 180 / math.pi;
    final lon = phi * 180 / math.pi;
    
    // Land vs Ocean
    if (_isLand(lat, lon)) {
      // Land colors - various shades of green and brown
      if (lat > 60 || lat < -60) {
        // Polar regions - white/light blue
        return const Color(0xFFE6F3FF);
      } else if (lat > 30 || lat < -30) {
        // Temperate regions - green
        return const Color(0xFF4CAF50);
      } else {
        // Tropical regions - darker green
        return const Color(0xFF2E7D32);
      }
    } else {
      // Ocean colors - various shades of blue
      if (lat > 60 || lat < -60) {
        // Polar oceans - darker blue
        return const Color(0xFF1565C0);
      } else if (lat > 30 || lat < -30) {
        // Temperate oceans - medium blue
        return const Color(0xFF1976D2);
      } else {
        // Tropical oceans - lighter blue
        return const Color(0xFF2196F3);
      }
    }
  }
  
  bool _isLand(double lat, double lon) {
    // Simplified land detection based on major landmasses
    // This is a basic approximation - in reality you'd use proper geographic data
    
    // North America
    if (lat > 15 && lat < 70 && lon > -170 && lon < -50) return true;
    
    // South America
    if (lat > -60 && lat < 15 && lon > -85 && lon < -30) return true;
    
    // Europe
    if (lat > 35 && lat < 70 && lon > -25 && lon < 40) return true;
    
    // Africa
    if (lat > -35 && lat < 35 && lon > -20 && lon < 55) return true;
    
    // Asia
    if (lat > 5 && lat < 70 && lon > 40 && lon < 180) return true;
    
    // Australia
    if (lat > -45 && lat < -10 && lon > 110 && lon < 155) return true;
    
    // Antarctica
    if (lat < -60) return true;
    
    return false;
  }
  
  double _getCloudDensity(double theta, double phi) {
    // Generate realistic cloud patterns
    final lat = (theta - math.pi / 2) * 180 / math.pi;
    final lon = phi * 180 / math.pi;
    
    // More clouds in tropical regions
    if (lat.abs() < 30) {
      return 0.3 + 0.4 * math.sin(phi * 3) * math.cos(theta * 2);
    } else if (lat.abs() < 60) {
      return 0.2 + 0.3 * math.sin(phi * 2) * math.cos(theta * 1.5);
    } else {
      return 0.1 + 0.2 * math.sin(phi * 1.5) * math.cos(theta);
    }
  }
  
  void _fetchISSData() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.wheretheiss.at/v1/satellites/25544'),
      );
      
      if (response.statusCode == 200) {
        setState(() {
          _issData = json.decode(response.body);
        });
        DebugUtils.log('ISS data updated: ${_issData?['latitude']}, ${_issData?['longitude']}');
      }
    } catch (e) {
      DebugUtils.logError('Failed to fetch ISS data: $e');
    }
  }
  
  void _startISSTimer() {
    _issUpdateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchISSData();
    });
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _cloudController.dispose();
    _issController.dispose();
    _issUpdateTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onPanStart: (details) {
          _isDragging = true;
          _lastPanPosition = details.globalPosition;
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            final delta = details.globalPosition - _lastPanPosition;
            setState(() {
              _cameraLongitude += delta.dx * 0.01;
              _cameraLatitude += delta.dy * 0.01;
              _cameraLatitude = _cameraLatitude.clamp(-math.pi / 2, math.pi / 2);
            });
            _lastPanPosition = details.globalPosition;
          }
        },
        onPanEnd: (_) {
          _isDragging = false;
        },
        child: Stack(
          children: [
            // 3D Earth
            AnimatedBuilder(
              animation: Listenable.merge([
                _rotationController,
                _cloudController,
                _issController,
              ]),
              builder: (context, child) {
                return CustomPaint(
                  painter: GoogleEarthPainter(
                    earthVertices: _earthVertices,
                    earthFaces: _earthFaces,
                    earthColors: _vertexColors,
                    normalVectors: _normalVectors,
                    cloudVertices: _cloudVertices,
                    cloudFaces: _cloudFaces,
                    cloudColors: _cloudColors,
                    atmosphereVertices: _atmosphereVertices,
                    atmosphereFaces: _atmosphereFaces,
                    lightDirection: _lightDirection,
                    earthRotation: _rotationController.value * 2 * math.pi,
                    cloudRotation: _cloudController.value * 2 * math.pi,
                    cameraDistance: _cameraDistance,
                    cameraLatitude: _cameraLatitude,
                    cameraLongitude: _cameraLongitude,
                    issData: _issData,
                    issRotation: _issController.value * 2 * math.pi,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            
            // UI Overlay
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Google Earth Quality 3D Viewer',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_issData != null) ...[
                    Text(
                      'ISS Position: ${_issData!['latitude']?.toStringAsFixed(2)}°N, ${_issData!['longitude']?.toStringAsFixed(2)}°E',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Altitude: ${_issData!['altitude']?.toStringAsFixed(0)} km',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Controls
            Positioned(
              bottom: 50,
              right: 20,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _cameraDistance = (_cameraDistance - 0.5).clamp(1.5, 5.0);
                      });
                    },
                    backgroundColor: AppColors.neonCyan,
                    child: const Icon(Icons.zoom_in),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _cameraDistance = (_cameraDistance + 0.5).clamp(1.5, 5.0);
                      });
                    },
                    backgroundColor: AppColors.neonCyan,
                    child: const Icon(Icons.zoom_out),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleEarthPainter extends CustomPainter {
  final List<vm.Vector3> earthVertices;
  final List<List<int>> earthFaces;
  final List<Color> earthColors;
  final List<vm.Vector3> normalVectors;
  final List<vm.Vector3> cloudVertices;
  final List<List<int>> cloudFaces;
  final List<Color> cloudColors;
  final List<vm.Vector3> atmosphereVertices;
  final List<List<int>> atmosphereFaces;
  final vm.Vector3 lightDirection;
  final double earthRotation;
  final double cloudRotation;
  final double cameraDistance;
  final double cameraLatitude;
  final double cameraLongitude;
  final Map<String, dynamic>? issData;
  final double issRotation;
  
  GoogleEarthPainter({
    required this.earthVertices,
    required this.earthFaces,
    required this.earthColors,
    required this.normalVectors,
    required this.cloudVertices,
    required this.cloudFaces,
    required this.cloudColors,
    required this.atmosphereVertices,
    required this.atmosphereFaces,
    required this.lightDirection,
    required this.earthRotation,
    required this.cloudRotation,
    required this.cameraDistance,
    required this.cameraLatitude,
    required this.cameraLongitude,
    required this.issData,
    required this.issRotation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.3;
    
    // Clear background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );
    
    // Draw stars
    _drawStars(canvas, size);
    
    // Calculate camera position
    final cameraX = cameraDistance * math.cos(cameraLatitude) * math.cos(cameraLongitude);
    final cameraY = cameraDistance * math.sin(cameraLatitude);
    final cameraZ = cameraDistance * math.cos(cameraLatitude) * math.sin(cameraLongitude);
    final cameraPos = vm.Vector3(cameraX, cameraY, cameraZ);
    
    // Draw atmosphere
    _drawAtmosphere(canvas, center, radius, cameraPos);
    
    // Draw Earth
    _drawEarth(canvas, center, radius, cameraPos);
    
    // Draw clouds
    _drawClouds(canvas, center, radius, cameraPos);
    
    // Draw ISS
    if (issData != null) {
      _drawISS(canvas, center, radius, cameraPos);
    }
  }
  
  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = math.Random(42);
    
    for (int i = 0; i < 5000; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final brightness = random.nextDouble();
      final starSize = 0.5 + random.nextDouble() * 2;
      
      paint.color = Colors.white.withOpacity(brightness);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }
  
  void _drawAtmosphere(Canvas canvas, Offset center, double radius, vm.Vector3 cameraPos) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.blue.withOpacity(0.1),
          Colors.blue.withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2));
    
    canvas.drawCircle(center, radius * 1.2, paint);
  }
  
  void _drawEarth(Canvas canvas, Offset center, double radius, vm.Vector3 cameraPos) {
    // Create high-quality Earth using multiple layers
    final earthGradient = RadialGradient(
      colors: [
        const Color(0xFF4FC3F7),
        const Color(0xFF1976D2),
        const Color(0xFF0D47A1),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    final paint = Paint()
      ..shader = earthGradient.createShader(Rect.fromCircle(center: center, radius: radius));
    
    // Draw base Earth sphere
    canvas.drawCircle(center, radius, paint);
    
    // Draw landmasses with high detail
    _drawLandmasses(canvas, center, radius, cameraPos);
  }
  
  void _drawLandmasses(Canvas canvas, Offset center, double radius, vm.Vector3 cameraPos) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw major continents with realistic shapes
    _drawContinent(canvas, center, radius, 0.0, 0.0, 0.3, 0.4, const Color(0xFF4CAF50)); // Africa
    _drawContinent(canvas, center, radius, 0.2, 0.1, 0.25, 0.35, const Color(0xFF2E7D32)); // Europe
    _drawContinent(canvas, center, radius, -0.3, 0.2, 0.4, 0.3, const Color(0xFF4CAF50)); // North America
    _drawContinent(canvas, center, radius, -0.1, -0.3, 0.2, 0.25, const Color(0xFF2E7D32)); // South America
    _drawContinent(canvas, center, radius, 0.4, 0.0, 0.35, 0.3, const Color(0xFF4CAF50)); // Asia
    _drawContinent(canvas, center, radius, 0.2, -0.4, 0.15, 0.2, const Color(0xFF2E7D32)); // Australia
  }
  
  void _drawContinent(Canvas canvas, Offset center, double radius, double x, double y, double width, double height, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final continentRect = Rect.fromCenter(
      center: Offset(center.dx + x * radius, center.dy + y * radius),
      width: width * radius * 2,
      height: height * radius * 2,
    );
    
    // Draw continent with irregular shape
    Path path = Path();
    path.addOval(continentRect);
    
    // Add some irregularity to make it look more realistic
    final points = <Offset>[];
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final distance = 0.8 + 0.4 * math.sin(angle * 3);
      final pointX = center.dx + x * radius + math.cos(angle) * width * radius * distance;
      final pointY = center.dy + y * radius + math.sin(angle) * height * radius * distance;
      points.add(Offset(pointX, pointY));
    }
    
    if (points.length >= 3) {
      path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();
    }
    
    canvas.drawPath(path, paint);
  }
  
  void _drawClouds(Canvas canvas, Offset center, double radius, vm.Vector3 cameraPos) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    // Draw cloud layer
    for (int i = 0; i < 20; i++) {
      final angle = (i * math.pi * 2 / 20) + cloudRotation;
      final cloudX = center.dx + math.cos(angle) * radius * 1.02;
      final cloudY = center.dy + math.sin(angle) * radius * 1.02;
      final cloudSize = 20 + (i % 3) * 10;
      
      canvas.drawCircle(
        Offset(cloudX, cloudY),
        cloudSize.toDouble(),
        paint,
      );
    }
  }
  
  void _drawISS(Canvas canvas, Offset center, double radius, vm.Vector3 cameraPos) {
    if (issData == null) return;
    
    final lat = issData!['latitude'] as double? ?? 0.0;
    final lon = issData!['longitude'] as double? ?? 0.0;
    
    // Convert lat/lon to 3D position
    final latRad = lat * math.pi / 180;
    final lonRad = lon * math.pi / 180;
    
    final issX = center.dx + math.cos(latRad) * math.cos(lonRad) * radius * 1.1;
    final issY = center.dy + math.sin(latRad) * radius * 1.1;
    
    // Draw ISS
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(issX, issY), 4, paint);
    
    // Draw ISS trail
    final trailPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(issX, issY),
      Offset(issX + 20, issY + 10),
      trailPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
