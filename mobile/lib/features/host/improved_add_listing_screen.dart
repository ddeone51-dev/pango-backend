import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/config/constants.dart';
import '../../core/providers/listing_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/translation_service.dart';
import '../../core/services/api_service.dart';
import '../../core/l10n/app_localizations.dart';
import 'package:dio/dio.dart';

class ImprovedAddListingScreen extends StatefulWidget {
  const ImprovedAddListingScreen({super.key});

  @override
  State<ImprovedAddListingScreen> createState() => _ImprovedAddListingScreenState();
}

class _ImprovedAddListingScreenState extends State<ImprovedAddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _translationService = TranslationService();
  final _imagePicker = ImagePicker();
  bool _hostStatusChecked = false;
  
  // Controllers - Only Swahili
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _priceController = TextEditingController();
  final _cleaningFeeController = TextEditingController();
  final _guestsController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bedsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  
  String _selectedPropertyType = 'apartment';
  String _selectedRegion = 'Dar es Salaam';
  List<String> _selectedAmenities = [];
  List<File> _selectedImages = [];
  bool _isTranslating = false;
  
  // Location coordinates
  double _latitude = -6.7924;  // Default: Dar es Salaam
  double _longitude = 39.2083;
  GoogleMapController? _mapController;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _priceController.dispose();
    _cleaningFeeController.dispose();
    _guestsController.dispose();
    _bedroomsController.dispose();
    _bedsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          // Add new images to existing ones
          for (var xFile in images) {
            if (_selectedImages.length < 5) {
              _selectedImages.add(File(xFile.path));
            }
          }
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Picha ${images.length} zimechaguliwa! (Jumla: ${_selectedImages.length})'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hitilafu ya kuchagua picha: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  Future<void> _pickSingleImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
          // Limit to 5 images
          if (_selectedImages.length > 5) {
            _selectedImages = _selectedImages.sublist(0, 5);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hitilafu ya kuchagua picha: $e')),
      );
    }
  }
  
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
          if (_selectedImages.length > 5) {
            _selectedImages = _selectedImages.sublist(0, 5);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hitilafu ya kupiga picha: $e')),
      );
    }
  }
  
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
  
  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tafadhali jaza sehemu zote zinazohitajika')),
      );
      return;
    }
    
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tafadhali chagua angalau picha moja')),
      );
      return;
    }
    
    setState(() => _isTranslating = true);
    
    try {
      // Step 1: Upload images to backend
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📤 Inapakia picha...'), duration: Duration(seconds: 2)),
      );
      
      final apiService = context.read<ApiService>();
      final List<Map<String, dynamic>> uploadedImages = [];
      
      for (var i = 0; i < _selectedImages.length; i++) {
        final file = _selectedImages[i];
        
        // Convert image to base64 for simpler upload (no multipart needed)
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);
        final fileName = file.path.split('/').last;
        
        // Create data URL
        final imageUrl = 'data:image/jpeg;base64,$base64Image';
        
        uploadedImages.add({
          'url': imageUrl,
          'caption': 'Picha ${i + 1}',
          'order': i,
        });
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🌍 Inatafsiri...'), duration: Duration(seconds: 2)),
      );
      
      // Step 2: Translate Swahili to English
      final titleEn = await _translationService.translateSwahiliToEnglish(_titleController.text.trim());
      final descriptionEn = await _translationService.translateSwahiliToEnglish(_descriptionController.text.trim());
      
      setState(() => _isTranslating = false);
      
      final listingProvider = context.read<ListingProvider>();
      
      final imageUrls = uploadedImages;
      
      // Prepare listing data
      final listingData = {
        'title': {
          'en': titleEn.isNotEmpty ? titleEn : _titleController.text.trim(),
          'sw': _titleController.text.trim(),
        },
        'description': {
          'en': descriptionEn.isNotEmpty ? descriptionEn : _descriptionController.text.trim(),
          'sw': _descriptionController.text.trim(),
        },
        'propertyType': _selectedPropertyType,
        'location': {
          'address': _addressController.text.trim(),
          'region': _selectedRegion,
          'city': _cityController.text.trim(),
          'district': _districtController.text.trim(),
          'coordinates': {
            'type': 'Point',
            'coordinates': [_longitude, _latitude], // Selected from map
          },
          'nearbyLandmarks': [],
        },
        'pricing': {
          'basePrice': double.parse(_priceController.text),
          'currency': 'TZS',
          'cleaningFee': double.parse(_cleaningFeeController.text.isEmpty ? '0' : _cleaningFeeController.text),
        },
        'capacity': {
          'guests': int.parse(_guestsController.text),
          'bedrooms': int.parse(_bedroomsController.text),
          'beds': int.parse(_bedsController.text),
          'bathrooms': int.parse(_bathroomsController.text),
        },
        'amenities': _selectedAmenities,
        'images': imageUrls,
        'houseRules': {
          'checkIn': '14:00',
          'checkOut': '11:00',
          'customRules': {
            'en': ['No smoking', 'Respect the property'],
            'sw': ['Usivute', 'Heshimu mali'],
          },
        },
        'availability': {
          'instantBooking': true,
          'minNights': 1,
          'maxNights': 30,
        },
        'status': 'active',
      };
      
      final success = await listingProvider.createListing(listingData);
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mali imesajiliwa kwa mafanikio!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${listingProvider.error ?? "Imeshindwa kusajili mali"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isTranslating = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hitilafu: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final hostStatus = authProvider.user?.hostStatus ?? 'not_requested';
    final isApproved = hostStatus == 'approved';
    final isPending = hostStatus == 'pending';
    final isRejected = hostStatus == 'rejected';
    final isNotRequested = hostStatus == 'not_requested';

    if (!_hostStatusChecked) {
      _hostStatusChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isApproved) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Host Approval Required'),
              content: Text(
                isPending
                    ? 'Your host application is still pending approval. Please wait for an admin to approve it before adding listings.'
                    : isRejected
                        ? 'Your host application was rejected. Please contact support or reapply if allowed.'
                        : 'You must request host access and wait for admin approval before you can add listings.',
              ),
              actions: [
                if (isNotRequested)
                  TextButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      final success = await authProvider.requestHostRole();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Request submitted. Please wait for admin approval.'
                                : (authProvider.error ?? 'Failed to submit host request.'),
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Request Host Access'),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      });
    }

    if (!isApproved) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
          title: const Text('Add Listing'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRejected ? Icons.block : Icons.hourglass_top,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  isPending
                      ? 'Your host application is pending approval.'
                      : isRejected
                          ? 'Your host application was rejected.'
                          : 'You need host approval before adding listings.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isPending
                      ? 'Please wait for an admin to review your application. We will notify you once it is approved.'
                      : isRejected
                          ? 'Contact support for more information or to reapply.'
                          : 'Request host access to start listing properties. An admin must approve your account before you can continue.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                if (isNotRequested)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final success = await authProvider.requestHostRole();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Request submitted. Please wait for admin approval.'
                                : (authProvider.error ?? 'Failed to submit host request.'),
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                      if (success) Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Request Host Approval'),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final listingProvider = context.watch<ListingProvider>();
    final isLoading = listingProvider.isLoading || _isTranslating;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Rudi Nyuma',
        ),
        title: const Text('Ongeza Mali Yako'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.home_work, size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 8),
                    const Text(
                      'Andika kwa Kiswahili',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Mfumo utatafsiri kwa Kiingereza kiotomatiki',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              '🏠 Taarifa za Mali',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Property Type
            DropdownButtonFormField<String>(
              value: _selectedPropertyType,
              decoration: const InputDecoration(
                labelText: 'Aina ya Mali *',
                border: OutlineInputBorder(),
                helperText: 'Chagua aina ya mali yako',
              ),
              items: [
                DropdownMenuItem(value: 'apartment', child: Text('Ghorofa')),
                DropdownMenuItem(value: 'house', child: Text('Nyumba')),
                DropdownMenuItem(value: 'villa', child: Text('Villa')),
                DropdownMenuItem(value: 'cottage', child: Text('Nyumba Ndogo')),
                DropdownMenuItem(value: 'studio', child: Text('Studio')),
                DropdownMenuItem(value: 'guesthouse', child: Text('Nyumba ya Wageni')),
                DropdownMenuItem(value: 'bungalow', child: Text('Bungalow')),
                DropdownMenuItem(value: 'resort', child: Text('Resort')),
              ],
              onChanged: (value) => setState(() => _selectedPropertyType = value!),
            ),
            const SizedBox(height: 16),
            
            // Title (Swahili only)
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Jina la Mali *',
                border: OutlineInputBorder(),
                helperText: 'Mfano: Ghorofa Nzuri ya Vyumba 2 Masaki',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Inahitajika' : null,
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            
            // Description (Swahili only)
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Maelezo *',
                border: OutlineInputBorder(),
                helperText: 'Elezea mali yako kwa undani',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Inahitajika' : null,
              maxLines: 5,
              maxLength: 500,
            ),
            const SizedBox(height: 24),
            
            Text(
              '📍 Mahali',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Region
            DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: const InputDecoration(
                labelText: 'Mkoa *',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.regions.map((region) => DropdownMenuItem(
                value: region,
                child: Text(region),
              )).toList(),
              onChanged: (value) => setState(() => _selectedRegion = value!),
            ),
            const SizedBox(height: 16),
            
            // City
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Jiji *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Inahitajika' : null,
            ),
            const SizedBox(height: 16),
            
            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Anwani *',
                border: OutlineInputBorder(),
                helperText: 'Mfano: Barabara ya Masaki, Karibu na Slipway',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Inahitajika' : null,
            ),
            const SizedBox(height: 16),
            
            // District
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(
                labelText: 'Wilaya',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Map Location Picker
            Text(
              '📍 Mahali Halisi pa Mali',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Bonyeza kwenye ramani ili kuonyesha mahali halisi pa mali yako',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RepaintBoundary(
                  child: GoogleMap(
                    key: const Key('host_location_picker'),
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_latitude, _longitude),
                      zoom: 13,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  onTap: (LatLng position) {
                    setState(() {
                      _latitude = position.latitude;
                      _longitude = position.longitude;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✅ Mahali pamechaguliwa: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('property_location'),
                      position: LatLng(_latitude, _longitude),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                      draggable: true,
                      onDragEnd: (LatLng position) {
                        setState(() {
                          _latitude = position.latitude;
                          _longitude = position.longitude;
                        });
                      },
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: false,
                  buildingsEnabled: false,
                  trafficEnabled: false,
                  indoorViewEnabled: false,
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
                  liteModeEnabled: false,
                ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mahali Palichochaguliwa:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Latitude: ${_latitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        Text(
                          'Longitude: ${_longitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      Position position = await Geolocator.getCurrentPosition();
                      setState(() {
                        _latitude = position.latitude;
                        _longitude = position.longitude;
                      });
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(LatLng(_latitude, _longitude)),
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Mahali yako ya sasa yamechaguliwa'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Imeshindwa kupata mahali yako'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.my_location, size: 16),
                  label: const Text('Mahali Yangu', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              '💰 Bei',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Base Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Bei kwa Usiku (TZS) *',
                border: OutlineInputBorder(),
                prefixText: 'TSh ',
                helperText: 'Mfano: 120000',
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'Inahitajika' : null,
            ),
            const SizedBox(height: 16),
            
            // Cleaning Fee
            TextFormField(
              controller: _cleaningFeeController,
              decoration: const InputDecoration(
                labelText: 'Ada ya Kusafisha (TZS)',
                border: OutlineInputBorder(),
                prefixText: 'TSh ',
                helperText: 'Si lazima',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            
            Text(
              '🛏️ Uwezo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _guestsController,
                    decoration: const InputDecoration(
                      labelText: 'Wageni *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Inahitajika' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _bedroomsController,
                    decoration: const InputDecoration(
                      labelText: 'Vyumba *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Inahitajika' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bedsController,
                    decoration: const InputDecoration(
                      labelText: 'Vitanda *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Inahitajika' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _bathroomsController,
                    decoration: const InputDecoration(
                      labelText: 'Bafu *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Inahitajika' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              '✨ Vifaa',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildAmenityChip('wifi', 'WiFi'),
                _buildAmenityChip('parking', 'Maegesho'),
                _buildAmenityChip('kitchen', 'Jiko'),
                _buildAmenityChip('air_conditioning', 'AC'),
                _buildAmenityChip('tv', 'TV'),
                _buildAmenityChip('pool', 'Bwawa'),
                _buildAmenityChip('gym', 'Gym'),
                _buildAmenityChip('security', 'Usalama'),
                _buildAmenityChip('breakfast', 'Kifungua Kinywa'),
                _buildAmenityChip('workspace', 'Eneo la Kazi'),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              '📸 Picha (${_selectedImages.length}/5)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Image selection buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Chagua Picha'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Piga Picha'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Selected images grid
            if (_selectedImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 12,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 16,
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => _removeImage(index),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            
            if (_selectedImages.isEmpty)
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Bonyeza kubonyeza ili kuongeza picha'),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            ElevatedButton(
              onPressed: isLoading ? null : _submitListing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Inatafsiri na kusajili...'),
                      ],
                    )
                  : const Text(
                      'Sajili Mali',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAmenityChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedAmenities.contains(value),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedAmenities.add(value);
          } else {
            _selectedAmenities.remove(value);
          }
        });
      },
    );
  }
}

