import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.photoUrl,
    required super.createdAt,
    super.bio,
    super.location,
    super.website,
    super.githubUsername,
    super.twitterUsername,
    super.leetcodeUsername,
    super.linkedinUsername,
    super.skills,
    super.theme,
    super.emailNotifications,
    super.pushNotifications,
    super.publicProfile,
  });

  /// Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'bio': bio,
      'location': location,
      'website': website,
      'githubUsername': githubUsername,
      'twitterUsername': twitterUsername,
      'leetcodeUsername': leetcodeUsername,
      'linkedinUsername': linkedinUsername,
      'skills': skills,
      'theme': theme,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'publicProfile': publicProfile,
    };
  }

  /// Create UserModel from JSON (Firestore)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['createdAt'];
    final createdAt = createdAtValue is Timestamp
        ? createdAtValue.toDate()
        : DateTime.parse(createdAtValue as String);

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: createdAt,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      githubUsername: json['githubUsername'] as String?,
      twitterUsername: json['twitterUsername'] as String?,
      leetcodeUsername: json['leetcodeUsername'] as String?,
      linkedinUsername: json['linkedinUsername'] as String?,
      skills: (json['skills'] as List?)?.map((e) => e as String).toList() ?? const [],
      theme: json['theme'] as String? ?? 'system',
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      publicProfile: json['publicProfile'] as bool? ?? true,
    );
  }

  /// Convert to User entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: createdAt,
      bio: bio,
      location: location,
      website: website,
      githubUsername: githubUsername,
      twitterUsername: twitterUsername,
      leetcodeUsername: leetcodeUsername,
      linkedinUsername: linkedinUsername,
      skills: skills,
      theme: theme,
      emailNotifications: emailNotifications,
      pushNotifications: pushNotifications,
      publicProfile: publicProfile,
    );
  }
}
