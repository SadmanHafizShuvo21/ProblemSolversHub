import 'package:flutter/material.dart';

import '../models/create_post_form_data.dart';

class ProblemInfoStep extends StatefulWidget {
  final CreatePostFormData formData;
  final Function(CreatePostFormData) onDataChanged;

  const ProblemInfoStep({
    super.key,
    required this.formData,
    required this.onDataChanged,
  });

  @override
  State<ProblemInfoStep> createState() => _ProblemInfoStepState();
}

class _ProblemInfoStepState extends State<ProblemInfoStep> {
  late TextEditingController _problemNameController;
  late TextEditingController _problemLinkController;

  final List<String> availablePlatforms = [
    'LeetCode',
    'Codeforces',
    'HackerRank',
    'GeeksforGeeks',
    'AtCoder',
    'CodeChef',
    'Interviewbit',
  ];
  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> availableTags = [
    'Array',
    'String',
    'Dynamic Programming',
    'Graph',
    'Tree',
    'Binary Search',
    'Greedy',
    'Stack',
    'Queue',
    'Heap',
    'Hash Map',
    'Recursion',
    'Sorting',
    'Linked List',
  ];

  String? _urlError;

  @override
  void initState() {
    super.initState();
    _problemNameController = TextEditingController(
      text: widget.formData.problemName,
    );
    _problemLinkController = TextEditingController(
      text: widget.formData.problemLink,
    );
  }

  @override
  void dispose() {
    _problemNameController.dispose();
    _problemLinkController.dispose();
    super.dispose();
  }

  void _updateFormData() {
    widget.formData.problemName = _problemNameController.text;
    widget.formData.problemLink = _problemLinkController.text;
    widget.onDataChanged(widget.formData);
  }

  void _validateURL(String value) {
    setState(() {
      if (value.isEmpty) {
        _urlError = null;
      } else if (!widget.formData.isValidURL(value)) {
        _urlError =
            'Please enter a valid URL (starting with http:// or https://)';
      } else {
        _urlError = null;
      }
    });
  }

  void _addPlatform() {
    if (widget.formData.selectedPlatform.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a platform first')),
      );
      return;
    }

    setState(() {
      if (!widget.formData.platforms
          .contains(widget.formData.selectedPlatform)) {
        widget.formData.platforms = [
          ...widget.formData.platforms,
          widget.formData.selectedPlatform,
        ];
        widget.formData.selectedPlatform = '';
        _updateFormData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Platform already added')),
        );
      }
    });
  }

  void _removePlatform(String platform) {
    setState(() {
      widget.formData.platforms =
          widget.formData.platforms.where((p) => p != platform).toList();
      _updateFormData();
    });
  }

  void _addTag() {
    if (widget.formData.selectedTag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tag first')),
      );
      return;
    }

    if (widget.formData.tags.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 tags allowed')),
      );
      return;
    }

    setState(() {
      if (!widget.formData.tags.contains(widget.formData.selectedTag)) {
        widget.formData.tags = [
          ...widget.formData.tags,
          widget.formData.selectedTag,
        ];
        widget.formData.selectedTag = '';
        _updateFormData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tag already added')),
        );
      }
    });
  }

  void _removeTag(String tag) {
    setState(() {
      widget.formData.tags =
          widget.formData.tags.where((t) => t != tag).toList();
      _updateFormData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Problem Name
          TextField(
            controller: _problemNameController,
            decoration: const InputDecoration(
              labelText: 'Problem Name *',
              hintText: 'e.g., Two Sum',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),

          // Problem Link
          TextField(
            controller: _problemLinkController,
            decoration: InputDecoration(
              labelText: 'Problem Link *',
              hintText: 'https://leetcode.com/problems/two-sum/',
              border: const OutlineInputBorder(),
              errorText: _urlError,
            ),
            onChanged: _validateURL,
          ),
          const SizedBox(height: 24),

          // Platform Selection with Add Button
          Text(
            'Platforms *',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.formData.selectedPlatform.isEmpty
                      ? null
                      : widget.formData.selectedPlatform,
                  decoration: const InputDecoration(
                    labelText: 'Select Platform',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: availablePlatforms
                      .map(
                        (platform) => DropdownMenuItem(
                          value: platform,
                          child: Text(platform),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.formData.selectedPlatform = value ?? '';
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addPlatform,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Selected Platforms
          if (widget.formData.platforms.isNotEmpty)
            Wrap(
              spacing: 8,
              children: widget.formData.platforms
                  .map(
                    (platform) => Chip(
                      label: Text(platform),
                      onDeleted: () => _removePlatform(platform),
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  )
                  .toList(),
            ),
          if (widget.formData.platforms.isEmpty)
            Text(
              'No platforms added yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 24),

          // Difficulty Selector
          Text(
            'Difficulty *',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: difficulties
                .map(
                  (diff) => ChoiceChip(
                    label: Text(diff),
                    selected: widget.formData.difficulty == diff,
                    onSelected: (selected) {
                      setState(() {
                        widget.formData.difficulty = diff;
                        _updateFormData();
                      });
                    },
                    backgroundColor: _getDifficultyColor(
                      diff,
                      theme,
                    ).withValues(alpha: 0.3),
                    selectedColor: _getDifficultyColor(diff, theme),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),

          // Tag Selection with Add Button
          Text(
            'Tags (max 5) *',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.formData.selectedTag.isEmpty
                      ? null
                      : widget.formData.selectedTag,
                  decoration: const InputDecoration(
                    labelText: 'Select Tag',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: availableTags
                      .map(
                        (tag) => DropdownMenuItem(
                          value: tag,
                          child: Text(tag),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.formData.selectedTag = value ?? '';
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addTag,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Selected Tags
          if (widget.formData.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              children: widget.formData.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      onDeleted: () => _removeTag(tag),
                      backgroundColor:
                          theme.colorScheme.tertiary.withValues(alpha: 0.2),
                    ),
                  )
                  .toList(),
            ),
          if (widget.formData.tags.isEmpty)
            Text(
              'No tags added yet (${widget.formData.tags.length}/5)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Text(
              'Added: ${widget.formData.tags.length}/5 tags',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty, ThemeData theme) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }
}
