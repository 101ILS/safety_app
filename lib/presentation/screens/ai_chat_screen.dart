import 'package:flutter/material.dart';

import '../../services/openai_service.dart';

class AiChatScreen extends StatefulWidget {
  static const routeName = '/ai-chat';

  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final controller = TextEditingController();

  final List<Map<String, String>> messages = [
    {
      "role": "ai",
      "text":
          "Здравствуйте! Я AI-ассистент по охране труда и технике безопасности. "
          "Могу помочь с пожарной безопасностью, электробезопасностью, инструктажами, "
          "безопасной работой с оборудованием и действиями при аварийных ситуациях."
    }
  ];

  bool loading = false;

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      loading = true;
    });

    controller.clear();

    final reply = await OpenAiService.ask(text);

    setState(() {
      messages.add({"role": "ai", "text": reply});
      loading = false;
    });
  }

  Widget quickButton(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        controller.text = text;
        sendMessage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI ассистент'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                quickButton('Что делать при пожаре?'),
                const SizedBox(width: 8),
                quickButton('Как проверить электрощит?'),
                const SizedBox(width: 8),
                quickButton('Какие правила при работе за компьютером?'),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: messages.map((msg) {
                final isUser = msg['role'] == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          if (loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Спросите по технике безопасности...',
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: loading ? null : sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}