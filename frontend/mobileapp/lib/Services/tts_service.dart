import 'package:flutter_tts/flutter_tts.dart';

/// Service to handle all Text-to-Speech operations
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  /// Initialize the TTS engine with default settings
  Future<void> initialize({String language = 'ar-EG'}) async {
    if (!_isInitialized) {
      await _tts.setLanguage(language);
      await _tts.setSpeechRate(0.5); // Slightly slower for language learning
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    }
  }

  /// Speak the provided text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _tts.stop(); // Stop any ongoing speech
    await _tts.speak(text);
  }

  /// Stop ongoing speech
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Change the language
  Future<void> setLanguage(String language) async {
    await _tts.setLanguage(language);
  }

  /// Cleanup resources
  Future<void> dispose() async {
    await _tts.stop();
  }
}