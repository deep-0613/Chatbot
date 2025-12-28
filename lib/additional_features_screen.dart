import 'package:flutter/material.dart';
import 'fraud_detection_service.dart';

class AdditionalFeaturesScreen extends StatefulWidget {
  const AdditionalFeaturesScreen({super.key});

  @override
  State<AdditionalFeaturesScreen> createState() => _AdditionalFeaturesScreenState();
}

class _AdditionalFeaturesScreenState extends State<AdditionalFeaturesScreen> {
  final FraudDetectionService _fraudService = FraudDetectionService();
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _reportController = TextEditingController();
  
  bool _isLoadingUPI = false;
  bool _isLoadingContact = false;
  bool _isLoadingReport = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fraud Detection Tools'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUPIValidation(),
            const SizedBox(height: 24),
            _buildContactVerification(),
            const SizedBox(height: 24),
            _buildReportSuspiciousActivity(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUPIValidation() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'UPI ID Fraud Detection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter a UPI ID to check for potential fraud risks, look-alike patterns, and suspicious activity.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _upiController,
              decoration: InputDecoration(
                hintText: 'e.g., username@upi',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.payment),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingUPI ? null : _validateUPI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoadingUPI
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Validate UPI ID'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactVerification() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_phone, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Contact Verification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Verify if a phone number or UPI ID exists in your trusted contacts list.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(
                hintText: 'Phone number or UPI ID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingContact ? null : _verifyContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoadingContact
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Verify Contact'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReportSuspiciousActivity() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.report_problem, color: Colors.red[700]),
                const SizedBox(width: 8),
                const Text(
                  'Report Suspicious Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Report suspicious messages, links, or activities for instant analysis and safety recommendations.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reportController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the suspicious activity...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingReport ? null : _reportActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoadingReport
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Report & Analyze'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _validateUPI() async {
    if (_upiController.text.trim().isEmpty) return;
    
    setState(() => _isLoadingUPI = true);
    
    try {
      final result = await _fraudService.validateUPIId(_upiController.text.trim());
      _showResultDialog('UPI Validation Result', result);
    } catch (e) {
      _showResultDialog('Error', 'Failed to validate UPI ID. Please try again.');
    } finally {
      setState(() => _isLoadingUPI = false);
    }
  }
  
  Future<void> _verifyContact() async {
    if (_contactController.text.trim().isEmpty) return;
    
    setState(() => _isLoadingContact = true);
    
    // Simulate contact verification
    await Future.delayed(const Duration(seconds: 2));
    
    final contact = _contactController.text.trim();
    String result;
    
    if (contact.contains('@') && contact.contains('upi')) {
      result = 'UPI ID "$contact" is not found in your verified contacts list. Proceed with caution.';
    } else if (contact.length == 10 && RegExp(r'^[0-9]+$').hasMatch(contact)) {
      result = 'Phone number "$contact" is not in your trusted contacts. Verify before making payments.';
    } else {
      result = 'Invalid contact format. Please enter a valid phone number or UPI ID.';
    }
    
    _showResultDialog('Contact Verification', result);
    setState(() => _isLoadingContact = false);
  }
  
  Future<void> _reportActivity() async {
    if (_reportController.text.trim().isEmpty) return;
    
    setState(() => _isLoadingReport = true);
    
    try {
      final result = await _fraudService.reportSuspiciousActivity(_reportController.text.trim());
      _showResultDialog('Suspicious Activity Report', result);
    } catch (e) {
      _showResultDialog('Error', 'Failed to analyze report. Please try again.');
    } finally {
      setState(() => _isLoadingReport = false);
    }
  }
  
  void _showResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
