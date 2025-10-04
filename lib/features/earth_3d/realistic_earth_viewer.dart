import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';

class RealisticEarthViewer extends StatefulWidget {
  @override
  _RealisticEarthViewerState createState() => _RealisticEarthViewerState();
}

class _RealisticEarthViewerState extends State<RealisticEarthViewer>
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
  late WebViewController _webViewController;

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

    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _updateISSPosition();
          },
        ),
      );
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
          
          // Update 3D model
          _updateISSPosition();
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

  void _updateISSPosition() {
    if (_webViewController != null) {
      final script = '''
        if (window.updateISSPosition) {
          window.updateISSPosition($_issLatitude, $_issLongitude, $_issAltitude);
        }
      ''';
      _webViewController.runJavaScript(script);
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

  String _getEarth3DHTML() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Realistic Earth 3D</title>
    <style>
        body { margin: 0; padding: 0; background: #000; overflow: hidden; }
        #container { width: 100vw; height: 100vh; }
        #loading { 
            position: absolute; 
            top: 50%; 
            left: 50%; 
            transform: translate(-50%, -50%); 
            color: #00FFF5; 
            font-family: Arial, sans-serif;
            z-index: 1000;
        }
    </style>
</head>
<body>
    <div id="loading">Loading Earth...</div>
    <div id="container"></div>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"></script>
    
    <script>
        let scene, camera, renderer, earth, iss, controls;
        let earthTexture, cloudsTexture, nightTexture;
        let issPosition = { lat: 0, lng: 0, alt: 420 };
        
        function init() {
            // Scene setup
            scene = new THREE.Scene();
            camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
            renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.shadowMap.enabled = true;
            renderer.shadowMap.type = THREE.PCFSoftShadowMap;
            document.getElementById('container').appendChild(renderer.domElement);
            
            // Controls
            controls = new THREE.OrbitControls(camera, renderer.domElement);
            controls.enableDamping = true;
            controls.dampingFactor = 0.05;
            controls.enableZoom = true;
            controls.enablePan = false;
            controls.minDistance = 2;
            controls.maxDistance = 10;
            
            // Lighting
            const ambientLight = new THREE.AmbientLight(0x404040, 0.3);
            scene.add(ambientLight);
            
            const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
            directionalLight.position.set(5, 3, 5);
            directionalLight.castShadow = true;
            scene.add(directionalLight);
            
            // Create Earth
            createEarth();
            
            // Create ISS
            createISS();
            
            // Stars background
            createStars();
            
            // Start animation
            animate();
            
            // Hide loading
            document.getElementById('loading').style.display = 'none';
        }
        
        function createEarth() {
            const geometry = new THREE.SphereGeometry(2, 64, 64);
            
            // Load textures
            const loader = new THREE.TextureLoader();
            
            // Earth day texture
            earthTexture = loader.load('https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/planets/earth_atmos_2048.jpg');
            
            // Earth night texture
            nightTexture = loader.load('https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/planets/earth_lights_2048.jpg');
            
            // Clouds texture
            cloudsTexture = loader.load('https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/planets/earth_clouds_1024.jpg');
            
            // Earth material with day/night cycle
            const earthMaterial = new THREE.MeshPhongMaterial({
                map: earthTexture,
                normalMap: loader.load('https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/planets/earth_normal_2048.jpg'),
                specularMap: loader.load('https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/planets/earth_specular_2048.jpg'),
                shininess: 1000
            });
            
            earth = new THREE.Mesh(geometry, earthMaterial);
            earth.castShadow = true;
            earth.receiveShadow = true;
            scene.add(earth);
            
            // Clouds layer
            const cloudsGeometry = new THREE.SphereGeometry(2.01, 32, 32);
            const cloudsMaterial = new THREE.MeshPhongMaterial({
                map: cloudsTexture,
                transparent: true,
                opacity: 0.3
            });
            const clouds = new THREE.Mesh(cloudsGeometry, cloudsMaterial);
            scene.add(clouds);
            
            // Atmosphere
            const atmosphereGeometry = new THREE.SphereGeometry(2.1, 32, 32);
            const atmosphereMaterial = new THREE.MeshPhongMaterial({
                color: 0x4A90E2,
                transparent: true,
                opacity: 0.1
            });
            const atmosphere = new THREE.Mesh(atmosphereGeometry, atmosphereMaterial);
            scene.add(atmosphere);
        }
        
        function createISS() {
            const issGeometry = new THREE.BoxGeometry(0.1, 0.1, 0.2);
            const issMaterial = new THREE.MeshPhongMaterial({ color: 0x00FFF5 });
            iss = new THREE.Mesh(issGeometry, issMaterial);
            iss.position.set(0, 0, 2.5);
            scene.add(iss);
        }
        
        function createStars() {
            const starsGeometry = new THREE.BufferGeometry();
            const starsMaterial = new THREE.PointsMaterial({ color: 0xffffff, size: 0.5 });
            
            const starsVertices = [];
            for (let i = 0; i < 10000; i++) {
                const x = (Math.random() - 0.5) * 2000;
                const y = (Math.random() - 0.5) * 2000;
                const z = (Math.random() - 0.5) * 2000;
                starsVertices.push(x, y, z);
            }
            
            starsGeometry.setAttribute('position', new THREE.Float32BufferAttribute(starsVertices, 3));
            const stars = new THREE.Points(starsGeometry, starsMaterial);
            scene.add(stars);
        }
        
        function updateISSPosition(lat, lng, alt) {
            issPosition = { lat: lat, lng: lng, alt: alt };
            
            // Convert lat/lng to 3D position
            const phi = (90 - lat) * (Math.PI / 180);
            const theta = (lng + 180) * (Math.PI / 180);
            const radius = 2 + (alt / 1000) * 0.1; // Scale altitude
            
            iss.position.x = radius * Math.sin(phi) * Math.cos(theta);
            iss.position.y = radius * Math.cos(phi);
            iss.position.z = radius * Math.sin(phi) * Math.sin(theta);
        }
        
        function animate() {
            requestAnimationFrame(animate);
            
            // Rotate Earth
            if (earth) {
                earth.rotation.y += 0.005;
            }
            
            // Update controls
            controls.update();
            
            // Render
            renderer.render(scene, camera);
        }
        
        // Handle window resize
        window.addEventListener('resize', () => {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
        });
        
        // Initialize when page loads
        window.addEventListener('load', init);
        
        // Make updateISSPosition globally available
        window.updateISSPosition = updateISSPosition;
    </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        title: Text('Live ISS Tracking - Realistic Earth'),
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
          // 3D Earth WebView
          Container(
            width: double.infinity,
            height: double.infinity,
            child: WebViewWidget(
              controller: _webViewController
                ..loadHtmlString(_getEarth3DHTML()),
            ),
          ),
          
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
                      'Loading Realistic Earth...',
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

