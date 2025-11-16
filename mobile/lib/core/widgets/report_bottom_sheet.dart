import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/report_service.dart';
import '../services/api_service.dart';

class ReportBottomSheet extends StatefulWidget {
  final String contentType;
  final String contentId;
  final String contentOwnerId;
  final String contentTitle;

  const ReportBottomSheet({
    super.key,
    required this.contentType,
    required this.contentId,
    required this.contentOwnerId,
    required this.contentTitle,
  });

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  String? selectedReason;
  final TextEditingController _descriptionController = TextEditingController();
  bool isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason')),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide more details')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Make actual API call to backend
      final reportService = ReportService(context.read<ApiService>());
      
      await reportService.reportContent(
        contentType: widget.contentType,
        contentId: widget.contentId,
        contentOwnerId: widget.contentOwnerId,
        reason: selectedReason!,
        description: _descriptionController.text.trim(),
      );
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your report. We will review it shortly.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reasons = ReportService.getReportReasons();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.flag, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Report Content',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.contentTitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Reason Selection
              const Text(
                'Why are you reporting this?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Reason Options
              ...reasons.map((reason) {
                return RadioListTile<String>(
                  value: reason['value']!,
                  groupValue: selectedReason,
                  onChanged: (value) {
                    setState(() => selectedReason = value);
                  },
                  title: Text(reason['label']!),
                  subtitle: Text(
                    reason['description']!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }).toList(),

              const SizedBox(height: 16),

              // Description Field
              const Text(
                'Additional Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Please provide more information about this issue...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),

              // Info Text
              Text(
                'Your report is anonymous. We will review it and take appropriate action.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function to show the report bottom sheet
Future<bool?> showReportBottomSheet({
  required BuildContext context,
  required String contentType,
  required String contentId,
  required String contentOwnerId,
  required String contentTitle,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => ReportBottomSheet(
      contentType: contentType,
      contentId: contentId,
      contentOwnerId: contentOwnerId,
      contentTitle: contentTitle,
    ),
  );
}

