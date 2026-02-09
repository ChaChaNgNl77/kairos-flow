import 'dart:convert';
import 'package:http/http.dart' as http;

//import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  //static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent';

  Future<Map<String, dynamic>> analyzeConcern({
    required String concern,
    required int severity,
    String? userOptionA,
    String? userOptionB,
  }) async {
    String optionContext = (userOptionA != null && userOptionB != null)
        ? 'User explicitly defined options: Option A="$userOptionA", Option B="$userOptionB"'
        : 'You must create two logical paths: Option A (Action/Change) vs Option B (Inaction/Maintain status quo).';

    final promptText =
        '''
        
      [CRITICAL: LANGUAGE RULE]
      - Detect the language of the user's concern: "$concern".
      - You MUST respond entirely in that SAME LANGUAGE.
      - If the concern is in English, all fields (title, desc, recommendation, timeline, action_steps) MUST be in English.
      - If the concern is in Korean, all fields MUST be in Korean.
      - NEVER mix languages.

      [PERSONA]
      You are a warm, wise, and witty life-mentor who helps people make decisions easily. 
      Your tone should be friendly, clear, and encouraging—like a supportive friend who is also incredibly smart.
      Avoid overly formal, academic, or "robotic consultant" language.

      [Context]
      - Concern: "$concern"
      - Severity: $severity / 5 (Note: This indicates emotional weight, NOT timeline length)
      - $optionContext

      [CRITICAL: Tone & Style Guidelines]
      1. Use "You-centric" language: Instead of "The research shows," say "You'll feel much better when..."
      2. Be concise but empathetic: Get straight to the point but acknowledge the user's feelings.
      3. Use active, conversational verbs: Instead of "Implement a strategy," say "Start by doing..."
      4. No Jargon: Use words a 10-year-old could understand, but with the wisdom of a mentor.
      
      [CRITICAL: Timeline Intelligence]
      
      You must analyze the concern's NATURAL TIMELINE based on these factors, NOT the severity level:
      
      **Factor 1: Urgency Assessment**
      - Does this have a deadline? (job interview, event, expiration)
      - Is there time pressure? (limited opportunity, competitive situation)
      - Can this wait indefinitely?
      
      **Factor 2: Impact Duration**
      - Is this a one-time decision? (what to eat tonight, which movie to watch)
      - Does this create ongoing effects? (starting a habit, moving cities)
      - Will consequences compound over time?
      
      **Factor 3: Complexity & Steps Required**
      - Simple binary choice? (yes/no, this/that)
      - Multiple steps needed? (research → decide → implement)
      - Requires behavioral change? (building habits, learning skills)
      
      **Timeline Scale Selection Rules:**
      
      Use SHORT timeline (minutes to days) when:
      - Immediate deadline exists
      - One-time simple decision
      - Quick action resolves it
      - Examples: "10 Mins", "1 Hour", "Tonight", "Tomorrow", "This Week"
      
      Use MEDIUM timeline (weeks to months) when:
      - No urgent deadline but moderate complexity
      - Requires planning or preparation
      - Results emerge gradually
      - Examples: "Next Week", "2 Weeks", "1 Month", "3 Months"
      
      Use LONG timeline (months to years) when:
      - Life-changing decision with lasting impact
      - Requires sustained effort or habit formation
      - Benefits/consequences unfold slowly
      - Examples: "6 Months", "1 Year", "2 Years", "5 Years"
      
      **Real-World Examples:**
      
      ❌ WRONG: "Should I text my ex?" (severity 5, emotional weight) → "6 Months", "2 Years", "5 Years"
      ✅ RIGHT: "Should I text my ex?" → "10 Mins" (impulse), "Tonight" (after reflection), "Tomorrow" (with clarity)
      
      ❌ WRONG: "What should I eat for dinner?" (severity 1, trivial) → "1 Hour", "Tonight", "Tomorrow"  
      ✅ RIGHT: "What should I eat for dinner if I have diabetes?" → "Tonight" (immediate), "1 Week" (habit forming), "3 Months" (health impact)
      
      ❌ WRONG: "Should I quit my job?" (severity 5) → Must use long timeline
      ✅ RIGHT: "Should I quit my job? (I have an offer expiring Friday)" → "Tomorrow", "This Week", "Next Month"
      
      [Instructions]
      1. **Timeline Intelligence First**: Analyze urgency, impact duration, and complexity to determine the NATURAL timeline
      2. **Deep Analysis**: Analyze pros, cons, and trade-offs
      3. **Dynamic Timeline Prediction**: Generate EXACTLY 3 predictions at progressively increasing time intervals
      4. **Action Plan**: Create EXACTLY 4 specific, actionable steps
      5. **Simple Output**: Summarize into concise JSON

      [Output Requirement - STRICT FORMAT]
      
      ⚠️ CRITICAL RULES:
      - timeline array MUST contain EXACTLY 3 items (no more, no less)
      - action_steps array MUST contain EXACTLY 4 items (no more, no less)
      - Each timeline entry MUST have "time" and "desc" fields
      
      Output ONLY a valid JSON object with this EXACT structure (No Markdown):
      {
        "isValid": true,
        "option_a": { "title": "Short Title", "desc": "Summary", "score": 70 },
        "option_b": { "title": "Short Title", "desc": "Summary", "score": 30 },
        "recommendation": "A single sentence advising what to do.",
        "timeline": [
          { "time": "Near-term checkpoint", "desc": "What happens in the immediate future" },
          { "time": "Mid-term checkpoint", "desc": "What develops over time" },
          { "time": "Long-term checkpoint", "desc": "The ultimate outcome" }
        ],
        "action_steps": [
          "First immediate action",
          "Second follow-up action",
          "Third monitoring action",
          "Fourth reflection action"
        ]
      }
      
      ⚠️ VALIDATION CHECKLIST before responding:
      - [ ] Does timeline have exactly 3 items?
      - [ ] Does action_steps have exactly 4 items?
      - [ ] Are timeline intervals progressively increasing?
      - [ ] Is each prediction specific to this concern?
      
      REMEMBER: 
      - Timeline MUST have exactly 3 checkpoints.
      - Timeline intervals reflect the NATURAL progression of THIS SPECIFIC concern, not its emotional severity.
      - Action steps MUST have exactly 4 items.
      - Output MUST be in the user's language ("$concern").
    ''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": promptText},
              ],
            },
          ],
          "generationConfig": {
            "response_mime_type": "application/json",
            "temperature": 0.7,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] == null || data['candidates'].isEmpty) {
          throw Exception("No candidates returned");
        }

        String rawText = data['candidates'][0]['content']['parts'][0]['text'];

        // JSON 파싱 전처리
        String cleanJson = rawText
            .replaceAll(RegExp(r'^```json'), '')
            .replaceAll(RegExp(r'^```'), '')
            .replaceAll('```', '')
            .trim();

        return jsonDecode(cleanJson);
      } else {
        print("🚨 서버 에러 Body: ${response.body}");
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 로직 에러: $e");
      return {
        "isValid": false,
        "option_a": {
          "title": "Error",
          "desc": "Check API Key or Network",
          "score": 0,
        },
        "option_b": {
          "title": "Error",
          "desc": "Check API Key or Network",
          "score": 0,
        },
        "recommendation": "System Error: Please try again.",
        "timeline": [],
        "action_steps": [
          "Please try again",
          "Check your internet connection",
          "Verify API key is correct",
          "Contact support if issue persists",
        ],
      };
    }
  }
}
