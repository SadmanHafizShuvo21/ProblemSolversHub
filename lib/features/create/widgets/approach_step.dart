import 'package:flutter/material.dart';

import '../models/create_post_form_data.dart';

class ApproachStep extends StatefulWidget {
  final CreatePostFormData formData;
  final Function(CreatePostFormData) onDataChanged;

  const ApproachStep({
    super.key,
    required this.formData,
    required this.onDataChanged,
  });

  @override
  State<ApproachStep> createState() => _ApproachStepState();
}

class _ApproachStepState extends State<ApproachStep> {
  late TextEditingController _approachController;
  late TextEditingController _timeComplexityController;
  late TextEditingController _spaceComplexityController;
  late TextEditingController _codeController;
  late List<TextEditingController> _learningControllers;

  @override
  void initState() {
    super.initState();
    _approachController = TextEditingController(
      text: widget.formData.approachExplanation,
    );
    _timeComplexityController = TextEditingController(
      text: widget.formData.timeComplexity,
    );
    _spaceComplexityController = TextEditingController(
      text: widget.formData.spaceComplexity,
    );
    _codeController = TextEditingController(text: widget.formData.codeSnippet);

    _learningControllers = widget.formData.keyLearnings
        .map((learning) => TextEditingController(text: learning))
        .toList();

    // Ensure at least one learning field
    if (_learningControllers.isEmpty) {
      _learningControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _approachController.dispose();
    _timeComplexityController.dispose();
    _spaceComplexityController.dispose();
    _codeController.dispose();
    for (var controller in _learningControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateFormData() {
    widget.formData.approachExplanation = _approachController.text;
    widget.formData.timeComplexity = _timeComplexityController.text;
    widget.formData.spaceComplexity = _spaceComplexityController.text;
    widget.formData.codeSnippet = _codeController.text;
    widget.formData.keyLearnings = _learningControllers
        .map((c) => c.text)
        .where((text) => text.isNotEmpty)
        .toList();
    widget.onDataChanged(widget.formData);
  }

  void _addLearningField() {
    setState(() {
      _learningControllers.add(TextEditingController());
    });
  }

  void _removeLearningField(int index) {
    setState(() {
      _learningControllers[index].dispose();
      _learningControllers.removeAt(index);
    });
    _updateFormData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Approach Explanation
          Text(
            'Approach Explanation *',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _approachController,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Describe your approach step by step...',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 24),
          // Time Complexity
          TextField(
            controller: _timeComplexityController,
            decoration: const InputDecoration(
              labelText: 'Time Complexity *',
              hintText: 'e.g., O(n log n)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          // Space Complexity
          TextField(
            controller: _spaceComplexityController,
            decoration: const InputDecoration(
              labelText: 'Space Complexity *',
              hintText: 'e.g., O(n)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 24),
          // Code Snippet
          Text(
            'Code Snippet',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _codeController,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: 'Paste your code here...',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.all(12),
              fillColor: theme.colorScheme.surfaceContainerHighest,
              filled: true,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 24),
          // Key Learnings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Key Learnings',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _addLearningField,
                tooltip: 'Add learning point',
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _learningControllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _learningControllers[index],
                        decoration: InputDecoration(
                          hintText: 'Learning point ${index + 1}...',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => _updateFormData(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_learningControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeLearningField(index),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
