import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flame/game.dart';
import '../di/data_layer.dart';
import '../services/audio_service.dart';
import '../services/game_data_service.dart';
import '../game/space_dodger_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SpaceDodgerGame _game;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  late GameDataService _gameDataService;

  @override
  void initState() {
    super.initState();
    _gameDataService = DataLayer.gameDataService;
    _game = SpaceDodgerGame();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3150612581225684/5107846894',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Stack(
        children: [
          // The Game
          GameWidget(
            game: _game,
            overlayBuilderMap: {
              'pause': (context, SpaceDodgerGame game) => _buildPauseOverlay(),
              'gameOver': (context, SpaceDodgerGame game) => _buildGameOverOverlay(),
              'levelComplete': (context, SpaceDodgerGame game) => _buildLevelCompleteOverlay(),
            },
          ),

          // Banner Ad at the bottom
          if (_isAdLoaded && _bannerAd != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
            
          // Back button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A3A).withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00D4FF), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 5),
            ),
            const SizedBox(height: 30),
            _buildOverlayButton('RESUME', Colors.green, () {
              _game.overlays.remove('pause');
              _game.resumeEngine();
              AudioService().resumeBackgroundMusic();
            }),
            const SizedBox(height: 15),
            _buildOverlayButton('RESTART', Colors.orange, () {
              _game.overlays.remove('pause');
              _game.restart();
              _game.resumeEngine();
            }),
            const SizedBox(height: 15),
            _buildOverlayButton('QUIT', Colors.red, () {
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final score = _gameDataService.currentGameStats?.score ?? 0;
    final highScore = _gameDataService.highScore;

    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A3A).withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(color: Colors.red, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 20),
            Text('SCORE: $score', style: const TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 10),
            Text('HIGH SCORE: $highScore', style: const TextStyle(color: Color(0xFF00D4FF), fontSize: 18)),
            const SizedBox(height: 30),
            _buildOverlayButton('PLAY AGAIN', const Color(0xFF00D4FF), () {
              _game.overlays.remove('gameOver');
              _game.restart();
              _game.resumeEngine();
            }),
            const SizedBox(height: 15),
            _buildOverlayButton('MAIN MENU', Colors.white24, () {
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCompleteOverlay() {
    final level = _game.levelManager?.currentLevel ?? 1;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'LEVEL $level COMPLETE',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [Shadow(blurRadius: 10, color: Colors.orange)],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'GET READY...',
            style: TextStyle(color: Colors.white70, fontSize: 18, letterSpacing: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayButton(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color == Colors.white24 ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
