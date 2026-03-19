import 'dart:math';
import 'package:flutter/foundation.dart';

class LevelManager {
  static const int maxLevels = 1000;
  static const double levelDuration = 60.0; // 1 minute per level

  int _currentLevel = 1;
  double _levelTimer = 0.0;
  bool _isLevelComplete = false;

  late final ValueNotifier<double> timeRemainingNotifier;
  late final ValueNotifier<int> scoreNotifier;
  late final ValueNotifier<int> livesNotifier;

  LevelManager() {
    timeRemainingNotifier = ValueNotifier<double>(levelDuration);
    scoreNotifier = ValueNotifier<int>(0);
    livesNotifier = ValueNotifier<int>(3);
  }

  int get currentLevel => _currentLevel;
  double get levelTimer => _levelTimer;
  bool get isLevelComplete => _isLevelComplete;
  double get timeRemaining => max(0, levelDuration - _levelTimer);
  double get progress => _levelTimer / levelDuration;

  /// Get difficulty multiplier for current level (1.0 to 10.0)
  double get difficultyMultiplier {
    // Starts at 1.0 for level 1, increases to 10.0 at level 1000
    return 1.0 + ((_currentLevel - 1) / (maxLevels - 1)) * 9.0;
  }

  /// Get asteroid spawn rate for current level (seconds between spawns)
  double get asteroidSpawnRate {
    // Starts at 1.5s, decreases to 0.2s at level 1000
    return max(0.2, 1.5 - ((_currentLevel - 1) / (maxLevels - 1)) * 1.3);
  }

  /// Get asteroid speed multiplier for current level
  double get asteroidSpeedMultiplier {
    // Starts at 1.0, increases to 3.0 at level 1000
    return 1.0 + ((_currentLevel - 1) / (maxLevels - 1)) * 2.0;
  }

  /// Get probability of large asteroids for current level
  double get largeAsteroidProbability {
    // Starts at 0.1, increases to 0.5 at level 1000
    return min(0.5, 0.1 + ((_currentLevel - 1) / (maxLevels - 1)) * 0.4);
  }

  /// Get probability of medium asteroids for current level
  double get mediumAsteroidProbability {
    // Starts at 0.3, increases to 0.4 at level 1000
    return min(0.4, 0.3 + ((_currentLevel - 1) / (maxLevels - 1)) * 0.1);
  }

  /// Get player speed penalty for current level
  double get playerSpeedPenalty {
    // Starts at 0 (no penalty), increases to 0.3 (30% slower) at level 1000
    return min(0.3, ((_currentLevel - 1) / (maxLevels - 1)) * 0.3);
  }

  /// Get power-up spawn rate for current level (seconds between spawns)
  double get powerUpSpawnRate {
    // Starts at 10s, decreases to 3s at level 1000
    return max(3.0, 10.0 - ((_currentLevel - 1) / (maxLevels - 1)) * 7.0);
  }

  /// Get shield duration for current level
  double get shieldDuration {
    // Starts at 5s, decreases to 2s at level 1000
    return max(2.0, 5.0 - ((_currentLevel - 1) / (maxLevels - 1)) * 3.0);
  }

  /// Get starting lives for current level
  int get startingLives {
    if (_currentLevel <= 10) return 3;
    if (_currentLevel <= 100) return 3;
    if (_currentLevel <= 500) return 2;
    return 2; // Expert levels
  }

  void startLevel(int level) {
    _currentLevel = max(1, min(maxLevels, level));
    _levelTimer = 0.0;
    _isLevelComplete = false;
    timeRemainingNotifier.value = levelDuration;
  }

  void update(double dt) {
    if (_isLevelComplete) return;

    _levelTimer += dt;
    timeRemainingNotifier.value = timeRemaining;

    if (_levelTimer >= levelDuration && !_isLevelComplete) {
      _isLevelComplete = true;
    }
  }

  void completeLevel() {
    if (_isLevelComplete && _currentLevel < maxLevels) {
      _currentLevel++;
      _levelTimer = 0.0;
      _isLevelComplete = false;
    }
  }

  void reset() {
    _currentLevel = 1;
    _levelTimer = 0.0;
    _isLevelComplete = false;
    timeRemainingNotifier.value = levelDuration;
    scoreNotifier.value = 0;
    livesNotifier.value = 3;
  }

  /// Get level name based on tier
  String get levelName {
    if (_currentLevel <= 50) return 'Beginner';
    if (_currentLevel <= 100) return 'Novice';
    if (_currentLevel <= 200) return 'Intermediate';
    if (_currentLevel <= 300) return 'Advanced';
    if (_currentLevel <= 400) return 'Expert';
    if (_currentLevel <= 500) return 'Master';
    if (_currentLevel <= 600) return 'Grand Master';
    if (_currentLevel <= 700) return 'Legend';
    if (_currentLevel <= 800) return 'Cosmic';
    if (_currentLevel <= 900) return 'Stellar';
    return 'Galactic';
  }

  /// Get level tier color
  int get levelTierColor {
    if (_currentLevel <= 50) return 0xFF00D4FF; // Cyan
    if (_currentLevel <= 100) return 0xFF00FF88; // Light Green
    if (_currentLevel <= 200) return 0xFF00FFFF; // Aqua
    if (_currentLevel <= 300) return 0xFFFFD700; // Gold
    if (_currentLevel <= 400) return 0xFFFFA500; // Orange
    if (_currentLevel <= 500) return 0xFFFF6600; // Red-Orange
    if (_currentLevel <= 600) return 0xFFFF4444; // Red
    if (_currentLevel <= 700) return 0xFFFF00FF; // Magenta
    if (_currentLevel <= 800) return 0xFF9900FF; // Purple
    if (_currentLevel <= 900) return 0xFF6600FF; // Deep Purple
    return 0xFF3300FF; // Indigo
  }
}
