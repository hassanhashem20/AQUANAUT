import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';

class Earth3DViewer extends StatefulWidget {
  @override
  _Earth3DViewerState createState() => _Earth3DViewerState();
}

class _Earth3DViewerState extends State<Earth3DViewer>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _issController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _issAnimation;
  
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
      duration: Duration(seconds: 20),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);
    
    // ISS movement animation
    _issController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    );
    _issAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _issController,
      curve: Curves.easeInOut,
    ));
    
    _rotationController.repeat();
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
        title: Text('Live ISS Tracking'),
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
          // 3D Earth Background
          _buildEarth3D(),
          
          // ISS Information Panel
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildInfoPanel(),
          ),
          
          // ISS Position Indicator
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: _buildISSPositionIndicator(),
          ),
          
          // Controls
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildEarth3D() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            AppColors.deepSpace,
            AppColors.darkSpace,
            AppColors.midSpace,
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: Earth3DPainter(
              rotation: _rotationAnimation.value,
              issLatitude: _issLatitude,
              issLongitude: _issLongitude,
              issAnimation: _issAnimation.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: EdgeInsets.all(16),
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

  Widget _buildISSPositionIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
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
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            if (_rotationController.isAnimating) {
              _rotationController.stop();
            } else {
              _rotationController.repeat();
            }
          },
          icon: Icon(_rotationController.isAnimating ? Icons.pause : Icons.play_arrow),
          label: Text(_rotationController.isAnimating ? 'Pause' : 'Play'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.spaceBlue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _fetchISSData,
          icon: Icon(Icons.refresh),
          label: Text('Update'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonCyan,
            foregroundColor: Colors.black,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
          label: Text('Close'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.errorRed,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class Earth3DPainter extends CustomPainter {
  final double rotation;
  final double issLatitude;
  final double issLongitude;
  final double issAnimation;

  Earth3DPainter({
    required this.rotation,
    required this.issLatitude,
    required this.issLongitude,
    required this.issAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.3;

    // Draw Earth
    _drawEarth(canvas, center, radius);
    
    // Draw ISS
    _drawISS(canvas, center, radius);
    
    // Draw orbit path
    _drawOrbitPath(canvas, center, radius);
  }

  void _drawEarth(Canvas canvas, Offset center, double radius) {
    final earthPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color(0xFF4A90E2), // Ocean blue
          Color(0xFF2E7D32), // Land green
          Color(0xFF8D6E63), // Mountain brown
        ],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, earthPaint);
    
    // Draw continents (simplified)
    _drawContinents(canvas, center, radius);
  }

  void _drawContinents(Canvas canvas, Offset center, double radius) {
    final continentPaint = Paint()
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
      center: Offset(center.dx + radius * 0.4, center.dy - radius * 0.1),
      width: radius * 0.4,
      height: radius * 0.3,
    ));
    
    canvas.drawPath(path, continentPaint);
  }

  void _drawISS(Canvas canvas, Offset center, double radius) {
    // Convert ISS coordinates to screen position
    final issX = center.dx + (issLongitude / 180) * radius * 0.8;
    final issY = center.dy - (issLatitude / 90) * radius * 0.8;
    
    // Draw ISS with animation
    final issPaint = Paint()
      ..color = AppColors.neonCyan
      ..style = PaintingStyle.fill;

    final issSize = 8.0 + (issAnimation * 4);
    canvas.drawCircle(Offset(issX, issY), issSize, issPaint);
    
    // Draw ISS glow
    final glowPaint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(issX, issY), issSize * 2, glowPaint);
  }

  void _drawOrbitPath(Canvas canvas, Offset center, double radius) {
    final orbitPaint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius * 1.2, orbitPaint);
  }

  @override
  bool shouldRepaint(Earth3DPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
           oldDelegate.issLatitude != issLatitude ||
           oldDelegate.issLongitude != issLongitude ||
           oldDelegate.issAnimation != issAnimation;
  }
}
