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

    USE FORMATTING in your response:
    - Use headers (H1, H2) for important sections
    - Use bullet points for lists
    - Use italic or bold text for emphasis
    - You can organize your thoughts in sections with headers
    
    else, start by saying, "hey, thanks for showing me this. my thoughts:"

    don't end with a question, just say what you think and end with a period. 
        
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
    final prompt =
        '''Journal entry: ${note.content.map((item) => item['insert']).join('')}

Please analyze this journal entry and provide:
1. A list of relevant tags (3-5 words that categorize this entry, make sure it says about the person emotional state)
2. The overall mood of the entry (one word)
3. A brief reflection (3-10 words) about what this entry reveals about the person
4. A thoughtful, well-formatted response (at least 200-300 words) that provides insights and reflections on the journal entry

Format your ENTIRE response as JSON with the following structure:
{
  "tags": ["tag1", "tag2", "tag3"],
  "mood": "mood",
  "reflect": "reflection",
  "response": [
    {
      "insert": "Main Heading",
      "attributes": {"bold": true, "size": 24, "color": "#000000"}
    },
    {
      "insert": "\\n",
      "attributes": {"header": 1}
    },
    {
      "insert": "\\n"
    },
    {
      "insert": "This is a paragraph of normal text. Make sure to provide at least 200-300 words of thoughtful insights."
    },
    {
      "insert": "\\n\\n"
    },
    {
      "insert": "Subheading",
      "attributes": {"bold": true, "size": 20, "color": "#000000"}
    },
    {
      "insert": "\\n",
      "attributes": {"header": 2}
    },
    {
      "insert": "\\n"
    },
    {
      "insert": "This is a bullet point item"
    },
    {
      "insert": "\\n",
      "attributes": {"list": "bullet"}
    },
    {
      "insert": "This is another bullet point item"
    },
    {
      "insert": "\\n",
      "attributes": {"list": "bullet"}
    },
    {
      "insert": "\\n"
    },
    {
      "insert": "This text has "
    },
    {
      "insert": "bold",
      "attributes": {"bold": true}
    },
    {
      "insert": " and "
    },
    {
      "insert": "italic",
      "attributes": {"italic": true}
    },
    {
      "insert": " formatting."
    },
    {
      "insert": "\\n\\n"
    },
    {
      "insert": "Another paragraph with more insights would go here. Remember to include multiple paragraphs with proper spacing between them."
    },
    {
      "insert": "\\n"
    }
  ]
}

IMPORTANT FORMATTING GUIDELINES for the "response" field:
1. SPACING AND LAYOUT:
   - Add an empty line ({"insert": "\\n"}) after each heading before content begins
   - Use double line breaks ({"insert": "\\n\\n"}) between paragraphs for better readability
   - Group bullet points together with no extra spacing between items in the list
   - Add an empty line after the last bullet point in a list

2. CONTENT REQUIREMENTS:
   - Write at least 200-300 words total in your response
   - Use 2-3 different headers to organize your thoughts
   - Include at least one bulleted list
   - Be conversational and friendly, as if talking to a friend
   - Provide meaningful insights about the journal entry

3. FORMATTING OPTIONS:
   - Main headers: Use header 1 with attributes {"header": 1} on the newline character, and always use color: "#000000"
   - Subheaders: Use header 2 with attributes {"header": 2} on the newline character, and always use color: "#000000"
   - Bullet points: Add attributes {"list": "bullet"} to the newline character
   - Text formatting: Use separate insert objects for bold, italic, or colored text

IMPORTANT: Do NOT use markdown syntax (like #, ##, *, etc.) in your text. Only use the Quill Delta format for all formatting, as shown in the example. Headings must be created using the 'header' attribute in the Delta, not with # or ##.

Make sure all closing brackets and braces are properly placed. The entire response must be valid JSON.''';

    final storyContent = await StoryGenerator.generateAIStory(prompt);

    // Parse the entire response as JSON
    final responseData = jsonDecode(storyContent);

    // Extract the components from the JSON
    final tags = List<String>.from(responseData['tags']);
    final mood = responseData['mood'] as String;
    final reflect = responseData['reflect'] as String;
    final responseContent = List<Map<String, dynamic>>.from(
      responseData['response'],
    );

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
      // Add the AI response in Delta format
      ...responseContent,
      {'insert': '\n'},

      // Tags Section
      {
        'insert': 'Tags\n',
        'attributes': {'bold': true, 'size': 16, 'color': '#E74C3C'},
      },
      {'insert': '${tags.join(', ')}\n\n'},

      // Mood Section
      {
        'insert': 'Mood\n',
        'attributes': {'bold': true, 'size': 16, 'color': '#E67E22'},
      },
      {'insert': '$mood\n\n'},

      // Reflection Section
      {
        'insert': 'Reflection\n',
        'attributes': {'bold': true, 'size': 16, 'color': '#27AE60'},
      },
      {'insert': '$reflect\n\n'},
    ];

    return Note(
      date: note.date,
      content: generatedContent,
      plainContent: reflect,
      id: note.id,
      isGenerated: true,
      tags: tags,
      mood: mood,
      reflect: reflect,
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
