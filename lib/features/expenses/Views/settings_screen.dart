import 'package:flutter/material.dart';
import '../../../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController(text: "Ann Sayuri");
  final TextEditingController _emailController = TextEditingController(text: "ann@example.com");
  
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
    // 🌗 දැනට මුළු ඇප් එකේම Dark Mode එක On ද නැද්ද කියලා මෙතනින් හඳුනා ගන්නවා
    final bool isDark = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Settings & Profile ⚙️', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade700,
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
                side: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE9ECEF)),
              ),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.deepPurple,
                      child: Text('AS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Name Input Field
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                        prefixIcon: Icon(Icons.person_outline, color: isDark ? Colors.white70 : Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: isDark ? Colors.white30 : Colors.grey.shade400),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    
                    // Email Input Field
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                        prefixIcon: Icon(Icons.email_outlined, color: isDark ? Colors.white70 : Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: isDark ? Colors.white30 : Colors.grey.shade400),
                        ),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade800),
            ),
            const SizedBox(height: 10.0),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE9ECEF)),
              ),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: Column(
                children: [
                  // 🌗 Dark Mode Toggle Switch
                  SwitchListTile(
                    title: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                    subtitle: Text('Toggle between light and dark theme', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                    secondary: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: Colors.amber.shade700,
                    ),
                    value: isDark,
                    activeColor: Colors.deepPurple.shade400,
                    onChanged: (bool value) {
                      setState(() {
                        // 👈 මෙන්න මෙතනින් මුළු ඇප් එකේම තේමාව වෙනස් කරන Global Notifier එක Update කරනවා
                        themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                      });
                    },
                  ),
                  Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),

                  // 💱 Currency Selection Dropdown
                  ListTile(
                    leading: const Icon(Icons.monetization_on_outlined, color: Colors.blue),
                    title: Text('Primary Currency', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                    subtitle: Text(_selectedCurrency, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                    trailing: DropdownButton<String>(
                      value: _selectedCurrency,
                      dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                      underline: const SizedBox(),
                      iconEnabledColor: isDark ? Colors.white : Colors.black,
                      items: <String>['LKR (Rs.)', 'USD (\$)', 'EUR (€)', 'GBP (£)'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() => _selectedCurrency = newValue);
                        }
                      },
                    ),
                  ),
                  Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),

                  // 🔔 Notifications Toggle
                  SwitchListTile(
                    title: Text('Bill Reminders & Alerts', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                    subtitle: Text('Get notified for upcoming bills', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
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
                    const SnackBar(content: Text('Profile Settings Saved Successfully! 💾'), backgroundColor: Colors.green),
                  );
                },
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                label: const Text('Save Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.deepPurple.shade500 : Colors.deepPurple.shade700,
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