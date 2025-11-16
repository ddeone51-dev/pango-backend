import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/host_analytics_models.dart';
import '../../core/providers/host_analytics_provider.dart';

class HostAnalyticsScreen extends StatefulWidget {
  const HostAnalyticsScreen({super.key});

  @override
  State<HostAnalyticsScreen> createState() => _HostAnalyticsScreenState();
}

class _HostAnalyticsScreenState extends State<HostAnalyticsScreen> {
  final List<int> _ranges = [7, 30, 90];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HostAnalyticsProvider>().fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HostAnalyticsProvider>(
      builder: (context, provider, child) {
        final analytics = provider.analytics;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Host Analytics'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.isLoading ? null : () => provider.fetchAnalytics(),
              ),
            ],
          ),
          body: provider.isLoading && analytics == null
              ? const Center(child: CircularProgressIndicator())
              : analytics == null
                  ? _ErrorState(
                      message: provider.error ?? 'No analytics data available.',
                      onRetry: provider.isLoading ? null : () => provider.fetchAnalytics(),
                    )
                  : RefreshIndicator(
                      onRefresh: () => provider.fetchAnalytics(),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Performance overview',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                              DropdownButton<int>(
                                value: provider.rangeDays,
                                items: _ranges
                                    .map(
                                      (range) => DropdownMenuItem<int>(
                                        value: range,
                                        child: Text('$range days'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: provider.isLoading
                                    ? null
                                    : (value) {
                                        if (value != null) {
                                          provider.fetchAnalytics(range: value);
                                        }
                                      },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _MetricsGrid(analytics: analytics),
                          const SizedBox(height: 24),
                          _RevenueSummary(analytics: analytics),
                          const SizedBox(height: 24),
                          _TopListings(topListings: analytics.topListings),
                          const SizedBox(height: 24),
                          _MonthlyTrend(trend: analytics.monthlyTrend),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.analytics});

  final HostAnalyticsData analytics;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MetricCardData(
        title: 'Total bookings',
        value: analytics.totalBookings.toString(),
        icon: Icons.book_outlined,
        color: Colors.blue,
      ),
      _MetricCardData(
        title: 'Upcoming',
        value: analytics.upcomingBookings.toString(),
        icon: Icons.event_available,
        color: Colors.green,
      ),
      _MetricCardData(
        title: 'Completed',
        value: analytics.completedBookings.toString(),
        icon: Icons.check_circle_outline,
        color: Colors.teal,
      ),
      _MetricCardData(
        title: 'Cancelled',
        value: analytics.cancelledBookings.toString(),
        icon: Icons.cancel_outlined,
        color: Colors.red,
      ),
      _MetricCardData(
        title: 'Occupancy',
        value: '${analytics.occupancyRate.toStringAsFixed(1)}%',
        icon: Icons.hotel_class,
        color: Colors.orange,
      ),
      _MetricCardData(
        title: 'Average stay',
        value: '${analytics.averageStay.toStringAsFixed(1)} nights',
        icon: Icons.nights_stay,
        color: Colors.purple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) => _MetricCard(data: cards[index]),
    );
  }
}

class _MetricCardData {
  const _MetricCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricCardData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(data.icon, color: data.color),
            const Spacer(),
            Text(
              data.value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              data.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueSummary extends StatelessWidget {
  const _RevenueSummary({required this.analytics});

  final HostAnalyticsData analytics;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RevenueTile(
                    title: 'Total revenue',
                    amount: currencyFormat.format(analytics.totalRevenue),
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RevenueTile(
                    title: 'Last ${analytics.rangeDays} days',
                    amount: currencyFormat.format(analytics.rangeRevenue),
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueTile extends StatelessWidget {
  const _RevenueTile({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _TopListings extends StatelessWidget {
  const _TopListings({required this.topListings});

  final List<HostTopListing> topListings;

  @override
  Widget build(BuildContext context) {
    if (topListings.isEmpty) {
      return const _SectionCard(
        title: 'Top listings',
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No bookings yet.'),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ');

    return _SectionCard(
      title: 'Top listings',
      child: Column(
        children: topListings.map((listing) {
          return ListTile(
            leading: CircleAvatar(
              child: Text(listing.title.isNotEmpty ? listing.title[0].toUpperCase() : '?'),
            ),
            title: Text(listing.title),
            subtitle: Text('Bookings: ${listing.bookings}'),
            trailing: Text(
              currencyFormat.format(listing.revenue),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MonthlyTrend extends StatelessWidget {
  const _MonthlyTrend({required this.trend});

  final List<HostMonthlyTrend> trend;

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) {
      return const _SectionCard(
        title: 'Monthly performance',
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No booking activity in the selected range.'),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ');

    return _SectionCard(
      title: 'Monthly performance',
      child: Column(
        children: trend.map((item) {
          return ListTile(
            title: Text(item.label),
            subtitle: Text('Bookings: ${item.bookings}'),
            trailing: Text(currencyFormat.format(item.revenue)),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


