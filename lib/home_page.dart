import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant_felipe_silva/feature_box.dart';
import 'package:voice_assistant_felipe_silva/openai_service.dart';
import 'package:voice_assistant_felipe_silva/palette.dart';

// stfw --> estate full widget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();

  final flutterTts = FlutterTts();
  String? generatedContent;
  String? generateImagenUrl;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(
      onResult: onSpeechResult,
    );
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('Voice Assistant')),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // virtual assistant picture
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Palette.assistantCicleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage(
                          "assets/images/virtualAssistant.png",
                        ))),
                  )
                ],
              ),
            ),
            // Chat dobble
            FadeInRight(
              child: Visibility(
                visible: generateImagenUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Palette.borderColor,
                      ),
                      borderRadius: BorderRadius.circular(20)
                          .copyWith(topLeft: Radius.zero)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedContent == null
                          ? 'Goog morning what task can I do for you?'
                          : generatedContent!,
                      style: const TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Palette.mainFontColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (generateImagenUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(generateImagenUrl!)),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generateImagenUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 10, left: 30),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                        color: Palette.mainFontColor,
                        fontFamily: 'Cera Pro',
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            // features list
            Visibility(
              visible: generatedContent == null && generateImagenUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: const Duration(milliseconds: 300),
                    child: const FeatureBox(
                        color: Palette.firstSuggestionBoxColor,
                        headerText: 'ChatGPT',
                        descriptionText:
                            'A smarter way to arganized and informed with ChatGPT'),
                  ),
                  SlideInLeft(
                    delay: const Duration(milliseconds: 800),
                    child: const FeatureBox(
                        color: Palette.secondSuggestionBoxColor,
                        headerText: 'Dall-E',
                        descriptionText:
                            'Get inspired and stay creative with your personal assistant powered by Ball-E'),
                  ),
                  SlideInLeft(
                    delay: const Duration(milliseconds: 1000),
                    child: const FeatureBox(
                        color: Palette.thirdSuggestionBoxColor,
                        headerText: 'Smart Voice Assistant',
                        descriptionText:
                            'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      // boton para grabar audio
      floatingActionButton: ZoomIn(
        delay: const Duration(milliseconds: 1000),
        child: FloatingActionButton(
          backgroundColor: Palette.blackColor,
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAIService.isArtPrompAPI(lastWords);

              if (speech.contains('https')) {
                generateImagenUrl = speech;
                generatedContent = null;
                setState(() {});
              } else {
                generateImagenUrl = null;
                generatedContent = speech;
                await systemSpeak(speech);
                setState(() {});
              }

              await stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: Icon(
            speechToText.isListening ? Icons.stop : Icons.mic,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
