import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../di/data_layer.dart';
import '../services/game_data_service.dart';
import '../services/audio_service.dart';
import 'player.dart';
import 'asteroid.dart';
import 'powerup.dart';
import 'level_manager.dart';

class SpaceDodgerGame extends FlameGame with DragCallbacks, HasCollisionDetection, WidgetsBindingObserver {
  Player? player;
  LevelManager? levelManager;

  double score = 0;
  bool isGameOver = false;
  double difficulty = 1.0;
  double asteroidSpawnTimer = 0;
  double powerUpSpawnTimer = 0;
  bool isScoreBoosted = false;
  double scoreBoostTime = 0;

  bool isLevelTransition = false;
  bool _isInitialized = false;

  late GameDataService _gameDataService;
  late AudioService _audioService;

  final Random random = Random();

  @override
  Color backgroundColor() => const Color(0xFF0A0A1A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    WidgetsBinding.instance.addObserver(this);

    // Get the game data service
    _gameDataService = DataLayer.gameDataService;
    _audioService = AudioService();

    // Start background music
    _audioService.startBackgroundMusic();

    // Initialize level manager
    levelManager = LevelManager();
    levelManager!.startLevel(1);

    // Add stars background
    const starCount = 100;
    for (int i = 0; i < starCount; i++) {
      final x = size.x > 0 ? random.nextDouble() * size.x : random.nextDouble() * 500;
      final y = size.y > 0 ? random.nextDouble() * size.y : random.nextDouble() * 800;
      add(Star(
        position: Vector2(x, y),
        speed: 50 + random.nextDouble() * 100,
      ));
    }

    player = Player();
    add(player!);

    // Set initial target position
    if (size.x > 0) {
      player!.targetPosition = Vector2(size.x / 2, size.y - 100);
    }

    // Start new game session
    _gameDataService.startNewGame();
    _isInitialized = true;
    resumeEngine(); // Ensure engine is running
  }

  @override
  void onRemove() {
    WidgetsBinding.instance.removeObserver(this);
    super.onRemove();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (!isGameOver && !isPaused) {
        pauseEngine();
        _audioService.pauseBackgroundMusic();
        overlays.add('pause');
      }
    } else if (state == AppLifecycleState.resumed) {
      // We don't automatically resume the engine here to let the user resume via the overlay
      // but we might want to refresh state or ensure audio is ready
    }
  }

  bool get isPaused => overlays.isActive('pause');

  @override
  void update(double dt) {
    if (dt > 0.1) dt = 0.1;
    super.update(dt);

    if (!_isInitialized || isGameOver || isLevelTransition || player == null || levelManager == null) return;

    // Update level manager
    levelManager!.update(dt);
    
    // Check if level is complete
    if (levelManager!.isLevelComplete) {
      _onLevelComplete();
      return;
    }

    // Update difficulty from level manager
    difficulty = levelManager!.difficultyMultiplier;

    // Update score
    double scoreMultiplier = isScoreBoosted ? 2.0 : 1.0;
    score += dt * 10 * difficulty * scoreMultiplier;
    
    // Sync score with data service and HUD
    _gameDataService.updateScore(score.toInt());
    levelManager!.scoreNotifier.value = score.toInt();

    if (isScoreBoosted) {
      scoreBoostTime -= dt;
      if (scoreBoostTime <= 0) {
        isScoreBoosted = false;
      }
    }

    // Spawn asteroids
    asteroidSpawnTimer -= dt;
    if (asteroidSpawnTimer <= 0) {
      spawnAsteroid();
      asteroidSpawnTimer = levelManager!.asteroidSpawnRate;
    }

    // Spawn power-ups
    powerUpSpawnTimer -= dt;
    if (powerUpSpawnTimer <= 0) {
      spawnPowerUp();
      powerUpSpawnTimer = levelManager!.powerUpSpawnRate + random.nextDouble() * 5;
    }

    // Check game over
    if (player != null && levelManager != null) {
      levelManager!.livesNotifier.value = player!.lives;
      if (player!.lives <= 0) {
        gameOver();
      }
    }
  }

  void _onLevelComplete() {
    if (levelManager == null) return;

    isLevelTransition = true;
    overlays.add('levelComplete');

    // Play level complete sound
    _audioService.playLevelCompleteSound();

    // Auto-advance to next level after a short delay
    add(TimerComponent(
      period: 2.0,
      removeOnFinish: true,
      onTick: () {
        if (!isGameOver && levelManager != null) {
          levelManager!.completeLevel();
          isLevelTransition = false;
          overlays.remove('levelComplete');

          // Reset player position and apply level-specific settings
          if (player != null) {
            player!.position = Vector2(size.x / 2, size.y - 100);
            player!.targetPosition = Vector2(size.x / 2, size.y - 100);
            player!.speed = 400 * (1 - levelManager!.playerSpeedPenalty);
          }
        }
      },
    ));
  }
  
  /// Record asteroid destroyed (call from Asteroid when destroyed)
  void recordAsteroidDestroyed() {
    _gameDataService.recordAsteroidDestroyed();
  }
  
  /// Record power-up collected (call from PowerUp when collected)
  void recordPowerUpCollected() {
    _gameDataService.recordPowerUpCollected();
  }

  void spawnAsteroid() {
    if (levelManager == null) return;

    int sizeCategory = 0;
    final rand = random.nextDouble();
    
    // Fixed logic: rand < probability for correct distribution
    final largeProb = levelManager!.largeAsteroidProbability;
    final mediumProb = levelManager!.mediumAsteroidProbability;
    
    if (rand < largeProb) {
      sizeCategory = 2; // Large
    } else if (rand < (largeProb + mediumProb)) {
      sizeCategory = 1; // Medium
    }

    final speed = (150 + (difficulty * 30) + (sizeCategory * 20)) * levelManager!.asteroidSpeedMultiplier;
    final asteroid = Asteroid(speed: speed, sizeCategory: sizeCategory);
    add(asteroid);
  }

  void spawnPowerUp() {
    if (levelManager == null) return;

    if (random.nextDouble() > 0.3) { // 70% chance
      const types = PowerUpType.values;
      final type = types[random.nextInt(types.length)];
      add(PowerUp(type: type));
    }
  }

  void applyPowerUp(PowerUpType type) {
    if (player == null || levelManager == null) return;

    switch (type) {
      case PowerUpType.shield:
        player!.activateShield(levelManager!.shieldDuration);
        break;
      case PowerUpType.extraLife:
        player!.lives++;
        break;
      case PowerUpType.scoreBoost:
        isScoreBoosted = true;
        scoreBoostTime = 10.0;
        break; // Fixed missing break
      case PowerUpType.speedBoost:
        player!.speed = min(800, player!.speed + 150);
        isScoreBoosted = true;
        scoreBoostTime += 5.0;
        break;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!isGameOver && player != null) {
      if (player!.targetPosition == null) {
        player!.targetPosition = player!.position.clone();
      }
      player!.targetPosition!.add(event.localDelta);
      
      // Clamp targetPosition to screen bounds to prevent ship sticking
      player!.targetPosition!.x = player!.targetPosition!.x.clamp(25, size.x - 25);
      player!.targetPosition!.y = player!.targetPosition!.y.clamp(30, size.y - 30);
    }
  }

  void gameOver() {
    isGameOver = true;
    pauseEngine();

    // Pause music and play game over sound
    _audioService.pauseBackgroundMusic();
    _audioService.playGameOverSound();

    // Final score sync
    _gameDataService.updateScore(score.toInt());
    if (levelManager != null) {
      levelManager!.scoreNotifier.value = score.toInt();
    }

    // End game and save stats
    _gameDataService.endGame();
    overlays.add('gameOver');
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Reposition player if they exist and game just started or resized
    if (player != null && !isGameOver && !isLevelTransition) {
      player!.position = Vector2(size.x / 2, size.y - 100);
      if (levelManager != null) {
        player!.speed = 400 * (1 - levelManager!.playerSpeedPenalty);
      }
    }
  }

  void restart() {
    if (levelManager == null) return;

    // Remove all asteroids and power-ups
    children.whereType<Asteroid>().forEach((a) => a.removeFromParent());
    children.whereType<PowerUp>().forEach((p) => p.removeFromParent());

    // Reset level manager
    levelManager!.reset();
    levelManager!.startLevel(1);

    // Reset player
    if (player != null) {
      player!.position = Vector2(size.x / 2, size.y - 100);
      player!.targetPosition = Vector2(size.x / 2, size.y - 100);
      player!.lives = levelManager!.startingLives;
      player!.isInvincible = false;
      player!.speed = 400;
    }

    // Reset game state
    score = 0;
    difficulty = 1.0;
    asteroidSpawnTimer = 0;
    powerUpSpawnTimer = 0;
    isScoreBoosted = false;
    isGameOver = false;
    isLevelTransition = false;

    // Start new game session
    _gameDataService.startNewGame();
    _audioService.resumeBackgroundMusic();
  }
}

class Star extends PositionComponent with HasGameRef {
  final double speed;
  late final Paint paint;
  late final double starSize;

  Star({required Vector2 position, required this.speed}) {
    this.position = position;
    starSize = 1 + Random().nextDouble() * 2;
    paint = Paint()
      ..color = Colors.white.withOpacity(0.5 + Random().nextDouble() * 0.5);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;

    if (position.y > gameRef.size.y) {
      position.y = 0;
      position.x = Random().nextDouble() * gameRef.size.x;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(starSize/2, starSize/2), starSize/2, paint);
  }
}
