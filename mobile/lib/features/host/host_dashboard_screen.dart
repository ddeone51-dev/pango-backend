import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/routes.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/host_analytics_provider.dart';

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HostAnalyticsProvider>().fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();
    final hasPayoutSettings = authProvider.hasPayoutSettings;

    if (!authProvider.isHostApproved) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.translate('host_dashboard')),
        ),
        body: const _HostNotApprovedState(),
      );
    }

    return Consumer<HostAnalyticsProvider>(
      builder: (context, analyticsProvider, child) {
        final analytics = analyticsProvider.analytics;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.translate('host_dashboard')),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: analyticsProvider.isLoading ? null : () => analyticsProvider.fetchAnalytics(),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!hasPayoutSettings) ...[
                _buildPayoutAlert(context),
                const SizedBox(height: 16),
              ] else if (hasPayoutSettings) ...[
                _buildPayoutUpdateCard(context, authProvider),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.home_outlined,
                      title: 'Listings',
                      value: analytics?.topListings.length.toString() ?? '-',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.book_outlined,
                      title: 'Bookings',
                      value: analytics?.totalBookings.toString() ?? '-',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.percent,
                      title: 'Occupancy',
                      value: analytics != null
                          ? '${analytics.occupancyRate.toStringAsFixed(1)}%'
                          : '-',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.attach_money,
                      title: l10n.translate('earnings'),
                      value: analytics != null
                          ? 'TZS ${analytics.totalRevenue.toStringAsFixed(0)}'
                          : '-',
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              if (analyticsProvider.isLoading)
                const LinearProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                context,
                icon: Icons.add_home,
                title: l10n.translate('add_listing'),
                subtitle: 'List your property on Homia',
                color: Theme.of(context).primaryColor,
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.addListing);
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.list_alt,
                title: l10n.translate('my_listings'),
                subtitle: 'Manage your properties',
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.hostListings);
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.calendar_month,
                title: 'Calendar',
                subtitle: 'Manage availability',
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.hostCalendar);
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.assessment,
                title: 'Analytics',
                subtitle: 'View performance insights',
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.hostAnalytics);
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.account_balance_wallet,
                title: 'Payout settings',
                subtitle: hasPayoutSettings
                    ? 'Update your bank or mobile money details'
                    : 'Add payout details to receive earnings',
                color: hasPayoutSettings ? null : Colors.orange,
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.hostPayoutSettings);
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Bookings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const _RecentBookingsPlaceholder(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
          child: Icon(icon, color: color ?? Theme.of(context).primaryColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPayoutAlert(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Add payout details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'We can only send your earnings after you add a bank account or mobile money number.',
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pushNamed(Routes.hostPayoutSettings),
                child: const Text('Add payout method'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutUpdateCard(BuildContext context, AuthProvider authProvider) {
    final payoutSettings = authProvider.user?.payoutSettings;
    final canUpdate = payoutSettings?.canUpdate ?? true;
    final daysUntilNextUpdate = payoutSettings?.daysUntilNextUpdate ?? 0;
    final verified = payoutSettings?.verified ?? false;
    final method = payoutSettings?.method;
    
    return Card(
      color: verified ? Colors.green.shade50 : Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  verified ? Icons.check_circle : Icons.info_outline,
                  color: verified ? Colors.green.shade700 : Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    verified ? 'Payout details verified' : 'Payout details pending verification',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: verified ? Colors.green.shade800 : Colors.blue.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              method == 'bank_account' 
                ? 'Bank Account: ${payoutSettings?.bankAccount?.bankName ?? 'N/A'}'
                : 'Mobile Money: ${payoutSettings?.mobileMoney?.provider?.toUpperCase() ?? 'N/A'}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            if (!canUpdate && daysUntilNextUpdate > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can update payout details in ${daysUntilNextUpdate.toStringAsFixed(1)} day(s) for security reasons.',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: canUpdate
                    ? () => Navigator.of(context).pushNamed(Routes.hostPayoutSettings)
                    : null,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Update payout details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostNotApprovedState extends StatelessWidget {
  const _HostNotApprovedState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_top, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Waiting for host approval',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Once your host request is approved, you will gain access to the host dashboard and tools.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentBookingsPlaceholder extends StatelessWidget {
  const _RecentBookingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No bookings yet',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




















