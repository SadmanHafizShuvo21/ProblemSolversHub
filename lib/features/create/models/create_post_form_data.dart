class CreatePostFormData {
  String problemName;
  String problemLink;
  String platform;
  String difficulty;
  List<String> tags;
  String approachExplanation;
  String timeComplexity;
  String spaceComplexity;
  String codeSnippet;
  List<String> keyLearnings;

  CreatePostFormData({
    this.problemName = '',
    this.problemLink = '',
    this.platform = 'LeetCode',
    this.difficulty = 'Easy',
    this.tags = const [],
    this.approachExplanation = '',
    this.timeComplexity = '',
    this.spaceComplexity = '',
    this.codeSnippet = '',
    this.keyLearnings = const [],
  });

  // Check if Step 1 is complete
  bool isStep1Valid() {
    return problemName.isNotEmpty &&
        problemLink.isNotEmpty &&
        platform.isNotEmpty &&
        difficulty.isNotEmpty;
  }

  // Check if Step 2 is complete
  bool isStep2Valid() {
    return approachExplanation.isNotEmpty &&
        timeComplexity.isNotEmpty &&
        spaceComplexity.isNotEmpty;
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
}
