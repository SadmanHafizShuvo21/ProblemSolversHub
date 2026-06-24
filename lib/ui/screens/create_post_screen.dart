import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:problem_solvers_hub/core/theme/app_theme.dart';
import 'package:problem_solvers_hub/ui/models/dummy_data.dart';
import 'package:problem_solvers_hub/ui/widgets/post_card.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _problemController = TextEditingController();
  final _linkController = TextEditingController();
  final _approachController = TextEditingController();
  final _codeController = TextEditingController();
  final _timeController = TextEditingController();
  final _spaceController = TextEditingController();
  final _tagController = TextEditingController();
  final _learningController = TextEditingController();
  final List<String> _tags = [];
  final List<String> _learnings = [];
  String _platform = 'LeetCode';
  String _difficulty = 'Beginner';
  int _currentStep = 0;

  static const _platformOptions = ['LeetCode', 'Codeforces', 'HackerRank'];
  static const _difficultyOptions = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _addTag(String tag) {
    if (tag.isEmpty) return;
    if (_tags.length < 5 && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _addLearning() {
    final value = _learningController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _learnings.add(value);
      _learningController.clear();
    });
  }

  Future<void> _submit() async {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login before submitting a post.')),
      );
      return;
    }

    final username = currentUser.displayName?.trim().isNotEmpty == true
        ? currentUser.displayName!
        : currentUser.email ?? 'Anonymous';
    final posterAvatar = currentUser.photoURL ??
        'https://via.placeholder.com/80';

    final postData = {
      'userId': currentUser.uid,
      'userName': username,
      'userAvatar': posterAvatar,
      'problemTitle': _problemController.text.trim(),
      'problemLink': _linkController.text.trim(),
      'platform': _platform,
      'difficulty': _difficulty,
      'timeComplexity': _timeController.text.trim(),
      'spaceComplexity': _spaceController.text.trim(),
      'approachPreview': _approachController.text.trim(),
      'approachFull': _approachController.text.trim(),
      'codeSnippet': _codeController.text.trim(),
      'tags': _tags,
      'keyLearnings': _learnings,
      'likes': 0,
      'comments': 0,
      'views': 0,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('posts').add(postData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post submitted successfully!')),
      );
      setState(() {
        _currentStep = 0;
        _problemController.clear();
        _linkController.clear();
        _approachController.clear();
        _codeController.clear();
        _timeController.clear();
        _spaceController.clear();
        _tags.clear();
        _learnings.clear();
        _difficulty = 'Beginner';
        _platform = 'LeetCode';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit post: $e')),
      );
    }
  }

  @override
  void dispose() {
    _problemController.dispose();
    _linkController.dispose();
    _approachController.dispose();
    _codeController.dispose();
    _timeController.dispose();
    _spaceController.dispose();
    _tagController.dispose();
    _learningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 18),
            Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    height: 8,
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? AppTheme.primary
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildStepContent(context)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentStep == 0 ? null : _previousStep,
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == 2 ? _submit : _nextStep,
                    child: Text(_currentStep == 2 ? 'Submit' : 'Next'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildProblemInfoStep(context);
      case 1:
        return _buildApproachStep(context);
      default:
        return _buildReviewStep(context);
    }
  }

  Widget _buildProblemInfoStep(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Problem Info',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          _buildTextField(
            label: 'Problem name',
            controller: _problemController,
          ),
          const SizedBox(height: 14),
          _buildTextField(label: 'Problem link', controller: _linkController),
          const SizedBox(height: 14),
          _buildDropdown(
            label: 'Platform',
            value: _platform,
            options: _platformOptions,
            onChanged: (value) => setState(() => _platform = value),
          ),
          const SizedBox(height: 14),
          _buildChoiceChips(
            label: 'Difficulty',
            options: _difficultyOptions,
            selected: _difficulty,
            onSelected: (value) => setState(() => _difficulty = value),
          ),
          const SizedBox(height: 14),
          _buildTagInput(context),
        ],
      ),
    );
  }

  Widget _buildApproachStep(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Approach',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          _buildTextField(
            label: 'Time complexity',
            controller: _timeController,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Space complexity',
            controller: _spaceController,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Approach',
            controller: _approachController,
            minLines: 5,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Code snippet',
            controller: _codeController,
            minLines: 5,
            fontFamily: 'monospace',
          ),
          const SizedBox(height: 14),
          Text(
            'Key learnings',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Add insight',
                  controller: _learningController,
                  hideLabel: true,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addLearning,
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _learnings.map((item) {
              return Chip(
                label: Text(item),
                onDeleted: () {
                  setState(() => _learnings.remove(item));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep(BuildContext context) {
    final preview = PostPreview(
      id: 'preview',
      username: 'You',
      avatarUrl:
          'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=crop&w=80&q=80',
      difficulty: _difficulty,
      title: _problemController.text.isEmpty
          ? 'Untitled problem'
          : _problemController.text,
      platform: _platform,
      tags: _tags.isEmpty ? ['Approach'] : _tags,
      preview: _approachController.text.isEmpty
          ? 'Preview of your approach will appear here.'
          : _approachController.text,
      likes: 0,
      comments: _learnings.length,
      views: 0,
      timestamp: 'Draft',
      approach: _approachController.text,
      code: _codeController.text.isEmpty
          ? '// Your code snippet'
          : _codeController.text,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          PostCard(post: preview, onTap: null),
          const SizedBox(height: 18),
          Text(
            'Tags',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _tags.map((tag) => Chip(label: Text(tag))).toList(),
          ),
          const SizedBox(height: 18),
          Text(
            'Key learnings',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ..._learnings.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: Theme.of(context).textTheme.bodyMedium),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int minLines = 1,
    String? fontFamily,
    bool hideLabel = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hideLabel)
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        if (!hideLabel) const SizedBox(height: 8),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: minLines > 1 ? null : 1,
          style: TextStyle(fontFamily: fontFamily),
          decoration: InputDecoration(
            hintText: hideLabel ? 'Enter value' : 'Enter $label',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: options
                .map(
                  (option) =>
                      DropdownMenuItem(value: option, child: Text(option)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChips({
    required String label,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final isActive = option == selected;
            return ChoiceChip(
              label: Text(option),
              selected: isActive,
              selectedColor: AppTheme.primary,
              backgroundColor: const Color(0xFFE2E8F0),
              labelStyle: TextStyle(
                color: isActive ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => onSelected(option),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _tags.map((tag) {
            return Chip(
              label: Text(tag),
              onDeleted: () => setState(() => _tags.remove(tag)),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Add a tag',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                onSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _addTag(_tagController.text.trim()),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Up to 5 tags',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
