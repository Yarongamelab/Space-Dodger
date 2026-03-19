import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/game_stats.dart';
import '../../domain/entities/player_data.dart';
import 'local_data_source.dart';

/// Implementation of LocalDataSource using SharedPreferences
class SharedPreferencesLocalDataSource implements LocalDataSource {
  static const String _playerDataKey = 'player_data';
  static const String _gameStatsKey = 'game_stats_list';
  static const String _highScoreKey = 'highScore'; // Legacy support

  final SharedPreferences _prefs;

  SharedPreferencesLocalDataSource(this._prefs);

  @override
  Future<PlayerData> getPlayerData() async {
    try {
      final playerDataJson = _prefs.getString(_playerDataKey);
      if (playerDataJson != null && playerDataJson.isNotEmpty) {
        final decoded = jsonDecode(playerDataJson);
        if (decoded is Map<String, dynamic>) {
          return PlayerData.fromJson(decoded);
        }
      }
    } catch (e) {
      debugPrint('Error loading player data: $e');
      // Try to recover legacy high score if exists
      try {
        final legacyHighScore = _prefs.getInt(_highScoreKey) ?? 0;
        if (legacyHighScore > 0) {
          return PlayerData(highScore: legacyHighScore);
        }
      } catch (legacyError) {
        debugPrint('Error loading legacy high score: $legacyError');
      }
    }
    return PlayerData();
  }

  @override
  Future<void> savePlayerData(PlayerData playerData) async {
    await _prefs.setString(
      _playerDataKey,
      jsonEncode(playerData.toJson()),
    );
    // Also save to legacy key for backwards compatibility
    await _prefs.setInt(_highScoreKey, playerData.highScore);
  }

  @override
  Future<void> saveHighScore(int score) async {
    final playerData = await getPlayerData();
    if (score > playerData.highScore) {
      final updatedData = playerData.copyWith(
        highScore: score,
        lastPlayed: DateTime.now(),
      );
      await savePlayerData(updatedData);
    }
  }

  @override
  Future<void> incrementGamesPlayed() async {
    final playerData = await getPlayerData();
    await savePlayerData(
      playerData.copyWith(
        totalGamesPlayed: playerData.totalGamesPlayed + 1,
        lastPlayed: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> incrementAsteroidsDestroyed([int count = 1]) async {
    final playerData = await getPlayerData();
    await savePlayerData(
      playerData.copyWith(
        totalAsteroidsDestroyed:
            playerData.totalAsteroidsDestroyed + count,
      ),
    );
  }

  @override
  Future<void> incrementPowerUpsCollected([int count = 1]) async {
    final playerData = await getPlayerData();
    await savePlayerData(
      playerData.copyWith(
        totalPowerUpsCollected: playerData.totalPowerUpsCollected + count,
      ),
    );
  }

  @override
  Future<void> saveGameStats(GameStats stats) async {
    var statsList = await getRecentGameStats(limit: 9);
    statsList.insert(0, stats);
    // Keep only the 10 most recent games
    if (statsList.length > 10) {
      statsList = statsList.sublist(0, 10);
    }
    final statsJsonList = statsList.map((s) => s.toJson()).toList();
    await _prefs.setString(_gameStatsKey, jsonEncode(statsJsonList));
  }

  @override
  Future<List<GameStats>> getRecentGameStats({int limit = 10}) async {
    try {
      final statsJson = _prefs.getString(_gameStatsKey);
      if (statsJson != null) {
        final List<dynamic> decoded = jsonDecode(statsJson);
        return decoded
            .map((s) => GameStats.fromJson(s))
            .take(limit)
            .toList();
      }
    } catch (e) {
      // Return empty list on error
    }
    return [];
  }

  @override
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
