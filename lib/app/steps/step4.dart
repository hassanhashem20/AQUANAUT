import 'dart:async';
import 'package:flutter/material.dart';

class CableConnectionWidget extends StatefulWidget {
  final VoidCallback onComplete;
  const CableConnectionWidget({Key? key, required this.onComplete})
    : super(key: key);

  @override
  State<CableConnectionWidget> createState() => _CableConnectionWidgetState();
}

class _CableConnectionWidgetState extends State<CableConnectionWidget> {
  double handlePosition = 0.0;
  bool isConnected = false;
  late Timer missionTimer;
  int elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    missionTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (!isConnected) {
        setState(() {
          elapsedSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    missionTimer.cancel();
    super.dispose();
  }

  String formatDuration(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  bool showDebrief = false;

  void onConnectionComplete() {
    setState(() {
      isConnected = true;
      showDebrief = true;
    });
    missionTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final double blockSize = 48;
    final double lineMinPadding = 20;
    final double totalWidth =
        MediaQuery.of(context).size.width - lineMinPadding * 2;
    final double lineLength = totalWidth - blockSize * 2;
    final double lineY = blockSize / 2;

    double handleCenterX = blockSize + handlePosition * lineLength;
    if (showDebrief) {
      return MissionDebriefScreen(
        duration: Duration(seconds: elapsedSeconds),
        accuracy: 95.0, // Provide actual accuracy calculation if available
        onNext: () {
          // Handle continue or navigation after debrief
          widget.onComplete();
        },
      );
    }
    return Stack(
      children: [
        // Background with virtual safety divers silhouettes
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.pool,
                    color: Colors.blueAccent.withOpacity(0.4),
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Main UI
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer visible at top
              Text(
                'Timer: ${formatDuration(elapsedSeconds)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '🔧 ISS Maintenance Task',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow[700],
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Connect Cable A to Port B on the ISS module',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF252D3B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  height: blockSize + 20,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalLength = constraints.maxWidth - blockSize * 2;

                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // Left block
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: Column(
                              children: [
                                Container(
                                  width: blockSize,
                                  height: blockSize,
                                  color: Colors.red[700],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Cable A",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right block
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Column(
                              children: [
                                Container(
                                  width: blockSize,
                                  height: blockSize,
                                  color: Colors.blue[700],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Port B",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Dashed line
                          Positioned(
                            left: blockSize,
                            top: lineY - 1,
                            child: CustomPaint(
                              painter: DashedLinePainter(width: totalLength),
                              size: Size(totalLength, 4),
                            ),
                          ),
                          // Draggable handle or completed icon
                          Positioned(
                            left: handleCenterX - 12,
                            top: lineY - 12,
                            child:
                                isConnected
                                    ? Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                    )
                                    : GestureDetector(
                                      onHorizontalDragUpdate: (details) {
                                        setState(() {
                                          handlePosition +=
                                              details.delta.dx / totalLength;
                                          handlePosition = handlePosition.clamp(
                                            0.0,
                                            1.0,
                                          );
                                        });
                                      },
                                      onHorizontalDragEnd: (details) {
                                        if (handlePosition > 0.92) {
                                          setState(() {
                                            isConnected = true;
                                          });
                                          onConnectionComplete();
                                        }
                                      },
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.blueAccent,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.circle_outlined,
                                          size: 18,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: isConnected ? widget.onComplete : null,
                child: Text("Complete Connection"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: Size(200, 48),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                    children: [
                      TextSpan(
                        text: "Real NBL Training: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text:
                            "Astronauts practice the exact same procedures they'll perform in space, using full-scale mockups of ISS modules underwater.",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final double width;
  DashedLinePainter({required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 10;
    double dashSpace = 6;
    Paint paint =
        Paint()
          ..color = Colors.white38
          ..strokeWidth = 2;

    double x = 0;
    while (x < width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + dashWidth).clamp(0, width), size.height / 2),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) => false;
}

class MissionDebriefScreen extends StatelessWidget {
  final Duration duration;
  final double accuracy;
  final VoidCallback onNext;

  const MissionDebriefScreen({
    Key? key,
    required this.duration,
    required this.accuracy,
    required this.onNext,
  }) : super(key: key);

  String get formattedTime {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Card(
          color: Colors.blueGrey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 36, horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🚀 Mission Debrief',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellowAccent,
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'Time: $formattedTime   |   Accuracy: ${accuracy.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Divider(color: Colors.white24, height: 34, thickness: 1),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Feedback:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '• "Perfect! Now you’re ready for space!"',
                    style: TextStyle(fontSize: 16, color: Colors.greenAccent),
                  ),
                ),
                SizedBox(height: 34),
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: Size(220, 50),
                  ),
                  child: Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
