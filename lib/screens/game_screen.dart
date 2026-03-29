import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../di/data_layer.dart';
import '../services/game_data_service.dart';
import '../services/audio_service.dart';
import '../game/space_dodger_game.dart';
import '../game/level_manager.dart';
import '../widgets/space_logo_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SpaceDodgerGame game;
  bool isPaused = false;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _adLoadFailed = false;
  late GameDataService _gameDataService;
  late AudioService _audioService;
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  @override
  void initState() {
    super.initState();
    game = SpaceDodgerGame();
    _gameDataService = DataLayer.gameDataService;
    _audioService = AudioService();
    _soundEnabled = _audioService.soundEnabled;
    _musicEnabled = _audioService.musicEnabled;
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    try {
      _bannerAd = BannerAd(
        adUnitId: 'ca-app-pub-3150612581225684/4511417308', // Real banner ad unit ID
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('BannerAd loaded: ${ad.adUnitId}');
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('BannerAd failed to load: ${ad.adUnitId}, Error: $error');
            ad.dispose();
            if (mounted) {
              setState(() {
                _adLoadFailed = true;
              });
            }
          },
        ),
      )..load();
    } catch (e) {
      debugPrint('Error starting BannerAd load: $e');
      // Ad loading failed, continue without ads
      _adLoadFailed = true;
    }
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ad unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd loaded: ${ad.adUnitId}');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitialAd(); // Load next one
    } else {
      debugPrint('InterstitialAd not ready yet.');
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Stack(
        children: [
          // Game
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'pause': (context, game) => _buildPauseOverlay(),
              'gameOver': (context, game) {
                // Show interstitial ad when game over occurs
                _showInterstitialAd();
                return _buildGameOverOverlay();
              },
              'levelComplete': (context, game) => _buildLevelCompleteOverlay(),
            },
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00D4FF),
              ),
            ),
            errorBuilder: (context, error) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading game',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        game = SpaceDodgerGame();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

          // HUD
          if (!isPaused && !game.isGameOver) _buildHUD(),

          // Pause button
          if (!isPaused && !game.isGameOver) _buildPauseButton(),

          // Banner Ad at the bottom
          if (_isAdLoaded && _bannerAd != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                height: 50,
                color: Colors.black, // Dark background for the ad area
                alignment: Alignment.center,
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    final levelManager = game.levelManager;
    if (levelManager == null) return const SizedBox.shrink();

    final level = levelManager.currentLevel;
    final levelName = levelManager.levelName;
    final tierColor = levelManager.levelTierColor;
    final timeRemaining = levelManager.timeRemaining;


    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Column(
        children: [
          // Level and Timer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Level Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A3A).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(tierColor),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      levelName.toUpperCase(),
                      style: TextStyle(
                        color: Color(tierColor),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flag, color: Color(0xFF00D4FF), size: 16),
                        const SizedBox(width: 5),
                        Text(
                          '$level/1000',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Timer
              ValueListenableBuilder<double>(
                valueListenable: levelManager.timeRemainingNotifier,
                builder: (context, timeRemaining, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A3A).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00FFFF), width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: timeRemaining < 10
                              ? const Color(0xFFFF4444)
                              : const Color(0xFF00FFFF),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${timeRemaining.toStringAsFixed(1)}s',
                          style: TextStyle(
                            color: timeRemaining < 10
                                ? const Color(0xFFFF4444)
                                : const Color(0xFF00FFFF),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Score and Lives Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score
              ValueListenableBuilder<int>(
                valueListenable: levelManager.scoreNotifier,
                builder: (context, currentScore, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A3A).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00D4FF), width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFFD700), size: 24),
                        const SizedBox(width: 10),
                        Text(
                          '$currentScore',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Lives
              ValueListenableBuilder<int>(
                valueListenable: levelManager.livesNotifier,
                builder: (context, currentLives, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A3A).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFF4444), width: 2),
                    ),
                    child: Row(
                      children: List.generate(
                        levelManager.startingLives,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Icon(
                            index < currentLives ? Icons.favorite : Icons.favorite_border,
                            color: const Color(0xFFFF4444),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // Level Progress Bar
          const SizedBox(height: 10),
          ValueListenableBuilder<double>(
            valueListenable: levelManager.timeRemainingNotifier,
            builder: (context, timeRemaining, child) {
              final progress = (LevelManager.levelDuration - timeRemaining) / LevelManager.levelDuration;
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A3A).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFF0A0A1A),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(tierColor),
                    ),
                    minHeight: 6,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPauseButton() {
    return Positioned(
      top: 50,
      right: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sound toggle button
          GestureDetector(
            onTap: () async {
              await _audioService.toggleSound();
              setState(() {
                _soundEnabled = _audioService.soundEnabled;
              });
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A3A).withOpacity(0.8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00D4FF), width: 2),
              ),
              child: Icon(
                _soundEnabled ? Icons.volume_up : Icons.volume_off,
                color: _soundEnabled ? Colors.white : Colors.grey,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Music toggle button
          GestureDetector(
            onTap: () async {
              await _audioService.toggleMusic();
              setState(() {
                _musicEnabled = _audioService.musicEnabled;
              });
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A3A).withOpacity(0.8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00D4FF), width: 2),
              ),
              child: Icon(
                _musicEnabled ? Icons.music_note : Icons.music_off,
                color: _musicEnabled ? Colors.white : Colors.grey,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Pause button
          GestureDetector(
            onTap: () {
              setState(() {
                isPaused = true;
                game.pauseEngine();
                game.overlays.add('pause');
              });
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A3A).withOpacity(0.8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00D4FF), width: 2),
              ),
              child: const Icon(Icons.pause, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 60),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
            color: const Color(0xFF1A1A3A),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF00D4FF), width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SpaceLogoWidget(size: 80),
              const SizedBox(height: 20),
              const Text(
                'PAUSED',
                style: TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 30),

              // Sound settings
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSoundToggle(
                    icon: _soundEnabled ? Icons.volume_up : Icons.volume_off,
                    isEnabled: _soundEnabled,
                    label: 'SFX',
                    onTap: () async {
                      await _audioService.toggleSound();
                      setState(() {
                        _soundEnabled = _audioService.soundEnabled;
                      });
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildSoundToggle(
                    icon: _musicEnabled ? Icons.music_note : Icons.music_off,
                    isEnabled: _musicEnabled,
                    label: 'MUSIC',
                    onTap: () async {
                      await _audioService.toggleMusic();
                      setState(() {
                        _musicEnabled = _audioService.musicEnabled;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              _buildPauseButtonAction(
                text: 'RESUME',
                icon: Icons.play_arrow,
                color: const Color(0xFF00D4FF),
                onTap: () {
                  game.overlays.remove('pause');
                  game.resumeEngine();
                  setState(() {
                    isPaused = false;
                  });
                },
              ),
              const SizedBox(height: 15),
              _buildPauseButtonAction(
                text: 'RESTART',
                icon: Icons.refresh,
                color: const Color(0xFFFFD700),
                onTap: () {
                  game.overlays.remove('pause');
                  game.restart();
                  game.resumeEngine();
                  setState(() {
                    isPaused = false;
                  });
                },
              ),
              const SizedBox(height: 15),
              _buildPauseButtonAction(
                text: 'QUIT',
                icon: Icons.exit_to_app,
                color: const Color(0xFFFF4444),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildPauseButtonAction({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundToggle({
    required IconData icon,
    required bool isEnabled,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEnabled
                ? [const Color(0xFF00D4FF), const Color(0xFF00D4FF).withOpacity(0.7)]
                : [const Color(0xFF444444), const Color(0xFF444444).withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled ? Colors.white : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 60),
          child: Container(
            margin: const EdgeInsets.all(30),
            padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A3A),
                Color(0xFF0A0A1A),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFFF4444), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4444).withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SpaceLogoWidget(size: 100),
              const SizedBox(height: 20),
              const Icon(
                Icons.error_outline,
                color: Color(0xFFFF4444),
                size: 50,
              ),
              const SizedBox(height: 20),
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Color(0xFFFF4444),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A1A),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SCORE:',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Text(
                          '${game.score.toInt()}',
                          style: const TextStyle(
                            color: Color(0xFF00D4FF),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'HIGH SCORE:',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Text(
                          '${_gameDataService.highScore}',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildGameOverButton(
                text: 'PLAY AGAIN',
                icon: Icons.refresh,
                color: const Color(0xFF00D4FF),
                onTap: () {
                  game.overlays.remove('gameOver');
                  game.restart();
                  game.resumeEngine();
                },
              ),
              const SizedBox(height: 15),
              _buildGameOverButton(
                text: 'MENU',
                icon: Icons.home,
                color: const Color(0xFFFF4444),
                onTap: () {
                  AudioService().resumeBackgroundMusic();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildLevelCompleteOverlay() {
    final level = game.levelManager?.currentLevel ?? 1;
    final nextLevel = level + 1;
    final isMaxLevel = level >= 1000;
    final tierColor = game.levelManager?.levelTierColor ?? 0xFF00D4FF;
    final progress = game.levelManager?.progress ?? 0.0;

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(tierColor),
                Color(tierColor).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Color(tierColor), width: 3),
            boxShadow: [
              BoxShadow(
                color: Color(tierColor).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SpaceLogoWidget(size: 100),
              const SizedBox(height: 20),
              Icon(
                Icons.celebration,
                color: Color(tierColor),
                size: 50,
              ),
              const SizedBox(height: 20),
              const Text(
                'LEVEL COMPLETE!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Level $level',
                style: TextStyle(
                  color: Color(tierColor),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              if (!isMaxLevel) ...[
                const Text(
                  'NEXT LEVEL',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Level $nextLevel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(tierColor),
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Starting soon...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else ...[
                const Text(
                  'MAX LEVEL REACHED!',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'You are a true legend!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
