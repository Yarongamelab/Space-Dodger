import '../../domain/entities/game_stats.dart';
import '../../domain/entities/player_data.dart';

/// Abstract interface for local data operations
abstract class LocalDataSource {
  Future<PlayerData> getPlayerData();
  Future<void> savePlayerData(PlayerData playerData);
  Future<void> saveHighScore(int score);
  Future<void> incrementGamesPlayed();
  Future<void> incrementAsteroidsDestroyed([int count = 1]);
  Future<void> incrementPowerUpsCollected([int count = 1]);
  Future<void> saveGameStats(GameStats stats);
  Future<List<GameStats>> getRecentGameStats({int limit = 10});
  Future<void> clearAllData();
}
