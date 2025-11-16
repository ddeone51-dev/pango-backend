import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/models/host_calendar_models.dart';
import '../../core/providers/host_calendar_provider.dart';

class HostCalendarScreen extends StatefulWidget {
  const HostCalendarScreen({super.key});

  @override
  State<HostCalendarScreen> createState() => _HostCalendarScreenState();
}

class _HostCalendarScreenState extends State<HostCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String? _selectedListingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HostCalendarProvider>().fetchCalendar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HostCalendarProvider>(
      builder: (context, provider, child) {
        final listings = provider.listings;
        final selectedListing = _getSelectedListing(listings);
        final eventsForDay = _getEventsForDay(selectedListing, _selectedDay);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Calendar & Availability'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.isLoading ? null : () => provider.fetchCalendar(),
              ),
            ],
          ),
          body: provider.isLoading && listings.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : listings.isEmpty
                  ? const _EmptyState()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: DropdownButtonFormField<String>(
                            value: selectedListing?.listingId,
                            decoration: const InputDecoration(
                              labelText: 'Listing',
                              border: OutlineInputBorder(),
                            ),
                            items: listings
                                .map(
                                  (listing) => DropdownMenuItem<String>(
                                    value: listing.listingId,
                                    child: Text(
                                      listing.title,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedListingId = value;
                              });
                            },
                          ),
                        ),
                        if (selectedListing == null)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Select a listing to view availability.'),
                          )
                        else ...[
                          _CalendarHeader(
                            listing: selectedListing,
                            onBlockDates: () => _onBlockDates(selectedListing),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildCalendar(selectedListing),
                                  _EventsList(
                                    date: _selectedDay,
                                    events: eventsForDay,
                                    onRemoveBlocked: (event) => _removeBlockedDate(selectedListing, event),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
        );
      },
    );
  }

  HostCalendarListing? _getSelectedListing(List<HostCalendarListing> listings) {
    if (listings.isEmpty) return null;
    if (_selectedListingId != null) {
      return listings.firstWhere(
        (listing) => listing.listingId == _selectedListingId,
        orElse: () => listings.first,
      );
    }
    return listings.first;
  }

  Widget _buildCalendar(HostCalendarListing listing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TableCalendar<HostCalendarEvent>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2040, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: (day) => _getEventsForDay(listing, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;
            return Align(
              alignment: Alignment.bottomCenter,
              child: Wrap(
                spacing: 2,
                children: events.take(3).map((event) {
                  final color = event.type == HostCalendarEventType.booking
                      ? Colors.green
                      : Colors.grey;
                  return Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  List<HostCalendarEvent> _getEventsForDay(HostCalendarListing? listing, DateTime day) {
    if (listing == null) return [];
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final events = <HostCalendarEvent>[];

    for (final booking in listing.bookings) {
      if (booking.end.isAfter(dayStart) && booking.start.isBefore(dayEnd)) {
        events.add(
          HostCalendarEvent(
            id: booking.id,
            start: booking.start,
            end: booking.end,
            type: HostCalendarEventType.booking,
            status: booking.status,
            guestName: booking.guestName,
            guestEmail: booking.guestEmail,
            guestPhone: booking.guestPhone,
          ),
        );
      }
    }

    for (final block in listing.blockedDates) {
      if (block.end.isAfter(dayStart) && block.start.isBefore(dayEnd)) {
        events.add(
          HostCalendarEvent(
            id: block.id,
            start: block.start,
            end: block.end,
            type: HostCalendarEventType.blocked,
            reason: block.reason,
          ),
        );
      }
    }

    return events;
  }

  Future<void> _onBlockDates(HostCalendarListing listing) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 1)),
      ),
    );

    if (range == null) return;

    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block availability'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Block dates'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final provider = context.read<HostCalendarProvider>();
    final success = await provider.blockDateRange(
      listingId: listing.listingId,
      start: range.start,
      end: range.end,
      reason: reasonController.text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Dates blocked successfully' : provider.error ?? 'Failed to block dates'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _removeBlockedDate(HostCalendarListing listing, HostCalendarEvent event) async {
    if (event.type != HostCalendarEventType.blocked) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove blocked dates'),
        content: const Text('Do you want to remove this blocked date range?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final provider = context.read<HostCalendarProvider>();
    final success = await provider.unblockDate(
      listingId: listing.listingId,
      blockId: event.id,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Blocked dates removed' : provider.error ?? 'Failed to remove blocked dates'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.listing,
    required this.onBlockDates,
  });

  final HostCalendarListing listing;
  final VoidCallback onBlockDates;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                listing.location.isNotEmpty ? listing.location : 'Location not set',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(listing.instantBooking ? 'Instant booking on' : 'Manual approval'),
                    backgroundColor: listing.instantBooking ? Colors.green.shade50 : Colors.orange.shade50,
                    labelStyle: TextStyle(
                      color: listing.instantBooking ? Colors.green.shade800 : Colors.orange.shade800,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: onBlockDates,
                    icon: const Icon(Icons.block),
                    label: const Text('Block dates'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({
    required this.date,
    required this.events,
    required this.onRemoveBlocked,
  });

  final DateTime date;
  final List<HostCalendarEvent> events;
  final ValueChanged<HostCalendarEvent> onRemoveBlocked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Events on ${_formatDate(date)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (events.isNotEmpty)
                Text(
                  '${events.length} item${events.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (events.isEmpty)
            const Text('No bookings or blocked dates on this day.')
          else
            ...events.map((event) {
              final color = event.type == HostCalendarEventType.booking ? Colors.green : Colors.grey;
              final title = event.type == HostCalendarEventType.booking
                  ? 'Booking (${event.status})'
                  : 'Blocked';
              final subtitle = event.type == HostCalendarEventType.booking
                  ? [
                      event.guestName,
                      if (event.guestEmail != null) event.guestEmail,
                      if (event.guestPhone != null) event.guestPhone,
                      _formatRange(event.start, event.end),
                    ].whereType<String>().join('\n')
                  : [
                      event.reason ?? 'No reason provided',
                      _formatRange(event.start, event.end),
                    ].join('\n');

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(
                      event.type == HostCalendarEventType.booking ? Icons.event_available : Icons.block,
                      color: color,
                    ),
                  ),
                  title: Text(title),
                  subtitle: Text(subtitle),
                  isThreeLine: true,
                  trailing: event.type == HostCalendarEventType.blocked
                      ? IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          onPressed: () => onRemoveBlocked(event),
                        )
                      : null,
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatRange(DateTime start, DateTime end) {
    final startStr = _formatDate(start);
    final endStr = _formatDate(end.subtract(const Duration(seconds: 1)));
    return '$startStr → $endStr';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No listings found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add a listing first, then you can manage availability from here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}



