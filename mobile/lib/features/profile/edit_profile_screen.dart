import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/models/user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _genderController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _alternateEmailController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  File? _profilePicture;
  String? _profilePictureUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      setState(() {
        _firstNameController.text = user.profile.firstName;
        _lastNameController.text = user.profile.lastName;
        _bioController.text = user.profile.bio ?? '';
        _nationalityController.text = user.profile.nationality ?? '';
        _whatsappController.text = user.profile.whatsappNumber ?? '';
        _alternateEmailController.text = user.profile.alternateEmail ?? '';
        _profilePictureUrl = user.profile.profilePicture;
        
        if (user.profile.dateOfBirth != null) {
          _dateOfBirthController.text = user.profile.dateOfBirth.toString().split(' ')[0];
        }
        
        if (user.profile.gender != null) {
          _genderController.text = user.profile.gender!;
        }
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _dateOfBirthController.dispose();
    _genderController.dispose();
    _nationalityController.dispose();
    _whatsappController.dispose();
    _alternateEmailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profilePicture = File(image.path);
        });
        // Upload image
        await _uploadProfilePicture();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_profilePicture == null) return;

    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_profilePicture!.path),
      });

      final response = await apiService.post('/upload/profile-picture', data: formData);
      
      if (response.data['success'] == true) {
        setState(() {
          _profilePictureUrl = response.data['data']['url'];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture uploaded successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final apiService = context.read<ApiService>();
      final updateData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'nationality': _nationalityController.text.trim(),
        'whatsappNumber': _whatsappController.text.trim(),
        'alternateEmail': _alternateEmailController.text.trim(),
      };

      if (_dateOfBirthController.text.isNotEmpty) {
        updateData['dateOfBirth'] = _dateOfBirthController.text;
      }

      if (_genderController.text.isNotEmpty) {
        updateData['gender'] = _genderController.text;
      }

      if (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty) {
        updateData['profilePicture'] = _profilePictureUrl!;
      }

      final response = await apiService.put('/users/profile', data: updateData);

      if (response.data['success'] == true) {
        // Update auth provider
        final authProvider = context.read<AuthProvider>();
        await authProvider.refreshUser();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).primaryColor,
                    backgroundImage: _profilePicture != null
                        ? FileImage(_profilePicture!)
                        : (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty)
                            ? NetworkImage(_profilePictureUrl!)
                            : null,
                    child: _profilePicture == null && (_profilePictureUrl == null || _profilePictureUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  if (_isLoading)
                    const Positioned.fill(
                      child: CircularProgressIndicator(),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        onPressed: _isLoading ? null : _pickImage,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Bio
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.edit_outlined),
                  hintText: 'Tell us about yourself...',
                ),
              ),

              const SizedBox(height: 16),

              // Date of Birth
              TextFormField(
                controller: _dateOfBirthController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: 'YYYY-MM-DD',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _dateOfBirthController.text = date.toString().split(' ')[0];
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Gender
              DropdownButtonFormField<String>(
                value: _genderController.text.isEmpty ? null : _genderController.text,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                  DropdownMenuItem(value: 'prefer_not_to_say', child: Text('Prefer not to say')),
                ],
                onChanged: (value) {
                  setState(() {
                    _genderController.text = value ?? '';
                  });
                },
              ),

              const SizedBox(height: 16),

              // Nationality
              TextFormField(
                controller: _nationalityController,
                decoration: const InputDecoration(
                  labelText: 'Nationality',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),

              const SizedBox(height: 16),

              // WhatsApp Number
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp Number',
                  prefixIcon: Icon(Icons.chat),
                  hintText: '+255...',
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              // Alternate Email
              TextFormField(
                controller: _alternateEmailController,
                decoration: const InputDecoration(
                  labelText: 'Alternate Email',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

























