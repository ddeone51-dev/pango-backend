import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          l10n.translate('add_listing'),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 4) {
            setState(() => _currentStep++);
          } else {
            // Submit listing
            Navigator.pop(context);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        steps: [
          Step(
            title: Text(l10n.translate('property_type')),
            content: Column(
              children: [
                Text(l10n.translate('what_type_property')),
                // Property type selection
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: Text(l10n.translate('location')),
            content: Column(
              children: [
                Text(l10n.translate('where_property_located')),
                // Location fields
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: Text(l10n.translate('details')),
            content: Column(
              children: [
                Text(l10n.translate('tell_about_property')),
                // Details fields
              ],
            ),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: Text(l10n.translate('photos')),
            content: Column(
              children: [
                Text(l10n.translate('add_photos')),
                // Photo upload
              ],
            ),
            isActive: _currentStep >= 3,
          ),
          Step(
            title: Text(l10n.translate('pricing')),
            content: Column(
              children: [
                Text(l10n.translate('set_price')),
                // Pricing fields
              ],
            ),
            isActive: _currentStep >= 4,
          ),
        ],
      ),
    );
  }
}

























