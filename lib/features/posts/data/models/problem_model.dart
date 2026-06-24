import 'package:cloud_firestore/cloud_firestore.dart';

class ProblemModel {
  final String? id;
  final String userId;
  final String problemName;
  final String problemLink;
  final List<String> platforms;
  final String difficulty;
  final List<String> tags;
  final List<String> timeComplexities;
  final List<String> spaceComplexities;
  final String approachExplanation;
  final String codeSnippet;
  final List<String> keyLearnings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProblemModel({
    this.id,
    required this.userId,
    required this.problemName,
    required this.problemLink,
    required this.platforms,
    required this.difficulty,
    required this.tags,
    required this.timeComplexities,
    required this.spaceComplexities,
    required this.approachExplanation,
    required this.codeSnippet,
    this.keyLearnings = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Convert ProblemModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
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

  /// Create ProblemModel from Firestore JSON
  factory ProblemModel.fromJson(Map<String, dynamic> json) {
    return ProblemModel(
      id: json['id'] as String?,
      userId: json['userId'] as String? ?? '',
      problemName: json['problemName'] as String? ?? '',
      problemLink: json['problemLink'] as String? ?? '',
      platforms: List<String>.from(json['platforms'] as List? ?? []),
      difficulty: json['difficulty'] as String? ?? 'Easy',
      tags: List<String>.from(json['tags'] as List? ?? []),
      timeComplexities:
          List<String>.from(json['timeComplexities'] as List? ?? []),
      spaceComplexities:
          List<String>.from(json['spaceComplexities'] as List? ?? []),
      approachExplanation: json['approachExplanation'] as String? ?? '',
      codeSnippet: json['codeSnippet'] as String? ?? '',
      keyLearnings: List<String>.from(json['keyLearnings'] as List? ?? []),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
