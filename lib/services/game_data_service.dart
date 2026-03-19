import 'package:flutter/foundation.dart';
import '../domain/entities/game_stats.dart';
import '../domain/entities/player_data.dart';
import '../domain/repositories/player_data_repository.dart';

/// Service class for managing game-related data operations
/// Provides a high-level API for the game logic to interact with the data layer
class GameDataService extends ChangeNotifier {
  final PlayerDataRepository _repository;
  
  PlayerData? _playerData;
  GameStats? _currentGameStats;
  DateTime? _gameStartTime;
  bool _isLoading = true;

  GameDataService(this._repository) {
    _initializeData();
  }

  // Getters
  PlayerData? get playerData => _playerData;
  GameStats? get currentGameStats => _currentGameStats;
  bool get isLoading => _isLoading;
  int get highScore => _playerData?.highScore ?? 0;

  /// Initialize data by loading from repository
  Future<void> _initializeData() async {
    try {
      _playerData = await _repository.getPlayerData();
    } catch (e) {
      debugPrint('Error loading player data: $e');
      _playerData = PlayerData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start a new game session
  void startNewGame() {
    _gameStartTime = DateTime.now();
    _currentGameStats = GameStats();
    notifyListeners();
  }

  /// Update current game score
  void updateScore(int score) {
    if (_currentGameStats != null) {
      _currentGameStats = _currentGameStats!.copyWith(score: score);
      notifyListeners();
    }
  }

  /// Record asteroid destruction
  Future<void> recordAsteroidDestroyed() async {
    if (_currentGameStats != null) {
      _currentGameStats = _currentGameStats!.copyWith(
        asteroidsDestroyed: _currentGameStats!.asteroidsDestroyed + 1,
      );
      notifyListeners();
    }
    await _repository.incrementAsteroidsDestroyed();
  }

  /// Record power-up collection
  Future<void> recordPowerUpCollected() async {
    if (_currentGameStats != null) {
      _currentGameStats = _currentGameStats!.copyWith(
        powerUpsCollected: _currentGameStats!.powerUpsCollected + 1,
      );
      notifyListeners();
    }
    await _repository.incrementPowerUpsCollected();
  }

  /// End the current game and save results
  Future<void> endGame() async {
    if (_currentGameStats == null || _gameStartTime == null) return;

    final gameDuration = DateTime.now().difference(_gameStartTime!).inSeconds;
    final completedStats = _currentGameStats!.copyWith(
      gameDuration: gameDuration.toDouble(),
      timestamp: DateTime.now(),
    );

    await _repository.recordGameCompleted(completedStats);
    
    // Reload player data to get updated high score
    _playerData = await _repository.getPlayerData();
    
    _currentGameStats = null;
    _gameStartTime = null;
    notifyListeners();
  }

  /// Get recent game statistics
  Future<List<GameStats>> getRecentGames({int limit = 10}) async {
    return await _repository.getRecentGames(limit: limit);
  }

  /// Reset all player data (use with caution!)
  Future<void> resetAllData() async {
    await _repository.resetAllData();
    _playerData = PlayerData();
    _currentGameStats = null;
    notifyListeners();
  }

  /// Refresh player data from storage
  Future<void> refreshData() async {
    _playerData = await _repository.getPlayerData();
    notifyListeners();
  }
}
