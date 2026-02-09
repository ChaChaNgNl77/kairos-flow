import 'package:flutter/material.dart';
import '../widgets/wizard_top_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/archive_item.dart';
import 'home_screen.dart';

class ActionPlanScreen extends StatefulWidget {
  final String userConcern;
  final int severityLevel;
  final Map<String, String> selectedOption;
  final List<String> actionSteps;
  final List<Map<String, String>> timeline;

  const ActionPlanScreen({
    Key? key,
    required this.userConcern,
    required this.severityLevel,
    required this.selectedOption,
    required this.actionSteps,
    required this.timeline,
  }) : super(key: key);

  @override
  State<ActionPlanScreen> createState() => _ActionPlanScreenState();
}

class _ActionPlanScreenState extends State<ActionPlanScreen> {
  late List<Map<String, dynamic>> _todoList;

  @override
  void initState() {
    super.initState();
    _todoList = _generateToDoList();
  }

  List<Map<String, dynamic>> _generateToDoList() {
    // Use Gemini-generated action steps
    return widget.actionSteps.map((step) {
      return {'task': step, 'isChecked': false};
    }).toList();
  }

  void _handleSave() async {
    // Get Hive archive box
    final box = Hive.box<ArchiveItem>('archives');

    // Create new archive item
    final newItem = ArchiveItem(
      date: DateFormat('yyyy. MM. dd').format(DateTime.now()),
      concern: widget.userConcern,
      decision: widget.selectedOption['title'] ?? 'My Decision',
      severity: widget.severityLevel,
      todoTasks: widget.actionSteps, 
      timeline: widget.timeline, 
      isSolved: false,
    );

    // Save to Hive
    await box.add(newItem);
    debugPrint("✅ Saved successfully! Total items: ${box.length}");

    // Show success message
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Saved to Archive!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E4B28),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate to home after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(hasSavedData: true),
          ),
          (route) => false,
        );
      }
    });
  }

  void _handleDiscard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Progress?'),
        content: const Text(
          'Are you sure you want to discard your action plan? This cannot be undone.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
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
                progress: 1.0,
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
                      "Let's make it happen.",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F1F1F),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Decision Summary
                    _buildDecisionSummary(),
                    const SizedBox(height: 32),

                    // Action Plan
                    _buildActionPlan(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Save & Discard Section
            _buildSaveSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDecisionSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Choice',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E4B28),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.selectedOption['title'] ?? 'Your Decision',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E4B28),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionPlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Next Steps',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F1F1F),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: _todoList.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No action steps available',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                  ),
                )
              : Column(
                  children: List.generate(_todoList.length, (index) {
                    return _buildCheckboxItem(index);
                  }),
                ),
        ),
      ],
    );
  }

  Widget _buildCheckboxItem(int index) {
    final item = _todoList[index];
    final isLast = index == _todoList.length - 1;

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: CheckboxListTile(
        value: item['isChecked'],
        onChanged: (bool? value) {
          setState(() {
            _todoList[index]['isChecked'] = value ?? false;
          });
        },
        title: Text(
          item['task'],
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1F1F1F),
            decoration: item['isChecked']
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            decorationColor: Colors.grey[500],
            decorationThickness: 2,
          ),
        ),
        activeColor: const Color(0xFF2E4B28),
        checkColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildSaveSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Column(
        children: [
          const Text(
            'Do you want to save this journey to your Archive?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F1F1F),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Discard Button
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: TextButton(
                    onPressed: _handleDiscard,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                    ),
                    child: const Text(
                      'Discard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Save Button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E4B28),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.archive_outlined, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Save to Archive',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
