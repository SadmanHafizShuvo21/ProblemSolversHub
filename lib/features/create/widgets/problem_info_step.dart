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

  final List<String> platforms = [
    'LeetCode',
    'Codeforces',
    'HackerRank',
    'GeeksforGeeks',
    'AtCoder',
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

  void _toggleTag(String tag) {
    setState(() {
      if (widget.formData.tags.contains(tag)) {
        widget.formData.tags = widget.formData.tags
            .where((t) => t != tag)
            .toList();
      } else if (widget.formData.tags.length < 5) {
        widget.formData.tags = [...widget.formData.tags, tag];
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Maximum 5 tags allowed')));
        return;
      }
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
          const SizedBox(height: 16),
          // Platform Dropdown
          DropdownButtonFormField<String>(
            initialValue: widget.formData.platform,
            decoration: const InputDecoration(
              labelText: 'Platform *',
              border: OutlineInputBorder(),
            ),
            items: platforms
                .map(
                  (platform) =>
                      DropdownMenuItem(value: platform, child: Text(platform)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                widget.formData.platform = value ?? 'LeetCode';
                _updateFormData();
              });
            },
          ),
          const SizedBox(height: 16),
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
          // Tags
          Text(
            'Tags (max 5) *',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: availableTags
                .map(
                  (tag) => FilterChip(
                    label: Text(tag),
                    selected: widget.formData.tags.contains(tag),
                    onSelected: (_) => _toggleTag(tag),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Selected: ${widget.formData.tags.isEmpty ? 'None' : widget.formData.tags.join(', ')} (${widget.formData.tags.length}/5)',
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
