/// Represents statistics for a single game session
class GameStats {
  final int score;
  final int asteroidsDestroyed;
  final int powerUpsCollected;
  final double gameDuration; // in seconds
  final DateTime timestamp;

  GameStats({
    this.score = 0,
    this.asteroidsDestroyed = 0,
    this.powerUpsCollected = 0,
    this.gameDuration = 0.0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  GameStats copyWith({
    int? score,
    int? asteroidsDestroyed,
    int? powerUpsCollected,
    double? gameDuration,
    DateTime? timestamp,
  }) {
    return GameStats(
      score: score ?? this.score,
      asteroidsDestroyed: asteroidsDestroyed ?? this.asteroidsDestroyed,
      powerUpsCollected: powerUpsCollected ?? this.powerUpsCollected,
      gameDuration: gameDuration ?? this.gameDuration,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'asteroidsDestroyed': asteroidsDestroyed,
      'powerUpsCollected': powerUpsCollected,
      'gameDuration': gameDuration,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      score: json['score'] ?? 0,
      asteroidsDestroyed: json['asteroidsDestroyed'] ?? 0,
      powerUpsCollected: json['powerUpsCollected'] ?? 0,
      gameDuration: json['gameDuration'] ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}
