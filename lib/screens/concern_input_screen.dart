import 'package:flutter/material.dart';
import '../widgets/wizard_top_bar.dart';
import 'mode_selection_screen.dart';

class ConcernInputScreen extends StatefulWidget {
  const ConcernInputScreen({Key? key}) : super(key: key);

  @override
  State<ConcernInputScreen> createState() => _ConcernInputScreenState();
}

class _ConcernInputScreenState extends State<ConcernInputScreen> {
  final TextEditingController _concernController = TextEditingController();
  int? _selectedSeverity;
  int _characterCount = 0;
  bool _hasUnsavedChanges = false;

  // Validation logic - improved
  bool get _isValid {
    final trimmedText = _concernController.text.trim();
    return trimmedText.length >= 10 && // Reduced from 20 to 10
        trimmedText.isNotEmpty && // Not just whitespace
        _selectedSeverity != null;
  }

  @override
  void initState() {
    super.initState();
    _concernController.addListener(() {
      setState(() {
        _characterCount = _concernController.text.length;
        _hasUnsavedChanges = _concernController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _concernController.dispose();
    super.dispose();
  }

  // Handle back button with confirmation if there's unsaved text
  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved text. Are you sure you want to go back?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  void _handleContinue() {
    // Dismiss keyboard before navigation
    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModeSelectionScreen(
          userConcern: _concernController.text.trim(),
          severityLevel: _selectedSeverity!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  progress: 0.2,
                  onBack: () async {
                    if (Navigator.canPop(context)) {
                      final shouldPop = await _onWillPop();
                      if (shouldPop && mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  onHome: () async {
                    final shouldPop = await _onWillPop();
                    if (shouldPop && mounted) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),

                      // Header
                      const Text(
                        'What is your concern?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Input Field
                      _buildConcernInput(),
                      const SizedBox(height: 8),

                      // Character Counter
                      _buildCharacterCounter(),
                      const SizedBox(height: 40),

                      // Severity Selector
                      _buildSeveritySelector(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Bottom Button Area (fixed)
              if (_isValid)
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: _buildContinueButton(),
                ),
              if (!_isValid) const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConcernInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _concernController,
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
          counterText: '', // Hide default counter
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildCharacterCounter() {
    final trimmedLength = _concernController.text.trim().length;
    final isValidLength = trimmedLength >= 10;

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '$_characterCount / 1000 ${!isValidLength && trimmedLength > 0 ? "(min 10)" : ""}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isValidLength ? const Color(0xFF2E4B28) : Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildSeveritySelector() {
    final severityLabels = {
      1: "Level 1 - Piece of Cake 🍰",
      2: "Level 2 - Not a big deal",
      3: "Level 3 - Something to think about",
      4: "Level 4 - Serious matter",
      5: "Level 5 - Life-Changing ⚡",
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Level of Concern',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F1F1F),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedSeverity,
              isExpanded: true,
              hint: Text(
                'Select Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF2E4B28),
                size: 28,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F1F1F),
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              items: severityLabels.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSeverity = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _handleContinue,
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
          'Continue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
