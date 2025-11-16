import 'package:dio/dio.dart';

class TranslationService {
  final Dio _dio;
  
  TranslationService() : _dio = Dio();
  
  /// Simple translation service using LibreTranslate or fallback to basic translation
  Future<String> translateSwahiliToEnglish(String text) async {
    if (text.trim().isEmpty) return '';
    
    try {
      // Using LibreTranslate (free, open-source translation API)
      final response = await _dio.post(
        'https://libretranslate.de/translate',
        data: {
          'q': text,
          'source': 'sw',
          'target': 'en',
          'format': 'text',
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      
      if (response.data != null && response.data['translatedText'] != null) {
        return response.data['translatedText'];
      }
    } catch (e) {
      print('Translation API error: $e');
      // Fallback: Return original text with a note
      // In production, you might want to use a local dictionary or cache
    }
    
    // Fallback: Return original text if translation fails
    return text;
  }
  
  /// Batch translate multiple texts
  Future<Map<String, String>> translateBatch(Map<String, String> texts) async {
    final results = <String, String>{};
    
    for (var entry in texts.entries) {
      results[entry.key] = await translateSwahiliToEnglish(entry.value);
    }
    
    return results;
  }
}
























