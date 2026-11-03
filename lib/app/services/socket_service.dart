import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:car_wash_customer_app/app/config/environment.dart';
import 'package:car_wash_customer_app/app/helpers/secure_store.dart';
import 'package:car_wash_customer_app/app/helpers/shared_preferences.dart';

/// SocketService handles real-time communication with the backend.
///
/// Responsibilities:
/// - Connect to Socket.IO server using Environment.baseUrl
/// - Join CUSTOMER room after connect
/// - Expose reactive booking status events
/// - Auto reconnect with websocket transport only
/// - Manual connect (disableAutoConnect)
/// - Handle disconnect cleanly
class SocketService extends GetxService {
  late IO.Socket _socket;

  // Reactive events for booking status updates
  Rx<Map<String, dynamic>?> bookingAcceptedEvent = Rx<Map<String, dynamic>?>(
    null,
  );
  Rx<Map<String, dynamic>?> bookingArrivedEvent = Rx<Map<String, dynamic>?>(
    null,
  );
  Rx<Map<String, dynamic>?> bookingStartedEvent = Rx<Map<String, dynamic>?>(
    null,
  );
  Rx<Map<String, dynamic>?> bookingCompletedEvent = Rx<Map<String, dynamic>?>(
    null,
  );

  // Reactive events for the support chat
  Rx<Map<String, dynamic>?> supportMessageEvent = Rx<Map<String, dynamic>?>(
    null,
  );

  /// Typing indicators from the support side:
  /// { conversation_id, sender_type: 'customer'|'agent', is_typing: bool }
  Rx<Map<String, dynamic>?> supportTypingEvent = Rx<Map<String, dynamic>?>(
    null,
  );
  Rx<Map<String, dynamic>?> supportConversationUpdatedEvent =
      Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> supportStatusEvent = Rx<Map<String, dynamic>?>(
    null,
  );

  /// Conversation room this device joined (re-joined automatically after a
  /// reconnect).
  String? _supportConversationId;

  /// Auth token cached when joining the support room, reused for typing events.
  String? _supportToken;

  bool _isConnected = false;

  /// Get connection status
  bool get isConnected => _isConnected;

  @override
  void onInit() {
    super.onInit();
    _initializeSocket();
  }

  /// Initialize Socket.IO with proper configuration
  void _initializeSocket() {
    try {
      const socketUrl = Environment.baseUrl;

      print("🔌 Initializing Socket.IO...");
      print("Server URL: $socketUrl");

      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']) // Use websocket only
            .disableAutoConnect() // Manual connect required
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(999)
            .build(),
      );

      _setupSocketListeners();
    } catch (e) {
      print("❌ Socket initialization error: $e");
    }
  }

  /// Set up all socket event listeners
  void _setupSocketListeners() {
    // Connection events
    _socket.on('connect', _onConnect);
    _socket.on('connect_error', _onConnectError);
    _socket.on('disconnect', _onDisconnect);

    // Booking status events
    _socket.on('booking_accepted', (data) => _handleBookingAccepted(data));
    _socket.on('booking_arrived', (data) => _handleBookingArrived(data));
    _socket.on('booking_started', (data) => _handleBookingStarted(data));
    _socket.on('booking_completed', (data) => _handleBookingCompleted(data));

    // Support chat events
    _socket.on('support:message', (data) => _handleSupportMessage(data));
    _socket.on('support:typing', (data) => _handleSupportTyping(data));
    _socket.on(
      'support:conversation_updated',
      (data) => _handleSupportConversationUpdated(data),
    );
    _socket.on('support:status', (data) => _handleSupportStatus(data));

    print("✅ Socket listeners registered");
  }

  /// Connect to Socket.IO server
  Future<void> connect() async {
    if (_isConnected) {
      print("⚠️ Socket already connected");
      return;
    }

    try {
      print("🚀 Attempting to connect to Socket.IO...");
      _socket.connect();
    } catch (e) {
      print("❌ Connection error: $e");
    }
  }

  /// Disconnect from Socket.IO server
  Future<void> disconnect() async {
    try {
      if (_isConnected) {
        print("🔌 Disconnecting from Socket.IO...");
        _socket.disconnect();
        _isConnected = false;
      }
    } catch (e) {
      print("❌ Disconnection error: $e");
    }
  }

  /// Join customer room with user ID
  Future<void> _joinCustomerRoom() async {
    try {
      final customerId = await SharedPrefsHelper.getString("customerUuid");

      if (customerId.isEmpty) {
        print("⚠️ Customer ID not found in SharedPrefs");
        return;
      }

      final payload = {'userType': 'customer', 'userId': customerId};

      print("📢 Joining customer room with ID: $customerId");

      _socket.emit('join_room', payload);
    } catch (e) {
      print("❌ Error joining room: $e");
    }
  }

  /// Handle connection
  void _onConnect(dynamic data) {
    print("✅ Socket connected successfully");
    _isConnected = true;
    _joinCustomerRoom();

    // Rejoin the support room if the user had the chat open
    final conversationId = _supportConversationId;
    if (conversationId != null && conversationId.isNotEmpty) {
      joinSupportRoom(conversationId);
    }
  }

  /// Handle connection errors
  void _onConnectError(dynamic error) {
    print("❌ Socket connection error: $error");
    _isConnected = false;
  }

  /// Handle disconnection
  void _onDisconnect(dynamic reason) {
    print("🔌 Socket disconnected: $reason");
    _isConnected = false;
  }

  /// Extract booking data from payload (handles both formats)
  /// Format 1: { booking: { ...bookingObject } }
  /// Format 2: { ...bookingObject }
  Map<String, dynamic> _extractBookingData(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Check if payload has 'booking' key
      if (data.containsKey('booking') && data['booking'] is Map) {
        return data['booking'] as Map<String, dynamic>;
      }
      // Return the entire payload as booking data
      return data;
    }
    return {};
  }

  /// Handle booking_accepted event
  void _handleBookingAccepted(dynamic data) {
    try {
      final bookingData = _extractBookingData(data);
      print("✅ Booking accepted event received");
      print("Data: $bookingData");
      bookingAcceptedEvent.value = bookingData;
    } catch (e) {
      print("❌ Error handling booking_accepted: $e");
    }
  }

  /// Handle booking_arrived event
  void _handleBookingArrived(dynamic data) {
    try {
      final bookingData = _extractBookingData(data);
      print("✅ Booking arrived event received");
      print("Data: $bookingData");
      bookingArrivedEvent.value = bookingData;
    } catch (e) {
      print("❌ Error handling booking_arrived: $e");
    }
  }

  /// Handle booking_started event
  void _handleBookingStarted(dynamic data) {
    try {
      final bookingData = _extractBookingData(data);
      print("✅ Booking started event received");
      print("Data: $bookingData");
      bookingStartedEvent.value = bookingData;
    } catch (e) {
      print("❌ Error handling booking_started: $e");
    }
  }

  /// Handle booking_completed event
  void _handleBookingCompleted(dynamic data) {
    try {
      final bookingData = _extractBookingData(data);
      print("✅ Booking completed event received");
      print("Data: $bookingData");
      bookingCompletedEvent.value = bookingData;
    } catch (e) {
      print("❌ Error handling booking_completed: $e");
    }
  }

  // ================= Support chat =================

  /// Join the room for one support conversation.
  ///
  /// The backend verifies the JWT and the conversation ownership before the
  /// socket is allowed in, so the token is sent with the event.
  Future<void> joinSupportRoom(String conversationId) async {
    try {
      _supportConversationId = conversationId;

      final token = await FlutterSecureStore().getSingleValue(
        SharedPrefsHelper.accessToken,
      );

      if (token == null || token.isEmpty) {
        print("⚠️ Support chat: no auth token, skipping socket join");
        return;
      }

      _supportToken = token;

      if (!_isConnected) {
        await connect();
      }

      _emitSupportJoin(conversationId, token);

      // A fresh connection may still be handshaking: emit again once connected
      // so the room join is never lost.
      if (!_isConnected) {
        _socket.once('connect', (_) => _emitSupportJoin(conversationId, token));
      }

      print("💬 Joined support room: $conversationId");
    } catch (e) {
      print("❌ Error joining support room: $e");
    }
  }

  /// The backend accepts both `conversationId` (web) and `conversation_id`
  /// (app); both are sent so the room is always joined.
  void _emitSupportJoin(String conversationId, String token) {
    try {
      _socket.emit('support:join', {
        'token': token,
        'conversationId': conversationId,
        'conversation_id': conversationId,
      });
    } catch (e) {
      print("❌ Error emitting support:join: $e");
    }
  }

  /// Leave the support conversation room (called when the chat screen closes).
  void leaveSupportRoom() {
    final conversationId = _supportConversationId;
    _supportConversationId = null;

    if (conversationId == null || conversationId.isEmpty) return;

    try {
      _socket.emit('support:leave', {
        'conversationId': conversationId,
        'conversation_id': conversationId,
      });
      print("💬 Left support room: $conversationId");
    } catch (e) {
      print("❌ Error leaving support room: $e");
    }
  }

  /// Leaves the conversation room without forgetting it, so the room can be
  /// rejoined when the app comes back to the foreground. Used while the app is
  /// in the background: the customer is NOT looking at the chat then, so the
  /// backend must send the push notification.
  void pauseSupportRoom() {
    final conversationId = _supportConversationId;
    if (conversationId == null || conversationId.isEmpty) return;

    try {
      _socket.emit('support:leave', {
        'conversationId': conversationId,
        'conversation_id': conversationId,
      });
      print("⏸️ Left support room while the app is in the background");
    } catch (e) {
      print("❌ Error pausing support room: $e");
    }
  }

  /// Rejoins the conversation room after the app returns to the foreground.
  Future<void> resumeSupportRoom() async {
    final conversationId = _supportConversationId;
    if (conversationId == null || conversationId.isEmpty) return;

    await joinSupportRoom(conversationId);
  }

  /// Tells the support team that the customer is (or stopped) typing.
  /// Best effort: never throws, the backend only relays it to the agent room.
  void sendSupportTyping({required bool isTyping}) {
    final conversationId = _supportConversationId;
    final token = _supportToken;

    if (conversationId == null || conversationId.isEmpty) return;
    if (token == null || token.isEmpty) return;

    try {
      _socket.emit('support:typing', {
        'token': token,
        'conversationId': conversationId,
        'conversation_id': conversationId,
        'isTyping': isTyping,
      });
    } catch (e) {
      print("⚠️ Could not send the typing indicator: $e");
    }
  }

  void _handleSupportTyping(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        supportTypingEvent.value = data;
      } else if (data is Map) {
        supportTypingEvent.value = Map<String, dynamic>.from(data);
      }
    } catch (e) {
      print("❌ Error handling support:typing: $e");
    }
  }

  void _handleSupportMessage(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        supportMessageEvent.value = data;
      } else if (data is Map) {
        supportMessageEvent.value = Map<String, dynamic>.from(data);
      }
    } catch (e) {
      print("❌ Error handling support:message: $e");
    }
  }

  void _handleSupportConversationUpdated(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        supportConversationUpdatedEvent.value = data;
      } else if (data is Map) {
        supportConversationUpdatedEvent.value = Map<String, dynamic>.from(data);
      }
    } catch (e) {
      print("❌ Error handling support:conversation_updated: $e");
    }
  }

  void _handleSupportStatus(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        supportStatusEvent.value = data;
      } else if (data is Map) {
        supportStatusEvent.value = Map<String, dynamic>.from(data);
      }
    } catch (e) {
      print("❌ Error handling support:status: $e");
    }
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
