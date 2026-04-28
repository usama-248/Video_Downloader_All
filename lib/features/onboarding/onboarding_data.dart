class OnboardingData {
  final String title;
  final String description;
  final String userName;
  final int likes;
  final int comments;
  final int shares;

  OnboardingData({
    required this.title,
    required this.description,
    required this.userName,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
  });
}
