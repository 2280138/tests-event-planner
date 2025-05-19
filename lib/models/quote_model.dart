class Quote {
  final String content;

  Quote({required this.content});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      content: json['advice'] ?? '',
    );
  }
}
