/// Tracks which support conversation the customer currently has open.
///
/// Two things depend on it:
///  - the app must not show a "support replied" banner while the customer is
///    already reading that exact conversation,
///  - a notification tap must open (or reuse) that conversation.
class SupportChatPresence {
  SupportChatPresence._();

  static String? _openConversationId;

  /// Conversation currently visible on screen, or null.
  static String? get openConversationId => _openConversationId;

  static bool get isChatOpen =>
      _openConversationId != null && _openConversationId!.isNotEmpty;

  /// True when the chat for [conversationId] is the one on screen.
  static bool isViewing(String? conversationId) {
    if (conversationId == null || conversationId.isEmpty) return false;
    return _openConversationId == conversationId;
  }

  static void open(String? conversationId) {
    if (conversationId == null || conversationId.isEmpty) return;
    _openConversationId = conversationId;
  }

  static void close([String? conversationId]) {
    if (conversationId == null || conversationId == _openConversationId) {
      _openConversationId = null;
    }
  }
}
