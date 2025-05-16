import 'package:intl/intl.dart';
import 'package:daydream/utils/types/types.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StoryGenerator {
  static const String _apiUrl = 'https://ai.hackclub.com/chat/completions';

  static Future<String> generateContent(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to generate content: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating content: $e');
    }
  }

  static const String _systemPrompt =
      '''this is my journal entry. wyt? if it's small then i just wrote something in points, talk through it with me like a friend. don't therpaize me and give me a whole breakdown, don't repeat my thoughts with headings. really take all of this, and tell me back stuff truly as if you're an old homie.
    
    Keep it casual, dont say yo, help me make new connections i don't see, comfort, validate, challenge, all of it. dont be afraid to say a lot. 

    do not just go through every single thing i say, and say it back to me. you need to proccess everythikng is say, make connections i don't see it, and deliver it all back to me as a story that makes me feel what you think i wanna feel. thats what the best therapists do.

    ideally, you're style/tone should sound like the user themselves. it's as if the user is hearing their own tone but it should still feel different, because you have different things to say and don't just repeat back they say.

    else, start by saying, "hey, thanks for showing me this. my thoughts:"

    don't end with a question, just say what you think and end with a period. 
        
    my entry:''';

  static const String _chatSystemPrompt =
      '''You are a friendly journal companion who helps users reflect on their journal entries. You have access to their journal entry and should:
1. Be empathetic and understanding
2. Help them explore their thoughts and feelings
3. Make connections they might not see
4. Ask thoughtful questions to deepen their reflection
5. Keep the conversation casual and friendly
6. Don't therapize or diagnose
7. Don't repeat their thoughts back with headings
8. Speak in a tone similar to their writing style
9. Remember the conversation history and refer back to previous points when relevant

The journal entry you're discussing is:''';

  static Future<String> chatAboutJournal(
    String journalContent,
    String userMessage,
    List<Map<String, String>> conversationHistory,
  ) async {
    try {
      final messages = [
        {'role': 'system', 'content': '$_chatSystemPrompt\n\n$journalContent'},
        ...conversationHistory,
        {'role': 'user', 'content': userMessage},
      ];

      final client = http.Client();
      final request =
          http.Request('POST', Uri.parse(_apiUrl))
            ..headers['Content-Type'] = 'application/json'
            ..body = jsonEncode({'messages': messages, 'stream': true});

      final response = await client.send(request);

      if (response.statusCode == 200) {
        final responseBody = StringBuffer();

        await response.stream.transform(utf8.decoder).listen((chunk) {
          responseBody.write(chunk);
        }).asFuture();

        return responseBody.toString();
      } else {
        throw Exception('Failed to get chat response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in chat: $e');
    }
  }

  static Future<String> generateAIStory(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to generate story: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating story: $e');
    }
  }
}

Future<Note> generateStory(Note note) async {
  try {
    final prompt =
        '''Journal entry: ${note.content.map((item) => item['insert']).join('')}

Please analyze this journal entry and provide:
1. A list of relevant tags (3-5 words that categorize this entry, make sure it says about the person emotional state)
2. The overall mood of the entry (one word)
3. A brief reflection (3-10 words) about what this entry reveals about the person

Format your response as JSON:
{
  "tags": ["tag1", "tag2", "tag3"],
  "mood": "mood",
  "reflect": "reflection"
}

Then provide your usual friendly response after the JSON.''';

    final storyContent = await StoryGenerator.generateAIStory(prompt);

    // Extract JSON from the response
    final jsonStart = storyContent.indexOf('{');
    final jsonEnd = storyContent.lastIndexOf('}') + 1;
    final jsonStr = storyContent.substring(jsonStart, jsonEnd);
    final analysis = jsonDecode(jsonStr);

    final generatedContent = [
      // Journal Entry Section
      {
        'insert': 'Your Entry\n',
        'attributes': {'bold': true, 'size': 20, 'color': '#2C3E50'},
      },
      {'insert': '${note.plainContent}\n\n'},

      // Divider
      {
        'insert': '• • •\n',
        'attributes': {'align': 'center', 'color': '#95A5A6', 'size': 16},
      },

      // AI Response Section
      {
        'insert': 'Journal Response\n',
        'attributes': {'bold': true, 'size': 16, 'color': '#3498DB'},
      },
      {'insert': storyContent.substring(jsonEnd + 1)},

      // Tags Section
      {
        'insert': 'Tags\n',
        'attributes': {'bold': true, 'size': 16, 'color': '#E74C3C'},
      },

      {'insert': '${(analysis['tags'] as List).join(', ')}\n\n'},

      // Mood Section
      {
        'insert': 'Mood\n',
        'attributes': {'bold': true, 'size': 16, 'color': '#E67E22'},
      },
      {'insert': '${analysis['mood']}\n\n'},

      // Reflection Section
      {
        'insert': 'Reflection\n',
        'attributes': {'bold': true, 'size': 16, 'color': '#27AE60'},
      },
      {'insert': '${analysis['reflect']}\n\n'},
    ];

    return Note(
      date: note.date,
      content: generatedContent,
      plainContent:
          'Generated story for ${DateFormat('MMM d, yyyy').format(note.date)}',
      id: note.id,
      isGenerated: true,
      tags: List<String>.from(analysis['tags']),
      mood: analysis['mood'],
      reflect: analysis['reflect'],
    );
  } catch (e) {
    // Fallback content in case AI generation fails
    final generatedContent = [
      {
        'insert': 'Unable to generate story at this time.\n',
        'attributes': {'color': '#E74C3C', 'italic': true},
      },
      {
        'insert': 'Please try again later.\n\n',
        'attributes': {'color': '#E74C3C', 'italic': true},
      },
    ];

    return Note(
      date: note.date,
      content: generatedContent,
      plainContent:
          'Generated story for ${DateFormat('MMM d, yyyy').format(note.date)}',
      id: note.id,
      isGenerated: true,
    );
  }
}
