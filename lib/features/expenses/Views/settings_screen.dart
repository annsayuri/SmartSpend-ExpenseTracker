import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 👈 Provider එක import කළා
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartspend_expensetracker/core/Theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = 'User';
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
      _nameController.text = _userName;
    });
  }

  void _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    setState(() {
      _userName = _nameController.text;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully!'),
        backgroundColor: Colors.deepPurple.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 මෙතනින් තමයි මුළු App එකේම තියෙන Theme Provider එකට සවන් දෙන්නේ 🌟
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile ⚙️', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: const BorderSide(color: Color(0xFFE9ECEF)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.deepPurple.shade100,
                          child: Icon(Icons.person, size: 48, color: Colors.deepPurple.shade700),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'User Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            prefixIcon: const Icon(Icons.edit),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            onPressed: _saveUserData,
                            child: const Text('Save Profile Details', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                
                const Text(
                  'App Preferences',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 12.0),

                // Theme Settings Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: const BorderSide(color: Color(0xFFE9ECEF)),
                  ),
                  child: Column(
                    children: [
                      // 🌟 මෙන්න මේ Switch එක දැන් Provider එකත් එක්ක කෙලින්ම වැඩ කරනවා! 🌟
                      SwitchListTile(
                        title: const Text('Dark Mode 🌙', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Switch between light and dark theme'),
                        value: themeProvider.isDarkMode, // 👈 Provider එකේ තියෙන අගය මෙතනට ගන්නවා
                        activeColor: Colors.deepPurple.shade700,
                        onChanged: (bool value) {
                          // 👈 Switch එක එහා මෙහා කරද්දී මුළු App එකේම Theme එක මාරු කරනවා
                          themeProvider.toggleTheme(value);
                        },
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('App Version'),
                        trailing: Text('v1.0.0', style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}