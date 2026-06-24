# Create Post Feature - Complete Implementation Guide

## 📋 Overview
Complete redesign of the create post feature with multi-select fields and Firestore integration. Data is now saved to both `posts` and `problems` collections with a new UI pattern for platform, tags, time complexity, and space complexity fields.

---

## ✨ Key Features

### 1. **Multi-Select Fields with Add Button Pattern**
The following fields now support adding multiple items via a select dropdown + add button:

#### **Platforms** (Problem Info Step)
```
[Select Dropdown: Platform options] [Add Button]
Selected: LeetCode, Codeforces, HackerRank (chips shown below)
```
- Available options: LeetCode, Codeforces, HackerRank, GeeksforGeeks, AtCoder, CodeChef, Interviewbit
- Users can select and add multiple platforms
- Click on chip's X to remove

#### **Tags** (Problem Info Step)
```
[Select Dropdown: Tag options] [Add Button]
Selected: Array, String, DP (chips shown below)
```
- Max 5 tags
- Available options: Array, String, Dynamic Programming, Graph, Tree, Binary Search, Greedy, Stack, Queue, Heap, Hash Map, Recursion, Sorting, Linked List

#### **Time Complexity** (Approach Step)
```
[Select Dropdown: O(1), O(n), O(n log n), etc.] [Add Button]
Selected: O(n), O(n log n) (chips shown below)
```
- Predefined complexity options for easy selection
- Users can add multiple approaches with different time complexities

#### **Space Complexity** (Approach Step)
```
[Select Dropdown: O(1), O(n), O(n²), etc.] [Add Button]
Selected: O(n), O(1) (chips shown below)
```
- Predefined complexity options
- Users can add multiple space complexity solutions

---

## 🗄️ Database Structure

### Firestore Collections

#### **posts** Collection
```
{
  id: "doc_id",
  userId: "user_id",
  userName: "User Name",
  userAvatar: "avatar_url",
  problemTitle: "Problem Name",
  platform: "First Platform", // For display
  difficulty: "Easy|Medium|Hard",
  tags: ["tag1", "tag2", ...],
  approachPreview: "Brief approach...",
  approachFull: "Full approach explanation...",
  codeSnippet: "Code here...",
  likes: 0,
  comments: 0,
  views: 0,
  timestamp: server_timestamp,
  createdAt: server_timestamp,
  updatedAt: server_timestamp
}
```

#### **problems** Collection
```
{
  id: "doc_id",
  userId: "user_id",
  problemName: "Problem Name",
  problemLink: "https://...",
  platforms: ["LeetCode", "Codeforces", ...],
  difficulty: "Easy|Medium|Hard",
  tags: ["Array", "String", ...],
  timeComplexities: ["O(n)", "O(n log n)", ...],
  spaceComplexities: ["O(n)", "O(1)", ...],
  approachExplanation: "Full explanation...",
  codeSnippet: "Code here...",
  keyLearnings: ["Learning 1", "Learning 2", ...],
  createdAt: server_timestamp,
  updatedAt: server_timestamp
}
```

---

## 📁 Files Modified/Created

### New Files Created:
1. **`lib/features/posts/data/datasources/firebase_problems_datasource.dart`**
   - Handles all Firestore operations for problems collection
   - CRUD operations, streaming, queries

2. **`lib/features/posts/data/models/problem_model.dart`**
   - Data model for problems
   - JSON serialization/deserialization
   - Handles Firestore timestamp conversion

### Files Modified:
1. **`lib/features/create/models/create_post_form_data.dart`**
   - Changed single string fields to lists for multi-select
   - Added selected field placeholders
   - Added toJson() method

2. **`lib/features/create/widgets/problem_info_step.dart`**
   - New UI with select dropdown + add button for platforms
   - New UI with select dropdown + add button for tags
   - Visual chips to show selected items
   - Remove button on each chip

3. **`lib/features/create/widgets/approach_step.dart`**
   - New UI with select dropdown + add button for time complexity
   - New UI with select dropdown + add button for space complexity
   - Predefined complexity options
   - Remove button on each chip

4. **`lib/features/create/widgets/review_step.dart`**
   - Updated to display multiple platforms as chips
   - Updated to display multiple time complexities
   - Updated to display multiple space complexities
   - Removed submit button (moved to create_post_page)

5. **`lib/features/create/screens/create_post_page.dart`**
   - Updated validation messages
   - Added submit button to navigation bar
   - Enhanced error messages

6. **`lib/features/create/presentation/bloc/create_post_bloc.dart`**
   - Now saves to both posts and problems collections
   - Injects FirebaseProblemsDataSource
   - Uses new form data structure

7. **`lib/core/service_locator.dart`**
   - Registered FirebaseProblemsDataSource
   - Updated CreatePostBloc constructor

---

## 🎯 Form Validation

### Step 1: Problem Info (Required Fields)
- ✓ Problem Name (not empty)
- ✓ Problem Link (valid URL format)
- ✓ At least one Platform
- ✓ Difficulty selected
- ✓ At least one Tag (up to 5)

### Step 2: Approach (Required Fields)
- ✓ Approach Explanation (not empty)
- ✓ At least one Time Complexity
- ✓ At least one Space Complexity

### Step 3: Review
- Shows all collected information
- Submit button (replaces Next button)
- Shows loading state during submission

---

## 🔄 User Flow

```
Step 1: Problem Info
├── Problem Name (text field)
├── Problem Link (text field)
├── Platforms (select + add)
│   └── Selected chips with delete
├── Difficulty (choice chips: Easy/Medium/Hard)
└── Tags (select + add)
    └── Selected chips with delete

    ↓ [Next] validation ↓

Step 2: Approach
├── Approach Explanation (text area)
├── Time Complexity (select + add)
│   └── Selected chips with delete
├── Space Complexity (select + add)
│   └── Selected chips with delete
├── Code Snippet (text area)
└── Key Learnings (dynamic fields)

    ↓ [Next] validation ↓

Step 3: Review
├── Problem Information Card
│   ├── Problem Name
│   ├── Difficulty
│   ├── Link
│   ├── Platforms (chips)
│   └── Tags (chips)
├── Approach Card
│   ├── Approach Text
│   ├── Time Complexities (chips)
│   └── Space Complexities (chips)
├── Code Snippet Card
└── Key Learnings Card

    ↓ [Submit] ↓

Both collections saved:
- posts (for feed/display)
- problems (for detailed problem tracking)
```

---

## 💾 Data Flow on Submit

When user clicks Submit:
1. ✓ Validate all required fields
2. ✓ Create Post object for posts collection
3. ✓ Create ProblemModel object for problems collection
4. ✓ Save Post to posts collection
5. ✓ Save ProblemModel to problems collection
6. ✓ Show success message
7. ✓ Navigate back to previous screen

---

## 🛠️ Technical Details

### Multi-Select Implementation Pattern

```dart
// Form Data
List<String> platforms = [];
List<String> selectedPlatforms = [];

// Add Logic
if (!platforms.contains(selected)) {
  platforms.add(selected);
  selectedPlatform = ''; // Reset dropdown
}

// Remove Logic
platforms = platforms.where((p) => p != item).toList();

// UI Display
Wrap(
  children: platforms.map((p) => Chip(
    label: Text(p),
    onDeleted: () => remove(p),
  )).toList(),
)
```

### Predefined Options
- **Time Complexities**: O(1), O(log n), O(n), O(n log n), O(n²), O(n³), O(2^n), O(n!)
- **Space Complexities**: O(1), O(log n), O(n), O(n²), O(2^n)
- **Platforms**: 7 major coding platforms
- **Tags**: 14 common algorithm/data structure tags

---

## ✅ Testing Checklist

- [ ] Add multiple platforms
- [ ] Remove platform by clicking chip X
- [ ] Try adding duplicate platform (shows error)
- [ ] Add up to 5 tags
- [ ] Try adding 6th tag (shows error)
- [ ] Add multiple time complexities
- [ ] Add multiple space complexities
- [ ] Review screen shows all selected items
- [ ] Submit saves to both collections
- [ ] Firestore has both posts and problems documents
- [ ] Previous/Next navigation works
- [ ] Validation messages appear correctly

---

## 🚀 Future Enhancements

1. Add custom complexity option input
2. Add custom tag creation
3. Add custom platform addition
4. Search/filter in dropdowns
5. Save as draft feature
6. Edit existing problems
7. Analytics for problem types
8. Difficulty distribution tracking
