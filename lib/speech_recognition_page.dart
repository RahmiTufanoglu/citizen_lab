import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(SpeechRecognitionPage());

class SpeechRecognitionPage extends StatefulWidget {
  @override
  _SpeechRecognitionPageState createState() => _SpeechRecognitionPageState();
}

enum TtsState { playing, stopped }

class _SpeechRecognitionPageState extends State<SpeechRecognitionPage> {
  FlutterTts flutterTts;
  dynamic languages;
  dynamic voices;
  String language;
  String voice;

  String _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    if (Platform.isAndroid) {
      flutterTts.ttsInitHandler(() {
        _getLanguages();
        _getVoices();
      });
    } else if (Platform.isIOS) {
      _getLanguages();
      _getVoices();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) setState(() => languages);
  }

  Future _getVoices() async {
    voices = await flutterTts.getVoices;
    if (voices != null) setState(() => voices);
  }

  Future _speak() async {
    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        final result = await flutterTts.speak(_newVoiceText);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  Future _stop() async {
    final result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems() {
    final items = List<DropdownMenuItem<String>>();
    for (final String type in languages) {
      items.add(DropdownMenuItem(
        value: type,
        child: Text(type),
      ));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getVoiceDropDownMenuItems() {
    final items = List<DropdownMenuItem<String>>();
    for (final String type in voices) {
      items.add(DropdownMenuItem(
        value: type,
        child: Text(type),
      ));
    }
    return items;
  }

  void changedLanguageDropDownItem(String selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language);
    });
  }

  void changedVoiceDropDownItem(String selectedType) {
    setState(() {
      voice = selectedType;
      flutterTts.setVoice(voice);
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Flutter TTS'),
            ),
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(children: [
                  inputSection(),
                  btnSection(),
                  languages != null ? languageDropDownSection() : const Text(''),
                  voices != null ? voiceDropDownSection() : const Text('')
                ]))));
  }

  Widget inputSection() => Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      child: TextField(
        onChanged: (String value) {
          _onChange(value);
        },
      ));

  Widget btnSection() => Container(
      padding: const EdgeInsets.only(top: 50.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildButtonColumn(
            Colors.green, Colors.greenAccent, Icons.play_arrow, 'PLAY', _speak),
        _buildButtonColumn(
            Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop)
      ]));

  Widget languageDropDownSection() => Container(
      padding: const EdgeInsets.only(top: 50.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(),
          onChanged: changedLanguageDropDownItem,
        )
      ]));

  Widget voiceDropDownSection() => Container(
      padding: const EdgeInsets.only(top: 50.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: voice,
          items: getVoiceDropDownMenuItems(),
          onChanged: changedVoiceDropDownItem,
        )
      ]));

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(icon),
              color: color,
              splashColor: splashColor,
              onPressed: () => func()),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }
}