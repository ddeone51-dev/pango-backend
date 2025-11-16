import 'api_service.dart';

class ReportService {
  final ApiService _apiService;

  ReportService(this._apiService);

  /// Report/flag content
  Future<Map<String, dynamic>> reportContent({
    required String contentType, // 'listing', 'review', 'user_profile', 'message'
    required String contentId,
    required String contentOwnerId,
    required String reason,
    required String description,
    List<String>? evidenceUrls,
  }) async {
    try {
      final response = await _apiService.post(
        '/moderation/report',
        data: {
          'contentType': contentType,
          'contentId': contentId,
          'contentOwner': contentOwnerId,
          'reason': reason,
          'description': description,
          if (evidenceUrls != null) 'evidence': evidenceUrls,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get report reasons
  static List<Map<String, String>> getReportReasons() {
    return [
      {
        'value': 'inappropriate_content',
        'label': 'Inappropriate Content',
        'description': 'Contains offensive or inappropriate material',
      },
      {
        'value': 'spam',
        'label': 'Spam',
        'description': 'Repetitive or unsolicited content',
      },
      {
        'value': 'fraud',
        'label': 'Fraud or Scam',
        'description': 'Attempting to defraud or scam users',
      },
      {
        'value': 'false_information',
        'label': 'False Information',
        'description': 'Contains misleading or false details',
      },
      {
        'value': 'harassment',
        'label': 'Harassment',
        'description': 'Harassment or bullying behavior',
      },
      {
        'value': 'violence',
        'label': 'Violence',
        'description': 'Promotes or depicts violence',
      },
      {
        'value': 'hate_speech',
        'label': 'Hate Speech',
        'description': 'Contains hateful or discriminatory content',
      },
      {
        'value': 'copyright',
        'label': 'Copyright Violation',
        'description': 'Uses copyrighted material without permission',
      },
      {
        'value': 'privacy_violation',
        'label': 'Privacy Violation',
        'description': 'Violates someone\'s privacy',
      },
      {
        'value': 'other',
        'label': 'Other',
        'description': 'Other issue not listed above',
      },
    ];
  }
}






