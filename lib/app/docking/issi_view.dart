import 'package:flutter/material.dart';
import 'package:nasa2/app/docking/issi_tracking_page.dart';
import 'package:nasa2/app/mission_control/mission_controle_page.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class CupolaExperience extends StatefulWidget {
  const CupolaExperience({super.key});

  @override
  State<CupolaExperience> createState() => _CupolaExperienceState();
}

class _CupolaExperienceState extends State<CupolaExperience> {
  late YoutubePlayerController _ytController;
  Timer? _issDataTimer;
  bool _shouldUpdateISSData = true;

  // Real-time ISS data
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _altitude = 420.0;
  double _velocity = 27600.0;
  String _currentLocation = "Loading...";
  String _currentCountry = "Loading...";
  bool _isLoading = true;
  String _errorMessage = "";

  final double _period = 92.0; // minutes
  final int _crewMin = 3;
  final int _crewMax = 7;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController.fromVideoId(
      videoId: 'fZ4aD6_YJSs',
      autoPlay: true,
      params: YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: false,
        loop: true,
        enableCaption: false,
        playsInline: true,
      ),
    );
    _startISSTracking();
  }

  void _startISSTracking() {
    _shouldUpdateISSData = true;

    // Fetch immediately
    _fetchISSData();

    // Update every 10 seconds
    _issDataTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_shouldUpdateISSData && mounted) {
        _fetchISSData();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchISSData() async {
    try {
      print("Starting fetch ISS data...");

      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      // Fetch ISS position from Where the ISS at API
      final positionResponse = await http
          .get(Uri.parse('https://api.wheretheiss.at/v1/satellites/25544'))
          .timeout(Duration(seconds: 10));

      print(
        "HTTP request completed with status: ${positionResponse.statusCode}",
      );

      if (positionResponse.statusCode == 200) {
        final positionData = json.decode(positionResponse.body);
        print("Response JSON decoded: $positionData");

        if (!mounted) return;
        setState(() {
          _latitude = positionData['latitude']?.toDouble() ?? 0.0;
          _longitude = positionData['longitude']?.toDouble() ?? 0.0;
          _altitude = positionData['altitude']?.toDouble() ?? 420.0;
          _velocity = positionData['velocity']?.toDouble() ?? 27600.0;
          _errorMessage = "";
        });
        print("State updated with ISS positional data.");

        // Get location name based on coordinates
        print("Fetching location name based on coordinates...");
        await _fetchLocationName(_latitude, _longitude);
        print("Location name fetched successfully.");
      } else {
        print(
          "Failed to fetch ISS data. Status Code: ${positionResponse.statusCode}",
        );
        throw Exception('Failed to fetch ISS data');
      }
    } catch (e) {
      print("Exception caught during ISS data fetch: $e");
      if (!mounted) return;
      _safeSetState(() {
        _errorMessage = "Live data unavailable. Showing demo data.";
        _currentLocation = "Pacific Ocean";
        _currentCountry = "International Waters";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLocationName(double lat, double lng) async {
    try {
      print("Starting reverse geocoding for lat: $lat, lng: $lng");

      // Use BigDataCloud API for reverse geocoding
      final response = await http
          .get(
            Uri.parse(
              'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lng&localityLanguage=en',
            ),
          )
          .timeout(Duration(seconds: 5));

      print(
        "HTTP request to BigDataCloud completed with status: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        final locationData = json.decode(response.body);
        print("Response JSON decoded: $locationData");

        if (!mounted) return;
        _safeSetState(() {
          // Extract country name
          _currentCountry =
              locationData['countryName']?.toString() ??
              _extractCountryFromLocalityInfo(locationData) ??
              'International Waters';

          print("Country found: $_currentCountry");

          // Extract location name with priority order
          _currentLocation =
              locationData['city']?.toString() ??
              locationData['locality']?.toString() ??
              locationData['principalSubdivision']?.toString() ??
              _extractLocationFromLocalityInfo(locationData) ??
              _getOceanFromCoordinates(lat, lng);

          print("Location found: $_currentLocation");
          _isLoading = false;
          print("Location state updated");
        });
      } else {
        throw Exception(
          'BigDataCloud API returned status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("Exception caught during reverse geocoding: $e");
      if (!mounted) return;
      _safeSetState(() {
        _currentLocation = _getOceanFromCoordinates(lat, lng);
        _currentCountry = _getRegionFromCoordinates(lat, lng);
        _isLoading = false;
        print("Fallback location set, loading false");
      });
    }
  }

  // Helper method to extract country from localityInfo
  String? _extractCountryFromLocalityInfo(Map<String, dynamic> locationData) {
    try {
      final localityInfo = locationData['localityInfo'];
      if (localityInfo != null) {
        final administrative = localityInfo['administrative'];
        final informative = localityInfo['informative'];

        if (administrative is List) {
          for (var admin in administrative) {
            if (admin is Map) {
              final name = admin['name']?.toString();
              final adminLevel = admin['adminLevel'];
              if (name != null && adminLevel == 2) {
                return name;
              }
            }
          }
        }

        if (informative is List) {
          for (var info in informative) {
            if (info is Map) {
              final name = info['name']?.toString();
              final description = info['description']?.toString();
              if (name != null && description?.contains('country') == true) {
                return name;
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error extracting country from localityInfo: $e");
    }
    return null;
  }

  // Helper method to extract location from localityInfo
  String? _extractLocationFromLocalityInfo(Map<String, dynamic> locationData) {
    try {
      final localityInfo = locationData['localityInfo'];
      if (localityInfo != null) {
        final administrative = localityInfo['administrative'];
        final informative = localityInfo['informative'];

        if (administrative is List && administrative.isNotEmpty) {
          for (var admin in administrative) {
            if (admin is Map) {
              final name = admin['name']?.toString();
              final description = admin['description']?.toString();
              if (name != null && description != 'maritime') {
                return name;
              }
            }
          }
        }

        if (informative is List && informative.isNotEmpty) {
          for (var info in informative) {
            if (info is Map) {
              final name = info['name']?.toString();
              if (name != null) {
                return name;
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error extracting location from localityInfo: $e");
    }
    return null;
  }

  String _getOceanFromCoordinates(double lat, double lng) {
    if (lat > 0 && lng > -30 && lng < 150) return "Pacific Ocean";
    if (lat > 0 && lng > -80 && lng < 40) return "Atlantic Ocean";
    if (lat < 0 && lng > 20 && lng < 150) return "Indian Ocean";
    if (lat > 60) return "Arctic Ocean";
    if (lat < -45) return "Southern Ocean";
    return "Ocean";
  }

  String _getRegionFromCoordinates(double lat, double lng) {
    if (lat > 0 && lng > -10 && lng < 50) return "Africa/Europe";
    if (lat > 0 && lng > 50 && lng < 150) return "Asia";
    if (lat > 0 && lng > -180 && lng < -30) return "North America";
    if (lat < 0 && lng > -80 && lng < -30) return "South America";
    if (lat < 0 && lng > 110 && lng < 180) return "Australia";
    return "International Waters";
  }

  String _getCardinalDirection(double lat, double lng) {
    String latDir = lat >= 0 ? 'N' : 'S';
    String lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(2)}°$latDir, ${lng.abs().toStringAsFixed(2)}°$lngDir';
  }

  // Safe state update helper
  void _safeSetState(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }

  @override
  void dispose() {
    _shouldUpdateISSData = false;
    _issDataTimer?.cancel();
    _ytController.close();
    super.dispose();
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true, forceSafariVC: true);
    }
  }

  Widget statsPanel() {
    return Container(
      width: 310,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.satellite_alt, color: Colors.cyanAccent, size: 20),
              SizedBox(width: 8),
              Text(
                "LIVE ISS POSITION",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (_isLoading) ...[
                SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
          SizedBox(height: 8),
          Text(
            "Currently passing over:",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            '📍 $_currentLocation',
            style: TextStyle(color: Colors.blue[100], fontSize: 15),
          ),
          Text(
            '🏴 $_currentCountry',
            style: TextStyle(color: Colors.blue[100], fontSize: 15),
          ),
          SizedBox(height: 8),
          Text(
            "📡 Coordinates: ${_getCardinalDirection(_latitude, _longitude)}",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Text(
            "📊 Altitude: ${_altitude.toStringAsFixed(1)} km",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Text(
            "🚀 Velocity: ${_velocity.toStringAsFixed(0)} km/h",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            "⏱ Orbital Period: ${_period.toStringAsFixed(0)} minutes",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Text(
            "👨‍🚀 Crew: $_crewMin–$_crewMax astronauts",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          if (_errorMessage.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget achievementPanel() {
    return Container(
      width: 310,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green[800]!.withOpacity(0.90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.yellowAccent, size: 24),
              SizedBox(width: 8),
              Text(
                "Congratulations!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            "You completed all astronaut training:",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 2),
          Text(
            "• NBL Neutral Buoyancy Training\n• Rocket Launch Simulation\n• ISS Docking Procedures\n• Cupola Observatory Experience",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget factsPanel() {
    return Container(
      width: 310,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Educational facts:",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "• ISS orbits Earth every ${_period.toStringAsFixed(0)} minutes\n"
            "• Astronauts see 16 sunrises/sunsets daily\n"
            "• Cupola has 7 windows for Earth observation\n"
            "• Station travels ${(_velocity / 3600).toStringAsFixed(1)} km each second",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget actionButtons() {
    return Row(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IssTrackerWebView()),
              ),
          child: Text(
            "Track ISS Live Position",
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(width: 5),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MissionControlClassroomScreen(),
                ),
              ),
          child: Text("For Educators", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget backgroundVideo() {
    return YoutubePlayerControllerProvider(
      controller: _ytController,
      child: YoutubePlayer(controller: _ytController, aspectRatio: 16 / 9),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            backgroundVideo(),
            SizedBox(height: 20),
            statsPanel(),
            SizedBox(height: 20),
            achievementPanel(),
            SizedBox(height: 20),
            factsPanel(),
            SizedBox(height: 20),
            actionButtons(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
