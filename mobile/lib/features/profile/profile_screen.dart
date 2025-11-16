import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/routes.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final localeProvider = context.watch<LocaleProvider>();

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.translate('profile')),
        ),
        body: const Center(
          child: Text('Please login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('profile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.editProfile);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      user.profile.firstName[0] + user.profile.lastName[0],
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(user.role.toUpperCase()),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Account Section
          _buildSectionTitle(context, 'Account'),
          _buildListTile(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              Navigator.of(context).pushNamed(Routes.editProfile);
            },
          ),
          _buildListTile(
            context,
            icon: Icons.verified_user_outlined,
            title: 'Verification',
            subtitle: user.isEmailVerified ? 'Verified' : 'Not verified',
            trailing: user.isEmailVerified
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.warning, color: Colors.orange),
          ),

          const SizedBox(height: 20),

          // Settings Section
          _buildSectionTitle(context, 'Settings'),
          _buildListTile(
            context,
            icon: Icons.language,
            title: 'Language',
            subtitle: localeProvider.locale.languageCode == 'sw' ? 'Kiswahili' : 'English',
            onTap: () => localeProvider.toggleLanguage(),
          ),
          _buildListTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              Navigator.of(context).pushNamed(Routes.notificationSettings);
            },
          ),
          _buildListTile(
            context,
            icon: Icons.lock_outline,
            title: 'Privacy & Security',
            onTap: () {
              Navigator.of(context).pushNamed(Routes.privacySecurity);
            },
          ),

          const SizedBox(height: 20),

          // Host Section
          if (user.role == 'host' || user.role == 'admin') ...[
            _buildSectionTitle(context, 'Hosting'),
            _buildListTile(
              context,
              icon: Icons.dashboard_outlined,
              title: l10n.translate('host_dashboard'),
              onTap: () {
                Navigator.of(context).pushNamed(Routes.hostDashboard);
              },
            ),
            _buildListTile(
              context,
              icon: Icons.add_home_outlined,
              title: l10n.translate('add_listing'),
              onTap: () {
                Navigator.of(context).pushNamed(Routes.addListing);
              },
            ),
          ] else ...[
            _buildSectionTitle(context, 'Become a Host'),
            Card(
              child: ListTile(
                leading: Icon(Icons.home_work, color: Theme.of(context).primaryColor),
                title: const Text('List your property'),
                subtitle: const Text('Start earning by hosting guests'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Switch to host
                },
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Support Section
          _buildSectionTitle(context, 'Support'),
          _buildListTile(
            context,
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.info_outline,
            title: 'About Homia',
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // Logout
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                l10n.translate('logout'),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await authProvider.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.login,
                  (route) => false,
                );
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}




















