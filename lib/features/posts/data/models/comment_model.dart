import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:problem_solvers_hub/features/posts/domain/entities/comment.dart';

class CommentModel extends PostComment {
  CommentModel({
    super.id,
    required super.postId,
    required super.userId,
    required super.userAvatar,
    required super.userName,
    required super.text,
    required super.timestamp,
  }) : super();

  factory CommentModel.fromJson(Map<String, dynamic> json, String documentId) {
    final rawTimestamp = json['timestamp'];
    DateTime parsedTimestamp;

    if (rawTimestamp is DateTime) {
      parsedTimestamp = rawTimestamp;
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else {
      parsedTimestamp = DateTime.now();
    }

    return CommentModel(
      id: documentId,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      userAvatar: json['userAvatar'] as String,
      userName: json['userName'] as String,
      text: json['text'] as String,
      timestamp: parsedTimestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'userAvatar': userAvatar,
      'userName': userName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  PostComment toEntity() {
    return PostComment(
      id: id,
      postId: postId,
      userId: userId,
      userAvatar: userAvatar,
      userName: userName,
      text: text,
      timestamp: timestamp,
    );
  }

  factory CommentModel.fromPostComment(PostComment comment) {
    return CommentModel(
      id: comment.id,
      postId: comment.postId,
      userId: comment.userId,
      userAvatar: comment.userAvatar,
      userName: comment.userName,
      text: comment.text,
      timestamp: comment.timestamp,
    );
  }
}
