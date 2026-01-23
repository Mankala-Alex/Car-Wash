import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:car_wash_customer_app/app/config/environment.dart';
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
  Rx<Map<String, dynamic>?> bookingAcceptedEvent =
      Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> bookingArrivedEvent =
      Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> bookingStartedEvent =
      Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> bookingCompletedEvent =
      Rx<Map<String, dynamic>?>(null);

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

      final payload = {
        'userType': 'customer',
        'userId': customerId,
      };

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

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
