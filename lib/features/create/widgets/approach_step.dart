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
  late TextEditingController _codeController;
  late List<TextEditingController> _learningControllers;

  final List<String> commonTimeComplexities = [
    'O(1)',
    'O(log n)',
    'O(n)',
    'O(n log n)',
    'O(n²)',
    'O(n³)',
    'O(2^n)',
    'O(n!)',
  ];

  final List<String> commonSpaceComplexities = [
    'O(1)',
    'O(log n)',
    'O(n)',
    'O(n²)',
    'O(2^n)',
  ];

  @override
  void initState() {
    super.initState();
    _approachController = TextEditingController(
      text: widget.formData.approachExplanation,
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
    _codeController.dispose();
    for (var controller in _learningControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateFormData() {
    widget.formData.approachExplanation = _approachController.text;
    widget.formData.codeSnippet = _codeController.text;
    widget.formData.keyLearnings = _learningControllers
        .map((c) => c.text)
        .where((text) => text.isNotEmpty)
        .toList();
    widget.onDataChanged(widget.formData);
  }

  void _addTimeComplexity() {
    if (widget.formData.selectedTimeComplexity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time complexity first')),
      );
      return;
    }

    setState(() {
      if (!widget.formData.timeComplexities
          .contains(widget.formData.selectedTimeComplexity)) {
        widget.formData.timeComplexities = [
          ...widget.formData.timeComplexities,
          widget.formData.selectedTimeComplexity,
        ];
        widget.formData.selectedTimeComplexity = '';
        _updateFormData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time complexity already added')),
        );
      }
    });
  }

  void _removeTimeComplexity(String complexity) {
    setState(() {
      widget.formData.timeComplexities = widget.formData.timeComplexities
          .where((c) => c != complexity)
          .toList();
      _updateFormData();
    });
  }

  void _addSpaceComplexity() {
    if (widget.formData.selectedSpaceComplexity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a space complexity first')),
      );
      return;
    }

    setState(() {
      if (!widget.formData.spaceComplexities
          .contains(widget.formData.selectedSpaceComplexity)) {
        widget.formData.spaceComplexities = [
          ...widget.formData.spaceComplexities,
          widget.formData.selectedSpaceComplexity,
        ];
        widget.formData.selectedSpaceComplexity = '';
        _updateFormData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Space complexity already added')),
        );
      }
    });
  }

  void _removeSpaceComplexity(String complexity) {
    setState(() {
      widget.formData.spaceComplexities = widget.formData.spaceComplexities
          .where((c) => c != complexity)
          .toList();
      _updateFormData();
    });
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

          // Time Complexity Selection with Add Button
          Text(
            'Time Complexity *',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.formData.selectedTimeComplexity.isEmpty
                      ? null
                      : widget.formData.selectedTimeComplexity,
                  decoration: const InputDecoration(
                    labelText: 'Select Time Complexity',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: commonTimeComplexities
                      .map(
                        (complexity) => DropdownMenuItem(
                          value: complexity,
                          child: Text(complexity),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.formData.selectedTimeComplexity = value ?? '';
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addTimeComplexity,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Selected Time Complexities
          if (widget.formData.timeComplexities.isNotEmpty)
            Wrap(
              spacing: 8,
              children: widget.formData.timeComplexities
                  .map(
                    (complexity) => Chip(
                      label: Text(complexity),
                      onDeleted: () => _removeTimeComplexity(complexity),
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  )
                  .toList(),
            ),
          if (widget.formData.timeComplexities.isEmpty)
            Text(
              'No time complexities added yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 24),

          // Space Complexity Selection with Add Button
          Text(
            'Space Complexity *',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.formData.selectedSpaceComplexity.isEmpty
                      ? null
                      : widget.formData.selectedSpaceComplexity,
                  decoration: const InputDecoration(
                    labelText: 'Select Space Complexity',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: commonSpaceComplexities
                      .map(
                        (complexity) => DropdownMenuItem(
                          value: complexity,
                          child: Text(complexity),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.formData.selectedSpaceComplexity = value ?? '';
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addSpaceComplexity,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Selected Space Complexities
          if (widget.formData.spaceComplexities.isNotEmpty)
            Wrap(
              spacing: 8,
              children: widget.formData.spaceComplexities
                  .map(
                    (complexity) => Chip(
                      label: Text(complexity),
                      onDeleted: () => _removeSpaceComplexity(complexity),
                      backgroundColor:
                          theme.colorScheme.tertiary.withValues(alpha: 0.2),
                    ),
                  )
                  .toList(),
            ),
          if (widget.formData.spaceComplexities.isEmpty)
            Text(
              'No space complexities added yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
