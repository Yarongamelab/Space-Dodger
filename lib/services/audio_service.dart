import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AudioService with WidgetsBindingObserver {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _soundVolume = 0.8;
  double _musicVolume = 0.5;
  bool _isInitialized = false;
  bool _musicPlaying = false;
  
  AudioPlayer? _bgmPlayer;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;
  bool get isInitialized => _isInitialized;

  void setSoundVolume(double volume, {bool save = true}) {
    _soundVolume = volume;
    if (save) _savePreferences();
  }

  void setMusicVolume(double volume, {bool save = true}) {
    _musicVolume = volume;
    if (_musicPlaying && _bgmPlayer != null) {
      _bgmPlayer!.setVolume(volume);
    }
    if (save) _savePreferences();
  }

  /// Initialize audio service and load preferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load sound preferences from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _musicEnabled = prefs.getBool('music_enabled') ?? true;
      _soundVolume = prefs.getDouble('sound_volume') ?? 0.8;
      _musicVolume = prefs.getDouble('music_volume') ?? 0.5;

      // Ensure global audio configuration allows background mix
      await AudioPlayer.global.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
      ));

      // Preload audio files
      await _preloadAudio();
      _isInitialized = true;
      
      // Auto-start music if enabled
      startBackgroundMusic();
      
      // Register global lifecycle observer so OS events pause/resume audio properly
      WidgetsBinding.instance.addObserver(this);
      
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
        'background_music.wav',
        'collision.wav',
        'powerup.wav',
        'gameover.wav',
        'level_complete.wav',
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
      await prefs.setDouble('sound_volume', _soundVolume);
      await prefs.setDouble('music_volume', _musicVolume);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving preferences: $e');
      }
    }
  }

  /// Start background music (loops)
  Future<void> startBackgroundMusic() async {
    if (!_musicEnabled || !_isInitialized || _musicPlaying) return;

    try {
      _bgmPlayer = await FlameAudio.loop(
        'background_music.wav',
        volume: _musicVolume,
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
      _bgmPlayer?.stop();
      _bgmPlayer?.dispose();
      _bgmPlayer = null;
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

  /// Pause background music
  void pauseBackgroundMusic() {
    try {
      _bgmPlayer?.pause();
      if (kDebugMode) {
        debugPrint('Background music paused');
      }
    } catch (e) {
      // Ignored
    }
  }

  /// Resume background music
  void resumeBackgroundMusic() {
    if (!_musicEnabled || !_isInitialized) return;
    try {
      _bgmPlayer?.resume();
      if (kDebugMode) {
        debugPrint('Background music resumed');
      }
    } catch (e) {
      // Ignored
    }
  }

  /// Play a sound effect
  void playSound(String soundFile) {
    if (!_soundEnabled || !_isInitialized) return;

    try {
      FlameAudio.play(soundFile, volume: _soundVolume);
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
    playSound('collision.wav');
  }

  /// Play power-up collection sound
  void playPowerUpSound() {
    playSound('powerup.wav');
  }

  /// Play game over sound
  void playGameOverSound() {
    playSound('gameover.wav');
  }

  /// Play level complete sound
  void playLevelCompleteSound() {
    playSound('level_complete.wav');
  }

  /// Dispose audio resources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopBackgroundMusic();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Always pause audio when minimizing the app
      pauseBackgroundMusic();
    } else if (state == AppLifecycleState.resumed) {
      // Resume audio explicitly when the app comes back to the foreground
      resumeBackgroundMusic();
    }
  }
}
