import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? _socket;

  // Callback to notify the UI of new locations
  Function(Map<String, dynamic>)? onLocationUpdate;

  void initSocket(String tripId, Function(Map<String, dynamic>) onUpdate) {
    onLocationUpdate = onUpdate;
    
    // IMPORTANT: Replace with your actual server address
    final String serverUrl = 'ws://34.93.60.221:3001/tracking';

    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket connected!');
      // After connecting, join the specific trip's room
      _socket!.emit('joinTripRoom', tripId);
    });

    // Listen for incoming location updates from the server
    _socket!.on('driverLocationUpdate', (data) {
      if (onLocationUpdate != null) {
        onLocationUpdate!(data as Map<String, dynamic>);
      }
    });

    _socket!.onDisconnect((_) => print('Socket disconnected'));
    _socket!.onError((error) => print('Socket Error: $error'));
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }
  }
} 