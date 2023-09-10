import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:voice_assistant_felipe_silva/secrets.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];

  Future<String> isArtPrompAPI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey'
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content':
                  'Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simple answer with yes or no',
            }
          ]
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();

        switch (content.toLowerCase()) {
          case 'yes':
          case 'Yes':
          case 'yes.':
          case 'Yes.':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGTPAPI(prompt);
            return res;
        }
      }
      return jsonDecode(response.body)['error']['message'].toString();
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGTPAPI(String prompt) async {
    messages.add({'role': 'user', 'content': prompt});
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey'
        },
        body: jsonEncode({'model': 'gpt-3.5-turbo', 'messages': messages}),
      );
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({'role': 'assistant', 'content': content});
        return content;
      }
      return 'An internal error ocurred...';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({'role': 'user', 'content': prompt});
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey'
        },
        body: jsonEncode({'promp': prompt, 'n': 1}),
      );
      if (response.statusCode == 200) {
        String imageUrl = jsonDecode(response.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({'role': 'assistant', 'content': imageUrl});
        return imageUrl;
      }
      return 'An internal error ocurred...';
    } catch (e) {
      return e.toString();
    }
  }
}
