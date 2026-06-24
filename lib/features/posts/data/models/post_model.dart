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
      userId: json['userId'] as String,
      userAvatar: json['userAvatar'] as String,
      userName: json['userName'] as String,
      problemTitle: json['problemTitle'] as String,
      platform: json['platform'] as String,
      difficulty: json['difficulty'] as String,
      tags: List<String>.from(json['tags'] as List<dynamic>),
      approachPreview: json['approachPreview'] as String,
      approachFull: json['approachFull'] as String,
      codeSnippet: json['codeSnippet'] as String,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      problemLink: json['problemLink'] as String?,
      timeComplexity: json['timeComplexity'] as String?,
      spaceComplexity: json['spaceComplexity'] as String?,
      keyLearnings:
          List<String>.from(json['keyLearnings'] as List<dynamic>? ?? []),
      timestamp: _parseDateTime(json['timestamp']),
    );
  }

  static DateTime _parseDateTime(dynamic json) {
    if (json is DateTime) return json;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
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
