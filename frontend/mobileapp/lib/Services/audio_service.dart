import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  String? _currentRecordingPath;
  bool _isRecorderInitialized = false;

  /// Initialize the audio recorder and request permission
  Future<void> initializeRecorder() async {
    try {
      // Request microphone permission
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Microphone permission not granted');
      }

      await _audioRecorder.openRecorder();
      _isRecorderInitialized = true;
    } catch (e) {
      debugPrint('Error initializing recorder: $e');
      throw Exception('Failed to initialize recorder');
    }
  }

  /// Start recording audio
  Future<void> startRecording() async {
    try {
      if (!_isRecorderInitialized) {
        await initializeRecorder();
      }

      final directory = await getTemporaryDirectory();
      _currentRecordingPath =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );
    } catch (e) {
      debugPrint('Error starting recording: $e');
      rethrow;
    }
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    try {
      if (_audioRecorder.isRecording) {
        await _audioRecorder.stopRecorder();
        return _currentRecordingPath;
      }
      return null;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  /// Dispose of the recorder resources
  Future<void> dispose() async {
    try {
      if (_isRecorderInitialized) {
        await _audioRecorder.closeRecorder();
        _isRecorderInitialized = false;
      }
    } catch (e) {
      debugPrint('Error disposing recorder: $e');
    }
  }
}
