enum MessageAuthor { user, jaxx }

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.author,
    required this.createdAt,
  });

  final String text;
  final MessageAuthor author;
  final DateTime createdAt;
}
