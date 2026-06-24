import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:problem_solvers_hub/shared/models/post.dart';

class PostModel extends Post {
  PostModel({
    super.id,
    required super.userId,
    required super.userAvatar,
    required super.userName,
    required super.problemTitle,
    required super.platform,
    required super.difficulty,
    required super.tags,
    required super.approachPreview,
    required super.approachFull,
    required super.codeSnippet,
    required super.likes,
    required super.comments,
    required super.views,
    required super.timestamp,
    super.problemLink,        // ✅ add these
    super.timeComplexity,     // ✅
    super.spaceComplexity,    // ✅
    super.keyLearnings,       // ✅
  });

  /// Convert PostModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userAvatar': userAvatar,
      'userName': userName,
      'problemTitle': problemTitle,
      'platform': platform,
      'difficulty': difficulty,
      'tags': tags,
      'approachPreview': approachPreview,
      'approachFull': approachFull,
      'codeSnippet': codeSnippet,
      'likes': likes,
      'comments': comments,
      'views': views,
      'problemLink': problemLink,
      'timeComplexity': timeComplexity,
      'spaceComplexity': spaceComplexity,
      'keyLearnings': keyLearnings,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create PostModel from Firestore JSON
  factory PostModel.fromJson(Map<String, dynamic> json, String documentId) {
    return PostModel(
      id: documentId,
      userId: _safeNonNullableString(json['userId'], fallback: 'unknown_user'),
      userAvatar: _safeNonNullableString(json['userAvatar'], fallback: ''),
      userName: _safeNonNullableString(json['userName'], fallback: 'Anonymous'),
      problemTitle: _safeNonNullableString(json['problemTitle'], fallback: 'Untitled problem'),
      platform: _safeNonNullableString(json['platform'], fallback: 'Unknown'),
      difficulty: _safeNonNullableString(json['difficulty'], fallback: 'Unknown'),
      tags: _parseStringList(json['tags']),
      approachPreview: _safeNonNullableString(json['approachPreview'], fallback: ''),
      approachFull: _safeNonNullableString(json['approachFull'], fallback: ''),
      codeSnippet: _safeNonNullableString(json['codeSnippet'], fallback: ''),
      likes: _safeInt(json['likes'], fallback: 0),
      comments: _safeInt(json['comments'], fallback: 0),
      views: _safeInt(json['views'], fallback: 0),
      problemLink: _safeString(json['problemLink']),
      timeComplexity: _safeString(json['timeComplexity']),
      spaceComplexity: _safeString(json['spaceComplexity']),
      keyLearnings: _parseStringList(json['keyLearnings']),
      timestamp: _parseDateTime(json['timestamp'] ?? json['createdAt'] ?? json['updatedAt']),
    );
  }

  static String? _safeString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  static String _safeNonNullableString(dynamic value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  static int _safeInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
    }
    return const [];
  }

  static DateTime _parseDateTime(dynamic json) {
    if (json is DateTime) return json;
    if (json is Timestamp) return json.toDate();
    if (json is String) {
      return DateTime.tryParse(json) ?? DateTime.now();
    }
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    if (json == null) {
      return DateTime.now();
    }
    throw ArgumentError.value(json, 'timestamp', 'Unsupported timestamp format');
  }

  /// Convert to Post entity
  Post toEntity() {
    return Post(
      id: id,
      userId: userId,
      userAvatar: userAvatar,
      userName: userName,
      problemTitle: problemTitle,
      platform: platform,
      difficulty: difficulty,
      tags: tags,
      approachPreview: approachPreview,
      approachFull: approachFull,
      codeSnippet: codeSnippet,
      likes: likes,
      comments: comments,
      views: views,
      timestamp: timestamp,
    );
  }

  /// Create from Post entity
  factory PostModel.fromPost(Post post) {
    return PostModel(
      id: post.id,
      userId: post.userId,
      userAvatar: post.userAvatar,
      userName: post.userName,
      problemTitle: post.problemTitle,
      platform: post.platform,
      difficulty: post.difficulty,
      tags: post.tags,
      approachPreview: post.approachPreview,
      approachFull: post.approachFull,
      codeSnippet: post.codeSnippet,
      likes: post.likes,
      comments: post.comments,
      views: post.views,
      timestamp: post.timestamp,
      problemLink: post.problemLink,
      timeComplexity: post.timeComplexity,
      spaceComplexity: post.spaceComplexity,
      keyLearnings: post.keyLearnings,
    );
  }
}
