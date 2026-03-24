import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _isInitialized = false;
  bool _musicPlaying = false;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get isInitialized => _isInitialized;

  /// Initialize audio service and load preferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load sound preferences from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _musicEnabled = prefs.getBool('music_enabled') ?? true;

      // Preload audio files
      await _preloadAudio();
      _isInitialized = true;
      
      if (kDebugMode) {
        debugPrint('AudioService initialized - Sound: $_soundEnabled, Music: $_musicEnabled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AudioService initialization error: $e');
      }
      _isInitialized = true;
    }
  }

  /// Preload all audio files
  Future<void> _preloadAudio() async {
    try {
      final loadedFiles = await FlameAudio.audioCache.loadAll([
        'audio/background_music.wav',
        'audio/collision.wav',
        'audio/powerup.wav',
        'audio/gameover.wav',
        'audio/level_complete.wav',
      ]);
      if (kDebugMode) {
        debugPrint('Preloaded ${loadedFiles.length} audio files');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error preloading audio: $e');
      }
    }
  }

  /// Toggle sound effects on/off
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await _savePreferences();
    if (kDebugMode) {
      debugPrint('Sound effects ${_soundEnabled ? 'enabled' : 'disabled'}');
    }
  }

  /// Toggle background music on/off
  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    if (_musicEnabled) {
      startBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
    await _savePreferences();
    if (kDebugMode) {
      debugPrint('Background music ${_musicEnabled ? 'enabled' : 'disabled'}');
    }
  }

  /// Save preferences to SharedPreferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', _soundEnabled);
      await prefs.setBool('music_enabled', _musicEnabled);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving preferences: $e');
      }
    }
  }

  /// Start background music (loops)
  void startBackgroundMusic() {
    if (!_musicEnabled || !_isInitialized || _musicPlaying) return;

    try {
      FlameAudio.bgm.initialize();
      FlameAudio.bgm.play(
        'audio/background_music.wav',
        volume: 0.5,
      );
      _musicPlaying = true;
      if (kDebugMode) {
        debugPrint('Background music started');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error starting background music: $e');
      }
    }
  }

  /// Stop background music
  void stopBackgroundMusic() {
    try {
      FlameAudio.bgm.stop();
      _musicPlaying = false;
      if (kDebugMode) {
        debugPrint('Background music stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error stopping background music: $e');
      }
    }
  }

  /// Play a sound effect
  void playSound(String soundFile) {
    if (!_soundEnabled || !_isInitialized) return;

    try {
      FlameAudio.play(soundFile, volume: 0.8);
      if (kDebugMode) {
        debugPrint('Playing sound: $soundFile');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing sound $soundFile: $e');
      }
    }
  }

  /// Play collision sound
  void playCollisionSound() {
    playSound('audio/collision.wav');
  }

  /// Play power-up collection sound
  void playPowerUpSound() {
    playSound('audio/powerup.wav');
  }

  /// Play game over sound
  void playGameOverSound() {
    playSound('audio/gameover.wav');
  }

  /// Play level complete sound
  void playLevelCompleteSound() {
    playSound('audio/level_complete.wav');
  }

  /// Dispose audio resources
  void dispose() {
    stopBackgroundMusic();
  }
}
