import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/models/listing.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/config/routes.dart';
import '../../core/services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final Listing listing;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guests;

  const BookingScreen({
    super.key,
    required this.listing,
    this.checkIn,
    this.checkOut,
    this.guests = 1,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime _checkIn;
  late DateTime _checkOut;
  late int _guests;
  // ZenoPay is the only payment method
  final Set<DateTime> _bookedDays = <DateTime>{};
  bool _loadingBooked = false;

  @override
  void initState() {
    super.initState();
    _checkIn = widget.checkIn ?? DateTime.now().add(const Duration(days: 1));
    _checkOut = widget.checkOut ?? DateTime.now().add(const Duration(days: 2));
    _guests = widget.guests;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBookedDates());
  }

  @override
  void dispose() {
    super.dispose();
  }

  int get numberOfNights => _checkOut.difference(_checkIn).inDays;

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _loadBookedDates() async {
    try {
      setState(() => _loadingBooked = true);
      final api = context.read<ApiService>();
      final res = await api.get('/listings/${widget.listing.id}/booked-dates');
      if (res.data['success'] == true) {
        final List ranges = res.data['data'] as List;
        final Set<DateTime> days = {};
        for (final r in ranges) {
          final DateTime start = DateTime.parse(r['start']).toLocal();
          final DateTime end = DateTime.parse(r['end']).toLocal();
          DateTime d = _normalize(start);
          final DateTime last = _normalize(end.subtract(const Duration(days: 1)));
          while (!d.isAfter(last)) {
            days.add(_normalize(d));
            d = d.add(const Duration(days: 1));
          }
        }
        setState(() {
          _bookedDays
            ..clear()
            ..addAll(days);
        });
      }
    } catch (_) {}
    finally {
      if (mounted) setState(() => _loadingBooked = false);
    }
  }

  double get subtotal => widget.listing.pricing.basePrice * numberOfNights;

  double get total =>
      subtotal +
      widget.listing.pricing.cleaningFee +
      (subtotal * 0.1) + // Service fee
      (subtotal * 0.18); // Tax

  // Show interactive calendar picker
  Future<void> _showCalendarPicker() async {
    DateTime? selectedCheckIn;
    DateTime? selectedCheckOut;
    DateTime focusedDay = _checkIn;
    CalendarFormat calendarFormat = CalendarFormat.month;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Dates',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Calendar
                Expanded(
                  child: SingleChildScrollView(
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: focusedDay,
                      calendarFormat: calendarFormat,
                      enabledDayPredicate: (day) => !_bookedDays.contains(DateTime(day.year, day.month, day.day)),
                      selectedDayPredicate: (day) {
                        return (selectedCheckIn != null && isSameDay(selectedCheckIn, day)) ||
                               (selectedCheckOut != null && isSameDay(selectedCheckOut, day));
                      },
                      rangeStartDay: selectedCheckIn,
                      rangeEndDay: selectedCheckOut,
                      rangeSelectionMode: RangeSelectionMode.enforced,
                      onDaySelected: (selectedDay, focused) {
                        setModalState(() {
                          final dNorm = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                          if (_bookedDays.contains(dNorm)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Date unavailable. Please choose another date.')),
                            );
                            return;
                          }
                          if (selectedCheckIn == null || (selectedCheckIn != null && selectedCheckOut != null)) {
                            // First selection or resetting
                            selectedCheckIn = selectedDay;
                            selectedCheckOut = null;
                            focusedDay = selectedDay;
                          } else if (selectedCheckIn != null && selectedCheckOut == null) {
                            // Second selection
                            if (selectedDay.isAfter(selectedCheckIn!)) {
                              // Reject if range includes any booked day
                              bool hasBlocked = false;
                              DateTime d = DateTime(selectedCheckIn!.year, selectedCheckIn!.month, selectedCheckIn!.day);
                              final DateTime last = DateTime(selectedDay.year, selectedDay.month, selectedDay.day).subtract(const Duration(days: 1));
                              while (!d.isAfter(last)) {
                                if (_bookedDays.contains(d)) { hasBlocked = true; break; }
                                d = d.add(const Duration(days: 1));
                              }
                              if (hasBlocked) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Selected range includes unavailable dates.')),
                                );
                              } else {
                              selectedCheckOut = selectedDay;
                              }
                            } else {
                              // If selected date is before check-in, swap them
                              selectedCheckOut = selectedCheckIn;
                              selectedCheckIn = selectedDay;
                            }
                          }
                        });
                      },
                      onFormatChanged: (format) {
                        setModalState(() {
                          calendarFormat = format;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        rangeStartDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        rangeEndDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        rangeHighlightColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        withinRangeDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        disabledTextStyle: const TextStyle(color: Colors.red),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                  ),
                ),
                
                // Selected Dates Info & Confirm Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Check-in', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                selectedCheckIn != null 
                                    ? '${selectedCheckIn!.day}/${selectedCheckIn!.month}'
                                    : 'Select',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.grey),
                          Column(
                            children: [
                              const Text('Check-out', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                selectedCheckOut != null 
                                    ? '${selectedCheckOut!.day}/${selectedCheckOut!.month}'
                                    : 'Select',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (selectedCheckIn != null && selectedCheckOut != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${selectedCheckOut!.difference(selectedCheckIn!).inDays} nights stay',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: selectedCheckIn != null && selectedCheckOut != null
                              ? () {
                                  setState(() {
                                    _checkIn = selectedCheckIn!;
                                    _checkOut = selectedCheckOut!;
                                  });
                                  Navigator.pop(context);
                                }
                              : null,
                          icon: const Icon(Icons.check),
                          label: const Text('Confirm Dates', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
        },
      ),
    );
  }

  Future<void> _confirmBooking() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) return;
    
    // Prompt for phone number to be charged
    final enteredPhone = await _promptPhoneNumber(initial: user.phoneNumber);
    if (!mounted) return;
    if (enteredPhone == null) {
      return; // cancelled
    }
    final normalizedPhone = _normalizeLocalTzPhone(enteredPhone);
    if (normalizedPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid Tanzanian phone (07XXXXXXXX).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Immediately navigate to awaiting screen, then process in background
    Navigator.of(context).pushReplacementNamed(
      Routes.bookingConfirmation,
      arguments: '', // no id yet; screen listens to provider updates
    );

    // Create booking (payment initiation will use this phone) in background
    final bookingProvider = context.read<BookingProvider>();
    // ignore: unawaited_futures
    bookingProvider.createBooking(
      listingId: widget.listing.id,
      checkInDate: _checkIn,
      checkOutDate: _checkOut,
      numberOfGuests: _guests,
      guestDetails: {
        'fullName': user.fullName,
        'phoneNumber': normalizedPhone,
        'email': user.email,
        'numberOfAdults': _guests,
        'numberOfChildren': 0,
      },
      totalAmount: total,
      phoneNumber: normalizedPhone,
    );
  }

  // Dialog to prompt for phone number
  Future<String?> _promptPhoneNumber({String? initial}) async {
    final controller = TextEditingController(text: initial ?? '');
    String? errorText;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Enter payment phone'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '07XXXXXXXX',
                        errorText: errorText,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final raw = controller.text.trim();
                    final normalized = _normalizeLocalTzPhone(raw);
                    if (normalized == null) {
                      setState(() => errorText = 'Use format 07XXXXXXXX');
                      return;
                    }
                    Navigator.pop(ctx, normalized);
                  },
                  child: const Text('Use this number'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Normalize +2557XXXXXXXX to 07XXXXXXXX and validate simple TZ format
  String? _normalizeLocalTzPhone(String input) {
    var p = input.replaceAll(' ', '');
    if (p.startsWith('+255')) p = p.replaceFirst('+255', '0');
    if (p.length == 10 && p.startsWith('0')) return p;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: Text(l10n.translate('confirm_booking')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dates
            Text(
              'Booking Dates',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Date Display Row - Tap to open calendar
                    InkWell(
                      onTap: _showCalendarPicker,
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Check-in', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  '${_checkIn.day}/${_checkIn.month}/${_checkIn.year}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.grey),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Check-out', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  '${_checkOut.day}/${_checkOut.month}/${_checkOut.year}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.edit_calendar, color: Theme.of(context).primaryColor),
                        ],
                      ),
                    ),
                    const Divider(height: 24),
                    // Nights Counter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.nights_stay, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '$numberOfNights ${numberOfNights == 1 ? 'night' : 'nights'}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Guests
            Text(
              l10n.translate('guests'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.people),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Number of guests',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _guests > 1
                          ? () => setState(() => _guests--)
                          : null,
                    ),
                    Text(
                      '$_guests',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _guests < widget.listing.capacity.guests
                          ? () => setState(() => _guests++)
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Payment Method
            Text(
              l10n.translate('payment_method'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            
            // Mobile money selection (logos + pay option) in one background block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE00211),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE00211)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logos row
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _logo('assets/images/mpesa.png', 'M-Pesa'),
                        _logo('assets/images/airtel.png', 'Airtel'),
                        _logo('assets/images/yas.png', 'Yas'),
                        _logo('assets/images/halopesa.png', 'Halopesa'),
                      ],
                    ),
                  ),

                  // Pay with Mobile tile
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2E7D32), width: 2),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.smartphone, color: Colors.white, size: 20),
                      ),
                      title: const Text('Pay with Mobile', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Secure payment processing', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Pay with Card option
            Card(
              elevation: 2,
              color: const Color(0xFF4B3BBF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.credit_card, color: Color(0xFF4B3BBF), size: 20),
                ),
                title: const Text(
                  'Pay with Card',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                subtitle: const Text(
                  'Visa, MasterCard and more',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                trailing: const Icon(Icons.radio_button_unchecked, color: Colors.white70),
              ),
            ),
            

            const SizedBox(height: 24),

            // Price Breakdown
            Text(
              'Price Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPriceRow(
                      '${CurrencyFormatter.format(widget.listing.pricing.basePrice)} x $numberOfNights nights',
                      CurrencyFormatter.format(subtotal),
                    ),
                    const Divider(height: 24),
                    _buildPriceRow(
                      l10n.translate('cleaning_fee'),
                      CurrencyFormatter.format(widget.listing.pricing.cleaningFee),
                    ),
                    _buildPriceRow(
                      l10n.translate('service_fee'),
                      CurrencyFormatter.format(subtotal * 0.1),
                    ),
                    _buildPriceRow(
                      l10n.translate('taxes'),
                      CurrencyFormatter.format(subtotal * 0.18),
                    ),
                    const Divider(height: 24),
                    _buildPriceRow(
                      l10n.translate('total'),
                      CurrencyFormatter.format(total),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: bookingProvider.isLoading ? null : _confirmBooking,
                child: bookingProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(l10n.translate('confirm_booking')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : null,
          ),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    )
                : Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _logo(String assetPath, String semantic) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        assetPath,
        height: 22,
        width: 22,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        semanticLabel: semantic,
      ),
    );
  }
}


