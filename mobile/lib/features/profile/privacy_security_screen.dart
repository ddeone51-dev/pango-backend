import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/config/routes.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _privacySettings;
  bool _loadingPrivacy = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    setState(() => _loadingPrivacy = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get('/users/privacy-settings');
      if (response.data['success'] == true) {
        setState(() {
          _privacySettings = response.data['data'];
        });
      }
    } catch (e) {
      print('Failed to load privacy settings: $e');
      // Set defaults if load fails
      setState(() {
        _privacySettings = {
          'profileVisibility': true,
          'locationSharing': false,
          'analyticsTracking': true,
        };
      });
    } finally {
      if (mounted) {
        setState(() => _loadingPrivacy = false);
      }
    }
  }

  Future<void> _updatePrivacySetting(String key, bool value) async {
    try {
      final apiService = context.read<ApiService>();
      final updateData = <String, dynamic>{};
      updateData[key] = value;
      final response = await apiService.put('/users/privacy-settings', data: updateData);

      if (response.data['success'] == true) {
        setState(() {
          _privacySettings = response.data['data'];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Privacy setting updated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update setting: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.security, size: 48, color: Colors.blue.shade700),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Security',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your account security and privacy settings',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Account Verification Section
          _buildSectionTitle('Account Verification'),
          _buildCard(
            child: Column(
              children: [
                _buildVerificationItem(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email Verification',
                  isVerified: user?.isEmailVerified ?? false,
                  onTap: user?.isEmailVerified == false
                      ? () => _showVerificationDialog(context, 'email')
                      : null,
                ),
                const Divider(),
                _buildVerificationItem(
                  context,
                  icon: Icons.phone_outlined,
                  title: 'Phone Verification',
                  isVerified: user?.isPhoneVerified ?? false,
                  onTap: user?.isPhoneVerified == false
                      ? () => _showVerificationDialog(context, 'phone')
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Password Section
          _buildSectionTitle('Password'),
          _buildCard(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              subtitle: const Text('Update your password regularly'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showChangePasswordDialog(context),
            ),
          ),

          const SizedBox(height: 24),

          // Privacy Settings Section
          _buildSectionTitle('Privacy Settings'),
          _buildCard(
            child: _loadingPrivacy
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.visibility_outlined),
                        title: const Text('Profile Visibility'),
                        subtitle: const Text('Allow others to see your profile'),
                        value: _privacySettings?['profileVisibility'] ?? true,
                        onChanged: (value) {
                          _updatePrivacySetting('profileVisibility', value);
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        secondary: const Icon(Icons.location_on_outlined),
                        title: const Text('Location Sharing'),
                        subtitle: const Text('Share your location for better recommendations'),
                        value: _privacySettings?['locationSharing'] ?? false,
                        onChanged: (value) {
                          _updatePrivacySetting('locationSharing', value);
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        secondary: const Icon(Icons.analytics_outlined),
                        title: const Text('Analytics & Tracking'),
                        subtitle: const Text('Help us improve by sharing usage data'),
                        value: _privacySettings?['analyticsTracking'] ?? true,
                        onChanged: (value) {
                          _updatePrivacySetting('analyticsTracking', value);
                        },
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 24),

          // Session Management Section
          _buildSectionTitle('Active Sessions'),
          _buildCard(
            child: ListTile(
              leading: const Icon(Icons.devices_outlined),
              title: const Text('Manage Devices'),
              subtitle: const Text('View and manage active sessions'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showActiveSessions(context),
            ),
          ),

          const SizedBox(height: 24),

          // Data Management Section
          _buildSectionTitle('Data Management'),
          _buildCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Download Your Data'),
                  subtitle: const Text('Get a copy of your account data'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _downloadUserData(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Permanently delete your account and all data'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Security Activity Section
          _buildSectionTitle('Security Activity'),
          _buildCard(
            child: ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text('Recent Activity'),
              subtitle: const Text('View your recent login activity'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showSecurityActivity(context),
            ),
          ),

          const SizedBox(height: 32),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'For additional security, we recommend enabling two-factor authentication and using a strong, unique password.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      child: child,
    );
  }

  Widget _buildVerificationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isVerified,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(isVerified ? 'Verified' : 'Not verified'),
      trailing: isVerified
          ? const Icon(Icons.check_circle, color: Colors.green)
          : TextButton(
              onPressed: onTap,
              child: const Text('Verify'),
            ),
    );
  }

  void _showVerificationDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verify ${type == 'email' ? 'Email' : 'Phone'}'),
        content: Text(
          type == 'email'
              ? 'A verification code will be sent to your email address.'
              : 'A verification code will be sent to your phone number.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement verification logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification code sent!')),
              );
            },
            child: const Text('Send Code'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters')),
                );
                return;
              }

              setState(() => _isLoading = true);
              try {
                final apiService = context.read<ApiService>();
                final response = await apiService.put('/users/change-password', data: {
                  'currentPassword': oldPasswordController.text,
                  'newPassword': newPasswordController.text,
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  if (response.data['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response.data['message'] ?? 'Failed to change password'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Sessions'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.phone_android),
                title: Text('This Device'),
                subtitle: Text('Android • Last active: Now'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.phone_iphone),
                title: Text('iPhone 12'),
                subtitle: Text('iOS • Last active: 2 hours ago'),
                trailing: IconButton(
                  icon: Icon(Icons.logout, color: Colors.red),
                  onPressed: null,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logoutFromAllDevices(context);
            },
            child: const Text('Logout All Devices', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _logoutFromAllDevices(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout from All Devices'),
        content: const Text(
          'This will log you out from all devices except this one. You will need to log in again on other devices.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement logout from all devices
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out from all devices')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout All'),
          ),
        ],
      ),
    );
  }

  void _downloadUserData(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get('/users/download-data');

      if (context.mounted) {
        if (response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data download link sent to your email'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to initiate data download'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This action cannot be undone. This will permanently delete your account and all associated data.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('To confirm, type "DELETE" below:'),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Type DELETE to confirm',
                ),
                onChanged: (value) {
                  setDialogState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: confirmController.text == 'DELETE'
                  ? () async {
                      Navigator.pop(context);
                      await _deleteAccount(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'Are you absolutely sure? This will permanently delete your account, all your listings, bookings, and data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Delete My Account'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.delete('/users/account');

      if (context.mounted) {
        if (response.data['success'] == true) {
          final authProvider = context.read<AuthProvider>();
          await authProvider.logout();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.login,
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your account has been deleted'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Failed to delete account'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSecurityActivity(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get('/users/security-activity');
      
      if (!mounted) return;
      
      final activities = response.data['success'] == true 
          ? (response.data['data'] as List)
          : [];

      setState(() => _isLoading = false);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Recent Security Activity'),
          content: SingleChildScrollView(
            child: activities.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No recent activity'),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: activities.map<Widget>((activity) {
                      IconData icon;
                      Color iconColor;
                      switch (activity['type']) {
                        case 'login':
                          icon = Icons.login;
                          iconColor = Colors.green;
                          break;
                        case 'password_changed':
                          icon = Icons.lock_reset;
                          iconColor = Colors.orange;
                          break;
                        case 'email_verified':
                          icon = Icons.email;
                          iconColor = Colors.blue;
                          break;
                        default:
                          icon = Icons.info;
                          iconColor = Colors.grey;
                      }

                      final timestamp = activity['timestamp'] != null
                          ? DateTime.parse(activity['timestamp'])
                          : DateTime.now();
                      final timeAgo = _formatTimeAgo(timestamp);

                      return Column(
                        children: [
                          ListTile(
                            leading: Icon(icon, color: iconColor),
                            title: Text(activity['description'] ?? 'Activity'),
                            subtitle: Text(
                              '${activity['device'] ?? 'Unknown Device'}\n$timeAgo',
                            ),
                          ),
                          if (activities.indexOf(activity) < activities.length - 1)
                            const Divider(),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load activity: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

