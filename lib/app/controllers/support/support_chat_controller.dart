import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/flutter_toast.dart';
import '../../models/support/support_models.dart';
import '../../repositories/support/support_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/socket_service.dart';
import '../../services/support_chat_presence.dart';

/// Live support chat between the customer and the support team.
///
/// Messages arrive over Socket.IO (`support:message`); a light polling loop
/// keeps the thread fresh when the socket is unavailable.
class SupportChatController extends GetxController {
  final SupportRepository _repository = SupportRepository();

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  RxBool isInitializing = true.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isSending = false.obs;
  RxBool isClosing = false.obs;
  RxString errorMessage = ''.obs;
  Rxn<SupportConversation> conversation = Rxn<SupportConversation>();
  RxList<SupportMessage> messages = <SupportMessage>[].obs;
  RxBool hasMore = false.obs;

  /// True while the support agent is typing (shown as a typing bubble).
  RxBool agentTyping = false.obs;

  /// Context handed over by the Help Center / FAQ answer / booking help screen.
  Map<String, dynamic> _context = {};

  /// Booking this chat is linked to (null for general help).
  String? _bookingId;

  SocketService? _socket;
  Timer? _pollTimer;
  Timer? _contextTimer;
  Timer? _typingStopTimer;
  Timer? _agentTypingTimer;
  Worker? _messageWorker;
  Worker? _statusWorker;
  Worker? _assignedWorker;
  Worker? _typingWorker;
  bool _typingAnnounced = false;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    _context =
        args is Map ? Map<String, dynamic>.from(args) : <String, dynamic>{};

    _bindSocket();
    _bootstrap();
  }

  // ==================== State helpers ====================

  String get languageCode => Get.locale?.languageCode ?? 'en';

  String? get _conversationId => conversation.value?.id;

  bool get canSend =>
      (conversation.value?.isClosed ?? true) == false && !isSending.value;

  bool get isEmpty => messages.isEmpty && !isInitializing.value;

  String get statusLabel => switch (conversation.value?.status.toUpperCase()) {
        'OPEN' => 'support_status_open'.tr,
        'ASSIGNED' => 'support_status_assigned'.tr,
        'WAITING_FOR_CUSTOMER' => 'support_status_waiting'.tr,
        'RESOLVED' => 'support_status_resolved'.tr,
        'CLOSED' => 'support_status_closed'.tr,
        _ => 'support_status_open'.tr,
      };

  String get agentName =>
      conversation.value?.assignedAdminName ?? 'support_team'.tr;

  // ==================== Bootstrap ====================

  Future<void> _bootstrap() async {
    try {
      isInitializing.value = true;
      errorMessage.value = '';

      final existingConversationId =
          _context['conversation_id']?.toString() ?? '';
      _bookingId = _context['booking_id']?.toString();
      if (_bookingId != null && _bookingId!.isEmpty) _bookingId = null;

      SupportConversation? active;

      if (existingConversationId.isNotEmpty) {
        // Opened from the booking help flow: the conversation already exists.
        active = await _repository.fetchConversation(existingConversationId);
      } else if (_bookingId != null) {
        // Booking-specific chat: reuse the active thread of this booking.
        active = await _repository.startBookingConversation(
          _bookingId!,
          category: _context['category']?.toString(),
          questionId: _context['question_id']?.toString(),
          questionEn: _context['question_en']?.toString(),
          questionAr: _context['question_ar']?.toString(),
          lastAttemptedSolution:
              _context['last_attempted_solution']?.toString(),
        );
      } else {
        try {
          active = await _repository.getActiveConversation();
        } catch (e) {
          // 404 simply means "no conversation yet" on some builds.
          print("ℹ️ No active support conversation: $e");
        }

        active ??= await _repository.startConversation(
          category: _context['category']?.toString(),
          source: _context['source']?.toString() ?? 'help_center',
          questionId: _context['question_id']?.toString(),
          questionEn: _context['question_en']?.toString(),
          questionAr: _context['question_ar']?.toString(),
          lastAttemptedSolution:
              _context['last_attempted_solution']?.toString(),
          bookingId: _context['booking_id']?.toString(),
          priority: _context['priority']?.toString(),
        );
      }

      conversation.value = active;
      _bookingId ??= active.bookingId;

      // No "support replied" banner while this conversation is on screen.
      SupportChatPresence.open(active.id);

      await _loadMessages(initial: true);
      await _markRead();
      await _joinRoom();
      _startPolling();

      // Announce "customer is typing" to the support team (debounced).
      textController.addListener(_onComposerChanged);

      _scrollToBottom();
    } catch (e) {
      print("❌ Support chat failed to start: $e");
      errorMessage.value = SupportRepository.errorMessage(
        e,
        'support_chat_unavailable'.tr,
      );
    } finally {
      isInitializing.value = false;
    }
  }

  /// Retry after a failed start (no connection, server error, ...).
  Future<void> retry() async {
    if (conversation.value == null) {
      await _bootstrap();
      return;
    }

    await _loadMessages(initial: true);
  }

  // ==================== Messages ====================

  Future<void> _loadMessages({bool initial = false}) async {
    final conversationId = _conversationId;
    if (conversationId == null) return;

    final result = await _repository.fetchMessages(
      conversationId,
      limit: 50,
      before: initial ? null : _oldestMessageDate(),
    );

    if (initial) {
      messages.value = result.messages;
    } else {
      final existingIds = messages.map((m) => m.id).toSet();
      final older = result.messages.where((m) => !existingIds.contains(m.id));
      messages.insertAll(0, older.toList());
    }

    hasMore.value = result.hasMore;
    _sortMessages();
  }

  /// Loads the previous page of history.
  Future<void> loadOlderMessages() async {
    if (isLoadingMore.value || !hasMore.value || _conversationId == null) {
      return;
    }

    try {
      isLoadingMore.value = true;
      await _loadMessages();
    } catch (e) {
      print("❌ Loading older support messages failed: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  String? _oldestMessageDate() {
    final withDates = messages.where((m) => m.createdAt != null).toList();
    if (withDates.isEmpty) return null;

    return withDates.first.createdAt!.toUtc().toIso8601String();
  }

  void _sortMessages() {
    messages.sort((a, b) {
      final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return left.compareTo(right);
    });
  }

  Future<void> send() async {
    final text = textController.text.trim();
    final current = conversation.value;

    if (text.isEmpty) return;
    if (current == null) {
      errorToast('support_chat_unavailable'.tr);
      return;
    }
    if (current.isClosed) {
      errorToast('support_chat_closed_message'.tr);
      return;
    }
    if (isSending.value) return;

    // The message is on its way: stop advertising "typing".
    _stopTypingIndicator();

    final clientMessageId = 'c_${DateTime.now().microsecondsSinceEpoch}';

    final optimistic = SupportMessage(
      id: clientMessageId,
      conversationId: current.id,
      senderType: 'customer',
      message: text,
      createdAt: DateTime.now(),
      status: SupportMessageStatus.sending,
      clientMessageId: clientMessageId,
    );

    messages.add(optimistic);
    textController.clear();
    _scrollToBottom();

    await _persistMessage(optimistic);
  }

  /// Re-sends a message that failed.
  Future<void> retryMessage(SupportMessage message) async {
    if (message.status != SupportMessageStatus.failed) return;
    if (conversation.value?.isClosed ?? true) return;

    final index = messages.indexWhere((m) => m.id == message.id);
    if (index == -1) return;

    messages[index] = message.copyWith(status: SupportMessageStatus.sending);
    messages.refresh();

    await _persistMessage(messages[index]);
  }

  Future<void> _persistMessage(SupportMessage pending) async {
    final conversationId = _conversationId;
    if (conversationId == null) return;

    try {
      isSending.value = true;

      final saved = await _repository.sendMessage(
        conversationId,
        pending.message,
        pending.clientMessageId ?? pending.id,
      );

      _replaceMessage(
        pending.clientMessageId ?? pending.id,
        saved.copyWith(status: SupportMessageStatus.sent),
      );
    } catch (e) {
      print("❌ Sending support message failed: $e");

      _replaceMessage(
        pending.clientMessageId ?? pending.id,
        pending.copyWith(status: SupportMessageStatus.failed),
      );

      errorToast(SupportRepository.errorMessage(e, 'message_not_sent'.tr));
    } finally {
      isSending.value = false;
    }
  }

  void _replaceMessage(String key, SupportMessage replacement) {
    final index = messages.indexWhere(
      (m) =>
          m.id == key ||
          (m.clientMessageId != null && m.clientMessageId == key) ||
          (replacement.id.isNotEmpty && m.id == replacement.id),
    );

    if (index == -1) {
      messages.add(replacement);
    } else {
      messages[index] = replacement;
    }

    _sortMessages();
    messages.refresh();
  }

  Future<void> _markRead() async {
    final conversationId = _conversationId;
    if (conversationId == null) return;

    try {
      await _repository.markRead(conversationId);
    } catch (e) {
      print("⚠️ Marking support messages read failed: $e");
    }
  }

  // ==================== Conversation status ====================

  /// Ask for confirmation, then close the conversation.
  Future<void> closeConversation() async {
    final current = conversation.value;
    if (current == null || current.isClosed) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('support_close_chat'.tr),
        content: Text('support_close_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('support_close_chat'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isClosing.value = true;
      final updated = await _repository.closeConversation(current.id);
      conversation.value = updated;
      successToast('support_chat_closed_message'.tr);
    } catch (e) {
      errorToast(SupportRepository.errorMessage(e, 'something_went_wrong'.tr));
    } finally {
      isClosing.value = false;
    }
  }

  Future<void> reopenConversation() async {
    final current = conversation.value;
    if (current == null) return;

    try {
      isClosing.value = true;
      final updated = await _repository.reopenConversation(current.id);
      conversation.value = updated;
      await _joinRoom();
      await _loadMessages(initial: true);
      _scrollToBottom();
    } catch (e) {
      errorToast(SupportRepository.errorMessage(e, 'something_went_wrong'.tr));
    } finally {
      isClosing.value = false;
    }
  }

  /// Leaves the chat screen (back to the Help Center).
  void goBackToHelpCenter() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
    } else {
      Get.offNamed(Routes.helpCenter);
    }
  }

  // ==================== Realtime ====================

  void _bindSocket() {
    try {
      // The dashboard normally registers it; create it for direct deep links.
      if (!Get.isRegistered<SocketService>()) {
        Get.put<SocketService>(SocketService());
      }

      _socket = Get.find<SocketService>();
    } catch (e) {
      print("⚠️ SocketService not available — support chat will poll only");
      _socket = null;
      return;
    }

    _messageWorker = ever(_socket!.supportMessageEvent, (payload) {
      if (payload == null) return;
      _onSocketMessage(payload);
    });

    _statusWorker = ever(_socket!.supportStatusEvent, (payload) {
      if (payload == null) return;

      final conversationId = payload['conversation_id']?.toString();
      final status = payload['status']?.toString();
      final current = conversation.value;

      if (current == null || status == null) return;
      if (conversationId != null && conversationId != current.id) return;

      conversation.value = current.copyWith(status: status);
    });

    _assignedWorker = ever(_socket!.supportConversationUpdatedEvent, (payload) {
      if (payload == null) return;
      // Agent assignment changes the header ("Support Team" -> agent name).
      _refreshConversationHeader();
    });

    _typingWorker = ever(_socket!.supportTypingEvent, (payload) {
      if (payload == null) return;

      final conversationId = payload['conversation_id']?.toString();
      final senderType = payload['sender_type']?.toString();
      final isTyping = payload['is_typing'] == true;

      if (senderType != 'agent') return;
      if (conversationId != null && conversationId != _conversationId) return;

      agentTyping.value = isTyping;

      // Safety net: never leave the bubble on screen forever.
      _agentTypingTimer?.cancel();
      if (isTyping) {
        _agentTypingTimer = Timer(const Duration(seconds: 6), () {
          agentTyping.value = false;
        });
      }

      if (isTyping) _scrollToBottom();
    });
  }

  Future<void> _joinRoom() async {
    final conversationId = _conversationId;
    if (conversationId == null || _socket == null) return;

    await _socket!.joinSupportRoom(conversationId);
  }

  void _onSocketMessage(Map<String, dynamic> payload) {
    final raw = payload['message'] ?? payload;
    if (raw is! Map) return;

    final incoming = SupportMessage.fromJson(Map<String, dynamic>.from(raw));

    final current = conversation.value;
    if (current == null) return;
    if (incoming.conversationId.isNotEmpty &&
        incoming.conversationId != current.id) {
      return;
    }

    // The same message can be an echo of our own optimistic send.
    final duplicate = messages.any(
      (m) =>
          (incoming.id.isNotEmpty && m.id == incoming.id) ||
          (incoming.clientMessageId != null &&
              incoming.clientMessageId!.isNotEmpty &&
              m.clientMessageId == incoming.clientMessageId),
    );

    if (duplicate) {
      _replaceMessage(
        incoming.clientMessageId ?? incoming.id,
        incoming.copyWith(status: SupportMessageStatus.sent),
      );
      return;
    }

    messages.add(incoming);
    _sortMessages();
    _scrollToBottom();

    if (!incoming.isMine) {
      _markRead();
    }
  }

  Future<void> _refreshConversationHeader() async {
    try {
      final active = _bookingId != null
          ? await _repository.getBookingConversation(_bookingId!)
          : await _repository.getActiveConversation();

      if (active == null) return;

      final current = conversation.value;
      conversation.value = current == null
          ? active
          : SupportConversation(
              id: current.id,
              status: active.status,
              category: active.category ?? current.category,
              assignedAdminName:
                  active.assignedAdminName ?? current.assignedAdminName,
              customerUnreadCount: current.customerUnreadCount,
              lastMessagePreview: current.lastMessagePreview,
              lastMessageAt: current.lastMessageAt,
              createdAt: current.createdAt,
              bookingId: active.bookingId ?? current.bookingId,
              bookingCode: active.bookingCode ?? current.bookingCode,
              booking: active.booking ?? current.booking,
            );
    } catch (e) {
      print("⚠️ Refreshing support conversation failed: $e");
    }
  }

  /// Polling fallback: only while this screen is the visible one, and only as a
  /// safety net — messages arrive instantly over the socket room.
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (Get.currentRoute != Routes.supportChat) return;
      if (conversation.value == null || isSending.value) return;
      _syncNewMessages();
    });

    // Booking status / payment status can change while the chat is open: keep
    // the context card accurate without hammering the API.
    if (_bookingId != null) {
      _contextTimer?.cancel();
      _contextTimer = Timer.periodic(const Duration(seconds: 60), (_) {
        if (Get.currentRoute != Routes.supportChat) return;
        _refreshConversationHeader();
      });
    }
  }

  Future<void> _syncNewMessages() async {
    final conversationId = _conversationId;
    if (conversationId == null) return;

    try {
      final result = await _repository.fetchMessages(conversationId, limit: 50);

      final existingIds = messages.map((m) => m.id).toSet();
      final fresh = result.messages
          .where((m) => !existingIds.contains(m.id))
          .where((m) => m.status != SupportMessageStatus.sending)
          .toList();

      if (fresh.isEmpty) return;

      messages.addAll(fresh);
      _sortMessages();
      _scrollToBottom();

      if (fresh.any((m) => !m.isMine)) {
        _markRead();
      }
    } catch (e) {
      print("⚠️ Support chat polling failed: $e");
    }
  }

  // ==================== Typing indicator ====================

  /// Sends "typing" once per typing burst, then "stopped" after a short idle
  /// period, so the support team sees an accurate indicator without flooding the
  /// socket with events.
  void _onComposerChanged() {
    if (!canSend) return;

    if (textController.text.trim().isEmpty) {
      _stopTypingIndicator();
      return;
    }

    if (!_typingAnnounced) {
      _typingAnnounced = true;
      _socket?.sendSupportTyping(isTyping: true);
    }

    _typingStopTimer?.cancel();
    _typingStopTimer = Timer(
      const Duration(milliseconds: 2500),
      _stopTypingIndicator,
    );
  }

  void _stopTypingIndicator() {
    _typingStopTimer?.cancel();
    _typingStopTimer = null;

    if (!_typingAnnounced) return;
    _typingAnnounced = false;
    _socket?.sendSupportTyping(isTyping: false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _contextTimer?.cancel();
    _typingStopTimer?.cancel();
    _agentTypingTimer?.cancel();
    _messageWorker?.dispose();
    _statusWorker?.dispose();
    _assignedWorker?.dispose();
    _typingWorker?.dispose();
    textController.removeListener(_onComposerChanged);
    SupportChatPresence.close(_conversationId);
    _socket?.leaveSupportRoom();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
