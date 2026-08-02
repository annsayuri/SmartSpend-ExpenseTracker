import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/db_helper.dart';
import '../../../main.dart'; // themeNotifier සඳහා

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  bool _isDarkMode = themeNotifier.value == ThemeMode.dark;
  bool _billReminders = true;
  String _selectedCurrency = 'LKR (Rs.)';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!mounted) return;

    setState(() {
      _nameController.text = prefs.getString('user_name') ?? 'Ann Sayuri Kotikawaththa';
      _emailController.text = prefs.getString('user_email') ?? 'ann@example.com';
      _isDarkMode = prefs.getBool('dark_mode') ?? (themeNotifier.value == ThemeMode.dark);
      _billReminders = prefs.getBool('bill_reminders') ?? true;
      _selectedCurrency = prefs.getString('currency') ?? 'LKR (Rs.)';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('user_email', _emailController.text.trim());
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setBool('bill_reminders', _billReminders);
    await prefs.setString('currency', _selectedCurrency);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully! 💾'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Reset All Data? ⚠️'),
          content: const Text(
            'This will permanently delete all your Transaction data. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await DBHelper().deleteAllTransactions();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data has been successfully deleted! 🧹'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Yes, Delete All', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile ⚙️'),
        backgroundColor: const Color(0xFF311B92),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFF673AB7),
                          child: Text(
                            'AS',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _nameController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: TextStyle(color: subTextColor),
                            prefixIcon: Icon(Icons.person_outline, color: subTextColor),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? Colors.white38 : Colors.black26),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF673AB7)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(color: subTextColor),
                            prefixIcon: Icon(Icons.email_outlined, color: subTextColor),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? Colors.white38 : Colors.black26),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF673AB7)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'App Preferences',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Settings Preferences List
                  Container(
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text('Dark Mode', style: TextStyle(color: textColor)),
                          subtitle: Text('Toggle between light and dark theme', style: TextStyle(color: subTextColor)),
                          value: _isDarkMode,
                          activeThumbColor: const Color(0xFF673AB7),
                          onChanged: (val) {
                            setState(() {
                              _isDarkMode = val;
                              themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                            });
                          },
                        ),
                        Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                        ListTile(
                          leading: const Icon(Icons.monetization_on_outlined, color: Colors.blue),
                          title: Text('Primary Currency', style: TextStyle(color: textColor)),
                          subtitle: Text(_selectedCurrency, style: TextStyle(color: subTextColor)),
                          trailing: DropdownButton<String>(
                            value: _selectedCurrency,
                            dropdownColor: cardBgColor,
                            style: TextStyle(color: textColor),
                            underline: const SizedBox(),
                            items: <String>['LKR (Rs.)', 'USD (\$)', 'EUR (€)', 'GBP (£)']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCurrency = val;
                                });
                              }
                            },
                          ),
                        ),
                        Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                        SwitchListTile(
                          title: Text('Bill Reminders & Alerts', style: TextStyle(color: textColor)),
                          subtitle: Text('Get notified for upcoming bills', style: TextStyle(color: subTextColor)),
                          value: _billReminders,
                          activeThumbColor: const Color(0xFF673AB7),
                          onChanged: (val) {
                            setState(() {
                              _billReminders = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Save Settings', style: TextStyle(fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ⚠️ Danger Zone / Reset Data Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Danger Zone ⚠️',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Resetting will erase all recorded transactions permanently.',
                          style: TextStyle(color: subTextColor, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: _showResetConfirmationDialog,
                            icon: const Icon(Icons.delete_forever, color: Colors.white),
                            label: const Text('Reset All App Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}