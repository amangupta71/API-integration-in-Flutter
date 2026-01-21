import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiPage extends StatefulWidget {
  const GeminiPage({super.key});

  @override
  State<GeminiPage> createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _loading = false;

  Future<void> _askGemini() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _loading = true;
      _response = '';
    });

    try {
      final url = Uri.parse('http://localhost:2000/api/content');
      // For Android emulator use 10.0.2.2
      // For iOS simulator use localhost or your LAN IP

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': question}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _response = data['result'] ?? 'No response text';
        });
      } else {
        setState(() {
          _response = 'Error: ${res.statusCode} ${res.body}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini API Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ask Gemini something...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loading ? null : _askGemini,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send to Gemini'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_response, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
