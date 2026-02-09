import 'package:flutter/material.dart';
import 'dart:async';
import 'options_result_screen.dart';
import '../services/gemini_service.dart';

class LoadingScreen extends StatefulWidget {
  final String userConcern;
  final int severityLevel;
  final String userOptionA;
  final String userOptionB;

  const LoadingScreen({
    Key? key,
    required this.userConcern,
    required this.severityLevel,
    required this.userOptionA,
    required this.userOptionB,
  }) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _textCycleTimer;
  Timer? _timeoutTimer;

  final GeminiService _geminiService = GeminiService();

  int _currentTextIndex = 0;
  bool _hasError = false;
  bool _isProcessing = false;

  final List<String> _loadingTexts = [
    "Connecting with Gemini...",
    "Analyzing patterns...",
    "Drafting future scenarios...",
  ];

  // Timeout duration (30 seconds)
  static const Duration _timeoutDuration = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Text cycle timer
    _startTextCycleTimer();

    // Start analysis with timeout
    _startAnalysis();
  }

  void _startTextCycleTimer() {
    _textCycleTimer?.cancel();
    _textCycleTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && !_hasError) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
        });
      }
    });
  }

  Future<void> _startAnalysis() async {
    if (_isProcessing) return; // Prevent multiple simultaneous calls

    setState(() {
      _isProcessing = true;
      _hasError = false;
    });

    // Start timeout timer
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_timeoutDuration, () {
      if (_isProcessing && mounted) {
        _handleTimeout();
      }
    });

    try {
      // Call Gemini API
      final result = await _geminiService.analyzeConcern(
        concern: widget.userConcern,
        severity: widget.severityLevel,
        userOptionA: widget.userOptionA.isEmpty ? null : widget.userOptionA,
        userOptionB: widget.userOptionB.isEmpty ? null : widget.userOptionB,
      );

      // Cancel timeout timer
      _timeoutTimer?.cancel();

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      // Check if API returned error
      if (result['isValid'] == false) {
        _showErrorDialog('Failed to analyze your concern. Please try again.');
        return;
      }

      // Validate required fields
      if (result['option_a'] == null || result['option_b'] == null) {
        _showErrorDialog('Invalid response from AI. Please try again.');
        return;
      }

      // Extract options with null safety
      final List<Map<String, String>> uiOptions = [
        {
          'label': 'Option A',
          'title':
              (result['option_a'] is Map
                  ? result['option_a']['title']
                  : null) ??
              'Option A',
          'desc':
              (result['option_a'] is Map ? result['option_a']['desc'] : null) ??
              'Description not available',
        },
        {
          'label': 'Option B',
          'title':
              (result['option_b'] is Map
                  ? result['option_b']['title']
                  : null) ??
              'Option B',
          'desc':
              (result['option_b'] is Map ? result['option_b']['desc'] : null) ??
              'Description not available',
        },
      ];

      // Extract timeline (exactly 3 items)
      final List<Map<String, String>> timeline = [];
      if (result['timeline'] is List) {
        final timelineData = result['timeline'] as List;
        for (int i = 0; i < 3 && i < timelineData.length; i++) {
          if (timelineData[i] is Map) {
            timeline.add({
              'time': timelineData[i]['time']?.toString() ?? 'Unknown',
              'desc': timelineData[i]['desc']?.toString() ?? 'No description',
            });
          }
        }
      }

      // Ensure exactly 3 timeline items
      while (timeline.length < 3) {
        timeline.add({
          'time': 'Future',
          'desc': 'Further developments will unfold',
        });
      }

      // Extract action steps (exactly 4 items)
      final List<String> actionSteps = [];
      if (result['action_steps'] is List) {
        final stepsData = result['action_steps'] as List;
        for (int i = 0; i < 4 && i < stepsData.length; i++) {
          final step = stepsData[i]?.toString().trim();
          if (step != null && step.isNotEmpty) {
            actionSteps.add(step);
          }
        }
      }

      // Ensure exactly 4 action steps
      while (actionSteps.length < 4) {
        actionSteps.add('Review and adjust as needed');
      }

      // Navigate to Result Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OptionsResultScreen(
            userConcern: widget.userConcern,
            severityLevel: widget.severityLevel,
            options: uiOptions,
            timeline: timeline,
            actionSteps: actionSteps,
          ),
        ),
      );
    } catch (e) {
      _timeoutTimer?.cancel();
      debugPrint("❌ Error in analysis: $e");

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      _showErrorDialog(
        'An error occurred during analysis. Please check your connection and try again.',
      );
    }
  }

  void _handleTimeout() {
    if (!mounted || _hasError) return;

    setState(() {
      _isProcessing = false;
    });

    _showErrorDialog(
      'Request timed out. Please check your connection and try again.',
    );
  }

  void _showErrorDialog(String message) {
    if (_hasError || !mounted) return; // Prevent duplicate dialogs

    setState(() {
      _hasError = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Analysis Failed'),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () {
              if (!mounted) return;
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!mounted) return;
              Navigator.pop(context); // Close dialog
              setState(() {
                _hasError = false;
                _currentTextIndex = 0;
              });
              _startTextCycleTimer(); // Restart timer
              _startAnalysis(); // Retry
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E4B28),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _textCycleTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button during loading
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFastPulsingBlob(),
                const SizedBox(height: 48),
                _buildCyclingText(),
                const SizedBox(height: 24),
                _buildProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFastPulsingBlob() {
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
                  color: const Color(0xFF2E4B28).withOpacity(0.3),
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

  Widget _buildCyclingText() {
    return SizedBox(
      height: 30,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Text(
          _loadingTexts[_currentTextIndex],
          key: ValueKey<int>(_currentTextIndex),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return SizedBox(
      width: 200,
      child: LinearProgressIndicator(
        backgroundColor: Colors.grey[200],
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E4B28)),
      ),
    );
  }
}
