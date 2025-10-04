import 'package:flutter/material.dart';
import 'package:nasa2/app/mission_control/iss_training.dart';
import 'package:nasa2/app/mission_control/math_worksheet_page.dart';
import 'package:nasa2/app/mission_control/nbl_traning.dart';

// Import your screens here for inline display
// import 'nbl_pool_screen.dart';
// import 'buoyancy_worksheet_screen.dart';
// import 'iss_info_panel_screen.dart';

class MissionControlClassroomScreen extends StatefulWidget {
  @override
  _MissionControlClassroomScreenState createState() =>
      _MissionControlClassroomScreenState();
}

class _MissionControlClassroomScreenState
    extends State<MissionControlClassroomScreen> {
  int selectedTabIndex = 0;

  final nasaRed = Color(0xFFDC143C);

  final tabs = [
    {'label': 'Overview', 'screen': null},
    {'label': 'NBL Training', 'screen': NblPoolScreen()},
    {'label': 'Math Worksheet', 'screen': BuoyancyWorksheetScreen()},
    {'label': 'ISS Tracking', 'screen': ISSInfoPanelScreen()},
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 800;

    // Adaptive font sizing
    double headingFont = isWideScreen ? 32 : 12;
    double cardFont = isWideScreen ? 20 : 16;
    double subFont = isWideScreen ? 18 : 14;

    return Scaffold(
      backgroundColor: Color(0xFF192556),
      appBar: AppBar(
        backgroundColor: Color(0xFF192556),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'NASA',
                style: TextStyle(
                  fontSize: 10,
                  color: nasaRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 16),
            Text(
              'Mission Control: Classroom',
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
                fontSize: headingFont,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(tabs.length, (i) {
                bool selected = i == selectedTabIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTabIndex = i;
                    });
                  },
                  child: _adaptiveTab(tabs[i]['label'] as String, selected),
                );
              }),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWideScreen ? 48 : 8,
          vertical: 20,
        ),
        child:
            selectedTabIndex == 0
                ? SingleChildScrollView(
                  child: _overviewContent(
                    headingFont,
                    subFont,
                    cardFont,
                    isWideScreen,
                  ),
                )
                : (tabs[selectedTabIndex]['screen'] as Widget? ?? SizedBox()),
      ),
    );
  }

  Widget _overviewContent(
    double headingFont,
    double subFont,
    double cardFont,
    bool isWideScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mission to the Classroom',
          style: TextStyle(
            color: Colors.lightBlueAccent,
            fontSize: headingFont,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF253577),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(16),
          child: Text(
            'Transform Digital Learning into Hands-On Experience\n\n'
            'These NASA-branded educational resources extend your students\' digital space experience into engaging classroom activities. '
            'All materials are ready-to-print and aligned with STEM education standards.',
            style: TextStyle(color: Colors.white, fontSize: subFont),
          ),
        ),
        SizedBox(height: 32),
        isWideScreen
            ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _resourceCard(
                    icon: Icons.science,
                    title: 'NBL Simulator',
                    subtitle:
                        'Build a neutral buoyancy demonstrator using simple materials',
                    color: Colors.amber,
                    fontSize: cardFont,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _resourceCard(
                    icon: Icons.calculate,
                    title: 'Math Problems',
                    subtitle:
                        'Real NASA calculations using Archimedes\' Principle',
                    color: Colors.green,
                    fontSize: cardFont,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _resourceCard(
                    icon: Icons.track_changes,
                    title: 'ISS Tracking',
                    subtitle: 'Find when the ISS will pass over your school',
                    color: Color(0xFF9577B6),
                    fontSize: cardFont,
                  ),
                ),
              ],
            )
            : Column(
              children: [
                _resourceCard(
                  icon: Icons.science,
                  title: 'NBL Simulator',
                  subtitle:
                      'Build a neutral buoyancy demonstrator using simple materials',
                  color: Colors.amber,
                  fontSize: cardFont,
                ),
                SizedBox(height: 12),
                _resourceCard(
                  icon: Icons.calculate,
                  title: 'Math Problems',
                  subtitle:
                      'Real NASA calculations using Archimedes\' Principle',
                  color: Colors.green,
                  fontSize: cardFont,
                ),
                SizedBox(height: 12),
                _resourceCard(
                  icon: Icons.track_changes,
                  title: 'ISS Tracking',
                  subtitle: 'Find when the ISS will pass over your school',
                  color: Color(0xFF9577B6),
                  fontSize: cardFont,
                ),
              ],
            ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF5A2E35),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.school, color: Colors.redAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'NASA Educational Standards\n'
                  'These activities align with Next Generation Science Standards (NGSS) and support learning objectives in Physics, Engineering Design, and Earth-Space Science.',
                  style: TextStyle(color: Colors.white, fontSize: subFont),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _adaptiveTab(String label, bool selected) => Container(
    margin: EdgeInsets.only(right: 12),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: BoxDecoration(
      color: selected ? Colors.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: selected ? Colors.white : Colors.grey[300],
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    ),
  );

  Widget _resourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required double fontSize,
  }) => Container(
    decoration: BoxDecoration(
      color: Color(0xFF29305A),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color, width: 2),
    ),
    padding: EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 36, color: color),
        SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(color: Colors.white, fontSize: fontSize - 2),
        ),
      ],
    ),
  );
}
