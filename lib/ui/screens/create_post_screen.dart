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
  // Controllers for text fields
  final _problemController = TextEditingController();
  final _linkController = TextEditingController();
  final _approachController = TextEditingController();
  final _codeController = TextEditingController();
  
  // Controller for learning field
  final TextEditingController _learningController = TextEditingController();
  
  // Selected items
  final List<String> _tags = []; // Multi-select for tags
  String _selectedTimeComplexity = ''; // Single select
  String _selectedSpaceComplexity = ''; // Single select
  final List<String> _learnings = [];
  
  // State variables
  String _selectedPlatform = '';
  String _selectedDifficulty = 'Beginner';
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Suggestion lists (loaded from Firestore + defaults)
  List<String> _suggestedTags = [];
  List<String> _suggestedTimeComplexities = [];
  List<String> _suggestedSpaceComplexities = [];
  List<String> _suggestedPlatforms = [];

  // Default data
  static const _difficultyOptions = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  static const _defaultTags = [
    'Array', 'String', 'Linked List', 'Tree', 'Graph', 'DP', 
    'Binary Search', 'Sorting', 'Hash Table', 'Stack', 'Queue', 
    'Heap', 'Recursion', 'Backtracking', 'Greedy', 'Bit Manipulation',
    'Trie', 'Segment Tree', 'Fenwick Tree', 'Union Find', 'Sliding Window',
    'Two Pointers', 'BFS', 'DFS', 'Dijkstra', 'Floyd Warshall',
    'KMP', 'Rabin-Karp', 'Z-Algorithm', 'Suffix Array'
  ];

  static const _defaultTimeComplexities = [
    'O(1)', 'O(log n)', 'O(n)', 'O(n log n)', 'O(n²)', 
    'O(n³)', 'O(2^n)', 'O(n!)', 'O(n + m)', 'O(n * m)',
    'O(log log n)', 'O(n√n)', 'O(√n)', 'O(α(n))', 'O(n² log n)'
  ];

  static const _defaultSpaceComplexities = [
    'O(1)', 'O(log n)', 'O(n)', 'O(n log n)', 'O(n²)', 
    'O(n³)', 'O(2^n)', 'O(n!)', 'O(n + m)', 'O(n * m)',
    'O(√n)', 'O(α(n))', 'O(n² log n)'
  ];

  static const _defaultPlatforms = [
    'LeetCode', 'Codeforces', 'HackerRank', 'AtCoder', 'CodeChef',
    'TopCoder', 'HackerEarth', 'Kattis', 'SPOJ', 'UVa', 'LightOJ',
    'CSES', 'Google Kick Start', 'CodeJam', 'Meta Hacker Cup'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _setDefaultSuggestions();
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _suggestedTags = List<String>.from(data['usedTags'] ?? []);
          _suggestedTimeComplexities = List<String>.from(data['usedTimeComplexities'] ?? []);
          _suggestedSpaceComplexities = List<String>.from(data['usedSpaceComplexities'] ?? []);
          _suggestedPlatforms = List<String>.from(data['usedPlatforms'] ?? []);
          
          // Merge with defaults
          _suggestedTags = [..._suggestedTags, ..._defaultTags].toSet().toList()..sort();
          _suggestedTimeComplexities = [..._suggestedTimeComplexities, ..._defaultTimeComplexities].toSet().toList()..sort();
          _suggestedSpaceComplexities = [..._suggestedSpaceComplexities, ..._defaultSpaceComplexities].toSet().toList()..sort();
          _suggestedPlatforms = [..._suggestedPlatforms, ..._defaultPlatforms].toSet().toList()..sort();
        });
      } else {
        _setDefaultSuggestions();
      }
    } catch (e) {
      _setDefaultSuggestions();
    }
  }

  void _setDefaultSuggestions() {
    setState(() {
      _suggestedTags = _defaultTags.toList()..sort();
      _suggestedTimeComplexities = _defaultTimeComplexities.toList()..sort();
      _suggestedSpaceComplexities = _defaultSpaceComplexities.toList()..sort();
      _suggestedPlatforms = _defaultPlatforms.toList()..sort();
    });
  }

  Future<void> _saveUserPreferences() async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Merge all used values
      final allTags = [..._suggestedTags, ..._tags].toSet().toList()..sort();
      final allTimeComplexities = [..._suggestedTimeComplexities];
      if (_selectedTimeComplexity.isNotEmpty && !allTimeComplexities.contains(_selectedTimeComplexity)) {
        allTimeComplexities.add(_selectedTimeComplexity);
        allTimeComplexities.sort();
      }
      final allSpaceComplexities = [..._suggestedSpaceComplexities];
      if (_selectedSpaceComplexity.isNotEmpty && !allSpaceComplexities.contains(_selectedSpaceComplexity)) {
        allSpaceComplexities.add(_selectedSpaceComplexity);
        allSpaceComplexities.sort();
      }
      final allPlatforms = [..._suggestedPlatforms];
      if (_selectedPlatform.isNotEmpty && !allPlatforms.contains(_selectedPlatform)) {
        allPlatforms.add(_selectedPlatform);
        allPlatforms.sort();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
            'usedTags': allTags,
            'usedTimeComplexities': allTimeComplexities,
            'usedSpaceComplexities': allSpaceComplexities,
            'usedPlatforms': allPlatforms,
          }, SetOptions(merge: true));
    } catch (e) {
      // Silent fail for preferences
    }
  }

  // ==================== MANAGEMENT METHODS ====================
  
  void _addTag(String value) {
    value = value.trim();
    if (value.isEmpty) return;
    if (_tags.length >= 5) {
      _showSnackbar('Maximum 5 tags allowed');
      return;
    }
    if (!_tags.contains(value)) {
      setState(() {
        _tags.add(value);
        if (!_suggestedTags.contains(value)) {
          _suggestedTags.add(value);
          _suggestedTags.sort();
        }
      });
    } else {
      _showSnackbar('Tag already added');
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _addLearning() {
    final value = _learningController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _learnings.add(value);
      _learningController.clear();
    });
  }

  void _removeLearning(String value) {
    setState(() {
      _learnings.remove(value);
    });
  }

  // ==================== NAVIGATION METHODS ====================

  void _nextStep() {
    if (_currentStep == 0 && _problemController.text.isEmpty) {
      _showSnackbar('Please enter the problem name');
      return;
    }
    if (_currentStep == 1 && _approachController.text.isEmpty) {
      _showSnackbar('Please describe your approach');
      return;
    }
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  // ==================== SUBMIT METHOD ====================

  Future<void> _submit() async {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showSnackbar('Please login before submitting a post.');
      return;
    }

    // Validation
    if (_problemController.text.trim().isEmpty) {
      _showSnackbar('Please enter the problem name');
      return;
    }
    
    if (_approachController.text.trim().isEmpty) {
      _showSnackbar('Please describe your approach');
      return;
    }

    if (_selectedPlatform.isEmpty) {
      _showSnackbar('Please select a platform');
      return;
    }

    setState(() => _isSubmitting = true);

    final username = currentUser.displayName?.trim().isNotEmpty == true
        ? currentUser.displayName!
        : currentUser.email?.split('@').first ?? 'Anonymous';
    final posterAvatar = currentUser.photoURL ??
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(username)}&background=random';

    final postData = {
      'userId': currentUser.uid,
      'userName': username,
      'userAvatar': posterAvatar,
      'problemTitle': _problemController.text.trim(),
      'problemLink': _linkController.text.trim(),
      'platform': _selectedPlatform,
      'difficulty': _selectedDifficulty,
      'timeComplexity': _selectedTimeComplexity, // Now stored as single value
      'spaceComplexity': _selectedSpaceComplexity, // Now stored as single value
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
      await _saveUserPreferences();
      
      if (!mounted) return;
      _showSnackbar('Post submitted successfully!');
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      _showSnackbar('Failed to submit post: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _resetForm() {
    setState(() {
      _currentStep = 0;
      _problemController.clear();
      _linkController.clear();
      _approachController.clear();
      _codeController.clear();
      _tags.clear();
      _selectedTimeComplexity = '';
      _selectedSpaceComplexity = '';
      _learnings.clear();
      _selectedDifficulty = 'Beginner';
      _selectedPlatform = '';
      _learningController.clear();
    });
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _problemController.dispose();
    _linkController.dispose();
    _approachController.dispose();
    _codeController.dispose();
    _learningController.dispose();
    super.dispose();
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: theme.colorScheme.onSurface),
        title: const Text('Create Post'),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 18),
            _buildStepper(),
            const SizedBox(height: 20),
            Expanded(child: _buildStepContent()),
            const SizedBox(height: 16),
            _buildNavigationButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
            height: 8,
            decoration: BoxDecoration(
              color: index <= _currentStep
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _currentStep == 0 || _isSubmitting ? null : _previousStep,
            child: const Text('Previous'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : (_currentStep == 2 ? _submit : _nextStep),
            child: Text(
              _isSubmitting 
                ? 'Submitting...' 
                : (_currentStep == 2 ? 'Submit' : 'Next')
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildProblemInfoStep();
      case 1:
        return _buildApproachStep();
      default:
        return _buildReviewStep();
    }
  }

  // ==================== STEP 1: PROBLEM INFO ====================

  Widget _buildProblemInfoStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Problem Info',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _buildTextField(
            label: 'Problem name *',
            controller: _problemController,
            hint: 'e.g., Two Sum',
            required: true,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Problem link',
            controller: _linkController,
            hint: 'https://leetcode.com/problems/...',
          ),
          const SizedBox(height: 14),
          _buildPlatformSelector(),
          const SizedBox(height: 14),
          _buildChoiceChips(
            label: 'Difficulty *',
            options: _difficultyOptions,
            selected: _selectedDifficulty,
            onSelected: (value) => setState(() => _selectedDifficulty = value),
          ),
          const SizedBox(height: 14),
          _buildMultiSelectDropdown(
            label: 'Tags',
            selectedItems: _tags,
            suggestions: _suggestedTags,
            onChanged: (newList) => setState(() => _tags
              ..clear()
              ..addAll(newList)),
            onAddCustom: (value) {
              if (!_suggestedTags.contains(value)) {
                setState(() {
                  _suggestedTags.add(value);
                  _suggestedTags.sort();
                });
              }
            },
            maxItems: 5,
            helperText: 'Select up to 5 tags • DSA concepts',
            isMultiSelect: true,
          ),
        ],
      ),
    );
  }

  // ==================== SINGLE SELECT DROPDOWN (Platform, Time, Space) ====================

  Widget _buildSingleSelectDropdown({
    required String label,
    required String selectedValue,
    required List<String> suggestions,
    required Function(String) onChanged,
    required Function(String) onAddCustom,
    String? helperText,
    bool isRequired = false,
  }) {
    final allItems = [...suggestions].toSet().toList()..sort();
    
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
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedValue.isNotEmpty ? selectedValue : null,
                    isExpanded: true,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Select $label...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    items: [
                      ...allItems.map((item) => DropdownMenuItem(
                        value: item,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                item == selectedValue ? Icons.check_circle : Icons.circle_outlined,
                                size: 20,
                                color: item == selectedValue ? Theme.of(context).colorScheme.primary : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item,
                                style: TextStyle(
                                  fontWeight: item == selectedValue ? FontWeight.w600 : FontWeight.normal,
                                  color: item == selectedValue ? Theme.of(context).colorScheme.primary : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onChanged(value);
                      }
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => _showAddCustomItemDialog(
                  title: 'Add Custom $label',
                  onAdd: (value) {
                    onAddCustom(value);
                    onChanged(value);
                  },
                ),
                tooltip: 'Add custom $label',
              ),
            ],
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              helperText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (isRequired && selectedValue.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Please select a $label',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlatformSelector() {
    return _buildSingleSelectDropdown(
      label: 'Platform',
      selectedValue: _selectedPlatform,
      suggestions: _suggestedPlatforms,
      onChanged: (value) => setState(() => _selectedPlatform = value),
      onAddCustom: (value) {
        if (!_suggestedPlatforms.contains(value)) {
          setState(() {
            _suggestedPlatforms.add(value);
            _suggestedPlatforms.sort();
          });
        }
      },
      isRequired: true,
      helperText: 'Select the platform where you solved this problem',
    );
  }

  // ==================== MULTI-SELECT DROPDOWN (Tags only) ====================

  Widget _buildMultiSelectDropdown({
    required String label,
    required List<String> selectedItems,
    required List<String> suggestions,
    required Function(List<String>) onChanged,
    required Function(String) onAddCustom,
    int? maxItems,
    String? helperText,
    bool isMultiSelect = true,
  }) {
    final allItems = [...suggestions].toSet().toList()..sort();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        // Display selected items as chips
        if (selectedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
                children: selectedItems.map((item) => Chip(
                label: Text(item),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  final newList = List<String>.from(selectedItems)..remove(item);
                  onChanged(newList);
                },
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              )).toList(),
            ),
          ),
        // Dropdown with add button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: null, // Always shows hint
                    isExpanded: true,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        selectedItems.isEmpty 
                            ? 'Select $label...' 
                            : '${selectedItems.length} selected',
                        style: TextStyle(
                          color: selectedItems.isNotEmpty
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade600,
                          fontWeight: selectedItems.isNotEmpty
                            ? FontWeight.w600
                            : FontWeight.normal,
                        ),
                      ),
                    ),
                    items: [
                      // Add a "Select All" option
                      DropdownMenuItem(
                        value: 'select_all',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                selectedItems.length == allItems.length 
                                    ? Icons.check_box 
                                    : Icons.check_box_outline_blank,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text('Select All'),
                            ],
                          ),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: 'divider',
                        enabled: false,
                        child: Divider(height: 1),
                      ),
                      ...allItems.map((item) {
                        final isSelected = selectedItems.contains(item);
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                  size: 20,
                                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      
                      if (value == 'select_all') {
                        // Toggle select all
                        if (selectedItems.length == allItems.length) {
                          onChanged([]);
                        } else {
                          if (maxItems != null && allItems.length > maxItems) {
                            _showSnackbar('Cannot select more than $maxItems items');
                            return;
                          }
                          onChanged(List.from(allItems));
                        }
                        return;
                      }
                      
                      // Toggle individual item
                      final newList = List<String>.from(selectedItems);
                      if (newList.contains(value)) {
                        newList.remove(value);
                      } else {
                        if (maxItems != null && newList.length >= maxItems) {
                          _showSnackbar('Maximum $maxItems items allowed');
                          return;
                        }
                        newList.add(value);
                      }
                      onChanged(newList);
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => _showAddCustomItemDialog(
                  title: 'Add Custom $label',
                  onAdd: (value) {
                    onAddCustom(value);
                    if (maxItems == null || selectedItems.length < maxItems) {
                      final newList = List<String>.from(selectedItems)..add(value);
                      onChanged(newList);
                    } else {
                      _showSnackbar('Maximum $maxItems items allowed');
                    }
                  },
                ),
                tooltip: 'Add custom $label',
              ),
            ],
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              helperText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (maxItems != null && selectedItems.length >= maxItems)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Maximum $maxItems items allowed',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showAddCustomItemDialog({
    required String title,
    required Function(String) onAdd,
  }) async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter value...',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              onAdd(value.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                onAdd(value);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ==================== STEP 2: APPROACH ====================

  Widget _buildApproachStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Approach Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _buildSingleSelectDropdown(
            label: 'Time Complexity',
            selectedValue: _selectedTimeComplexity,
            suggestions: _suggestedTimeComplexities,
            onChanged: (value) => setState(() => _selectedTimeComplexity = value),
            onAddCustom: (value) {
              if (!_suggestedTimeComplexities.contains(value)) {
                setState(() {
                  _suggestedTimeComplexities.add(value);
                  _suggestedTimeComplexities.sort();
                });
              }
            },
            helperText: 'Common: O(1), O(n), O(log n), O(n²)',
          ),
          const SizedBox(height: 14),
          _buildSingleSelectDropdown(
            label: 'Space Complexity',
            selectedValue: _selectedSpaceComplexity,
            suggestions: _suggestedSpaceComplexities,
            onChanged: (value) => setState(() => _selectedSpaceComplexity = value),
            onAddCustom: (value) {
              if (!_suggestedSpaceComplexities.contains(value)) {
                setState(() {
                  _suggestedSpaceComplexities.add(value);
                  _suggestedSpaceComplexities.sort();
                });
              }
            },
            helperText: 'Common: O(1), O(n), O(log n), O(n²)',
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Approach *',
            controller: _approachController,
            minLines: 5,
            maxLines: 10,
            hint: 'Describe your approach in detail...',
            required: true,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Code Snippet',
            controller: _codeController,
            minLines: 5,
            maxLines: 10,
            fontFamily: 'monospace',
            hint: 'Paste your code here...',
          ),
          const SizedBox(height: 14),
          _buildKeyLearnings(),
        ],
      ),
    );
  }

  Widget _buildKeyLearnings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Learnings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _learningController,
                decoration: InputDecoration(
                  hintText: 'Add an insight...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _addLearning(),
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
              onDeleted: () => _removeLearning(item),
            );
          }).toList(),
        ),
        if (_learnings.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Add key insights you learned from this problem',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  // ==================== STEP 3: REVIEW ====================

  Widget _buildReviewStep() {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final String username = currentUser?.displayName?.trim().isNotEmpty == true
        ? currentUser!.displayName!
        : currentUser?.email?.split('@').first ?? 'You';
    final avatarUrl = currentUser?.photoURL ??
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(username)}&background=random';

    final preview = PostPreview(
      id: 'preview',
      username: username,
      avatarUrl: avatarUrl,
      difficulty: _selectedDifficulty,
      title: _problemController.text.isEmpty
          ? 'Untitled problem'
          : _problemController.text,
      platform: _selectedPlatform.isNotEmpty ? _selectedPlatform : 'Other',
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
            'Review Your Post',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check everything looks good before publishing',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          PostCard(post: preview, onTap: null, isHovered: false),
          const SizedBox(height: 18),
          _buildReviewSection(
            title: 'Details',
            items: [
              'Platform: ${_selectedPlatform.isNotEmpty ? _selectedPlatform : 'Not set'}',
              'Difficulty: $_selectedDifficulty',
            ],
          ),
          const SizedBox(height: 12),
          _buildReviewSection(
            title: 'Time Complexity',
            items: [_selectedTimeComplexity.isNotEmpty ? _selectedTimeComplexity : 'Not specified'],
            isChip: true,
          ),
          const SizedBox(height: 12),
          _buildReviewSection(
            title: 'Space Complexity',
            items: [_selectedSpaceComplexity.isNotEmpty ? _selectedSpaceComplexity : 'Not specified'],
            isChip: true,
          ),
          const SizedBox(height: 12),
          _buildReviewSection(
            title: 'Tags',
            items: _tags.isEmpty ? ['No tags added'] : _tags,
            isChip: true,
          ),
          const SizedBox(height: 12),
          _buildReviewSection(
            title: 'Key Learnings',
            items: _learnings.isEmpty ? ['No learnings added'] : _learnings,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection({
    required String title,
    required List<String> items,
    bool isChip = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (isChip)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items.map((item) => Chip(label: Text(item))).toList(),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
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
    );
  }

  // ==================== COMMON WIDGETS ====================

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int minLines = 1,
    int? maxLines,
    String? fontFamily,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines ?? (minLines > 1 ? null : 1),
          style: TextStyle(fontFamily: fontFamily),
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
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
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: const Color(0xFFE2E8F0),
              labelStyle: TextStyle(
                color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => onSelected(option),
            );
          }).toList(),
        ),
      ],
    );
  }
}