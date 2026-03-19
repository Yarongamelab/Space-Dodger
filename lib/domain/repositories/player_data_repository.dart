import '../entities/game_stats.dart';
import '../entities/player_data.dart';

/// Repository interface for player data operations
/// Defines the contract that implementations must follow
abstract class PlayerDataRepository {
  Future<PlayerData> getPlayerData();
  Future<void> updateHighScore(int score);
  Future<void> recordGameCompleted(GameStats stats);
  Future<void> incrementAsteroidsDestroyed([int count = 1]);
  Future<void> incrementPowerUpsCollected([int count = 1]);
  Future<List<GameStats>> getRecentGames({int limit = 10});
  Future<void> resetAllData();
}
