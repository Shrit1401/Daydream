import 'package:intl/intl.dart';
import 'package:daydream/utils/types/types.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StoryGenerator {
  static const String _apiUrl = 'https://ai.hackclub.com/chat/completions';

  static const String _systemPrompt =
      '''this is my journal entry. wyt? if it's small then i just wrote something in points, talk through it with me like a friend. don't therpaize me and give me a whole breakdown, don't repeat my thoughts with headings. really take all of this, and tell me back stuff truly as if you're an old homie.
    
    Keep it casual, dont say yo, help me make new connections i don't see, comfort, validate, challenge, all of it. dont be afraid to say a lot. 

    do not just go through every single thing i say, and say it back to me. you need to proccess everythikng is say, make connections i don't see it, and deliver it all back to me as a story that makes me feel what you think i wanna feel. thats what the best therapists do.

    ideally, you're style/tone should sound like the user themselves. it's as if the user is hearing their own tone but it should still feel different, because you have different things to say and don't just repeat back they say.

    else, start by saying, "hey, thanks for showing me this. my thoughts:"
        
    my entry:''';

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
    final prompt = '''Journal entry: ${note.plainContent}''';

    final storyContent = await StoryGenerator.generateAIStory(prompt);

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
      {'insert': storyContent},
    ];

    return Note(
      date: note.date,
      content: generatedContent,
      plainContent:
          'Generated story for ${DateFormat('MMM d, yyyy').format(note.date)}',
      id: note.id,
      isGenerated: true,
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
