import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';

class EnhancedDragDropItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final bool isRequired;

  const EnhancedDragDropItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    this.isRequired = true,
  });
}

class EnhancedDragDropWidget extends StatefulWidget {
  final List<EnhancedDragDropItem> items;
  final List<String> targetIds;
  final Function(List<String>) onItemsChanged;
  final String title;
  final String instruction;
  final Widget? targetWidget;
  final bool showProgress;
  final bool enableHapticFeedback;

  const EnhancedDragDropWidget({
    Key? key,
    required this.items,
    required this.targetIds,
    required this.onItemsChanged,
    required this.title,
    required this.instruction,
    this.targetWidget,
    this.showProgress = true,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  _EnhancedDragDropWidgetState createState() => _EnhancedDragDropWidgetState();
}

class _EnhancedDragDropWidgetState extends State<EnhancedDragDropWidget>
    with TickerProviderStateMixin {
  late List<String> _placedItems;
  late AnimationController _successController;
  late Animation<double> _successAnimation;
  String? _draggingItem;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _placedItems = List.from(widget.targetIds);
    _successController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    
    _checkCompletion();
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  void _checkCompletion() {
    final isCompleted = _placedItems.length == widget.items.length;
    if (isCompleted != _isCompleted) {
      setState(() {
        _isCompleted = isCompleted;
      });
      if (isCompleted) {
        _successController.forward();
        if (widget.enableHapticFeedback) {
          HapticFeedback.heavyImpact();
        }
      }
    }
  }

  void _onDragStarted(String itemId) {
    setState(() {
      _draggingItem = itemId;
    });
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _onDragEnd(String itemId) {
    setState(() {
      _draggingItem = null;
    });
  }

  void _onItemPlaced(String itemId) {
    if (!_placedItems.contains(itemId)) {
      setState(() {
        _placedItems.add(itemId);
      });
      widget.onItemsChanged(_placedItems);
      _checkCompletion();
      
      if (widget.enableHapticFeedback) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  void _onItemRemoved(String itemId) {
    setState(() {
      _placedItems.remove(itemId);
    });
    widget.onItemsChanged(_placedItems);
    _checkCompletion();
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSpace.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isCompleted 
            ? AppColors.successGreen 
            : AppColors.neonCyan.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isCompleted ? AppColors.successGreen : AppColors.neonCyan)
                .withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                _isCompleted ? Icons.check_circle : Icons.touch_app,
                color: _isCompleted ? AppColors.successGreen : AppColors.neonCyan,
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: AppTextStyles.heading3.copyWith(
                    color: _isCompleted ? AppColors.successGreen : Colors.white,
                  ),
                ),
              ),
              if (widget.showProgress)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.midSpace,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_placedItems.length}/${widget.items.length}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.neonCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Instruction
          Text(
            widget.instruction,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Items grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.items.map((item) {
              final isPlaced = _placedItems.contains(item.id);
              final isDragging = _draggingItem == item.id;
              
              return Draggable<String>(
                data: item.id,
                feedback: Material(
                  color: Colors.transparent,
                  child: Transform.scale(
                    scale: 1.1,
                    child: _buildItemCard(item, true, isPlaced),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _buildItemCard(item, false, isPlaced),
                ),
                child: _buildItemCard(item, isPlaced, isPlaced),
                onDragStarted: () => _onDragStarted(item.id),
                onDragEnd: (details) => _onDragEnd(item.id),
              );
            }).toList(),
          ),
          
          SizedBox(height: 24),
          
          // Target area
          DragTarget<String>(
            onWillAccept: (data) => !_placedItems.contains(data),
            onAccept: (data) => _onItemPlaced(data),
            builder: (context, candidateData, rejectedData) {
              final isHovering = candidateData.isNotEmpty;
              
              return AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isHovering 
                    ? AppColors.successGreen.withOpacity(0.1)
                    : AppColors.midSpace.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHovering 
                      ? AppColors.successGreen 
                      : AppColors.neonCyan.withOpacity(0.3),
                    width: isHovering ? 3 : 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Target content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sports_kabaddi,
                            size: 60,
                            color: isHovering 
                              ? AppColors.successGreen 
                              : Colors.white.withOpacity(0.3),
                          ),
                          SizedBox(height: 12),
                          Text(
                            isHovering 
                              ? 'Drop here!' 
                              : _placedItems.isEmpty 
                                ? 'Drop items here' 
                                : 'Items placed: ${_placedItems.length}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: isHovering 
                                ? AppColors.successGreen 
                                : Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Placed items
                    if (_placedItems.isNotEmpty)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _placedItems.map((itemId) {
                            final item = widget.items.firstWhere((i) => i.id == itemId);
                            return GestureDetector(
                              onTap: () => _onItemRemoved(itemId),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.successGreen,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      item.icon,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      item.title,
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          
          // Success animation
          if (_isCompleted)
            ScaleTransition(
              scale: _successAnimation,
              child: Container(
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.successGreen),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.successGreen,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Excellent! All items placed correctly.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemCard(EnhancedDragDropItem item, bool isPlaced, bool isDragging) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: 120,
      height: 100,
      decoration: BoxDecoration(
        color: isPlaced 
          ? AppColors.successGreen.withOpacity(0.2)
          : AppColors.midSpace,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaced 
            ? AppColors.successGreen 
            : item.color.withOpacity(0.5),
          width: isPlaced ? 2 : 1,
        ),
        boxShadow: isPlaced ? [
          BoxShadow(
            color: AppColors.successGreen.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            color: isPlaced ? AppColors.successGreen : item.color,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            item.title,
            style: AppTextStyles.caption.copyWith(
              color: isPlaced ? AppColors.successGreen : Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isPlaced)
            Icon(
              Icons.check_circle,
              color: AppColors.successGreen,
              size: 16,
            ),
        ],
      ),
    );
  }
}
