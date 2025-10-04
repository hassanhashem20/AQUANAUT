import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasa2/core/constants/app_colors.dart';
import 'package:nasa2/core/constants/app_text_styles.dart';
import 'package:nasa2/core/widgets/accessibility_widgets.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isHighContrastEnabled = false;
  bool _isHapticFeedbackEnabled = true;
  bool _isScreenReaderEnabled = false;
  double _textScaleFactor = 1.0;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _isHighContrastEnabled = AccessibilitySettings.isHighContrastEnabled;
      _isHapticFeedbackEnabled = AccessibilitySettings.isHapticFeedbackEnabled;
      _isScreenReaderEnabled = AccessibilitySettings.isScreenReaderEnabled;
      _textScaleFactor = AccessibilitySettings.textScaleFactor;
    });
  }

  void _saveSettings() {
    AccessibilitySettings.setHighContrastEnabled(_isHighContrastEnabled);
    AccessibilitySettings.setHapticFeedbackEnabled(_isHapticFeedbackEnabled);
    AccessibilitySettings.setScreenReaderEnabled(_isScreenReaderEnabled);
    AccessibilitySettings.setTextScaleFactor(_textScaleFactor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: AppColors.darkSpace,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accessibility Section
            _buildSectionHeader('Accessibility'),
            SizedBox(height: 16),
            
            _buildSwitchTile(
              title: 'High Contrast Mode',
              subtitle: 'Increases contrast for better visibility',
              value: _isHighContrastEnabled,
              onChanged: (value) {
                setState(() {
                  _isHighContrastEnabled = value;
                });
                _saveSettings();
                if (value) {
                  HapticFeedback.lightImpact();
                }
              },
              icon: Icons.contrast,
            ),
            
            _buildSwitchTile(
              title: 'Haptic Feedback',
              subtitle: 'Vibrate on interactions',
              value: _isHapticFeedbackEnabled,
              onChanged: (value) {
                setState(() {
                  _isHapticFeedbackEnabled = value;
                });
                _saveSettings();
                if (value) {
                  HapticFeedback.lightImpact();
                }
              },
              icon: Icons.vibration,
            ),
            
            _buildSwitchTile(
              title: 'Screen Reader Support',
              subtitle: 'Optimize for screen readers',
              value: _isScreenReaderEnabled,
              onChanged: (value) {
                setState(() {
                  _isScreenReaderEnabled = value;
                });
                _saveSettings();
                if (value) {
                  HapticFeedback.lightImpact();
                }
              },
              icon: Icons.accessibility,
            ),
            
            // Text Size Section
            _buildSectionHeader('Text Size'),
            SizedBox(height: 16),
            
            _buildSliderTile(
              title: 'Text Scale Factor',
              subtitle: 'Adjust text size for better readability',
              value: _textScaleFactor,
              min: 0.8,
              max: 2.0,
              divisions: 12,
              onChanged: (value) {
                setState(() {
                  _textScaleFactor = value;
                });
                _saveSettings();
              },
              icon: Icons.text_fields,
            ),
            
            SizedBox(height: 32),
            
            // Display Section
            _buildSectionHeader('Display'),
            SizedBox(height: 16),
            
            _buildSwitchTile(
              title: 'Dark Mode',
              subtitle: 'Use dark theme throughout the app',
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                if (value) {
                  HapticFeedback.lightImpact();
                }
              },
              icon: Icons.dark_mode,
            ),
            
            SizedBox(height: 32),
            
            // About Section
            _buildSectionHeader('About'),
            SizedBox(height: 16),
            
            _buildInfoTile(
              title: 'App Version',
              subtitle: '1.0.0',
              icon: Icons.info,
            ),
            
            _buildInfoTile(
              title: 'NASA Space Apps Challenge',
              subtitle: '2025 - ISS 25th Anniversary',
              icon: Icons.rocket_launch,
            ),
            
            _buildInfoTile(
              title: 'Team AQUANAUT',
              subtitle: 'Inspiring the next generation of explorers',
              icon: Icons.group,
            ),
            
            SizedBox(height: 32),
            
            // Reset Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showResetDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                icon: Icon(Icons.refresh),
                label: Text('Reset All Settings'),
              ),
            ),
            
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3.copyWith(
        color: AppColors.neonCyan,
        fontSize: 20,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSpace.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonCyan.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.neonCyan,
          size: 24,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white70,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.neonCyan,
          activeTrackColor: AppColors.neonCyan.withOpacity(0.3),
          inactiveThumbColor: Colors.white54,
          inactiveTrackColor: AppColors.midSpace,
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSpace.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonCyan.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.neonCyan,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neonCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: AppColors.neonCyan,
            inactiveColor: AppColors.midSpace,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSpace.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonCyan.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.neonCyan,
          size: 24,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSpace,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppColors.warningYellow,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Reset Settings',
              style: AppTextStyles.heading3.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonText.copyWith(
                color: Colors.white54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _isHighContrastEnabled = false;
      _isHapticFeedbackEnabled = true;
      _isScreenReaderEnabled = false;
      _textScaleFactor = 1.0;
      _isDarkMode = true;
    });
    _saveSettings();
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings reset to default values'),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

