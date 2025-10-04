import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NblPoolScreen extends StatefulWidget {
  @override
  _NblPoolScreenState createState() => _NblPoolScreenState();
}

class _NblPoolScreenState extends State<NblPoolScreen> {
  String? nasaImageUrl;
  bool isLoading = true;
  final String apiQuery = "Neutral Buoyancy Lab";

  @override
  void initState() {
    super.initState();
    fetchNasaImages();
  }

  Future<void> fetchNasaImages() async {
    final Uri url = Uri.https('images-api.nasa.gov', '/search', {
      'q': apiQuery,
      'media_type': 'image',
      'page': '1',
      'page_size': '5',
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final items = data['collection']?['items'];
        if (items != null && items.isNotEmpty) {
          final firstItem = items[0];
          final links = firstItem['links'];
          if (links != null && links.isNotEmpty) {
            setState(() {
              nasaImageUrl = links[0]['href'];
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
          print("No items found in NASA API response.");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print("Failed to load NASA images: HTTP ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching NASA images: $e");
    }
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
              // Header Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[800]!, Colors.purple[800]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('👩‍🚀', style: TextStyle(fontSize: 40)),
                        SizedBox(width: 16),
                        Icon(
                          Icons.water_drop,
                          color: Colors.cyanAccent,
                          size: 40,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Neutral Buoyancy Laboratory',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'NASA Training Facility',
                      style: TextStyle(color: Colors.blue[100], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // NASA Image Section (dynamic)
              if (isLoading)
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: CircularProgressIndicator(color: Colors.cyanAccent),
                )
              else if (nasaImageUrl != null)
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(nasaImageUrl!),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'No NASA images found for "$apiQuery".',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),

              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.science,
                            color: Colors.cyanAccent,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Training Principles',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildTrainingCard(
                      number: 1,
                      title: 'Neutral Buoyancy',
                      description: 'Weight = Water Displaced',
                      icon: Icons.balance,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 12),
                    _buildTrainingCard(
                      number: 2,
                      title: 'Weighted Suit',
                      description: 'Adjusted for perfect hover',
                      icon: Icons.engineering,
                      color: Colors.green,
                    ),
                    SizedBox(height: 12),
                    _buildTrainingCard(
                      number: 3,
                      title: 'AQUANAUT Simulation',
                      description: 'Mimics weightlessness in space',
                      icon: Icons.rocket_launch,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),

              // NBL Facts Section
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.fact_check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'NBL Facility Facts',
                          style: TextStyle(
                            color: Colors.orange[200],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Column(
                      children: [
                        _buildFactItem(
                          icon: Icons.height,
                          label: 'Pool Depth',
                          value: '40 feet (12 meters)',
                        ),
                        SizedBox(height: 12),
                        _buildFactItem(
                          icon: Icons.water,
                          label: 'Water Volume',
                          value: '6.2 million gallons',
                        ),
                        SizedBox(height: 12),
                        _buildFactItem(
                          icon: Icons.timer,
                          label: 'Training Ratio',
                          value: '7 hours underwater = 1 hour EVA',
                        ),
                        SizedBox(height: 12),
                        _buildFactItem(
                          icon: Icons.architecture,
                          label: 'Mockups',
                          value: 'Full-scale ISS and Hubble underwater',
                        ),
                        SizedBox(height: 12),
                        _buildFactItem(
                          icon: Icons.public,
                          label: 'Usage',
                          value: 'Used by astronauts worldwide',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Classroom Activity Section
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.green[900]!.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green[300]!),
                ),
                padding: EdgeInsets.all(20),
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
                            Icons.school,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Classroom Activity',
                          style: TextStyle(
                            color: Colors.green[200],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Build Your Own Neutral Buoyancy Simulator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildActivityStep(
                      step: 1,
                      instruction: 'Fill balloon with air and tie securely',
                    ),
                    _buildActivityStep(
                      step: 2,
                      instruction: 'Attach weights until balloon just sinks',
                    ),
                    _buildActivityStep(
                      step: 3,
                      instruction: 'Test different weights to find balance',
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[800]!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Materials Needed:',
                            style: TextStyle(
                              color: Colors.green[100],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildMaterialChip('Balloon'),
                              _buildMaterialChip('Small weights'),
                              _buildMaterialChip('String'),
                              _buildMaterialChip('Paperclips'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Download Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    // Download logic
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download, color: Colors.white),
                      SizedBox(width: 12),
                      Column(
                        children: [
                          Text(
                            'Download Printable Infographic',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'PDF Format',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTrainingCard({
  required int number,
  required String title,
  required String description,
  required IconData icon,
  required MaterialColor color,
}) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color[50]!.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color[300]!),
    ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color[300], size: 18),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: color[200], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildFactItem({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blueGrey[800],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.orange[400],
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
                  color: Colors.orange[200],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildActivityStep({required int step, required String instruction}) {
  return Container(
    margin: EdgeInsets.only(bottom: 8),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.green[800]!.withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            instruction,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    ),
  );
}

Widget _buildMaterialChip(String material) {
  return Chip(
    label: Text(
      material,
      style: TextStyle(
        fontSize: 12,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
    ),
    backgroundColor: Colors.green[300],
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );
}
