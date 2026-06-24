class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final String? bio;
  final String? location;
  final String? website;
  final String? githubUsername;
  final String? twitterUsername;
  final String? leetcodeUsername;
  final String? linkedinUsername;
  final List<String> skills;
  final String theme;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool publicProfile;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.bio,
    this.location,
    this.website,
    this.githubUsername,
    this.twitterUsername,
    this.leetcodeUsername,
    this.linkedinUsername,
    this.skills = const [],
    this.theme = 'system',
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.publicProfile = true,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    String? bio,
    String? location,
    String? website,
    String? githubUsername,
    String? twitterUsername,
    String? leetcodeUsername,
    String? linkedinUsername,
    List<String>? skills,
    String? theme,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? publicProfile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      githubUsername: githubUsername ?? this.githubUsername,
      twitterUsername: twitterUsername ?? this.twitterUsername,
      leetcodeUsername: leetcodeUsername ?? this.leetcodeUsername,
      linkedinUsername: linkedinUsername ?? this.linkedinUsername,
      skills: skills ?? this.skills,
      theme: theme ?? this.theme,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      publicProfile: publicProfile ?? this.publicProfile,
    );
  }
}
