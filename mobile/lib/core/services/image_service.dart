import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'api_service.dart';

class ImageService {
  final ApiService apiService;
  
  ImageService({required this.apiService});
  
  /// Upload images to backend and get URLs
  Future<List<String>> uploadImages(List<File> images) async {
    try {
      final List<String> imageUrls = [];
      
      for (var i = 0; i < images.length; i++) {
        final file = images[i];
        final fileName = file.path.split('/').last;
        
        // Create form data
        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        });
        
        // Upload to backend
        final response = await apiService.post('/upload/image', data: formData);
        
        if (response.data['success']) {
          imageUrls.add(response.data['data']['url']);
        }
      }
      
      return imageUrls;
    } catch (e) {
      print('Error uploading images: $e');
      rethrow;
    }
  }
  
  /// Convert image to base64 (alternative method)
  Future<String> imageToBase64(File image) async {
    try {
      final bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      rethrow;
    }
  }
  
  /// Convert multiple images to base64
  Future<List<String>> imagesToBase64(List<File> images) async {
    final List<String> base64Images = [];
    
    for (var image in images) {
      final base64 = await imageToBase64(image);
      base64Images.add(base64);
    }
    
    return base64Images;
  }
}












