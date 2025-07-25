// lib/services/socket_service.dart

import 'dart:developer';
import 'package:flutter_arch/storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  // --- Singleton Setup ---
  static final SocketService _instance = SocketService._internal();
  factory SocketService() {
    return _instance;
  }
  SocketService._internal();
  // -------------------------

  IO.Socket? _socket;
  IO.Socket? get socket => _socket;

  bool get isConnected => _socket?.connected ?? false;

  // Generic initializer
  void _initializeSocket(String userToken) {
    if (_socket != null && _socket!.connected) {
      log("✅ Socket is already connected.", name: 'SocketService');
      return;
    }
    
    // Disconnect any previous instance before creating a new one
    _socket?.dispose();

    try {
      const String socketUrl = 'http://34.93.60.221:3001/tracking'; // TODO: Use https/wss in production

      _socket = IO.io(socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false, // We will connect manually
        'auth': {'token': userToken}, // Pass the token for authentication
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
      });

      _socket!.connect();

      _socket!.onConnect((_) {
        log('✅ WebSocket Connected to server: ${_socket?.id}', name: 'SocketService');
      });

      _socket!.onDisconnect((reason) {
        log('❌ WebSocket Disconnected from server. Reason: $reason', name: 'SocketService');
      });

      _socket!.onError((error) {
        log('😡 Socket Error: $error', name: 'SocketService');
      });
      
      _socket!.onConnectError((error) {
        log('😡 Socket Connection Error: $error', name: 'SocketService');
      });

    } catch (e) {
      log('😡 Error initializing socket: $e', name: 'SocketService');
    }
  }

  /// ==================================================================
  ///  Passenger Specific Methods (Called from TrackingViewModel)
  /// ==================================================================
  void initSocketForPassenger(
    String bookingId,
    Function(dynamic) onLocationUpdate, {
    required Function(bool) onConnectionChange,
  }) async {
    final token = await MySecureStorage().readToken();
    // const userToken = "PASSENGER_JWT_TOKEN_PLACEHOLDER";

    // Ensure socket is initialized
    _initializeSocket(token!);

    if (_socket == null) return;

    // Listen for connection status changes
    socket!.onConnect((_) => onConnectionChange(true));
    socket!.onDisconnect((_) => onConnectionChange(false));

    // Join the room for this specific booking
    _socket!.emit('joinBookingRoom', bookingId);
    log('📡 Emitted event: joinBookingRoom for booking: $bookingId', name: 'SocketService');

    // Listen for incoming driver location updates from the server
    _socket!.on('driverLocationUpdate', (data) {
      // Pass the data to the callback function provided by the ViewModel
      onLocationUpdate(data);
    });
  }

  void leaveBookingRoom(String bookingId) {
    if (_socket != null) {
      _socket!.emit('leaveBookingRoom', bookingId);
      log('📡 Emitted event: leaveBookingRoom for booking: $bookingId', name: 'SocketService');
    }
  }

  /// ==================================================================
  ///  Driver Specific Methods (Called from Driver App)
  /// ==================================================================
  
  // A generic method to send any event to the server
  void emit(String event, dynamic data) {
    if (_socket == null || !_socket!.connected) {
      log('⚠ Socket not initialized or disconnected. Cannot send event: $event', name: 'SocketService');
      return;
    }
    _socket!.emit(event, data);
    log('📡 Emitted event: $event with data: $data', name: 'SocketService');
  }

  // You can keep driver-specific functions here if this service is shared
  // For example:
  void joinDriverRoom(String tripId) { /* ... */ }
  void leaveDriverRoom(String tripId) { /* ... */ }
  void notifyTripStarted(String tripId) { /* ... */ }

  /// ==================================================================
  ///  General Methods
  /// ==================================================================

  void forceRefresh() {
    if (_socket != null) {
      log("🔄 Forcing a manual disconnect and reconnect.", name: 'SocketService');
      _socket!.disconnect();
      _socket!.connect();
    }
  }

  void disconnect() {
    if (_socket != null) {
      log("🔌 Disconnecting socket permanently.", name: 'SocketService');
      _socket!.dispose(); // Use dispose to clean up all listeners
      _socket = null;
    }
  }
}