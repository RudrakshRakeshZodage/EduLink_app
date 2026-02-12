import 'dart:convert';
import 'package:http/http.dart' as http;

class DidService {
  static const String _apiKey = 'c2F1bnRhbmlzaGFAZ21haWwuY29t:Ej53tRZ93T1JVY_Ec9QGF';
  static const String _baseUrl = 'https://api.d-id.com';

  // Create a talking video from text
  Future<String?> createTalk(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/talks'),
        headers: {
          'Authorization': 'Basic $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'source_url': 'https://clips-presenters.d-id.com/amy/image.png',
          'script': {
            'type': 'text',
            'input': text,
            'provider': {
              'type': 'microsoft',
              'voice_id': 'en-US-JennyNeural',
            },
          },
          'config': {
            'fluent': true,
            'pad_audio': 0,
          },
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final talkId = data['id'];
        
        // Poll for video URL
        return await _pollForVideo(talkId);
      } else {
        print('D-ID Create Talk Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('D-ID Service Error: $e');
      return null;
    }
  }

  // Poll until video is ready
  Future<String?> _pollForVideo(String talkId) async {
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/talks/$talkId'),
          headers: {
            'Authorization': 'Basic $_apiKey',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status = data['status'];
          
          if (status == 'done') {
            return data['result_url'];
          } else if (status == 'error') {
            print('D-ID Video Generation Error: ${data['error']}');
            return null;
          }
        }
      } catch (e) {
        print('D-ID Polling Error: $e');
      }
    }
    
    print('D-ID: Video generation timed out');
    return null;
  }
}
