import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

/// Saves your notification preferences on this device. Actual push
/// notifications need a service like Firebase Cloud Messaging — these
/// switches are where the app will read the user's choices from.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _scanKey = 'notif_scan_results';
  static const _tipsKey = 'notif_crop_tips';
  static const _remindKey = 'notif_weekly_reminder';

  bool _scan = true;
  bool _tips = true;
  bool _reminder = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _scan = prefs.getBool(_scanKey) ?? true;
      _tips = prefs.getBool(_tipsKey) ?? true;
      _reminder = prefs.getBool(_remindKey) ?? false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text('Notifications', style: AppText.h2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _switchTile(
            title: 'Scan results',
            subtitle: 'Alert me when an analysis finishes',
            value: _scan,
            onChanged: (v) {
              setState(() => _scan = v);
              _save(_scanKey, v);
            },
          ),
          _switchTile(
            title: 'Crop care tips',
            subtitle: 'Seasonal advice for healthier crops',
            value: _tips,
            onChanged: (v) {
              setState(() => _tips = v);
              _save(_tipsKey, v);
            },
          ),
          _switchTile(
            title: 'Weekly scan reminder',
            subtitle: 'Remind me to check my plants once a week',
            value: _reminder,
            onChanged: (v) {
              setState(() => _reminder = v);
              _save(_remindKey, v);
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Your choices are saved on this device. Delivering real push '
            'notifications will need a service such as Firebase Cloud Messaging.',
            style: AppText.body,
          ),
        ],
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        title: Text(title, style: AppText.label),
        subtitle: Text(subtitle, style: AppText.body),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
