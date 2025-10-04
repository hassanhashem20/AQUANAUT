import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuoyancyWorksheetScreen extends StatefulWidget {
  @override
  _BuoyancyWorksheetScreenState createState() =>
      _BuoyancyWorksheetScreenState();
}

class _BuoyancyWorksheetScreenState extends State<BuoyancyWorksheetScreen> {
  Map<String, dynamic>? _issData;
  Map<String, dynamic>? _astronautData;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isDisposed = false; // Add disposal flag

  @override
  void initState() {
    super.initState();
    _fetchNASAData();
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed when widget is removed
    super.dispose();
  }

  // Safe state update method
  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _fetchNASAData() async {
    _safeSetState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch ISS current position
      final issResponse = await http.get(
        Uri.parse('https://api.wheretheiss.at/v1/satellites/25544'),
      );

      // Fetch current astronauts in space
      final astronautResponse = await http.get(
        Uri.parse('http://api.open-notify.org/astros.json'),
      );

      // Check if widget is still mounted before updating state
      if (!mounted) return;

      if (issResponse.statusCode == 200 &&
          astronautResponse.statusCode == 200) {
        _safeSetState(() {
          _issData = json.decode(issResponse.body);
          _astronautData = json.decode(astronautResponse.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load NASA data: ${issResponse.statusCode}');
      }
    } catch (e) {
      // Check if widget is still mounted before updating state
      if (!mounted) return;

      _safeSetState(() {
        _errorMessage = 'Failed to load live data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _getCurrentAstronautName() {
    if (_astronautData != null && _astronautData!['people'] != null) {
      final people = _astronautData!['people'] as List;
      if (people.isNotEmpty) {
        // Find astronauts on ISS
        final issAstronauts =
            people.where((person) => person['craft'] == 'ISS').toList();
        if (issAstronauts.isNotEmpty) {
          return issAstronauts.first['name'];
        }
        return people.first['name'];
      }
    }
    return 'Christina Koch'; // Fallback name
  }

  int _getAstronautCount() {
    return _astronautData?['number'] ?? 7; // Fallback count
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // NASA Header with Live Data Indicator
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.rocket_launch,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'LIVE NASA DATA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (_isLoading)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Loading...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (_errorMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Offline',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 8),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Main Content Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Title Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue[800],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 80,
                                width: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: Center(
                                  child: Text(
                                    'NASA',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'The Math of Buoyancy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Student Worksheet: Buoyancy Calculations',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Using Real NASA Data - Updated Live from Space',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Content Area
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Live Mission Context Card
                          if (!_isLoading && _errorMessage.isEmpty)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.purple[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.purple[200]!),
                              ),
                              padding: EdgeInsets.all(16),
                              margin: EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.purple,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.track_changes,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "Current Mission Context",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.purple[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  _buildLiveDataRow(
                                    icon: Icons.people,
                                    label: 'Astronauts in Space',
                                    value: '${_getAstronautCount()} people',
                                  ),
                                  SizedBox(height: 8),
                                  _buildLiveDataRow(
                                    icon: Icons.speed,
                                    label: 'ISS Current Velocity',
                                    value:
                                        '${_issData?['velocity']?.toStringAsFixed(2) ?? '27,600'} km/h',
                                  ),
                                  SizedBox(height: 8),
                                  _buildLiveDataRow(
                                    icon: Icons.height,
                                    label: 'ISS Altitude',
                                    value:
                                        '${_issData?['altitude']?.toStringAsFixed(1) ?? '408'} km',
                                  ),
                                ],
                              ),
                            ),

                          // Archimedes Principle Card
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.science,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Archimedes' Principle",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.deepPurple[800],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "An object submerged in a fluid experiences an upward buoyant force equal to the weight of the fluid displaced by the object.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.orange[300]!,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'FORMULA',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.orange[800],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Buoyant Force = Weight of Displaced Water',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // NASA Data Card with Real Calculations
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.rocket,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Real NASA Mission Data",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.red[800],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),

                                // Data Grid
                                Column(
                                  children: [
                                    _buildDataRow(
                                      icon: Icons.person,
                                      label: 'Astronaut Training Today',
                                      value: _getCurrentAstronautName(),
                                      color: Colors.blue,
                                    ),
                                    SizedBox(height: 12),
                                    _buildDataRow(
                                      icon: Icons.scale,
                                      label: 'EMU Suit Mass (Earth)',
                                      value: '150 kg',
                                      color: Colors.green,
                                    ),
                                    SizedBox(height: 12),
                                    _buildDataRow(
                                      icon: Icons.water_drop,
                                      label: 'NBL Water Density',
                                      value: '1,000 kg/m³',
                                      color: Colors.blue,
                                    ),
                                    SizedBox(height: 12),
                                    _buildDataRow(
                                      icon: Icons.rocket,
                                      label: 'Earth Gravity',
                                      value: '9.8 m/s²',
                                      color: Colors.orange,
                                    ),
                                    SizedBox(height: 12),
                                    _buildDataRow(
                                      icon: Icons.speed,
                                      label: 'Current ISS Speed',
                                      value:
                                          '${_issData?['velocity']?.toStringAsFixed(2) ?? '27,600'} km/h',
                                      color: Colors.purple,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Problem Section with Real Context
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.calculate,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Your Mission - Real NASA Scenario",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Calculate the buoyant force needed for astronaut ${_getCurrentAstronautName()} to achieve neutral buoyancy during NBL training for the upcoming spacewalk. The ISS is currently orbiting at ${_issData?['altitude']?.toStringAsFixed(1) ?? '408'} km altitude.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Given:\n"
                                    "- Astronaut + EMU suit mass: 150 kg\n"
                                    "- Water density: 1000 kg/m³\n"
                                    "- Gravity: 9.8 m/s²\n"
                                    "- Volume of water displaced = Mass of object\n"
                                    "\n"
                                    "Calculate the buoyant force using:\n"
                                    "Buoyant Force = Density × Gravity × Volume",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(12),
                                  child: TextField(
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Show your calculations here...\n\nStep 1: Calculate volume of water displaced\nStep 2: Apply Archimedes principle\nStep 3: Calculate buoyant force',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Refresh Button
                          if (_errorMessage.isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(top: 16),
                              child: ElevatedButton(
                                onPressed: _fetchNASAData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.refresh, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Retry NASA Data Connection',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Footer
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      'Data sourced from NASA Open APIs and Where the ISS At? API',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'NASA Educational Resources | Mission Control: Classroom\nAll materials aligned with NGSS Standards',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveDataRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.purple[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.purple[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow({
    required IconData icon,
    required String label,
    required String value,
    required MaterialColor color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
