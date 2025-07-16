import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/socket_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class TrackingViewModel extends ChangeNotifier {
  final String bookingId;
  final String userToken;
  final SocketService _socketService = SocketService();

  TrackingViewModel({required this.bookingId, required this.userToken}) {
    startTracking();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  LatLng? _driverPosition;
  LatLng? get driverPosition => _driverPosition;

  // --- New: Timer for sending passenger location ---
  Timer? _locationTimer;
  String _bookingStatus = "CONFIRMED"; // Default, should be set from API/parent
  bool _sendingLocation = false;

  // --- New: Start/stop location sending based on status ---
  void updateBookingStatus(String status) {
    if (_bookingStatus != status) {
      _bookingStatus = status;
      if (_bookingStatus == "CONFIRMED") {
        _startSendingLocation();
      } else {
        _stopSendingLocation();
      }
      notifyListeners();
    }
  }

  void _startSendingLocation() {
    _stopSendingLocation();
    _locationTimer = Timer.periodic(Duration(seconds: 12), (_) => _sendPassengerLocation());
    _sendingLocation = true;
  }

  void _stopSendingLocation() {
    _locationTimer?.cancel();
    _sendingLocation = false;
  }

  Future<void> _sendPassengerLocation() async {
    try {
      // Request permission if not granted
      if (await Permission.location.request().isGranted) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        final url = Uri.parse('http://34.93.60.221:3001/bookings/$bookingId/location');
        final response = await http.patch(
          url,
          headers: {
            'Authorization': 'Bearer $userToken',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'latitude': position.latitude,
            'longitude': position.longitude,
          }),
        );
        if (response.statusCode != 200) {
          print('Failed to send location: \\u001b[31m${response.body}\\u001b[0m');
        }
      } else {
        print('Location permission not granted');
      }
    } catch (e) {
      print('Error sending passenger location: $e');
    }
  }

  // This is the main function to start the process
  Future<void> startTracking() async {
    try {
      // PHASE 1: Call the API to get initial data
      // IMPORTANT: Replace with your server address
      final Uri url = Uri.parse('http://34.93.60.221:3001/bookings/$bookingId/track');
      
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $userToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String tripId = data['tripId'];
        
        // Set initial driver position if available
        if (data['latitude'] != null && data['longitude'] != null) {
          _driverPosition = LatLng(data['latitude'], data['longitude']);
        }

        // PHASE 2: Connect to WebSocket
        _socketService.initSocket(tripId, (locationData) {
          // This function is called every time a new location arrives
          _driverPosition = LatLng(locationData['latitude'], locationData['longitude']);
          notifyListeners(); // Notify UI to rebuild
        });

        // --- New: Optionally update status from API response ---
        if (data['bookingStatus'] != null) {
          updateBookingStatus(data['bookingStatus']);
        }

      } else {
        // Handle API error
        print('Failed to get tracking info:  [31m${response.body} [0m');
      }
    } catch (e) {
      print('Error starting tracking: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Critical: Clean up resources when the screen is closed
  @override
  void dispose() {
    _stopSendingLocation();
    _socketService.disconnect();
    super.dispose();
  }
} 