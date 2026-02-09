import 'package:flutter/material.dart';
import '../widgets/wizard_top_bar.dart';
import 'loading_screen.dart';

class ManualInputScreen extends StatefulWidget {
  final String userConcern;
  final int severityLevel;

  const ManualInputScreen({
    Key? key,
    required this.userConcern,
    required this.severityLevel,
  }) : super(key: key);

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  int _currentStep = 1;

  final TextEditingController _optionAController = TextEditingController();
  final TextEditingController _optionBController = TextEditingController();

  int _characterCount = 0;
  String _optionAText = '';
  String _optionBText = '';
  bool _hasUnsavedChanges = false;

  // Minimum 5 characters for meaningful input
  bool get _isValid {
    final currentText = _currentStep == 1
        ? _optionAController.text.trim()
        : _optionBController.text.trim();
    return currentText.length >= 5 && currentText.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _optionAController.addListener(_updateCharacterCount);
    _optionBController.addListener(_updateCharacterCount);
  }

  void _updateCharacterCount() {
    setState(() {
      if (_currentStep == 1) {
        _characterCount = _optionAController.text.length;
        _hasUnsavedChanges = _optionAController.text.trim().isNotEmpty;
      } else {
        _characterCount = _optionBController.text.length;
        _hasUnsavedChanges = _optionBController.text.trim().isNotEmpty;
      }
    });
  }

  @override
  void dispose() {
    _optionAController.dispose();
    _optionBController.dispose();
    super.dispose();
  }

  // Handle back button with confirmation
  Future<bool> _onWillPop() async {
    // If on Step 2, go back to Step 1 without confirmation
    if (_currentStep == 2) {
      setState(() {
        _currentStep = 1;
        _characterCount = _optionAController.text.length;
        _hasUnsavedChanges = _optionAController.text.trim().isNotEmpty;
      });
      return false; // Don't pop the route
    }

    // If on Step 1 and has unsaved changes, show confirmation
    if (_hasUnsavedChanges) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved text. Are you sure you want to go back?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }

    return true; // No unsaved changes, allow pop
  }

  void _handleNext() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_currentStep == 1) {
      // Step 1 -> Step 2
      _optionAText = _optionAController.text.trim();
      setState(() {
        _currentStep = 2;
        _characterCount = _optionBController.text.length;
        _hasUnsavedChanges = _optionBController.text.trim().isNotEmpty;
      });
    } else {
      // Step 2 -> Validate and navigate to Loading
      _optionBText = _optionBController.text.trim();

      // Check if options are the same
      if (_optionAText.toLowerCase() == _optionBText.toLowerCase()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Options A and B cannot be the same'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Navigate to LoadingScreen with user-defined options
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoadingScreen(
            userConcern: widget.userConcern,
            severityLevel: widget.severityLevel,
            userOptionA: _optionAText,
            userOptionB: _optionBText,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentController = _currentStep == 1
        ? _optionAController
        : _optionBController;
    final headerText = _currentStep == 1 ? 'Write Option A' : 'Write Option B';
    final buttonText = _currentStep == 1 ? 'Next' : 'Analyze';
    final progress = _currentStep == 1 ? 0.6 : 0.7;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Top Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: WizardTopBar(
                  progress: progress,
                  onBack: () async {
                    final shouldPop = await _onWillPop();
                    if (shouldPop && mounted) {
                      Navigator.pop(context);
                    }
                  },
                  onHome: () async {
                    if (_hasUnsavedChanges) {
                      final shouldPop = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Discard changes?'),
                          content: const Text(
                            'You have unsaved text. Are you sure you want to go home?',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Discard'),
                            ),
                          ],
                        ),
                      );
                      if (shouldPop == true && mounted) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    } else {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Step Indicator
                      _buildStepIndicator(),
                      const SizedBox(height: 16),

                      // Header
                      Text(
                        headerText,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Input Box
                      _buildInputBox(currentController),
                      const SizedBox(height: 8),

                      // Character Counter
                      _buildCharacterCounter(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Bottom Button Area (fixed)
              if (_isValid)
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: _buildActionButton(buttonText),
                ),
              if (!_isValid) const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(
          1,
          isActive: _currentStep == 1,
          isCompleted: _currentStep > 1,
        ),
        _buildStepLine(isCompleted: _currentStep > 1),
        _buildStepDot(2, isActive: _currentStep == 2, isCompleted: false),
      ],
    );
  }

  Widget _buildStepDot(
    int step, {
    required bool isActive,
    required bool isCompleted,
  }) {
    Color color;
    if (isCompleted) {
      color = const Color(0xFF2E4B28);
    } else if (isActive) {
      color = const Color(0xFF2E4B28);
    } else {
      color = Colors.grey[300]!;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : Text(
                '$step',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.grey[500],
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? const Color(0xFF2E4B28) : Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildInputBox(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.start,
        minLines: 8,
        maxLines: null,
        maxLength: 1000,
        textInputAction: TextInputAction.done,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F1F1F),
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: 'Write here...',
          hintStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.grey[400],
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          counterText: '',
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildCharacterCounter() {
    final currentText = _currentStep == 1
        ? _optionAController.text.trim()
        : _optionBController.text.trim();
    final trimmedLength = currentText.length;
    final isValidLength = trimmedLength >= 5;

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '$_characterCount / 1000 ${!isValidLength && trimmedLength > 0 ? "(min 5)" : ""}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isValidLength ? const Color(0xFF2E4B28) : Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _handleNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E4B28),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
