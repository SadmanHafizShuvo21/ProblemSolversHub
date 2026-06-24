# Create Post - UI Changes Visual Guide

## 🎨 New UI Pattern: Select + Add Button

### Before (Old)
```
Platform:           [Dropdown with single selection]
Difficulty:         [Choice Chips: Easy | Medium | Hard]
Tags:              [Filter Chips: Select multiple directly from list]
Time Complexity:    [Text field: O(n log n)]
Space Complexity:   [Text field: O(n)]
```

### After (New)
```
PLATFORMS SECTION:
┌─────────────────────────────────────────────┐
│ Platforms *                                  │
├─────────────────────────────────────────────┤
│ [Select Platform ▼]  [+ Add]               │
├─────────────────────────────────────────────┤
│ Selected:                                   │
│ ┌─────────────┐  ┌──────────────┐          │
│ │ LeetCode  ✕ │  │ Codeforces ✕ │         │
│ └─────────────┘  └──────────────┘          │
└─────────────────────────────────────────────┘

TIME COMPLEXITY SECTION:
┌─────────────────────────────────────────────┐
│ Time Complexity *                            │
├─────────────────────────────────────────────┤
│ [Select Time Complexity ▼]  [+ Add]        │
├─────────────────────────────────────────────┤
│ Selected:                                   │
│ ┌──────────┐  ┌─────────────┐             │
│ │ O(n)  ✕  │  │ O(n log n)✕ │            │
│ └──────────┘  └─────────────┘             │
└─────────────────────────────────────────────┘

SPACE COMPLEXITY SECTION:
┌─────────────────────────────────────────────┐
│ Space Complexity *                           │
├─────────────────────────────────────────────┤
│ [Select Space Complexity ▼]  [+ Add]       │
├─────────────────────────────────────────────┤
│ Selected:                                   │
│ ┌──────────┐  ┌────────┐                  │
│ │ O(1)  ✕  │  │ O(n) ✕ │                 │
│ └──────────┘  └────────┘                  │
└─────────────────────────────────────────────┘
```

---

## 📝 Form Steps Breakdown

### STEP 1: Problem Info
```
┌─────────────────────────────────────────────┐
│           CREATE POST - STEP 1 OF 3         │
│  ⭕ Problem Info  → Approach  → Review      │
├─────────────────────────────────────────────┤
│                                             │
│ Problem Name *                              │
│ ┌───────────────────────────────────────┐  │
│ │ e.g., Two Sum                         │  │
│ └───────────────────────────────────────┘  │
│                                             │
│ Problem Link *                              │
│ ┌───────────────────────────────────────┐  │
│ │ https://leetcode.com/problems/two-sum/│  │
│ └───────────────────────────────────────┘  │
│                                             │
│ Platforms *                                 │
│ ┌───────────────────────┐  ┌──────────┐   │
│ │ Select Platform    ▼ │  │ + Add    │   │
│ └───────────────────────┘  └──────────┘   │
│ ┌────────────┐  ┌──────────────┐         │
│ │ LeetCode ✕ │  │ Codeforces ✕ │        │
│ └────────────┘  └──────────────┘         │
│                                             │
│ Difficulty *                                │
│ ┌────────┐ ┌────────┐ ┌────────┐         │
│ │ Easy   │ │ Medium │ │ Hard   │         │
│ └────────┘ └────────┘ └────────┘         │
│                                             │
│ Tags (max 5) *                              │
│ ┌───────────────────────┐  ┌──────────┐   │
│ │ Select Tag         ▼ │  │ + Add    │   │
│ └───────────────────────┘  └──────────┘   │
│ ┌────────┐ ┌────────┐ ┌────────┐        │
│ │ Array ✕│ │String ✕│ │DP     ✕│       │
│ └────────┘ └────────┘ └────────┘        │
│ Added: 3/5 tags                            │
│                                             │
├─────────────────────────────────────────────┤
│ [Previous ✖]              [Next ▶]         │
└─────────────────────────────────────────────┘
```

### STEP 2: Approach
```
┌─────────────────────────────────────────────┐
│           CREATE POST - STEP 2 OF 3         │
│  Problem Info → ⭕ Approach  → Review      │
├─────────────────────────────────────────────┤
│                                             │
│ Approach Explanation *                      │
│ ┌───────────────────────────────────────┐  │
│ │ Describe your approach step by        │  │
│ │ step...                               │  │
│ │                                       │  │
│ └───────────────────────────────────────┘  │
│                                             │
│ Time Complexity *                           │
│ ┌───────────────────────┐  ┌──────────┐   │
│ │ Select Time   ▼       │  │ + Add    │   │
│ └───────────────────────┘  └──────────┘   │
│ ┌──────────┐  ┌─────────────┐             │
│ │ O(n)  ✕  │  │ O(n log n)✕ │            │
│ └──────────┘  └─────────────┘             │
│                                             │
│ Space Complexity *                          │
│ ┌───────────────────────┐  ┌──────────┐   │
│ │ Select Space  ▼       │  │ + Add    │   │
│ └───────────────────────┘  └──────────┘   │
│ ┌──────────┐  ┌────────┐                  │
│ │ O(1)  ✕  │  │ O(n) ✕ │                 │
│ └──────────┘  └────────┘                  │
│                                             │
│ Code Snippet                                │
│ ┌───────────────────────────────────────┐  │
│ │ def twoSum(nums, target):             │  │
│ │     map = {}                          │  │
│ │     for num in nums:                  │  │
│ │         ...                           │  │
│ └───────────────────────────────────────┘  │
│                                             │
│ Key Learnings                               │
│ ┌───────────────────────────────────────┐  │
│ │ Used hash map for O(1) lookup  [×]    │  │
│ │ Important to check duplicates [×]     │  │
│ │ [+ Add new learning]                  │  │
│ └───────────────────────────────────────┘  │
│                                             │
├─────────────────────────────────────────────┤
│ [◀ Previous]              [Next ▶]         │
└─────────────────────────────────────────────┘
```

### STEP 3: Review
```
┌─────────────────────────────────────────────┐
│           CREATE POST - STEP 3 OF 3         │
│  Problem Info → Approach → ⭕ Review       │
├─────────────────────────────────────────────┤
│                                             │
│ Review Your Post                            │
│                                             │
│ ┌────────────────────────────────────────┐ │
│ │ Problem Information                    │ │
│ ├────────────────────────────────────────┤ │
│ │ Problem Name: Two Sum                  │ │
│ │ Difficulty: Easy                       │ │
│ │ Link: https://leetcode.com/...         │ │
│ │                                        │ │
│ │ Platforms:                             │ │
│ │ ┌────────────┐  ┌──────────────┐     │ │
│ │ │ LeetCode   │  │ Codeforces   │     │ │
│ │ └────────────┘  └──────────────┘     │ │
│ │                                        │ │
│ │ Tags:                                  │ │
│ │ ┌────────┐ ┌────────┐ ┌────────┐    │ │
│ │ │ Array  │ │ String │ │ DP     │    │ │
│ │ └────────┘ └────────┘ └────────┘    │ │
│ └────────────────────────────────────────┘ │
│                                             │
│ ┌────────────────────────────────────────┐ │
│ │ Approach                               │ │
│ ├────────────────────────────────────────┤ │
│ │ Approach: Use hash map to store...     │ │
│ │                                        │ │
│ │ Time Complexities:                     │ │
│ │ ┌──────────┐  ┌─────────────┐        │ │
│ │ │ O(n)     │  │ O(n log n)  │        │ │
│ │ └──────────┘  └─────────────┘        │ │
│ │                                        │ │
│ │ Space Complexities:                    │ │
│ │ ┌──────────┐  ┌────────┐             │ │
│ │ │ O(1)     │  │ O(n)   │             │ │
│ │ └──────────┘  └────────┘             │ │
│ └────────────────────────────────────────┘ │
│                                             │
├─────────────────────────────────────────────┤
│ [◀ Previous]      [Submit ▶] (loading...)  │
└─────────────────────────────────────────────┘
```

---

## 🎯 User Interactions

### Adding a Platform:
```
1. Tap on [Select Platform ▼]
2. Choose "LeetCode" from dropdown
3. Tap [+ Add]
4. Chip appears: [LeetCode ✕]
5. Repeat for more platforms
```

### Adding Multiple Time Complexities:
```
1. [Select Time Complexity ▼] → O(n) → [+ Add]
   Result: [O(n) ✕]
2. [Select Time Complexity ▼] → O(n log n) → [+ Add]
   Result: [O(n) ✕] [O(n log n) ✕]
```

### Removing an Item:
```
1. Click ✕ on any chip
2. Item removed from list
3. Can add again if needed
```

---

## 📊 Data Saved to Firestore

### When Submit is clicked:

**posts collection:**
```
{
  platforms: "LeetCode", // first platform only
  tags: ["Array", "String", "DP"],
  ...
}
```

**problems collection:**
```
{
  platforms: ["LeetCode", "Codeforces"],
  tags: ["Array", "String", "DP"],
  timeComplexities: ["O(n)", "O(n log n)"],
  spaceComplexities: ["O(1)", "O(n)"],
  ...
}
```

---

## 🔄 Form Validation Flow

```
User enters all fields
        ↓
Click [Next]
        ↓
Check validation:
  ✓ All required fields filled?
  ✓ URLs valid?
  ✓ At least 1 platform selected?
  ✓ Tags within limit?
        ↓
  YES → Show next step
  NO  → Show error snackbar
        ↓
        Go to Review Step
        ↓
        Click [Submit]
        ↓
        Validate all required fields
        ↓
  YES → Save to Firestore (posts + problems)
        Show success
        Navigate back
  NO  → Show error snackbar
```

---

## 🎨 UI Colors & Styling

- **Platform chips**: Primary color (0.2 alpha)
- **Tag chips**: Tertiary color (0.2 alpha)
- **Time Complexity chips**: Primary color (0.2 alpha)
- **Space Complexity chips**: Secondary color (0.2 alpha)
- **Difficulty selection**: Color-coded
  - Easy: Green
  - Medium: Orange
  - Hard: Red
- **Error messages**: Red background with white text
- **Success messages**: Green background with white text

---

## ⌚ Step Indicator

At the top of each step:
```
┌─────────────────────────────────────────┐
│ (1) Problem Info  →  (2) Approach  →   │
│     (3) Review                          │
└─────────────────────────────────────────┘
```

- Current step: Blue circle with number/checkmark
- Completed steps: Blue circle with checkmark
- Future steps: Gray circle with number

---

## 📱 Responsive Design

All elements scale appropriately for:
- ✓ Mobile phones (320px+)
- ✓ Tablets (600px+)
- ✓ Desktop (900px+)

Multi-select fields stack properly:
```
Mobile:
[Dropdown]
[Add Button]

Tablet/Desktop:
[Dropdown] [Add Button]  (Row layout)
```
