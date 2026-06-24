# Create Post - Code Quick Reference

## 📚 Key Classes & Files

### 1. CreatePostFormData Model
**File**: `lib/features/create/models/create_post_form_data.dart`

```dart
class CreatePostFormData {
  // Single fields
  String problemName;
  String problemLink;
  String difficulty;
  String approachExplanation;
  String codeSnippet;
  
  // Multi-select fields (NEW)
  List<String> platforms;          // Selected platforms
  String selectedPlatform;         // Dropdown selection
  List<String> tags;               // Selected tags
  String selectedTag;              // Dropdown selection
  List<String> timeComplexities;   // Selected complexities
  String selectedTimeComplexity;   // Dropdown selection
  List<String> spaceComplexities;  // Selected complexities
  String selectedSpaceComplexity;  // Dropdown selection
  
  // Key learnings
  List<String> keyLearnings;

  // Validation methods
  bool isStep1Valid() {
    return problemName.isNotEmpty &&
        problemLink.isNotEmpty &&
        platforms.isNotEmpty &&
        difficulty.isNotEmpty &&
        tags.isNotEmpty;
  }

  bool isStep2Valid() {
    return approachExplanation.isNotEmpty &&
        timeComplexities.isNotEmpty &&
        spaceComplexities.isNotEmpty;
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'problemName': problemName,
      'problemLink': problemLink,
      'platforms': platforms,
      'difficulty': difficulty,
      'tags': tags,
      'timeComplexities': timeComplexities,
      'spaceComplexities': spaceComplexities,
      'approachExplanation': approachExplanation,
      'codeSnippet': codeSnippet,
      'keyLearnings': keyLearnings,
    };
  }
}
```

---

### 2. ProblemModel
**File**: `lib/features/posts/data/models/problem_model.dart`

```dart
class ProblemModel {
  final String? id;
  final String userId;
  final String problemName;
  final String problemLink;
  final List<String> platforms;      // Multiple platforms
  final String difficulty;
  final List<String> tags;           // Multiple tags
  final List<String> timeComplexities;
  final List<String> spaceComplexities;
  final String approachExplanation;
  final String codeSnippet;
  final List<String> keyLearnings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // JSON serialization
  Map<String, dynamic> toJson() { ... }
  
  factory ProblemModel.fromJson(Map<String, dynamic> json) { ... }
}
```

---

### 3. FirebaseProblemsDataSource
**File**: `lib/features/posts/data/datasources/firebase_problems_datasource.dart`

```dart
class FirebaseProblemsDataSource {
  final FirebaseFirestore _firestore;

  Future<ProblemModel> createProblem(
    ProblemModel problem,
    String userId,
  ) async {
    // Creates document in 'problems' collection
    // Adds userId, timestamps automatically
  }

  Future<List<ProblemModel>> getUserProblems(String userId) async {
    // Fetches all problems by user
  }

  Stream<List<ProblemModel>> getUserProblemsStream(String userId) {
    // Real-time updates for user's problems
  }

  // Additional methods: update, delete, getById, etc.
}
```

---

## 🎯 Multi-Select Implementation Pattern

### Adding Items

```dart
void _addPlatform() {
  if (widget.formData.selectedPlatform.isEmpty) {
    _showError('Please select a platform first');
    return;
  }

  setState(() {
    if (!widget.formData.platforms
        .contains(widget.formData.selectedPlatform)) {
      // Add new platform
      widget.formData.platforms = [
        ...widget.formData.platforms,
        widget.formData.selectedPlatform,
      ];
      // Reset dropdown
      widget.formData.selectedPlatform = '';
      _updateFormData();
    } else {
      _showError('Platform already added');
    }
  });
}
```

### Removing Items

```dart
void _removePlatform(String platform) {
  setState(() {
    widget.formData.platforms =
        widget.formData.platforms.where((p) => p != platform).toList();
    _updateFormData();
  });
}
```

### UI Display

```dart
// Dropdown + Add Button
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
        ),
        items: availablePlatforms
            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
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
    ),
  ],
)

// Selected Items as Chips
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
)
```

---

## 🔄 CreatePostBloc Update

**File**: `lib/features/create/presentation/bloc/create_post_bloc.dart`

```dart
class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final CreatePostUsecase createPostUsecase;
  final AuthBloc authBloc;
  final FirebaseProblemsDataSource problemsDataSource;  // NEW

  CreatePostBloc({
    required this.createPostUsecase,
    required this.authBloc,
    required this.problemsDataSource,  // NEW
  }) : super(const CreatePostInitial()) {
    on<CreatePostSubmitEvent>(_onCreatePostSubmit);
  }

  Future<void> _onCreatePostSubmit(
    CreatePostSubmitEvent event,
    Emitter<CreatePostState> emit,
  ) async {
    emit(const CreatePostLoading());
    try {
      final authState = authBloc.state;
      if (authState is! AuthAuthenticated) {
        emit(const CreatePostError('User not authenticated'));
        return;
      }

      final user = authState.user;
      final formData = event.formData;

      // Create and save post
      final post = Post(
        userId: user.id,
        userAvatar: user.photoUrl ?? 'https://via.placeholder.com/40',
        userName: user.displayName,
        problemTitle: formData.problemName,
        platform: formData.platforms.isNotEmpty
            ? formData.platforms.first
            : '',
        difficulty: formData.difficulty,
        tags: formData.tags,
        approachPreview: formData.approachExplanation,
        approachFull: formData.approachExplanation,
        codeSnippet: formData.codeSnippet,
        likes: 0,
        comments: 0,
        views: 0,
        timestamp: DateTime.now(),
      );

      // Save to posts collection
      final createdPost =
          await createPostUsecase(post: post, userId: user.id);

      // Create problem model
      final problemModel = ProblemModel(
        userId: user.id,
        problemName: formData.problemName,
        problemLink: formData.problemLink,
        platforms: formData.platforms,
        difficulty: formData.difficulty,
        tags: formData.tags,
        timeComplexities: formData.timeComplexities,
        spaceComplexities: formData.spaceComplexities,
        approachExplanation: formData.approachExplanation,
        codeSnippet: formData.codeSnippet,
        keyLearnings: formData.keyLearnings,
      );

      // Save to problems collection (NEW)
      await problemsDataSource.createProblem(problemModel, user.id);

      emit(CreatePostSuccess(createdPost));
    } catch (e) {
      emit(CreatePostError(e.toString()));
    }
  }
}
```

---

## 🔧 ServiceLocator Setup

**File**: `lib/core/service_locator.dart`

```dart
void setupServiceLocator() {
  // ... existing code ...

  // ============= POSTS =============
  getIt.registerLazySingleton<FirebasePostsDatasource>(
    () => FirebasePostsDatasource(),
  );
  
  // NEW: Register problems datasource
  getIt.registerLazySingleton<FirebaseProblemsDataSource>(
    () => FirebaseProblemsDataSource(),
  );
  
  getIt.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImpl(getIt<FirebasePostsDatasource>()),
  );
  
  getIt.registerLazySingleton<CreatePostUsecase>(
    () => CreatePostUsecase(getIt<PostsRepository>()),
  );
  
  getIt.registerLazySingleton<CreatePostBloc>(() => CreatePostBloc(
    createPostUsecase: getIt<CreatePostUsecase>(),
    authBloc: getIt<AuthBloc>(),
    problemsDataSource: getIt<FirebaseProblemsDataSource>(),  // NEW
  ));
}
```

---

## 📋 Predefined Options

### Available Platforms (7)
```dart
final List<String> availablePlatforms = [
  'LeetCode',
  'Codeforces',
  'HackerRank',
  'GeeksforGeeks',
  'AtCoder',
  'CodeChef',
  'Interviewbit',
];
```

### Available Tags (14)
```dart
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
```

### Time Complexities (8)
```dart
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
```

### Space Complexities (5)
```dart
final List<String> commonSpaceComplexities = [
  'O(1)',
  'O(log n)',
  'O(n)',
  'O(n²)',
  'O(2^n)',
];
```

---

## ⚠️ Validation Messages

### Step 1 Validation Error:
```
"Please fill in all required fields:
 - Problem Name
 - Problem Link
 - At least one Platform
 - Difficulty
 - At least one Tag"
```

### Step 2 Validation Error:
```
"Please fill in all required fields:
 - Approach Explanation
 - At least one Time Complexity
 - At least one Space Complexity"
```

### Add Errors:
```
"Please select a platform first"
"Platform already added"
"Maximum 5 tags allowed"
"Please select a time complexity first"
"Time complexity already added"
```

---

## 📊 Firestore Collection Structure

### posts Collection
```
└── posts/
    └── {docId}
        ├── id: "docId"
        ├── userId: "user123"
        ├── problemTitle: "Two Sum"
        ├── platform: "LeetCode"  (string, first item)
        ├── difficulty: "Easy"
        ├── tags: ["Array", "String"]
        ├── codeSnippet: "..."
        ├── timestamp: 2024-01-15...
        └── ... (other fields)
```

### problems Collection (NEW)
```
└── problems/
    └── {docId}
        ├── id: "docId"
        ├── userId: "user123"
        ├── problemName: "Two Sum"
        ├── problemLink: "https://..."
        ├── platforms: ["LeetCode", "Codeforces"]  (array)
        ├── difficulty: "Easy"
        ├── tags: ["Array", "String"]
        ├── timeComplexities: ["O(n)", "O(n log n)"]
        ├── spaceComplexities: ["O(1)", "O(n)"]
        ├── approachExplanation: "..."
        ├── codeSnippet: "..."
        ├── keyLearnings: ["...", "..."]
        ├── createdAt: 2024-01-15...
        └── updatedAt: 2024-01-15...
```

---

## ✅ Testing Code Snippets

### Test Adding Platform
```dart
// Select platform from dropdown
formData.selectedPlatform = 'LeetCode';

// Add platform
if (!formData.platforms.contains(formData.selectedPlatform)) {
  formData.platforms = [
    ...formData.platforms,
    formData.selectedPlatform,
  ];
}

// Assert
expect(formData.platforms, contains('LeetCode'));
expect(formData.platforms.length, 1);
```

### Test Validation
```dart
// Create form data
var formData = CreatePostFormData(
  problemName: 'Two Sum',
  problemLink: 'https://leetcode.com/problems/two-sum/',
  platforms: ['LeetCode'],
  difficulty: 'Easy',
  tags: ['Array'],
);

// Assert Step 1 valid
expect(formData.isStep1Valid(), true);

// Empty required field
formData.platforms = [];
expect(formData.isStep1Valid(), false);
```

---

## 🚀 Future Enhancements

### Custom Input for Complexity
```dart
// Allow user to input custom complexity
TextField(
  decoration: InputDecoration(
    labelText: 'Or enter custom complexity',
  ),
  onChanged: (value) {
    if (value.isNotEmpty) {
      selectedComplexity = value;
    }
  },
)
```

### Custom Tag Creation
```dart
// Add custom tag if not in predefined list
if (!availableTags.contains(selectedTag)) {
  availableTags.add(selectedTag);
  tags.add(selectedTag);
}
```

### Search/Filter Dropdowns
```dart
DropdownButtonFormField<String>(
  isExpanded: true,
  items: items
      .where((item) => item
          .toLowerCase()
          .contains(searchValue.toLowerCase()))
      .map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          ))
      .toList(),
)
```

---

## 🔍 Debugging Tips

### Check Form Data
```dart
// In _submitPost
print('Platforms: ${_formData.platforms}');
print('Tags: ${_formData.tags}');
print('Time Complexities: ${_formData.timeComplexities}');
print('Space Complexities: ${_formData.spaceComplexities}');
```

### Firestore Document Check
```dart
// Check if problem was saved
final problemDoc = await FirebaseFirestore.instance
    .collection('problems')
    .doc(docId)
    .get();
print('Problem data: ${problemDoc.data()}');
```

### Validation Debug
```dart
// Check validation step by step
debugPrint('Problem Name Valid: ${_formData.problemName.isNotEmpty}');
debugPrint('Platforms Valid: ${_formData.platforms.isNotEmpty}');
debugPrint('Tags Valid: ${_formData.tags.isNotEmpty}');
debugPrint('Overall Step1 Valid: ${_formData.isStep1Valid()}');
```

---

## 📞 Common Issues & Solutions

### Issue: Duplicate items in list
**Solution**: Check before adding
```dart
if (!list.contains(item)) {
  list.add(item);
}
```

### Issue: Dropdown not updating
**Solution**: Call setState()
```dart
setState(() {
  selectedValue = value;
});
```

### Issue: Firestore timestamp null
**Solution**: Use FieldValue.serverTimestamp()
```dart
'createdAt': FieldValue.serverTimestamp()
```

### Issue: Multiple platforms not saving
**Solution**: Ensure using List, not String
```dart
// ❌ Wrong
platforms: formData.platforms.first  // string

// ✅ Correct
platforms: formData.platforms  // list
```

---

## 📱 Responsive Design Check

```dart
// Get screen width
final screenWidth = MediaQuery.of(context).size.width;

// Responsive layout
if (screenWidth < 600) {
  // Mobile: Stack vertically
} else {
  // Tablet/Desktop: Row layout
}
```

---

## 🎓 Learning Resources

- Cloud Firestore Documentation
- Flutter BLoC Pattern
- Form Validation in Flutter
- State Management with BLoC
- Dart Collections (List, Map)

