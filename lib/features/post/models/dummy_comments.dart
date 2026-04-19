import 'comment.dart';

final List<Comment> dummyComments = [
  Comment(
    userAvatar: 'https://via.placeholder.com/32',
    userName: 'David Wilson',
    text:
        'Great explanation! The hash map approach is indeed optimal for this problem.',
    timestamp: DateTime(2024, 4, 15, 11, 0),
  ),
  Comment(
    userAvatar: 'https://via.placeholder.com/32',
    userName: 'Emma Davis',
    text:
        'I was stuck on this for hours. Your step-by-step breakdown really helped!',
    timestamp: DateTime(2024, 4, 15, 12, 30),
  ),
  Comment(
    userAvatar: 'https://via.placeholder.com/32',
    userName: 'Frank Miller',
    text:
        'What about the brute force approach? O(n²) would work but time out for large inputs.',
    timestamp: DateTime(2024, 4, 15, 14, 15),
  ),
];
