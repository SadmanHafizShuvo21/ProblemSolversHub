import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/create_post_form_data.dart';
import '../presentation/bloc/create_post_bloc.dart';
import '../widgets/approach_step.dart';
import '../widgets/problem_info_step.dart';
import '../widgets/review_step.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final CreatePostFormData _formData = CreatePostFormData();

  final List<String> _stepTitles = ['Problem Info', 'Approach', 'Review'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    // Validate current step before moving
    if (_currentStep == 0 && step > _currentStep) {
      if (!_formData.isStep1Valid()) {
        _showValidationError(
          'Please fill in all required fields:\n- Problem Name\n- Problem Link\n- At least one Platform\n- Difficulty\n- At least one Tag',
        );
        return;
      }
    }

    if (_currentStep == 1 && step > _currentStep) {
      if (!_formData.isStep2Valid()) {
        _showValidationError(
          'Please fill in all required fields:\n- Approach Explanation\n- At least one Time Complexity\n- At least one Space Complexity',
        );
        return;
      }
    }

    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formData.isStep1Valid()) {
        _showValidationError(
          'Please fill in all required fields:\n- Problem Name\n- Problem Link\n- At least one Platform\n- Difficulty\n- At least one Tag',
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (!_formData.isStep2Valid()) {
        _showValidationError(
          'Please fill in all required fields:\n- Approach Explanation\n- At least one Time Complexity\n- At least one Space Complexity',
        );
        return;
      }
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _submitPost() {
    context.read<CreatePostBloc>().add(CreatePostSubmitEvent(_formData));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<CreatePostBloc, CreatePostState>(
      listener: (context, state) {
        if (state is CreatePostSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post created successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop();
        }

        if (state is CreatePostError) {
          _showValidationError(state.message);
        }
      },
      child: BlocBuilder<CreatePostBloc, CreatePostState>(
        builder: (context, state) {
          final isLoading = state is CreatePostLoading;

          return Scaffold(
            appBar: AppBar(title: const Text('Create Post'), elevation: 0),
            body: Column(
              children: [
                // Step Indicator
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: List.generate(
                      _stepTitles.length,
                      (index) => Expanded(
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => _goToStep(index),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentStep >= index
                                      ? theme.colorScheme.primary
                                      : theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                ),
                                child: Center(
                                  child: _currentStep > index
                                      ? Icon(
                                          Icons.check,
                                          color: theme.colorScheme.onPrimary,
                                        )
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: _currentStep >= index
                                                ? theme.colorScheme.onPrimary
                                                : theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _stepTitles[index],
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: _currentStep == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _currentStep == index
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Divider
                Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),

                // Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentStep = index);
                    },
                    children: [
                      // Step 1: Problem Info
                      ProblemInfoStep(
                        formData: _formData,
                        onDataChanged: (updatedData) {
                          // Update form data
                        },
                      ),
                      // Step 2: Approach
                      ApproachStep(
                        formData: _formData,
                        onDataChanged: (updatedData) {
                          // Update form data
                        },
                      ),
                      // Step 3: Review
                      ReviewStep(
                        formData: _formData,
                        onSubmit: _submitPost,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),

                // Navigation Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Previous Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentStep > 0 ? _previousStep : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            foregroundColor: theme.colorScheme.onSurface,
                          ),
                          child: const Text('Previous'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Next/Submit Button
                      if (_currentStep < 2)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _nextStep,
                            child: const Text('Next'),
                          ),
                        ),
                      if (_currentStep == 2)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submitPost,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Submit'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
