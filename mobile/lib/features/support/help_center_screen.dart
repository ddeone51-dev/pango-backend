import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/l10n/app_localizations.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isLoading = false;

  final List<FAQCategory> _categories = [
    FAQCategory(
      id: 'getting-started',
      title: 'Getting Started',
      titleSw: 'Kuanza',
      icon: Icons.rocket_launch,
      faqs: [
        FAQ(
          question: 'How do I create an account?',
          questionSw: 'Ninawezaje kuunda akaunti?',
          answer: 'To create an account, tap on "Register" from the login screen. Enter your email or phone number, create a password, and provide your name. You\'ll receive a verification code to complete registration.',
          answerSw: 'Ili kuunda akaunti, bofya "Jisajili" kutoka skrini ya kuingia. Ingiza barua pepe au nambari ya simu, unda neno la siri, na toa jina lako. Utapokea nambari ya uthibitishaji ili kukamilisha usajili.',
        ),
        FAQ(
          question: 'How do I book a property?',
          questionSw: 'Ninawezaje kuhifadhi mali?',
          answer: 'Browse available properties, select your dates and number of guests, then tap "Book Now". Complete the payment process and you\'ll receive a confirmation.',
          answerSw: 'Vinjari mali zinazopatikana, chagua tarehe zako na idadi ya wageni, kisha bofya "Hifadhi Sasa". Kamilisha mchakato wa malipo na utapokea uthibitishaji.',
        ),
        FAQ(
          question: 'What payment methods are accepted?',
          questionSw: 'Njia gani za malipo zinakubalika?',
          answer: 'We accept M-Pesa, Tigo Pesa, Airtel Money, and other mobile money services. All payments are secure and processed instantly.',
          answerSw: 'Tunakubali M-Pesa, Tigo Pesa, Airtel Money, na huduma zingine za pesa za simu. Malipo yote ni salama na yanachakatwa mara moja.',
        ),
      ],
    ),
    FAQCategory(
      id: 'bookings',
      title: 'Bookings',
      titleSw: 'Uhifadhi',
      icon: Icons.calendar_today,
      faqs: [
        FAQ(
          question: 'Can I cancel my booking?',
          questionSw: 'Naweza kufuta uhifadhi wangu?',
          answer: 'Yes, you can cancel your booking from the Bookings section. Cancellation policies vary by property. Check the property details for specific cancellation terms.',
          answerSw: 'Ndio, unaweza kufuta uhifadhi wako kutoka sehemu ya Uhifadhi. Sera za kufuta hutofautiana kulingana na mali. Angalia maelezo ya mali kwa masharti maalum ya kufuta.',
        ),
        FAQ(
          question: 'How do I modify my booking?',
          questionSw: 'Ninawezaje kubadilisha uhifadhi wangu?',
          answer: 'To modify your booking, go to the Bookings section, select your booking, and tap "Modify". You can change dates or number of guests, subject to availability.',
          answerSw: 'Ili kubadilisha uhifadhi wako, nenda kwenye sehemu ya Uhifadhi, chagua uhifadhi wako, na bofya "Badilisha". Unaweza kubadilisha tarehe au idadi ya wageni, kulingana na upatikanaji.',
        ),
        FAQ(
          question: 'What happens if I don\'t show up?',
          questionSw: 'Nini kitatokea ikiwa sitafika?',
          answer: 'If you don\'t check in, the booking will be marked as a no-show. Refund policies depend on the property\'s cancellation policy. Contact support for assistance.',
          answerSw: 'Ikiwa hutaingia, uhifadhi utawekwa alama kama "no-show". Sera za kurudisha pesa hutegemea sera ya kufuta ya mali. Wasiliana na msaada kwa usaidizi.',
        ),
      ],
    ),
    FAQCategory(
      id: 'hosting',
      title: 'Hosting',
      titleSw: 'Kuweka Mali',
      icon: Icons.home_work,
      faqs: [
        FAQ(
          question: 'How do I become a host?',
          questionSw: 'Ninawezaje kuwa mwenyeji?',
          answer: 'Go to your profile, tap "Become a Host", and submit your request. Once approved, you can start listing your properties and earning money.',
          answerSw: 'Nenda kwenye wasifu wako, bofya "Kuwa Mwenyeji", na wasilisha ombi lako. Mara tu litakapoidhinishwa, unaweza kuanza kuweka mali zako na kupata pesa.',
        ),
        FAQ(
          question: 'How do I get paid?',
          questionSw: 'Ninawezaje kupata malipo?',
          answer: 'Set up your payout details in Host Dashboard > Payout Settings. You can add bank account or mobile money details. Payments are released after guest check-in.',
          answerSw: 'Weka maelezo yako ya malipo kwenye Dashibodi ya Mwenyeji > Mipangilio ya Malipo. Unaweza kuongeza maelezo ya akaunti ya benki au pesa za simu. Malipo yanatolewa baada ya mgeni kuingia.',
        ),
        FAQ(
          question: 'What are the platform fees?',
          questionSw: 'Ada za jukwaa ni nini?',
          answer: 'Homia charges a 7% platform fee on each booking. This covers payment processing, marketing, and customer support. You receive 93% of the booking total.',
          answerSw: 'Homia inatoza ada ya jukwaa ya 7% kwa kila uhifadhi. Hii inajumuisha usindikaji wa malipo, uuzaji, na msaada wa wateja. Unapokea 93% ya jumla ya uhifadhi.',
        ),
      ],
    ),
    FAQCategory(
      id: 'payments',
      title: 'Payments & Refunds',
      titleSw: 'Malipo na Kurudisha Pesa',
      icon: Icons.payment,
      faqs: [
        FAQ(
          question: 'When will I be charged?',
          questionSw: 'Nitachajiwa lini?',
          answer: 'You\'ll be charged immediately when you complete the booking. The payment is held securely until check-in, then released to the host.',
          answerSw: 'Utachajiwa mara moja unapokamilisha uhifadhi. Malipo yanashikiliwa kwa usalama hadi kuingia, kisha yanatolewa kwa mwenyeji.',
        ),
        FAQ(
          question: 'How long do refunds take?',
          questionSw: 'Kurudisha pesa huchukua muda gani?',
          answer: 'Refunds are processed within 5-7 business days, depending on your payment method. Mobile money refunds are usually faster than bank transfers.',
          answerSw: 'Kurudisha pesa husindikwa ndani ya siku 5-7 za kazi, kulingana na njia yako ya malipo. Kurudisha pesa za simu kwa kawaida ni haraka kuliko uhamishaji wa benki.',
        ),
        FAQ(
          question: 'What if my payment fails?',
          questionSw: 'Nini ikiwa malipo yangu yatashindwa?',
          answer: 'If payment fails, your booking won\'t be confirmed. Check your account balance and try again. Contact support if the issue persists.',
          answerSw: 'Ikiwa malipo yatashindwa, uhifadhi wako hautathibitishwa. Angalia salio la akaunti yako na jaribu tena. Wasiliana na msaada ikiwa tatizo linaendelea.',
        ),
      ],
    ),
    FAQCategory(
      id: 'account',
      title: 'Account & Profile',
      titleSw: 'Akaunti na Wasifu',
      icon: Icons.person,
      faqs: [
        FAQ(
          question: 'How do I update my profile?',
          questionSw: 'Ninawezaje kusasisha wasifu wangu?',
          answer: 'Go to Profile > Edit Profile. You can update your name, photo, bio, and contact information. Changes are saved immediately.',
          answerSw: 'Nenda kwenye Wasifu > Hariri Wasifu. Unaweza kusasisha jina lako, picha, wasifu, na maelezo ya mawasiliano. Mabadiliko yanahifadhiwa mara moja.',
        ),
        FAQ(
          question: 'How do I change my password?',
          questionSw: 'Ninawezaje kubadilisha neno la siri?',
          answer: 'Go to Profile > Privacy & Security > Change Password. Enter your current password and new password to update.',
          answerSw: 'Nenda kwenye Wasifu > Faragha na Usalama > Badilisha Neno la Siri. Ingiza neno lako la siri la sasa na jipya ili kusasisha.',
        ),
        FAQ(
          question: 'Can I delete my account?',
          questionSw: 'Naweza kufuta akaunti yangu?',
          answer: 'Yes, you can delete your account from Profile > Privacy & Security > Delete Account. This action is permanent and cannot be undone.',
          answerSw: 'Ndio, unaweza kufuta akaunti yako kutoka Wasifu > Faragha na Usalama > Futa Akaunti. Kitendo hiki ni cha kudumu na hakiwezi kufutwa.',
        ),
      ],
    ),
  ];

  List<FAQ> get _filteredFAQs {
    if (_selectedCategory == null && _searchQuery.isEmpty) {
      return [];
    }

    List<FAQ> allFAQs = [];
    for (var category in _categories) {
      if (_selectedCategory == null || category.id == _selectedCategory) {
        allFAQs.addAll(category.faqs);
      }
    }

    if (_searchQuery.isEmpty) {
      return allFAQs;
    }

    final query = _searchQuery.toLowerCase();
    return allFAQs.where((faq) {
      final l10n = AppLocalizations.of(context);
      final isSwahili = l10n.locale.languageCode == 'sw';
      final question = isSwahili ? faq.questionSw : faq.question;
      final answer = isSwahili ? faq.answerSw : faq.answer;
      return question.toLowerCase().contains(query) ||
          answer.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSwahili = l10n.locale.languageCode == 'sw';

    return Scaffold(
      appBar: AppBar(
        title: Text(isSwahili ? 'Kituo cha Msaada' : 'Help Center'),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: isSwahili ? 'Tafuta msaada...' : 'Search for help...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Content
          Expanded(
            child: _searchQuery.isNotEmpty || _selectedCategory != null
                ? _buildSearchResults()
                : _buildCategories(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final l10n = AppLocalizations.of(context);
    final isSwahili = l10n.locale.languageCode == 'sw';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Contact Support Card
        Card(
          color: Colors.blue.shade50,
          child: InkWell(
            onTap: () => _showContactSupport(context),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.support_agent, size: 48, color: Colors.blue.shade700),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSwahili ? 'Wasiliana na Msaada' : 'Contact Support',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSwahili
                              ? 'Pata msaada wa moja kwa moja kutoka kwa timu yetu'
                              : 'Get direct help from our support team',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.blue.shade700),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Popular Questions
        Text(
          isSwahili ? 'Maswali Yanayoulizwa Mara kwa Mara' : 'Popular Questions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        ..._categories.take(3).expand((category) => [
              _buildCategoryCard(category),
              const SizedBox(height: 12),
            ]),

        const SizedBox(height: 8),

        // All Categories
        Text(
          isSwahili ? 'Kategoria Zote' : 'All Categories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        ..._categories.map((category) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCategoryCard(category),
            )),
      ],
    );
  }

  Widget _buildCategoryCard(FAQCategory category) {
    final l10n = AppLocalizations.of(context);
    final isSwahili = l10n.locale.languageCode == 'sw';

    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = category.id;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(category.icon, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSwahili ? category.titleSw : category.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${category.faqs.length} ${isSwahili ? "maswali" : "questions"}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final l10n = AppLocalizations.of(context);
    final isSwahili = l10n.locale.languageCode == 'sw';
    final filteredFAQs = _filteredFAQs;

    if (filteredFAQs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                isSwahili
                    ? 'Hakuna matokeo yaliyopatikana'
                    : 'No results found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSwahili
                    ? 'Jaribu maneno mengine ya kutafuta'
                    : 'Try different search terms',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_selectedCategory != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
                Text(
                  isSwahili
                      ? _categories.firstWhere((c) => c.id == _selectedCategory).titleSw
                      : _categories.firstWhere((c) => c.id == _selectedCategory).title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ...filteredFAQs.map((faq) => _buildFAQCard(faq)),
      ],
    );
  }

  Widget _buildFAQCard(FAQ faq) {
    final l10n = AppLocalizations.of(context);
    final isSwahili = l10n.locale.languageCode == 'sw';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          isSwahili ? faq.questionSw : faq.question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              isSwahili ? faq.answerSw : faq.answer,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSwahili = l10n.locale.languageCode == 'sw';
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    String selectedTopic = 'general';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isSwahili ? 'Wasiliana na Msaada' : 'Contact Support'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSwahili
                      ? 'Tutajibu ujumbe wako haraka iwezekanavyo.'
                      : 'We\'ll respond to your message as soon as possible.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    labelText: isSwahili ? 'Somo' : 'Subject',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTopic,
                  decoration: InputDecoration(
                    labelText: isSwahili ? 'Mada' : 'Topic',
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'general',
                      child: Text(isSwahili ? 'Jumla' : 'General'),
                    ),
                    DropdownMenuItem(
                      value: 'booking',
                      child: Text(isSwahili ? 'Uhifadhi' : 'Booking'),
                    ),
                    DropdownMenuItem(
                      value: 'payment',
                      child: Text(isSwahili ? 'Malipo' : 'Payment'),
                    ),
                    DropdownMenuItem(
                      value: 'hosting',
                      child: Text(isSwahili ? 'Kuweka Mali' : 'Hosting'),
                    ),
                    DropdownMenuItem(
                      value: 'technical',
                      child: Text(isSwahili ? 'Kiufundi' : 'Technical'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedTopic = value ?? 'general';
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    labelText: isSwahili ? 'Ujumbe' : 'Message',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isSwahili ? 'Futa' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (subjectController.text.isEmpty ||
                    messageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isSwahili
                          ? 'Tafadhali jaza sehemu zote'
                          : 'Please fill in all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                await _submitSupportRequest(
                  context,
                  subject: subjectController.text,
                  message: messageController.text,
                  topic: selectedTopic,
                );
              },
              child: Text(isSwahili ? 'Tuma' : 'Send'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSupportRequest(
    BuildContext context, {
    required String subject,
    required String message,
    required String topic,
  }) async {
    final l10n = AppLocalizations.of(context);
    final isSwahili = l10n.locale.languageCode == 'sw';

    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.post('/users/support/contact', data: {
        'subject': subject,
        'message': message,
        'topic': topic,
      });

      if (context.mounted) {
        if (response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isSwahili
                  ? 'Ujumbe wako umetumwa. Tutawasiliana nawe hivi karibuni.'
                  : 'Your message has been sent. We\'ll contact you soon.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ??
                  (isSwahili
                      ? 'Imeshindwa kutuma ujumbe'
                      : 'Failed to send message')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSwahili
                ? 'Hitilafu: ${e.toString()}'
                : 'Error: ${e.toString()}'),
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
}

class FAQCategory {
  final String id;
  final String title;
  final String titleSw;
  final IconData icon;
  final List<FAQ> faqs;

  FAQCategory({
    required this.id,
    required this.title,
    required this.titleSw,
    required this.icon,
    required this.faqs,
  });
}

class FAQ {
  final String question;
  final String questionSw;
  final String answer;
  final String answerSw;

  FAQ({
    required this.question,
    required this.questionSw,
    required this.answer,
    required this.answerSw,
  });
}

