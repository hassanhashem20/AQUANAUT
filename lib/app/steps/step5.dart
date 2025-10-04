import 'package:flutter/material.dart';

class WeightAdjustmentChallengeStep extends StatefulWidget {
  final VoidCallback? onComplete;

  const WeightAdjustmentChallengeStep({Key? key, this.onComplete})
    : super(key: key);

  @override
  _WeightAdjustmentChallengeStepState createState() =>
      _WeightAdjustmentChallengeStepState();
}

class _WeightAdjustmentChallengeStepState
    extends State<WeightAdjustmentChallengeStep> {
  Map<String, int> weights = {
    'Left Weight': 45,
    'Right Weight': 50,
    'Chest Weight': 50,
    'Back Weight': 50,
  };
  final int targetTotalWeight = 200;
  final int tolerance = 5; // accept from 195kg to 205kg

  int get totalWeight => weights.values.reduce((a, b) => a + b);

  String get feedbackMessage {
    if (totalWeight < targetTotalWeight - tolerance) {
      return 'Add more weight to reach neutral buoyancy.';
    } else if (totalWeight > targetTotalWeight + tolerance) {
      return 'Remove some weight to reach neutral buoyancy.';
    } else {
      return 'Perfect! You\'ve achieved neutral buoyancy.';
    }
  }

  bool get canProceed =>
      totalWeight >= targetTotalWeight - tolerance &&
      totalWeight <= targetTotalWeight + tolerance;

  void adjustWeight(String key, int delta) {
    setState(() {
      int newValue = (weights[key]! + delta).clamp(0, 100);
      weights[key] = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Step 4: Weight Adjustment Challenge',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'Adjust weights to achieve neutral buoyancy (target 200kg total).',
        ),
        SizedBox(height: 10),
        ...weights.keys.map((key) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(key),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed:
                        weights[key]! > 0 ? () => adjustWeight(key, -5) : null,
                  ),
                  Text('${weights[key]} kg'),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => adjustWeight(key, 5),
                  ),
                ],
              ),
            ],
          );
        }),
        SizedBox(height: 10),
        Text('Total Weight: $totalWeight kg'),
        SizedBox(height: 10),
        Text(
          feedbackMessage,
          style: TextStyle(
            color: canProceed ? Colors.green : Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: canProceed ? widget.onComplete : null,
          child: Text('Proceed to Launch'),
        ),
      ],
    );
  }
}
