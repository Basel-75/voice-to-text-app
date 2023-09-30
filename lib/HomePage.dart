import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isAvailable = false;
  String speech = '';
  Color blue = Colors.blue;
  Color red = Colors.red;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
  }

  void initSpeechToText() async {
    _isAvailable = await _speechToText.initialize();
    if (_isAvailable) {
      _speechToText.errorListener!((error) {
        print("Error: $error");
      } as SpeechRecognitionError);
    }
  }

  void toggleRecording() {
    if (_isAvailable) {
      if (isRecording) {
        _speechToText.stop();
      } else {
        final locales = ['en_US', 'ar_AE'];
        _speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              setState(() {
                speech = result.recognizedWords;
              });
            }
          },
          localeId: locales[1],
        );
      }
      setState(() {
        isRecording = !isRecording;
      });
    } else {
      // Handle speech recognition not available
      // e.g., show a message
    }
  }

  void copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: speech));
    // Show a copied successfully message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          const Text(
            'Your speech is:',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blueGrey,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  speech,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: copyToClipboard,
                icon: const Icon(
                  Icons.copy,
                  color: Colors.green,
                ),
              ),
              const Text('Copy'),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: toggleRecording,
            child: AvatarGlow(
              glowColor: isRecording ? red : blue,
              endRadius: 40.0,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              showTwoGlows: true,
              repeatPauseDuration: const Duration(milliseconds: 100),
              child: Material(
                elevation: 8.0,
                shape: const CircleBorder(),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  child: const Icon(Icons.mic),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }
}
