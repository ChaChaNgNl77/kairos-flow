import 'package:flutter/material.dart';
import '../widgets/wizard_top_bar.dart';
import 'timeline_screen.dart';

class OptionsResultScreen extends StatefulWidget {
  final String userConcern;
  final int severityLevel;
  final List<Map<String, String>> options;
  final List<Map<String, String>> timeline; // ← Added
  final List<String> actionSteps; // ← Added

  const OptionsResultScreen({
    Key? key,
    required this.userConcern,
    required this.severityLevel,
    required this.options,
    required this.timeline, // ← Added
    required this.actionSteps, // ← Added
  }) : super(key: key);

  @override
  State<OptionsResultScreen> createState() => _OptionsResultScreenState();
}

class _OptionsResultScreenState extends State<OptionsResultScreen> {
  late List<Map<String, String>> _displayOptions;

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of the options list
    _displayOptions = List.from(widget.options);

    // Ensure we always have 3 options - add "Do Nothing" if needed
    if (_displayOptions.length < 3) {
      _displayOptions.add({
        'label': 'Option C',
        'title': 'Do Nothing',
        'desc': 'Maintain the status quo and see what happens naturally.',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: WizardTopBar(
                progress: 0.8,
                onBack: () => Navigator.pop(context),
                onHome: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Header
                    const Text(
                      'Here are your paths.',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F1F1F),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Option Cards
                    ..._displayOptions.map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: OptionCard(
                          label: option['label']!,
                          title: option['title']!,
                          description: option['desc']!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TimelineScreen(
                                  userConcern: widget.userConcern,
                                  severityLevel: widget.severityLevel,
                                  selectedOption: option,
                                  timeline: widget.timeline, // ← Pass timeline
                                  actionSteps:
                                      widget.actionSteps, // ← Pass actionSteps
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Widget for the Option Card
class OptionCard extends StatelessWidget {
  final String label;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const OptionCard({
    Key? key,
    required this.label,
    required this.title,
    required this.description,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipPath(
        clipper: DiagonalCutClipper(cutSize: 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
          ),
          child: Stack(
            children: [
              // Decorative Green Triangle in the cut corner
              Positioned(
                top: 0,
                right: 0,
                child: CustomPaint(
                  size: const Size(24, 24),
                  painter: CornerTrianglePainter(),
                ),
              ),
              // Card Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E4B28),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F1F1F),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                        height: 1.5,
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

// Clipper for the top-right diagonal cut
class DiagonalCutClipper extends CustomClipper<Path> {
  final double cutSize;

  DiagonalCutClipper({this.cutSize = 24});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - cutSize, 0);
    path.lineTo(size.width, cutSize);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Painter for the small green triangle overlay
class CornerTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E4B28)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width - 24, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, 24);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
