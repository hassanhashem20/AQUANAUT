import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nasa2/core/widgets/enhanced_drag_drop.dart';
import 'package:nasa2/core/widgets/enhanced_step_widget.dart';
import 'package:nasa2/core/providers/user_progress_provider.dart';

class SuitAssemblyStep2 extends ConsumerStatefulWidget {
  final VoidCallback? nextStep;

  const SuitAssemblyStep2({Key? key, this.nextStep}) : super(key: key);

  @override
  ConsumerState<SuitAssemblyStep2> createState() => _SuitAssemblyStep2State();
}

class _SuitAssemblyStep2State extends ConsumerState<SuitAssemblyStep2> {
  List<String> _placedItems = [];

  final List<EnhancedDragDropItem> _suitParts = [
    EnhancedDragDropItem(
      id: 'helmet',
      title: 'Helmet',
      icon: Icons.emoji_emotions,
      color: Colors.blue,
      description: 'Protects the head and provides oxygen',
      isRequired: true,
    ),
    EnhancedDragDropItem(
      id: 'torso',
      title: 'Torso',
      icon: Icons.safety_divider,
      color: Colors.green,
      description: 'Main body section with life support systems',
      isRequired: true,
    ),
    EnhancedDragDropItem(
      id: 'gloves',
      title: 'Gloves',
      icon: Icons.back_hand,
      color: Colors.orange,
      description: 'Protects hands and provides dexterity',
      isRequired: true,
    ),
    EnhancedDragDropItem(
      id: 'boots',
      title: 'Boots',
      icon: Icons.hiking,
      color: Colors.purple,
      description: 'Protects feet and provides stability',
      isRequired: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return EnhancedStepWidget(
      stepNumber: 2,
      totalSteps: 7,
      title: 'Suiting Up in the EMU',
      description: 'Astronauts wear the Extravehicular Mobility Unit (EMU) for spacewalks. Drag and drop each part of the spacesuit to complete the assembly.',
      content: EnhancedDragDropWidget(
        items: _suitParts,
        targetIds: _placedItems,
        onItemsChanged: (items) {
          setState(() {
            _placedItems = items;
          });
          
          // Add XP for progress
          if (items.length == _suitParts.length) {
            ref.read(userProgressProvider.notifier).addXP(100);
            ref.read(userProgressProvider.notifier).unlockAchievement('Suit Master');
          }
        },
        title: 'EMU Suit Assembly',
        instruction: 'Drag each spacesuit component to the assembly area below. All parts must be placed correctly to proceed.',
        showProgress: true,
        enableHapticFeedback: true,
      ),
      onNext: _placedItems.length == _suitParts.length ? widget.nextStep : null,
      isCompleted: _placedItems.length == _suitParts.length,
      nextButtonText: 'Complete Suit Assembly',
      showProgress: true,
      enableHapticFeedback: true,
    );
  }
}
