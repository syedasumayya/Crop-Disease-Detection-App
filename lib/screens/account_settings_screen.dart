import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/auth_store.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _nameController = TextEditingController();
  final _currentPw = TextEditingController();
  final _newPw = TextEditingController();
  String _email = '';
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPw.dispose();
    _newPw.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final name = await AuthStore.currentUserName();
    final email = await AuthStore.currentUserEmail();
    if (!mounted) return;
    setState(() {
      _nameController.text = name ?? '';
      _email = email ?? '';
    });
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.danger : AppColors.primary,
      ),
    );
  }

  Future<void> _saveName() async {
    final error = await AuthStore.updateName(_nameController.text);
    if (!mounted) return;
    error == null ? _snack('Name updated.') : _snack(error, error: true);
  }

  Future<void> _changePassword() async {
    final error = await AuthStore.changePassword(_currentPw.text, _newPw.text);
    if (!mounted) return;
    if (error != null) {
      _snack(error, error: true);
      return;
    }
    _currentPw.clear();
    _newPw.clear();
    _snack('Password changed.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text('Account Settings', style: AppText.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Full Name', style: AppText.label),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: appInputDecoration('Your name', Icons.person_outline),
            ),
            const SizedBox(height: 16),
            const Text('Email Address', style: AppText.label),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: _email),
              enabled: false,
              decoration: appInputDecoration('Email', Icons.mail_outline),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveName,
              style: primaryButtonStyle(),
              child: const Text('Save Name'),
            ),
            const SizedBox(height: 32),
            Text('Change Password', style: AppText.h2),
            const SizedBox(height: 12),
            TextField(
              controller: _currentPw,
              obscureText: _obscure,
              decoration: appInputDecoration(
                'Current password',
                Icons.lock_outline,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPw,
              obscureText: _obscure,
              decoration: appInputDecoration(
                'New password (min 6 characters)',
                Icons.lock_reset,
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _changePassword,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Change Password',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
