import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/core/debug/debug_utils.dart';

class ThreeJSEarthViewer extends StatefulWidget {
  @override
  _ThreeJSEarthViewerState createState() => _ThreeJSEarthViewerState();
}

class _ThreeJSEarthViewerState extends State<ThreeJSEarthViewer>
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
  late WebViewController _webViewController;

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

    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            DebugUtils.log('WebView loading progress: $progress%');
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
            DebugUtils.log('WebView loaded successfully');
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
      DebugUtils.log('Fetching ISS data...');
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
        DebugUtils.log('ISS data updated successfully');
      }
    } catch (e) {
      DebugUtils.logError('Error fetching ISS data', error: e);
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
      DebugUtils.logError('Error fetching location', error: e);
    }
  }

  String _getEarth3DHTML() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <title>3D Earth with Live ISS</title>
  <style>
    body { 
      margin: 0; 
      background: #000;
      overflow: hidden;
      font-family: Arial, sans-serif;
    }
    #loading {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      color: #00FFF5;
      z-index: 1000;
    }
    #info {
      position: absolute;
      top: 10px;
      left: 10px;
      color: white;
      background: rgba(0, 0, 0, 0.7);
      padding: 10px;
      border-radius: 5px;
      font-size: 12px;
    }
  </style>
</head>
<body>
  <div id="loading">Loading 3D Earth...</div>
  <div id="info">
    <div>ISS Position: <span id="issPos">Loading...</span></div>
    <div>Altitude: <span id="issAlt">Loading...</span> km</div>
    <div>Velocity: <span id="issVel">Loading...</span> km/h</div>
  </div>
  
  <script src="https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/three@0.160.0/examples/js/controls/OrbitControls.js"></script>

  <script>
    // Scene, Camera, Renderer
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth/window.innerHeight, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    document.body.appendChild(renderer.domElement);

    // Lighting
    const ambientLight = new THREE.AmbientLight(0x404040, 0.3);
    scene.add(ambientLight);
    
    const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
    directionalLight.position.set(5, 3, 5);
    directionalLight.castShadow = true;
    scene.add(directionalLight);

    // Earth Sphere with realistic texture
    const geometry = new THREE.SphereGeometry(1, 64, 64);
    const texture = new THREE.TextureLoader().load('https://upload.wikimedia.org/wikipedia/commons/9/97/The_Earth_seen_from_Apollo_17.jpg');
    const material = new THREE.MeshPhongMaterial({ 
      map: texture,
      shininess: 1000
    });
    const earth = new THREE.Mesh(geometry, material);
    earth.castShadow = true;
    earth.receiveShadow = true;
    scene.add(earth);

    // ISS (International Space Station)
    const issGeometry = new THREE.BoxGeometry(0.05, 0.05, 0.1);
    const issMaterial = new THREE.MeshPhongMaterial({ color: 0x00FFF5 });
    const iss = new THREE.Mesh(issGeometry, issMaterial);
    iss.position.set(0, 0, 1.2);
    scene.add(iss);

    // ISS Orbit Ring
    const orbitGeometry = new THREE.RingGeometry(1.2, 1.21, 32);
    const orbitMaterial = new THREE.MeshBasicMaterial({ 
      color: 0x00FFF5, 
      transparent: true, 
      opacity: 0.3,
      side: THREE.DoubleSide
    });
    const orbit = new THREE.Mesh(orbitGeometry, orbitMaterial);
    orbit.rotation.x = Math.PI / 2;
    scene.add(orbit);

    // Stars background
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

    // Controls
    const controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.enableZoom = true;
    controls.enablePan = false;
    controls.minDistance = 1.5;
    controls.maxDistance = 5;

    // Camera position
    camera.position.z = 3;

    // ISS position variables
    let issLatitude = 0;
    let issLongitude = 0;
    let issAltitude = 420;

    // Function to update ISS position
    function updateISSPosition(lat, lng, alt) {
      issLatitude = lat;
      issLongitude = lng;
      issAltitude = alt;
      
      // Convert lat/lng to 3D position
      const phi = (90 - lat) * (Math.PI / 180);
      const theta = (lng + 180) * (Math.PI / 180);
      const radius = 1.2 + (alt / 1000) * 0.1; // Scale altitude
      
      iss.position.x = radius * Math.sin(phi) * Math.cos(theta);
      iss.position.y = radius * Math.cos(phi);
      iss.position.z = radius * Math.sin(phi) * Math.sin(theta);
      
      // Update info display
      document.getElementById('issPos').textContent = lat.toFixed(4) + '°, ' + lng.toFixed(4) + '°';
      document.getElementById('issAlt').textContent = alt.toFixed(1);
      document.getElementById('issVel').textContent = '27600'; // Approximate orbital velocity
    }

    // Make updateISSPosition globally available
    window.updateISSPosition = updateISSPosition;

    // Animate
    function animate() {
      requestAnimationFrame(animate);
      
      // Rotate Earth slowly
      earth.rotation.y += 0.001;
      
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

    // Start animation
    animate();
    
    // Hide loading
    document.getElementById('loading').style.display = 'none';
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
        title: Text('Live ISS 3D Tracker'),
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
                      'Loading 3D Earth...',
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
