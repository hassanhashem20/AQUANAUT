import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ISSInfoPanelScreen extends StatefulWidget {
  @override
  _ISSInfoPanelScreenState createState() => _ISSInfoPanelScreenState();
}

class _ISSInfoPanelScreenState extends State<ISSInfoPanelScreen> {
  Map<String, dynamic>? _issData;
  Map<String, dynamic>? _astronautData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchNASAData();
  }

  Future<void> _fetchNASAData() async {
    setState(() {
      _isLoading = true;
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

      if (issResponse.statusCode == 200 &&
          astronautResponse.statusCode == 200) {
        setState(() {
          _issData = json.decode(issResponse.body);
          _astronautData = json.decode(astronautResponse.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load NASA data');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load live data: $e';
        _isLoading = false;
      });
    }
  }

  String _getCurrentAstronautNames() {
    if (_astronautData != null && _astronautData!['people'] != null) {
      final people = _astronautData!['people'] as List;
      final issAstronauts =
          people.where((person) => person['craft'] == 'ISS').take(2).toList();
      if (issAstronauts.isNotEmpty) {
        return issAstronauts.map((a) => a['name']).join(', ');
      }
      return 'ISS Crew';
    }
    return 'NASA Astronauts';
  }

  int _getAstronautCount() {
    return _astronautData?['number'] ?? 7;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header with Live Data Status
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[700]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isLoading
                              ? Icons.refresh
                              : _errorMessage.isNotEmpty
                              ? Icons.error
                              : Icons.rocket_launch,
                          color:
                              _isLoading
                                  ? Colors.orange
                                  : _errorMessage.isNotEmpty
                                  ? Colors.red
                                  : Colors.green,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _isLoading
                              ? 'Loading NASA Data...'
                              : _errorMessage.isNotEmpty
                              ? 'Offline Mode'
                              : 'LIVE NASA DATA',
                          style: TextStyle(
                            color:
                                _isLoading
                                    ? Colors.orange
                                    : _errorMessage.isNotEmpty
                                    ? Colors.red
                                    : Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'NASA Mission Control: Classroom',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Training • Math Worksheet • Live ISS Tracking',
                      style: TextStyle(color: Colors.blue[100], fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Current Mission Status Panel
              if (!_isLoading && _errorMessage.isEmpty)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  padding: EdgeInsets.all(14),
                  margin: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.track_changes,
                            color: Colors.greenAccent,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Current Mission Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[100],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildLiveDataChip(
                            '${_getAstronautCount()} People in Space',
                            Colors.blue,
                            Icons.people,
                          ),
                          _buildLiveDataChip(
                            '${_issData?['velocity']?.toStringAsFixed(0) ?? '27,600'} km/h',
                            Colors.orange,
                            Icons.speed,
                          ),
                          _buildLiveDataChip(
                            '${_issData?['altitude']?.toStringAsFixed(0) ?? '420'} km Altitude',
                            Colors.purple,
                            Icons.height,
                          ),
                          _buildLiveDataChip(
                            '${_getCurrentAstronautNames()}',
                            Colors.red,
                            Icons.person,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Teaching Moments Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[300]!),
                ),
                padding: EdgeInsets.all(14),
                margin: EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.rocket_launch,
                          color: Colors.greenAccent,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Teaching Moments',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[100],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTeachingMomentChip(
                          'Orbital mechanics and velocity',
                          Colors.blue,
                        ),
                        _buildTeachingMomentChip(
                          'International cooperation',
                          Colors.purple,
                        ),
                        _buildTeachingMomentChip(
                          'Life in microgravity',
                          Colors.orange,
                        ),
                        _buildTeachingMomentChip(
                          'Scientific research in space',
                          Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Content - Responsive Row
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Tablet/Desktop layout
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildLinksPanel()),
                        SizedBox(width: 12),
                        Expanded(child: _buildActivitiesPanel()),
                      ],
                    );
                  } else {
                    // Mobile layout - stacked
                    return Column(
                      children: [
                        _buildLinksPanel(),
                        SizedBox(height: 12),
                        _buildActivitiesPanel(),
                      ],
                    );
                  }
                },
              ),

              SizedBox(height: 16),

              // Quick ISS Facts with Live Data
              _buildFactsPanel(),

              SizedBox(height: 16),

              // Refresh Button if error
              if (_errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
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

              SizedBox(height: 16),

              // Footer
              Container(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      'Live data from NASA-compatible APIs: Where the ISS At? & Open Notify',
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

  Widget _buildLiveDataChip(String text, MaterialColor color, IconData icon) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: color[800],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTeachingMomentChip(String text, MaterialColor color) {
    return Chip(
      label: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: color[800],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildLinksPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[300]!),
      ),
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: Colors.cyanAccent, size: 18),
              SizedBox(width: 8),
              Text(
                'Helpful Educational Links',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[100],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Column(
            children: [
              LinkButton(
                text: "Earth photos from ISS",
                color: Colors.blue[300]!,
                onTap: () {},
              ),
              SizedBox(height: 6),
              LinkButton(
                text: "NBL Official Info",
                color: Colors.orange[300]!,
                onTap: () {},
              ),
              SizedBox(height: 6),
              LinkButton(
                text: "Real-time ISS Tracker",
                color: Colors.green[300]!,
                onTap: () {
                  // Could open actual NASA tracker
                },
              ),
              SizedBox(height: 6),
              LinkButton(
                text: "Live ISS Position Map",
                color: Colors.purple[300]!,
                onTap: () {
                  // Could show current position from _issData
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[700]!),
      ),
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Text(
                'Classroom Activity Ideas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow[200],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Column(
            children: [
              ActivityStep(
                label: "Before the Pass:",
                detail:
                    "Calculate ISS speed: ${_issData?['velocity']?.toStringAsFixed(0) ?? '27,600'} km/h",
              ),
              SizedBox(height: 8),
              ActivityStep(
                label: "During the Pass:",
                detail:
                    "Time the crossing - altitude: ${_issData?['altitude']?.toStringAsFixed(0) ?? '420'} km",
              ),
              SizedBox(height: 8),
              ActivityStep(
                label: "After the Pass:",
                detail:
                    "Research experiments with ${_getAstronautCount()} astronauts onboard",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFactsPanel() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.deepPurple[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink[200]!),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.pink[200], size: 18),
              SizedBox(width: 8),
              Text(
                'Quick ISS Facts for Students',
                style: TextStyle(
                  color: Colors.pink[200],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 400) {
                // Two columns for wider screens
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFactsColumn1()),
                    SizedBox(width: 16),
                    Expanded(child: _buildFactsColumn2()),
                  ],
                );
              } else {
                // Single column for narrow screens
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFactsColumn1(),
                    SizedBox(height: 8),
                    _buildFactsColumn2(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFactsColumn1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFactItem(
          'Speed: ${_issData?['velocity']?.toStringAsFixed(0) ?? '27,600'} km/h',
        ),
        _buildFactItem(
          'Altitude: ${_issData?['altitude']?.toStringAsFixed(0) ?? '420'} km above Earth',
        ),
        _buildFactItem('Orbit time: 90 minutes'),
        _buildFactItem('Daily orbits: 15.5 times per day'),
      ],
    );
  }

  Widget _buildFactsColumn2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFactItem('Size: Football field sized'),
        _buildFactItem('Mass: 450,000 kg'),
        _buildFactItem('Crew: ${_getAstronautCount()} people in space'),
        _buildFactItem('Countries: 15 nations involved'),
      ],
    );
  }

  Widget _buildFactItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.white)),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

// Helper link button widget
class LinkButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;
  const LinkButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// Activity step widget
class ActivityStep extends StatelessWidget {
  final String label, detail;
  const ActivityStep({required this.label, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.yellow[100],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(detail, style: TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}
