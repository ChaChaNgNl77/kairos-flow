import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/wizard_top_bar.dart';
import 'action_plan_screen.dart';

class TimelineScreen extends StatefulWidget {
  final String userConcern;
  final int severityLevel;
  final Map<String, String> selectedOption;
  final List<Map<String, String>> timeline; // ← Added
  final List<String> actionSteps; // ← Added

  const TimelineScreen({
    Key? key,
    required this.userConcern,
    required this.severityLevel,
    required this.selectedOption,
    required this.timeline, // ← Added
    required this.actionSteps, // ← Added
  }) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animation Definitions
  late Animation<double> _centerDotScale;
  late Animation<double> _ripple1Scale;
  late Animation<double> _ripple1Opacity;
  late Animation<double> _ripple2Scale;
  late Animation<double> _ripple2Opacity;
  late Animation<double> _ripple3Scale;
  late Animation<double> _ripple3Opacity;

  late List<Animation<double>> _cardOpacities;
  late List<Animation<Offset>> _cardSlides;

  @override
  void initState() {
    super.initState();

    // Animation Duration (4.5 seconds for slow ripple)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    );

    // Define Intervals for "Ripple Effect"
    _centerDotScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.elasticOut),
      ),
    );

    // Ripple 1
    _ripple1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
      ),
    );
    _ripple1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.4, curve: Curves.easeIn),
      ),
    );

    // Ripple 2
    _ripple2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    _ripple2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    // Ripple 3
    _ripple3Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );
    _ripple3Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

    // Card Animations
    _cardOpacities = [];
    _cardSlides = [];

    final cardIntervals = [
      const Interval(0.4, 0.7, curve: Curves.easeOut),
      const Interval(0.6, 0.9, curve: Curves.easeOut),
      const Interval(0.8, 1.0, curve: Curves.easeOut),
    ];

    for (var interval in cardIntervals) {
      _cardOpacities.add(
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: _controller, curve: interval)),
      );
      _cardSlides.add(
        Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: interval)),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Epicenter for ripples
    final double epicenterY = screenHeight * 0.15;

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
                progress: 0.9,
                onBack: () => Navigator.pop(context),
                onHome: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Future Projection',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F1F),
                  letterSpacing: -0.5,
                ),
              ),
            ),

            Expanded(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Background Ripples (Fixed Position)
                  _buildAnimatedRipple(
                    animationScale: _ripple3Scale,
                    animationOpacity: _ripple3Opacity,
                    width: screenWidth * 1.2,
                    topOffset: epicenterY - (screenWidth * 1.2 / 2),
                    borderColor: const Color(0xFF2E4B28).withOpacity(0.15),
                  ),
                  _buildAnimatedRipple(
                    animationScale: _ripple2Scale,
                    animationOpacity: _ripple2Opacity,
                    width: screenWidth * 0.85,
                    topOffset: epicenterY - (screenWidth * 0.85 / 2),
                    borderColor: const Color(0xFF2E4B28).withOpacity(0.25),
                  ),
                  _buildAnimatedRipple(
                    animationScale: _ripple1Scale,
                    animationOpacity: _ripple1Opacity,
                    width: screenWidth * 0.5,
                    topOffset: epicenterY - (screenWidth * 0.5 / 2),
                    borderColor: const Color(0xFF2E4B28).withOpacity(0.35),
                  ),
                  Positioned(
                    top: epicenterY - 8,
                    child: ScaleTransition(
                      scale: _centerDotScale,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2E4B28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E4B28).withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Scrollable Card Content
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            SizedBox(height: epicenterY + 40),

                            // Use Gemini-generated timeline data
                            if (widget.timeline.isNotEmpty) ...[
                              for (
                                int i = 0;
                                i < widget.timeline.length && i < 3;
                                i++
                              )
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 32),
                                  child: _buildAnimatedCard(
                                    i,
                                    widget.timeline[i],
                                    alignment: i == 0
                                        ? Alignment.center
                                        : (i == 1
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft),
                                    widthFactor: 0.8 + (i * 0.05),
                                  ),
                                ),
                            ],

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Button
            _buildCompleteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedRipple({
    required Animation<double> animationScale,
    required Animation<double> animationOpacity,
    required double width,
    required double topOffset,
    required Color borderColor,
  }) {
    return Positioned(
      top: topOffset,
      child: FadeTransition(
        opacity: animationOpacity,
        child: ScaleTransition(
          scale: animationScale,
          child: Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(
    int index,
    Map<String, String> data, {
    required Alignment alignment,
    required double widthFactor,
  }) {
    return FadeTransition(
      opacity: _cardOpacities[index],
      child: SlideTransition(
        position: _cardSlides[index],
        child: Align(
          alignment: alignment,
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E4B28).withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data['time'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E4B28),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['desc'] ?? 'No description',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1F1F1F).withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: SizedBox(
        height: 60,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActionPlanScreen(
                  userConcern: widget.userConcern,
                  severityLevel: widget.severityLevel,
                  selectedOption: widget.selectedOption,
                  actionSteps: widget.actionSteps, 
                  timeline: widget.timeline,
                ),
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
            'Complete',
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
