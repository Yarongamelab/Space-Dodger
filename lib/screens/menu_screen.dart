import 'package:flutter/material.dart';
import '../di/data_layer.dart';
import '../services/game_data_service.dart';
import 'game_screen.dart';
import '../widgets/space_logo_widget.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late GameDataService _gameDataService;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _gameDataService = DataLayer.gameDataService;
    _highScore = _gameDataService.highScore;
    
    // Listen for changes
    _gameDataService.addListener(_onDataChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {
        _highScore = _gameDataService.highScore;
      });
    }
  }

  @override
  void dispose() {
    _gameDataService.removeListener(_onDataChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A1A),
              Color(0xFF1A1A3A),
              Color(0xFF0A0A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title and Logo Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFF00D4FF),
                                  Color(0xFF00FFFF),
                                  Color(0xFF00D4FF),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'SPACE',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFFF6600),
                                  Color(0xFFFFD700),
                                  Color(0xFFFF6600),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'DODGER',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Spaceship logo
                          const SpaceLogoWidget(size: 100),
                          const SizedBox(height: 30),

                          // High Score
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF00D4FF), width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'HIGH SCORE',
                                  style: TextStyle(
                                    color: Color(0xFF00D4FF),
                                    fontSize: 16,
                                    letterSpacing: 3,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '$_highScore',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Menu buttons
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        children: [
                          _buildMenuButton(
                            text: 'PLAY',
                            icon: Icons.play_arrow,
                            color: const Color(0xFF00D4FF),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const GameScreen(),
                                ),
                              ).then((value) {
                                _gameDataService.refreshData();
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildMenuButton(
                            text: 'HOW TO PLAY',
                            icon: Icons.info_outline,
                            color: const Color(0xFFFFD700),
                            onTap: () => _showInstructions(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00D4FF), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'HOW TO PLAY',
                style: TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 25),
              _buildInstructionRow(Icons.touch_app, 'Drag to move your spaceship'),
              _buildInstructionRow(Icons.block, 'Avoid the asteroids'),
              _buildInstructionRow(Icons.shield, 'Collect power-ups for bonuses'),
              _buildInstructionRow(Icons.star, 'Survive as long as possible!'),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'GOT IT!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00D4FF), size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpaceshipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00D4FF), Color(0xFF00FFFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, size.height * 0.8);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
