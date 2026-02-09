import 'package:flutter/material.dart';
import '../models/archive_item.dart';
import 'home_screen.dart';

class ArchiveDetailScreen extends StatefulWidget {
  final ArchiveItem item;

  const ArchiveDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<ArchiveDetailScreen> createState() => _ArchiveDetailScreenState();
}

class _ArchiveDetailScreenState extends State<ArchiveDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleSolve() {
    setState(() {
      widget.item.isSolved = !widget.item.isSolved;
      widget.item.save();
    });
  }

  void _toggleTodo(int index, bool? value) {
    setState(() {
      // Ensure the list is large enough to avoid Index Out of Bounds
      if (widget.item.todoStatus.length <= index) {
        widget.item.todoStatus.add(false);
      }
      widget.item.todoStatus[index] = value ?? false;
      widget.item.save();
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      widget.item.comments.add(_commentController.text);
      widget.item.save();
      _commentController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(hasSavedData: true),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F1F1F),
          ),
          onPressed: () => Navigator.pop(context, widget.item.isSolved),
        ),
        title: const Text(
          'Archive Detail',
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Color(0xFF1F1F1F)),
            onPressed: _goHome,
            tooltip: 'Go Home',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 32),

            _buildSectionTitle('Check your progress'),
            const SizedBox(height: 16),
            _buildTodoList(), 
            const SizedBox(height: 32),

            _buildSectionTitle('Predicted Timeline'),
            const SizedBox(height: 16),
            _buildTimelinePreview(), 
            const SizedBox(height: 32),

            _buildSectionTitle('Retrospective Note'),
            const SizedBox(height: 8),
            const Text(
              'Leave a short note about your feelings (Max 200).',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),

            _buildCommentList(),
            const SizedBox(height: 16),
            _buildCommentInput(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // --- Widgets ---

  Widget _buildTodoList() {
    final tasks = widget.item.todoTasks;

    // Sync todoStatus length with todoTasks length if they don't match
    if (widget.item.todoStatus.length < tasks.length) {
      widget.item.todoStatus = List.generate(
        tasks.length,
        (index) => index < widget.item.todoStatus.length
            ? widget.item.todoStatus[index]
            : false,
      );
    }

    return Column(
      children: List.generate(tasks.length, (index) {
        final bool isChecked = widget.item.todoStatus[index];
        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFF2E4B28),
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            tasks[index], // Use actual task text from model
            style: TextStyle(
              decoration: isChecked ? TextDecoration.lineThrough : null,
              color: isChecked ? Colors.grey : const Color(0xFF1F1F1F),
            ),
          ),
          value: isChecked,
          onChanged: (val) => _toggleTodo(index, val),
        );
      }),
    );
  }

  // [Updated] Show timeline using the dynamic data from the model
  Widget _buildTimelinePreview() {
    final timelineData = widget.item.timeline;

    if (timelineData.isEmpty) {
      return const Text("No timeline data available.");
    }

    return Column(
      children: timelineData.map((data) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildTimelineBox(
            data['time'] ?? 'N/A',
            data['desc'] ?? 'No description',
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimelineBox(String time, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70, // Fixed width for time labels
            child: Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E4B28),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList() {
    if (widget.item.comments.isEmpty) return Container();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.item.comments.length,
      itemBuilder: (context, index) {
        final comment = widget.item.comments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.comment, size: 18, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  comment,
                  style: const TextStyle(color: Color(0xFF424242), height: 1.4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _commentController,
          maxLength: 200,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Write a comment...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2E4B28),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _addComment,
          icon: const Icon(Icons.send, size: 16, color: Colors.white),
          label: const Text(
            "Add Note",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E4B28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.item.date, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            widget.item.concern,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Decision: ${widget.item.decision}",
            style: const TextStyle(
              color: Color(0xFF2E4B28),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F1F1F),
      ),
    );
  }

  Widget _buildBottomButton() {
    final bool isSolved = widget.item.isSolved;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: _toggleSolve,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSolved
                ? Colors.grey[300]
                : const Color(0xFF2E4B28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: Text(
            isSolved ? 'Resolved' : 'Mark as Solved',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
