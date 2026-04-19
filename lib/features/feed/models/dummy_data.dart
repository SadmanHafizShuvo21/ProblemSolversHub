import '../../../shared/models/post.dart';

final List<Post> dummyPosts = [
  Post(
    id: 'post_001',
    userId: 'user_alice_001',
    userAvatar: 'https://via.placeholder.com/40',
    userName: 'Alice Johnson',
    problemTitle: 'Two Sum',
    platform: 'LeetCode',
    difficulty: 'Easy',
    tags: ['Array', 'Hash Table'],
    approachPreview: 'Use a hash map to store complements...',
    approachFull:
        '''Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

You can return the answer in any order.

Example:
Input: nums = [2,7,11,15], target = 9
Output: [0,1]
Explanation: Because nums[0] + nums[1] == 9, we return [0, 1].

Approach:
1. Create a hash map to store the complement of each number (target - num) as key and index as value.
2. Iterate through the array, for each number, check if its complement exists in the hash map.
3. If found, return the current index and the stored index.
4. Otherwise, store the current number and index in the hash map.

Time Complexity: O(n)
Space Complexity: O(n)''',
    codeSnippet: '''class Solution {
    public int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> map = new HashMap<>();
        for (int i = 0; i < nums.length; i++) {
            int complement = target - nums[i];
            if (map.containsKey(complement)) {
                return new int[] { map.get(complement), i };
            }
            map.put(nums[i], i);
        }
        throw new IllegalArgumentException("No two sum solution");
    }
}''',
    likes: 42,
    comments: 8,
    views: 120,
    timestamp: DateTime(2024, 4, 15, 10, 30),
  ),
  Post(
    id: 'post_002',
    userId: 'user_bob_002',
    userAvatar: 'https://via.placeholder.com/40',
    userName: 'Bob Smith',
    problemTitle: 'Longest Substring Without Repeating Characters',
    platform: 'LeetCode',
    difficulty: 'Medium',
    tags: ['String', 'Sliding Window'],
    approachPreview: 'Maintain a window with unique characters...',
    approachFull:
        '''Given a string s, find the length of the longest substring without repeating characters.

Example:
Input: s = "abcabcbb"
Output: 3
Explanation: The answer is "abc", with the length of 3.

Approach:
1. Use a sliding window technique with two pointers.
2. Maintain a set to track characters in the current window.
3. Move the right pointer to expand the window.
4. If a duplicate is found, move the left pointer to remove characters until no duplicate.
5. Keep track of the maximum length.

Time Complexity: O(n)
Space Complexity: O(min(n, m)) where m is charset size''',
    codeSnippet: '''class Solution {
    public int lengthOfLongestSubstring(String s) {
        Set<Character> set = new HashSet<>();
        int left = 0, maxLength = 0;
        for (int right = 0; right < s.length(); right++) {
            while (set.contains(s.charAt(right))) {
                set.remove(s.charAt(left));
                left++;
            }
            set.add(s.charAt(right));
            maxLength = Math.max(maxLength, right - left + 1);
        }
        return maxLength;
    }
}''',
    likes: 67,
    comments: 12,
    views: 200,
    timestamp: DateTime(2024, 4, 14, 14, 45),
  ),
  Post(
    id: 'post_003',
    userId: 'user_charlie_003',
    userAvatar: 'https://via.placeholder.com/40',
    userName: 'Charlie Brown',
    problemTitle: 'Median of Two Sorted Arrays',
    platform: 'LeetCode',
    difficulty: 'Hard',
    tags: ['Array', 'Binary Search'],
    approachPreview: 'Use binary search to partition arrays...',
    approachFull:
        '''Given two sorted arrays nums1 and nums2 of size m and n respectively, return the median of the two sorted arrays.

The overall run time complexity should be O(log (m+n)).

Example:
Input: nums1 = [1,3], nums2 = [2]
Output: 2.00000
Explanation: merged array = [1,2,3] and median is 2.

Approach:
1. Use binary search on the smaller array to find the partition point.
2. Ensure the partition divides the arrays such that all elements on left are <= all on right.
3. Calculate median based on total elements (odd/even).

Time Complexity: O(log min(m,n))
Space Complexity: O(1)''',
    codeSnippet: '''class Solution {
    public double findMedianSortedArrays(int[] nums1, int[] nums2) {
        if (nums1.length > nums2.length) {
            return findMedianSortedArrays(nums2, nums1);
        }
        int m = nums1.length, n = nums2.length;
        int left = 0, right = m;
        while (left <= right) {
            int partitionA = (left + right) / 2;
            int partitionB = (m + n + 1) / 2 - partitionA;
            int maxLeftA = (partitionA == 0) ? Integer.MIN_VALUE : nums1[partitionA - 1];
            int minRightA = (partitionA == m) ? Integer.MAX_VALUE : nums1[partitionA];
            int maxLeftB = (partitionB == 0) ? Integer.MIN_VALUE : nums2[partitionB - 1];
            int minRightB = (partitionB == n) ? Integer.MAX_VALUE : nums2[partitionB];
            if (maxLeftA <= minRightB && maxLeftB <= minRightA) {
                if ((m + n) % 2 == 0) {
                    return (Math.max(maxLeftA, maxLeftB) + Math.min(minRightA, minRightB)) / 2.0;
                } else {
                    return Math.max(maxLeftA, maxLeftB);
                }
            } else if (maxLeftA > minRightB) {
                right = partitionA - 1;
            } else {
                left = partitionA + 1;
            }
        }
        throw new IllegalArgumentException("Input arrays are not sorted");
    }
}''',
    likes: 89,
    comments: 15,
    views: 350,
    timestamp: DateTime(2024, 4, 13, 9, 15),
  ),
];
