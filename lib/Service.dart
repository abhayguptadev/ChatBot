import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ChatMsg.dart';

class GroqApiService {
  static const String _apiKey = 'YOUR API HERE';


  // now question is how secure our api
  // use api in your backend, and make venv in code and add this to .gitignore
  // full code on my github account " @abhayguptadev "


  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';
  Future<String> sendMessageToGroq(List<ChatMessage> history) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': history.map((msg) => msg.toJson()).toList(),
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // FIX 2: Correct array navigation mapping index
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        try {
          final errorData = jsonDecode(response.body);

          return 'Error: ${response
              .statusCode} - ${errorData['error']['message'] ??
              'Unknown error'}';
        } catch (_) {
          return 'Error: ${response
              .statusCode} - Server returned unreadable body.';
        }
      }
    } catch (e) {
      return 'Network Error: Failed to connect to Groq API. ($e)';
    }
  }
}