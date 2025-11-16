import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/l10n/app_localizations.dart';

class AboutHomiaScreen extends StatefulWidget {
  const AboutHomiaScreen({super.key});

  @override
  State<AboutHomiaScreen> createState() => _AboutHomiaScreenState();
}

class _AboutHomiaScreenState extends State<AboutHomiaScreen> {
  String _appVersion = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      print('Failed to load app info: $e');
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSwahili = l10n.locale.languageCode == 'sw';

    return Scaffold(
      appBar: AppBar(
        title: Text(isSwahili ? 'Kuhusu Homia' : 'About Homia'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo/Header Section
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    size: 64,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Homia',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSwahili
                      ? 'Nyumbani Kwako Mbali na Nyumbani'
                      : 'Your Home Away From Home',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'v$_appVersion (Build $_buildNumber)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSection(
            context,
            title: isSwahili ? 'Kuhusu Homia' : 'About Homia',
            icon: Icons.info_outline,
            child: Text(
              isSwahili
                  ? 'Homia ni jukwaa la kukodisha makazi linalojengwa kwa ajili ya soko la Tanzania. Tunawaunganisha watalii na wenyeweji wanaotoa makazi kote Tanzania, kutoka vyumba vya mijini Dar es Salaam hadi nyumba za pwani Zanzibar. Lengo letu ni kufanya ujio wa makazi bora kuwa rahisi na salama kwa wote.'
                  : 'Homia is a mobile accommodation booking platform specifically designed for the Tanzanian market. We connect travelers with hosts offering accommodations across Tanzania, from urban apartments in Dar es Salaam to serene beach houses in Zanzibar. Our mission is to make finding the perfect accommodation easy and secure for everyone.',
              style: TextStyle(height: 1.6, color: Colors.grey.shade700),
            ),
          ),

          const SizedBox(height: 16),

          // Mission Section
          _buildSection(
            context,
            title: isSwahili ? 'Lengo Letu' : 'Our Mission',
            icon: Icons.flag_outlined,
            child: Text(
              isSwahili
                  ? 'Kutoa jukwaa bora la kukodisha makazi nchini Tanzania, kuongeza ufikiaji wa makazi bora kwa watalii na kuwasaidia wenyeweji kujenga biashara zao za ukarimu.'
                  : 'To provide the best accommodation booking platform in Tanzania, increasing access to quality accommodations for travelers and helping hosts build their hospitality businesses.',
              style: TextStyle(height: 1.6, color: Colors.grey.shade700),
            ),
          ),

          const SizedBox(height: 16),

          // Features Section
          _buildSection(
            context,
            title: isSwahili ? 'Vipengele' : 'Key Features',
            icon: Icons.star_outline,
            child: Column(
              children: [
                _buildFeatureItem(
                  context,
                  icon: Icons.search,
                  title: isSwahili ? 'Tafuta na Filti' : 'Search & Filters',
                  description: isSwahili
                      ? 'Tafuta makazi kwa eneo, bei, na huduma'
                      : 'Search accommodations by location, price, and amenities',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  context,
                  icon: Icons.calendar_today,
                  title: isSwahili ? 'Uhifadhi Rahisi' : 'Easy Booking',
                  description: isSwahili
                      ? 'Hifadhi makazi yako kwa mibofyo michache tu'
                      : 'Book your stay with just a few taps',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  context,
                  icon: Icons.payment,
                  title: isSwahili ? 'Malipo Salama' : 'Secure Payments',
                  description: isSwahili
                      ? 'Malipo kwa M-Pesa, Tigo Pesa, na Airtel Money'
                      : 'Pay with M-Pesa, Tigo Pesa, and Airtel Money',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  context,
                  icon: Icons.star_rate,
                  title: isSwahili ? 'Ukaguzi na Maoni' : 'Reviews & Ratings',
                  description: isSwahili
                      ? 'Soma maoni kutoka kwa wageni wengine'
                      : 'Read reviews from other guests',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  context,
                  icon: Icons.home_work,
                  title: isSwahili ? 'Dashibodi ya Mwenyeji' : 'Host Dashboard',
                  description: isSwahili
                      ? 'Dhibiti mali zako na mapato yako'
                      : 'Manage your listings and earnings',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  context,
                  icon: Icons.language,
                  title: isSwahili ? 'Lugha Mbili' : 'Bilingual Support',
                  description: isSwahili
                      ? 'Inatumika kwa Kiingereza na Kiswahili'
                      : 'Available in English and Swahili',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // How It Works Section
          _buildSection(
            context,
            title: isSwahili ? 'Inafanya Kazi Vipi?' : 'How It Works',
            icon: Icons.help_outline,
            child: Column(
              children: [
                _buildStepItem(
                  context,
                  step: 1,
                  title: isSwahili ? 'Tafuta' : 'Search',
                  description: isSwahili
                      ? 'Tafuta makazi kwa eneo, tarehe, na idadi ya wageni'
                      : 'Search for accommodations by location, dates, and number of guests',
                ),
                const SizedBox(height: 16),
                _buildStepItem(
                  context,
                  step: 2,
                  title: isSwahili ? 'Chagua' : 'Choose',
                  description: isSwahili
                      ? 'Angalia picha, maelezo, na maoni ya mali'
                      : 'Browse photos, descriptions, and reviews of properties',
                ),
                const SizedBox(height: 16),
                _buildStepItem(
                  context,
                  step: 3,
                  title: isSwahili ? 'Hifadhi' : 'Book',
                  description: isSwahili
                      ? 'Hifadhi na malipa kwa njia yako ya pesa za simu'
                      : 'Book and pay using your preferred mobile money method',
                ),
                const SizedBox(height: 16),
                _buildStepItem(
                  context,
                  step: 4,
                  title: isSwahili ? 'Furahia' : 'Enjoy',
                  description: isSwahili
                      ? 'Furahia makazi yako na toa maoni baada ya kukaa'
                      : 'Enjoy your stay and leave a review after your visit',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Contact Section
          _buildSection(
            context,
            title: isSwahili ? 'Wasiliana Nasi' : 'Contact Us',
            icon: Icons.contact_support_outlined,
            child: Column(
              children: [
                _buildContactItem(
                  context,
                  icon: Icons.email,
                  title: isSwahili ? 'Barua Pepe' : 'Email',
                  value: 'support@homia.co.tz',
                  onTap: () => _launchURL('mailto:support@homia.co.tz'),
                ),
                const SizedBox(height: 12),
                _buildContactItem(
                  context,
                  icon: Icons.phone,
                  title: isSwahili ? 'Simu' : 'Phone',
                  value: '+255 22 123 4567',
                  onTap: () => _launchURL('tel:+255221234567'),
                ),
                const SizedBox(height: 12),
                _buildContactItem(
                  context,
                  icon: Icons.location_on,
                  title: isSwahili ? 'Eneo' : 'Location',
                  value: isSwahili
                      ? 'Dar es Salaam, Tanzania'
                      : 'Dar es Salaam, Tanzania',
                  onTap: null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Legal Links Section
          _buildSection(
            context,
            title: isSwahili ? 'Maelezo ya Kisheria' : 'Legal Information',
            icon: Icons.gavel_outlined,
            child: Column(
              children: [
                _buildLinkItem(
                  context,
                  title: isSwahili ? 'Masharti ya Matumizi' : 'Terms of Service',
                  onTap: () {
                    // Navigate to terms page or open URL
                    _launchURL('https://homia.co.tz/terms');
                  },
                ),
                const Divider(),
                _buildLinkItem(
                  context,
                  title: isSwahili ? 'Sera ya Faragha' : 'Privacy Policy',
                  onTap: () {
                    // Navigate to privacy policy page or open URL
                    _launchURL('https://homia.co.tz/privacy');
                  },
                ),
                const Divider(),
                _buildLinkItem(
                  context,
                  title: isSwahili ? 'Sera ya Kufuta' : 'Cancellation Policy',
                  onTap: () {
                    // Navigate to cancellation policy
                    _launchURL('https://homia.co.tz/cancellation');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Social Media Section
          _buildSection(
            context,
            title: isSwahili ? 'Fuata Sisi' : 'Follow Us',
            icon: Icons.share_outlined,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(
                  context,
                  icon: Icons.facebook,
                  onTap: () => _launchURL('https://facebook.com/homia'),
                ),
                const SizedBox(width: 16),
                _buildSocialIcon(
                  context,
                  icon: Icons.camera_alt,
                  onTap: () => _launchURL('https://instagram.com/homia'),
                ),
                const SizedBox(width: 16),
                _buildSocialIcon(
                  context,
                  icon: Icons.alternate_email,
                  onTap: () => _launchURL('https://twitter.com/homia'),
                ),
                const SizedBox(width: 16),
                _buildSocialIcon(
                  context,
                  icon: Icons.link,
                  onTap: () => _launchURL('https://homia.co.tz'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Company Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  isSwahili ? 'Homia Tanzania' : 'Homia Tanzania',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSwahili
                      ? '© 2024 Homia. Haki zote zimehifadhiwa.'
                      : '© 2024 Homia. All rights reserved.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  isSwahili
                      ? 'Jukwaa la kukodisha makazi bora nchini Tanzania'
                      : 'Tanzania\'s premier accommodation booking platform',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(
    BuildContext context, {
    required int step,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue.shade700),
      ),
    );
  }
}

