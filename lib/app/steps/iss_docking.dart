import 'package:flutter/material.dart';

class ISSDockingAlignmentStep extends StatefulWidget {
  final VoidCallback? onDockingSuccess;

  const ISSDockingAlignmentStep({Key? key, this.onDockingSuccess})
    : super(key: key);

  @override
  _ISSDockingAlignmentStepState createState() =>
      _ISSDockingAlignmentStepState();
}

class _ISSDockingAlignmentStepState extends State<ISSDockingAlignmentStep> {
  int alignment = 75; // 0 to 100%
  double velocity = 5.0; // m/s approach velocity

  bool dockingSuccessful = false;
  String feedback = '';

  final int alignmentMin = 70;
  final int alignmentMax = 80;
  final double velocityMax = 10.0; // maximum safe docking velocity

  void adjustAlignment(int change) {
    setState(() {
      alignment = (alignment + change).clamp(0, 100);
    });
  }

  void adjustVelocity(double change) {
    setState(() {
      velocity = (velocity + change).clamp(0, 20);
    });
  }

  void tryDocking() {
    if (alignment >= alignmentMin &&
        alignment <= alignmentMax &&
        velocity <= velocityMax) {
      setState(() {
        dockingSuccessful = true;
        feedback = 'Docking successful! Welcome aboard the ISS.';
      });
      
      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Docking successful! Welcome aboard the ISS.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Call success callback and delay navigation
      widget.onDockingSuccess?.call();
      
      // Delay navigation to show success message
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    } else {
      setState(() {
        feedback =
            'Alignment or velocity not within safe range. Adjust further.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dockingSuccessful) {
      return Scaffold(
        appBar: AppBar(title: Text('Docking Successful')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 100, color: Colors.green),
              SizedBox(height: 20),
              Text(
                'Welcome aboard the ISS!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to next screen (e.g., ISS onboarding)
                  // Navigator.push(...)
                },
                child: Text('Enter ISS'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('ISS Docking Alignment')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Align with docking port',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Alignment: $alignment%', style: TextStyle(fontSize: 18)),
            Slider(
              value: alignment.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: '$alignment%',
              onChanged: (value) {
                setState(() {
                  alignment = value.round();
                });
              },
            ),
            SizedBox(height: 20),
            Text('Adjust alignment with RCS thrusters'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: alignment > 0 ? () => adjustAlignment(-1) : null,
                  child: Icon(Icons.arrow_left),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: alignment < 100 ? () => adjustAlignment(1) : null,
                  child: Icon(Icons.arrow_right),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'Approach Velocity: ${velocity.toStringAsFixed(1)} m/s',
              style: TextStyle(fontSize: 18),
            ),
            Slider(
              value: velocity,
              min: 0,
              max: 20,
              divisions: 200,
              label: '${velocity.toStringAsFixed(1)} m/s',
              onChanged: (value) {
                setState(() {
                  velocity = value;
                });
              },
            ),
            Text('Adjust velocity with thrusters'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: velocity > 0 ? () => adjustVelocity(-0.2) : null,
                  child: Icon(Icons.remove),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: velocity < 20 ? () => adjustVelocity(0.2) : null,
                  child: Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: tryDocking,
              child: Text('Attempt Docking'),
            ),
            SizedBox(height: 20),
            Text(
              feedback,
              style: TextStyle(
                color: dockingSuccessful ? Colors.green : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
