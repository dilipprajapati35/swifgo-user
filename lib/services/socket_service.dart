import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentBookingId;
  Timer? _refreshTimer;
  Timer? _heartbeatTimer;

  // Callback to notify the UI of new locations
  Function(Map<String, dynamic>)? onLocationUpdate;

  void initSocket(String tripId, Function(Map<String, dynamic>) onUpdate) {
    print('Initializing socket for trip: $tripId');
    
    // Use the same logic as passenger socket
    initSocketForPassenger(tripId, onUpdate);
  }

  void initSocketForPassenger(String bookingId, Function(Map<String, dynamic>) onUpdate) {
    print('Initializing socket for booking: $bookingId');
    
    // Store the callback and booking ID
    onLocationUpdate = onUpdate;
    _currentBookingId = bookingId;
    
    // If socket is already connected to the same booking, just update callback
    if (_socket != null && _isConnected && _currentBookingId == bookingId) {
      print('Socket already connected for this booking');
      return;
    }
    
    // Disconnect existing socket if any
    _disconnectSocket();
    
    // Start the socket connection
    _createSocketConnection(bookingId);
    
    // Set up periodic refresh every 2 seconds
    _startPeriodicRefresh(bookingId);
    
    // Set up heartbeat to check connection
    _startHeartbeat();
  }
  
  void _createSocketConnection(String bookingId) {
    final String serverUrl = 'http://34.93.60.221:3001';
    
    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 500,
      'timeout': 10000,
      'forceNew': true, // Force new connection each time
    });

    _socket!.onConnect((_) {
      print('Socket connected for passenger! Joining booking room: $bookingId');
      _isConnected = true;
      _socket!.emit('joinBookingRoom', bookingId);
      
      // Request immediate driver location update
      _socket!.emit('requestDriverLocation', bookingId);
    });

    _socket!.on('driverLocationUpdate', (data) {
      print('Received driver location update: $data');
      if (onLocationUpdate != null) {
        try {
          onLocationUpdate!(data as Map<String, dynamic>);
        } catch (e) {
          print('Error processing location update: $e');
        }
      }
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
      _isConnected = false;
    });

    _socket!.onReconnect((_) {
      print('Socket reconnected! Rejoining booking room: $bookingId');
      _isConnected = true;
      _socket!.emit('joinBookingRoom', bookingId);
      _socket!.emit('requestDriverLocation', bookingId);
    });

    _socket!.onError((error) {
      print('Socket Error: $error');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      print('Socket Connection Error: $error');
      _isConnected = false;
    });
  }
  
  void _startPeriodicRefresh(String bookingId) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_socket != null && _isConnected) {
        print('Requesting driver location update (periodic)');
        _socket!.emit('requestDriverLocation', bookingId);
        _socket!.emit('joinBookingRoom', bookingId); // Rejoin room to ensure connection
      } else {
        print('Socket not connected, attempting to reconnect...');
        _createSocketConnection(bookingId);
      }
    });
  }
  
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_socket != null && _isConnected) {
        _socket!.emit('ping');
      }
    });
  }

  void _disconnectSocket() {
    if (_socket != null) {
      print('Disconnecting existing socket');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
    
    // Cancel timers
    _refreshTimer?.cancel();
    _heartbeatTimer?.cancel();
  }

  void disconnect() {
    print('Manually disconnecting socket');
    _disconnectSocket();
    onLocationUpdate = null;
    _currentBookingId = null;
  }

  // Method to manually refresh connection immediately
  void forceRefresh() {
    if (_currentBookingId != null) {
      print('Force refreshing socket connection');
      _disconnectSocket();
      _createSocketConnection(_currentBookingId!);
      _startPeriodicRefresh(_currentBookingId!);
      _startHeartbeat();
    }
  }

  // Method to check connection status
  bool get isConnected => _isConnected;
  
  // Method to get current booking ID
  String? get currentBookingId => _currentBookingId;
} 