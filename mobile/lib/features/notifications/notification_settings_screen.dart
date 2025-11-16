import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/notification_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final prefs = provider.preferences;

          return ListView(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notifications_active, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Stay Updated',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose how you want to receive notifications from Homia',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Push Notifications
              _buildSettingSection(
                context: context,
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Get notifications on your device',
                value: prefs.push,
                onChanged: (value) async {
                  final success = await provider.updatePreferences(push: value);
                  if (!mounted) return;
                  
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update settings'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),

              if (prefs.push) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildSubSetting(
                        'Booking Updates',
                        'Confirmations, cancellations, and reminders',
                        true,
                      ),
                      _buildSubSetting(
                        'Reviews',
                        'New reviews and host responses',
                        true,
                      ),
                      _buildSubSetting(
                        'Payments',
                        'Payment confirmations and receipts',
                        true,
                      ),
                      _buildSubSetting(
                        'Promotions',
                        'Special offers and discounts',
                        true,
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 32),

              // Email Notifications
              _buildSettingSection(
                context: context,
                icon: Icons.email,
                title: 'Email Notifications',
                subtitle: 'Receive updates via email',
                value: prefs.email,
                onChanged: (value) async {
                  final success = await provider.updatePreferences(email: value);
                  if (!mounted) return;
                  
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update settings'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),

              const Divider(height: 32),

              // SMS Notifications
              _buildSettingSection(
                context: context,
                icon: Icons.sms,
                title: 'SMS Notifications',
                subtitle: 'Important updates via text message',
                value: prefs.sms,
                onChanged: (value) async {
                  final success = await provider.updatePreferences(sms: value);
                  if (!mounted) return;
                  
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update settings'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 32),

              // Test Notification Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final success = await provider.sendTestNotification();
                    if (!mounted) return;
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Test notification sent! Check your notifications.'
                              : 'Failed to send test notification',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Send Test Notification'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Info Card
              Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You can change these settings anytime. Some notifications may be sent regardless to keep you informed about important updates.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade900,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildSubSetting(String title, String subtitle, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: enabled ? Colors.green : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}

