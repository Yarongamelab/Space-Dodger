/// Represents player data including high score and statistics
class PlayerData {
  final int highScore;
  final int totalGamesPlayed;
  final int totalAsteroidsDestroyed;
  final int totalPowerUpsCollected;
  final DateTime firstPlayed;
  final DateTime lastPlayed;

  PlayerData({
    this.highScore = 0,
    this.totalGamesPlayed = 0,
    this.totalAsteroidsDestroyed = 0,
    this.totalPowerUpsCollected = 0,
    DateTime? firstPlayed,
    DateTime? lastPlayed,
  })  : firstPlayed = firstPlayed ?? DateTime.now(),
        lastPlayed = lastPlayed ?? DateTime.now();

  PlayerData copyWith({
    int? highScore,
    int? totalGamesPlayed,
    int? totalAsteroidsDestroyed,
    int? totalPowerUpsCollected,
    DateTime? firstPlayed,
    DateTime? lastPlayed,
  }) {
    return PlayerData(
      highScore: highScore ?? this.highScore,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalAsteroidsDestroyed:
          totalAsteroidsDestroyed ?? this.totalAsteroidsDestroyed,
      totalPowerUpsCollected:
          totalPowerUpsCollected ?? this.totalPowerUpsCollected,
      firstPlayed: firstPlayed ?? this.firstPlayed,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'highScore': highScore,
      'totalGamesPlayed': totalGamesPlayed,
      'totalAsteroidsDestroyed': totalAsteroidsDestroyed,
      'totalPowerUpsCollected': totalPowerUpsCollected,
      'firstPlayed': firstPlayed.toIso8601String(),
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      highScore: json['highScore'] ?? 0,
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalAsteroidsDestroyed: json['totalAsteroidsDestroyed'] ?? 0,
      totalPowerUpsCollected: json['totalPowerUpsCollected'] ?? 0,
      firstPlayed: json['firstPlayed'] != null
          ? DateTime.parse(json['firstPlayed'])
          : DateTime.now(),
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'])
          : DateTime.now(),
    );
  }
}
