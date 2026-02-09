import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'concern_input_screen.dart';
// [New] 아카이브 화면을 import 합니다.
import 'archive_screen.dart';

class HomeScreen extends StatefulWidget {
  // [New] 저장된 데이터가 있는지 확인하는 변수 (기본값 false)
  final bool hasSavedData;

  const HomeScreen({
    Key? key,
    this.hasSavedData = false, 
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Pattern Layer (Geometric Remix) - [기존 유지]
            CustomPaint(
              painter: GeometricRemixPainter(),
              size: Size.infinite,
            ),

            // [New] 보관함 아이콘 (hasSavedData가 true일 때만 표시)
            if (widget.hasSavedData)
              Positioned(
                top: 16,
                right: 24,
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ArchiveScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.inventory_2_outlined, // 예쁜 박스 아이콘
                        color: Color(0xFF2E4B28),
                        size: 24,
                      ),
                      tooltip: 'My Archive',
                    ),
                  ),
                ),
              ),

            // Main Content - [기존 유지]
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Pulsing Blob Animation
                  _buildPulsingBlob(),
                  const SizedBox(height: 40),
                  // Greeting Text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Hello, tell me your worry.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F1F1F),
                        letterSpacing: -0.3,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Start Button
                  _buildStartButton(context),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingBlob() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2E4B28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E4B28).withOpacity(0.25),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to ConcernInputScreen using direct navigation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ConcernInputScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E4B28),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: const Text(
            'Start',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// [기존 유지] 배경 지오메트릭 패턴 페인터
class GeometricRemixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E4B28).withOpacity(0.04)
      ..style = PaintingStyle.fill;

    // Large circle - top right
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      size.width * 0.45,
      paint,
    );

    // Large circle - bottom left
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.85),
      size.width * 0.4,
      paint,
    );

    // Rounded polygon (hexagon) - center right
    final hexPath = Path();
    final centerX = size.width * 0.75;
    final centerY = size.height * 0.5;
    final radius = size.width * 0.35;
    final sides = 6;

    for (int i = 0; i < sides; i++) {
      final angle = (math.pi * 2 * i / sides) - math.pi / 2;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();

    paint.color = const Color(0xFF2E4B28).withOpacity(0.03);
    canvas.drawPath(hexPath, paint);

    // Additional subtle circle - middle left
    paint.color = const Color(0xFF2E4B28).withOpacity(0.05);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.4),
      size.width * 0.3,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}