import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Profile විස්තර සඳහා Controllers (පසුව Shared Preferences හෝ DB එකට සම්බන්ධ කළ හැක)
  final TextEditingController _nameController = TextEditingController(text: "Ann Sayuri");
  final TextEditingController _emailController = TextEditingController(text: "ann@example.com");
  
  bool _isDarkMode = false;
  String _selectedCurrency = 'LKR (Rs.)';
  bool _notificationsEnabled = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // දැනට තියෙන Theme එක අනුව initial state එක සකස් කිරීම
    setState(() {
      _isDarkMode = isDark;
    });

    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Settings & Profile ⚙️', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _isDarkMode ? Colors.deepPurple.shade900 : Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 Profile Section Card එක
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(color: _isDarkMode ? Colors.white10 : const Color(0xFFE9ECEF)),
              ),
              color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        'AS', // Profile Initials
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Name Input Field
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    
                    // Email Input Field
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // ⚙️ App Preferences Section
            Text(
              'App Preferences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.grey.shade400 : Colors.blueGrey.shade800,
              ),
            ),
            const SizedBox(height: 10.0),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(color: _isDarkMode ? Colors.white10 : const Color(0xFFE9ECEF)),
              ),
              color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              child: Column(
                children: [
                  // 🌗 Dark Mode Toggle
                  SwitchListTile(
                    title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Toggle between light and dark theme'),
                    secondary: Icon(
                      _isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: Colors.amber.shade700,
                    ),
                    value: _isDarkMode,
                    activeColor: Colors.deepPurple.shade400,
                    onChanged: (bool value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                      // 💡 සටහන: මුළු ඇප් එකේම Theme එක මාරු කරන්න නම් Main.dart එකේ ThemeProvider එකක් හරහා මේ අගය Pass කරන්න ඕනේ.
                    },
                  ),
                  const Divider(height: 1),

                  // 💱 Currency Selection Dropdown
                  ListTile(
                    leading: const Icon(Icons.monetization_on_outlined, color: Colors.blue),
                    title: const Text('Primary Currency', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(_selectedCurrency),
                    trailing: DropdownButton<String>(
                      value: _selectedCurrency,
                      underline: const SizedBox(),
                      items: <String>['LKR (Rs.)', 'USD (\$)', 'EUR (€)', 'GBP (£)'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() => _selectedCurrency = newValue);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // 🔔 Notifications Toggle
                  SwitchListTile(
                    title: const Text('Bill Reminders & Alerts', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Get notified for upcoming bills'),
                    secondary: const Icon(Icons.notifications_active_outlined, color: Colors.green),
                    value: _notificationsEnabled,
                    activeColor: Colors.deepPurple.shade400,
                    onChanged: (bool value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // 💾 Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile Settings Saved Successfully! 💾'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                label: const Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDarkMode ? Colors.deepPurple.shade500 : Colors.deepPurple.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}