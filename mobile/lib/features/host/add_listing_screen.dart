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
        title: Text(l10n.translate('add_listing')),
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
            title: const Text('Property Type'),
            content: Column(
              children: [
                const Text('What type of property are you listing?'),
                // Property type selection
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Location'),
            content: Column(
              children: [
                const Text('Where is your property located?'),
                // Location fields
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Details'),
            content: Column(
              children: [
                const Text('Tell us about your property'),
                // Details fields
              ],
            ),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Photos'),
            content: Column(
              children: [
                const Text('Add photos of your property'),
                // Photo upload
              ],
            ),
            isActive: _currentStep >= 3,
          ),
          Step(
            title: const Text('Pricing'),
            content: Column(
              children: [
                const Text('Set your price'),
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

























