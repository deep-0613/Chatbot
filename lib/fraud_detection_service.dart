import 'package:google_generative_ai/google_generative_ai.dart';

class FraudDetectionService {
  late GenerativeModel _model;
  
  FraudDetectionService() {
    _initializeModel();
  }
  
  void _initializeModel() {
    // Your Gemini API key
    const apiKey = 'Youe API Key';
    
    if (apiKey.isEmpty) {
      throw Exception('API key cannot be empty');
    }
    
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
    );
  }
  
  Future<String> analyzeFraudRisk(String userInput) async {
    try {
      print('Analyzing message: $userInput');
      
      final prompt = '''
You are Fraud Guard AI, a cyber awareness and fraud detection expert. Analyze the following user message for potential fraud risks:

User Message: "$userInput"

Provide a response that:
1. Identifies if this is a potential scam/fraud
2. Explains the red flags 
3. Gives specific safety advice
4. Is conversational and helpful
5. Focuses on Indian context if relevant (UPI, electricity bills, etc.)

Keep responses concise but informative (2-3 sentences max).
''';
      
      print('Sending request to Gemini API...');
      final response = await _model.generateContent([Content.text(prompt)]);
      
      if (response.text == null || response.text!.isEmpty) {
        print('Received empty response from API');
        return 'I apologize, but I cannot process this request right now. Please try again.';
      }
      
      print('Received response: ${response.text}');
      return response.text!;
      
    } catch (e, stackTrace) {
      print('Error in analyzeFraudRisk: $e');
      print('Stack trace: $stackTrace');
      return 'I apologize, but I encountered an error: ${e.toString()}. Please try again.';
    }
  }
  
  Future<String> validateUPIId(String upiId) async {
    try {
      final prompt = '''
Analyze this UPI ID for potential fraud: "$upiId"

Check for:
- Fake/look-alike patterns
- Typo-squatting attempts
- Suspicious domain patterns
- Known scam prefixes

Provide a risk assessment (Low/Medium/High) with brief explanation.
''';
      
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to validate UPI ID at this moment.';
    } catch (e) {
      return 'Error validating UPI ID. Please try again.';
    }
  }
  
  Future<String> getDailyTip() async {
    try {
      final prompt = '''
Generate a daily cyber security/fraud prevention tip. Focus on:
- UPI safety
- Online scams
- Phishing awareness
- Digital payment security

Keep it concise and actionable (1-2 sentences).
''';
      
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Stay safe online by verifying unknown contacts before making payments.';
    } catch (e) {
      return 'Daily tip: Always double-check payment details before confirming transactions.';
    }
  }
  
  Future<String> reportSuspiciousActivity(String report) async {
    try {
      final prompt = '''
Analyze this suspicious activity report: "$report"

Provide:
1. Risk assessment
2. Immediate safety steps
3. Whether this should be reported to authorities
4. Prevention measures for the future

Be thorough but clear in your response.
''';
      
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Thank you for reporting. Stay vigilant and verify all unexpected requests.';
    } catch (e) {
      return 'Error processing report. Please contact customer support if needed.';
    }
  }
}
