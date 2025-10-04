import 'package:flutter/material.dart';
import 'dart:async';

class DestinyLabOnboarding extends StatefulWidget {
  final VoidCallback onComplete;
  const DestinyLabOnboarding({Key? key, required this.onComplete})
    : super(key: key);
  @override
  State<DestinyLabOnboarding> createState() => _DestinyLabOnboardingState();
}

enum OnboardState {
  AwaitEnter,
  ISSArrival,
  MissionCompletePopup,
  DestinyLab,
  ShowPanelRepair,
  ShowPlantMonitor,
  ShowComms,
}

class _DestinyLabOnboardingState extends State<DestinyLabOnboarding> {
  OnboardState _state = OnboardState.AwaitEnter;
  List<bool> taskCompleted = [false, false, false]; // [Panel, Plant, Comms]
  bool get allTasksComplete => taskCompleted.every((completed) => completed);

  void onEnterCupolaPressed() {
    setState(() => _state = OnboardState.ISSArrival);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _state = OnboardState.MissionCompletePopup);
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _state = OnboardState.DestinyLab);
      });
    });
  }

  void showPanelRepair() =>
      setState(() => _state = OnboardState.ShowPanelRepair);
  void showPlantMonitor() =>
      setState(() => _state = OnboardState.ShowPlantMonitor);
  void showCommsCheck() => setState(() => _state = OnboardState.ShowComms);

  Widget buildArrivalScreen() {
    return Center(
      child: Container(
        width: 500,
        color: Colors.black87,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "🚀 ISS Arrival",
              style: TextStyle(fontSize: 32, color: Colors.blue),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.blue[900],
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      "Welcome aboard the ISS, Crew Member!",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "You are now entering the Destiny Laboratory module through the airlock. Prepare for your onboarding tasks.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: 1,
              backgroundColor: Colors.white10,
              color: Colors.blue[300],
              minHeight: 8,
            ),
            Text(
              "Airlock pressurization complete...",
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMissionCompletePopup() {
    return Center(
      child: Container(
        width: 420,
        decoration: BoxDecoration(
          color: Colors.green[900],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green, width: 2),
        ),
        padding: EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "🎉 Mission Complete!",
              style: TextStyle(fontSize: 28, color: Colors.green[200]),
            ),
            SizedBox(height: 14),
            Icon(Icons.check_circle, color: Colors.green, size: 52),
            SizedBox(height: 14),
            Text(
              "Outstanding Work!",
              style: TextStyle(fontSize: 19, color: Colors.green[100]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "You've successfully completed all onboarding tasks. The Cupola Observatory is now unlocked!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              runSpacing: 8,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTaskChip("Panel Repaired", Icons.build),
                SizedBox(width: 8),
                buildTaskChip("Plants Monitored", Icons.eco),
                SizedBox(width: 8),
                buildTaskChip("Comms Verified", Icons.satellite_alt_rounded),
              ],
            ),
            SizedBox(height: 18),
            ElevatedButton.icon(
              icon: Icon(Icons.remove_red_eye, color: Colors.black),
              label: Text(
                "Enter Cupola Observatory",
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[200],
              ),
              onPressed: widget.onComplete,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTaskChip(String label, IconData icon) => Container(
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(8),
    ),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        SizedBox(width: 5),
        Text(label, style: TextStyle(color: Colors.white)),
      ],
    ),
  );

  Widget buildDestinyLabScreen() {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              SizedBox(height: 25),
              Text(
                "ISS Destiny Laboratory",
                style: TextStyle(fontSize: 26, color: Colors.blue[100]),
              ),
              SizedBox(height: 38),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildLabBox(
                    color: Colors.red[900],
                    icon: Icons.build_sharp,
                    onTap: showPanelRepair,
                    complete: taskCompleted[0],
                  ),
                  SizedBox(width: 24),
                  buildLabBox(
                    color: Colors.blue[900],
                    icon: Icons.eco_sharp,
                    onTap: showPlantMonitor,
                    complete: taskCompleted[1],
                  ),
                  SizedBox(width: 24),
                  buildLabBox(
                    color: Colors.blue[800],
                    icon: Icons.satellite_alt_rounded,
                    onTap: showCommsCheck,
                    complete: taskCompleted[2],
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        SizedBox(width: 300, child: buildTaskSidebar()),
      ],
    );
  }

  Widget buildLabBox({
    Color? color,
    IconData? icon,
    VoidCallback? onTap,
    required bool complete,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: complete ? Colors.green[900] : color,
          borderRadius: BorderRadius.circular(14),
          border:
              complete ? Border.all(color: Colors.greenAccent, width: 3) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            if (complete)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "✓ COMPLETE",
                  style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTaskSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ISS Onboarding Tasks",
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue[200],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          buildSidebarButton(
            "Inspection & Repair",
            "Tighten loose panel causing red alert light",
            Icons.build,
            showPanelRepair,
            taskCompleted[0],
          ),
          SizedBox(height: 14),
          buildSidebarButton(
            "Plant Growth Check",
            "Monitor plant growth in the plant module",
            Icons.eco,
            showPlantMonitor,
            taskCompleted[1],
          ),
          SizedBox(height: 14),
          buildSidebarButton(
            "Communications Check",
            "Send status report to Mission Control",
            Icons.satellite_alt_rounded,
            showCommsCheck,
            taskCompleted[2],
          ),
        ],
      ),
    );
  }

  Widget buildSidebarButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
    bool complete, // new param
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: complete ? Colors.green[900] : Colors.blueGrey[900],
          borderRadius: BorderRadius.circular(10),
          border:
              complete ? Border.all(color: Colors.greenAccent, width: 2) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[100]),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      if (complete)
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.check,
                            color: Colors.greenAccent,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTaskPopup(
    String title,
    String msg,
    String btn,
    Function() onConfirm, {
    Color? color,
    IconData? icon,
  }) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color ?? Colors.black,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.yellow, width: 2),
        ),
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Icons.warning, color: Colors.yellow, size: 42),
            SizedBox(height: 14),
            Text(title, style: TextStyle(color: Colors.yellow, fontSize: 22)),
            SizedBox(height: 7),
            Text(
              msg,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 17),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
              onPressed: () {
                setState(() {
                  if (title == "Inspection & Repair") taskCompleted[0] = true;
                  if (title == "Plant Growth Check") taskCompleted[1] = true;
                  if (title == "Communications Check") taskCompleted[2] = true;
                  if (allTasksComplete) {
                    _state = OnboardState.MissionCompletePopup;
                  } else {
                    _state = OnboardState.DestinyLab;
                  }
                });
              },
              child: Text(btn),
            ),
            TextButton(
              onPressed: () => setState(() => _state = OnboardState.DestinyLab),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[300])),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case OnboardState.AwaitEnter:
        return Center(
          child: ElevatedButton(
            onPressed: onEnterCupolaPressed,
            child: Text("Enter the Cupola Observatory"),
          ),
        );
      case OnboardState.ISSArrival:
        return buildArrivalScreen();
      case OnboardState.MissionCompletePopup:
        return buildMissionCompletePopup();
      case OnboardState.DestinyLab:
        return buildDestinyLabScreen();
      case OnboardState.ShowPanelRepair:
        return buildTaskPopup(
          "Inspection & Repair",
          "Red alert light detected! Tighten loose panel causing red alert light.",
          "Tighten Panel 🔧",
          () {},
        );
      case OnboardState.ShowPlantMonitor:
        return buildTaskPopup(
          "Plant Growth Check",
          "Check plant growth progress in the plant module.",
          "Monitor Plants 🌱",
          () {},
        );
      case OnboardState.ShowComms:
        return buildTaskPopup(
          "Communications Check",
          "Send status report to Mission Control.",
          "Send Report 🛰️",
          () {},
        );
      default:
        return Container();
    }
  }
}
