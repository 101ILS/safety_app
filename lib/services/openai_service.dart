import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class OpenAiService {
  static const _apiKey = String.fromEnvironment('OPENAI_API_KEY');

  static Future<String> ask(String message) async {
    if (_apiKey.isEmpty) {
      return 'API ключ OpenAI не настроен.';
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "temperature": 0.2,
        "messages": [
          {
            "role": "system",
            "content": """
Ты — корпоративный AI-ассистент по охране труда и технике безопасности для предприятия инженерно-технического проектирования.

Ты отвечаешь ТОЛЬКО на темы:
- охрана труда;
- техника безопасности;
- пожарная безопасность;
- электробезопасность;
- безопасность офисной и проектной работы;
- безопасность инженерных систем;
- действия при авариях;
- инструктажи;
- использование СИЗ;
- безопасная работа с оборудованием;
- AR-аудит оборудования;
- требования к рабочему месту.

Если вопрос НЕ связан с этими темами, вежливо откажись и скажи:
"Я могу помочь только по вопросам охраны труда, техники безопасности и инженерной безопасности предприятия."

Отвечай кратко, понятно и по шагам.
Не ставь медицинские диагнозы.
Не заменяй специалиста по охране труда.
"""
          },
          {
            "role": "user",
            "content": message,
          }
        ],
      }),
    );

    if (response.statusCode != 200) {
      return 'Не удалось получить ответ от AI. Проверьте API ключ или подключение.';
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }

  static Future<String?> rawRequest(String prompt) async {
    if (_apiKey.isEmpty) return null;

    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "temperature": 0.3,
          "messages": [
            {
              "role": "system",
              "content":
                  "Ты эксперт по технике безопасности. Отвечай только чистым JSON без markdown."
            },
            {
              "role": "user",
              "content": prompt,
            }
          ],
        }),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      return data['choices']?[0]?['message']?['content'];
    } catch (e) {
      return null;
    }
  }

  static Future<String?> analyzeEquipmentImage(Uint8List imageBytes) async {
    if (_apiKey.isEmpty) return null;

    try {
      final base64Image = base64Encode(imageBytes);

      final url = Uri.parse('https://api.openai.com/v1/chat/completions');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "temperature": 0.2,
          "messages": [
            {
              "role": "system",
              "content":
                  "Ты AI-аудитор по технике безопасности инженерного предприятия. Анализируй фото оборудования и возвращай только JSON без markdown."
            },
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": """
Проанализируй изображение оборудования.

Определи:
- objectName
- riskLevel: low, medium или high
- findings: список замечаний
- recommendations: список рекомендаций

Важно:
- не выдумывай опасные нарушения, если их не видно;
- если изображение не связано с оборудованием, укажи objectName: \"Неизвестный объект\";
- отвечай строго JSON:

{
  "objectName": "...",
  "riskLevel": "medium",
  "findings": ["..."],
  "recommendations": ["..."]
}
"""
                },
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "data:image/jpeg;base64,$base64Image"
                  }
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      return data['choices']?[0]?['message']?['content'];
    } catch (e) {
      return null;
    }
  }
}
