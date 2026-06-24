class CreatePostFormData {
  String problemName;
  String problemLink;
  List<String> platforms;
  String selectedPlatform;
  String difficulty;
  List<String> tags;
  String selectedTag;
  List<String> timeComplexities;
  String selectedTimeComplexity;
  List<String> spaceComplexities;
  String selectedSpaceComplexity;
  String approachExplanation;
  String codeSnippet;
  List<String> keyLearnings;

  CreatePostFormData({
    this.problemName = '',
    this.problemLink = '',
    this.platforms = const [],
    this.selectedPlatform = '',
    this.difficulty = 'Easy',
    this.tags = const [],
    this.selectedTag = '',
    this.timeComplexities = const [],
    this.selectedTimeComplexity = '',
    this.spaceComplexities = const [],
    this.selectedSpaceComplexity = '',
    this.approachExplanation = '',
    this.codeSnippet = '',
    this.keyLearnings = const [],
  });

  // Check if Step 1 is complete
  bool isStep1Valid() {
    return problemName.isNotEmpty &&
        problemLink.isNotEmpty &&
        platforms.isNotEmpty &&
        difficulty.isNotEmpty &&
        tags.isNotEmpty;
  }

  // Check if Step 2 is complete
  bool isStep2Valid() {
    return approachExplanation.isNotEmpty &&
        timeComplexities.isNotEmpty &&
        spaceComplexities.isNotEmpty;
  }

  // Validate URL format
  bool isValidURL(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
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
}
