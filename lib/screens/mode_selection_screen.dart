import 'package:flutter/material.dart';
import '../widgets/wizard_top_bar.dart';
import 'loading_screen.dart';
import 'manual_input_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  final String userConcern;
  final int severityLevel;

  const ModeSelectionScreen({
    Key? key,
    required this.userConcern,
    required this.severityLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = 16.0;
    final spacing = 16.0;

    // Calculate card dimensions with max height constraint
    final cardWidth = (screenWidth - (horizontalPadding * 2) - spacing) / 2;
    final calculatedHeight = cardWidth / 0.65;
    final cardHeight = calculatedHeight.clamp(
      200.0,
      screenHeight * 0.5,
    ); // Max 50% of screen height

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Top Navigation Bar
              WizardTopBar(
                progress: 0.5,
                onBack: () => Navigator.pop(context),
                onHome: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),

              const Spacer(flex: 1),

              // Title
              const Text(
                'Choose your path',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F1F),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 40),

              // Selection Cards Row
              SizedBox(
                height: cardHeight,
                child: Row(
                  children: [
                    // Option 1: AI Suggestion
                    Expanded(
                      child: SelectionCard(
                        title: 'AI Suggestion',
                        subtitle: 'Wait for\nthe magic.',
                        isAiMode: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoadingScreen(
                                userConcern: userConcern,
                                severityLevel: severityLevel,
                                userOptionA: "", // Empty indicates AI mode
                                userOptionB: "",
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(width: spacing),

                    // Option 2: Manual Input
                    Expanded(
                      child: SelectionCard(
                        title: 'Write My Own',
                        subtitle: 'I have\na plan.',
                        isAiMode: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManualInputScreen(
                                userConcern: userConcern,
                                severityLevel: severityLevel,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Selection Card Widget
class SelectionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isAiMode;
  final VoidCallback onTap;

  const SelectionCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.isAiMode,
    required this.onTap,
  }) : super(key: key);

  @override
  State<SelectionCard> createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFF2E4B28).withOpacity(0.08)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: Stack(
            children: [
              // Background Pattern (Bottom Right)
              Positioned(
                bottom: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(24),
                  ),
                  child: CustomPaint(
                    size: const Size(120, 120),
                    painter: widget.isAiMode
                        ? AiPatternPainter()
                        : ManualPatternPainter(),
                  ),
                ),
              ),

              // Text Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: widget.title,
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          widget.title.replaceAll(' ', '\n'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E4B28),
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F1F1F).withOpacity(0.6),
                        height: 1.3,
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
}

// Custom Painter for AI Mode (Circles)
class AiPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E4B28).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.8), 40, paint);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.9), 25, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.4), 20, paint);

    final linePaint = Paint()
      ..color = const Color(0xFF2E4B28).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.8),
      Offset(size.width * 0.4, size.height * 0.9),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Manual Mode (Sharp Lines)
class ManualPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E4B28).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(size.width, size.height * 0.5);
    path.close();

    path.moveTo(size.width * 0.8, size.height * 0.9);
    path.lineTo(size.width * 0.3, size.height * 0.9);
    path.lineTo(size.width * 0.6, size.height * 0.6);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
