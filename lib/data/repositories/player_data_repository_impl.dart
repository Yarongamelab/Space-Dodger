import '../../domain/entities/game_stats.dart';
import '../../domain/entities/player_data.dart';
import '../../domain/repositories/player_data_repository.dart';
import '../data_sources/local_data_source.dart';

/// Implementation of PlayerDataRepository using LocalDataSource
class PlayerDataRepositoryImpl implements PlayerDataRepository {
  final LocalDataSource _localDataSource;

  PlayerDataRepositoryImpl(this._localDataSource);

  @override
  Future<PlayerData> getPlayerData() async {
    return await _localDataSource.getPlayerData();
  }

  @override
  Future<void> updateHighScore(int score) async {
    await _localDataSource.saveHighScore(score);
  }

  @override
  Future<void> recordGameCompleted(GameStats stats) async {
    await _localDataSource.saveGameStats(stats);
    await _localDataSource.incrementGamesPlayed();
    
    // Update high score if this game's score is higher
    final playerData = await getPlayerData();
    if (stats.score > playerData.highScore) {
      await updateHighScore(stats.score);
    }
  }

  @override
  Future<void> incrementAsteroidsDestroyed([int count = 1]) async {
    await _localDataSource.incrementAsteroidsDestroyed(count);
  }

  @override
  Future<void> incrementPowerUpsCollected([int count = 1]) async {
    await _localDataSource.incrementPowerUpsCollected(count);
  }

  @override
  Future<List<GameStats>> getRecentGames({int limit = 10}) async {
    return await _localDataSource.getRecentGameStats(limit: limit);
  }

  @override
  Future<void> resetAllData() async {
    await _localDataSource.clearAllData();
  }
}
