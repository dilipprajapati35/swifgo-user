import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/socket_service.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class TrackingViewModel extends ChangeNotifier {
  final String bookingId;
  final String userToken;
  final SocketService _socketService = SocketService();
  BitmapDescriptor driverIcon = BitmapDescriptor.defaultMarker;

  TrackingViewModel({
    required this.bookingId,
    required this.userToken,
    this.pickupPosition,
    LatLng? destinationPosition,
  }) {
    this.destinationPosition = destinationPosition;
    _startTrackingFlow();
    _getPassengerLocation();
    loadCustomMarker();
    _startUIUpdateTimer();
  }

  void _startUIUpdateTimer() {
    // Update UI every second to refresh the "last update" time
    _uiUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      notifyListeners();
    });
  }

  void loadCustomMarker() async {
    driverIcon = await BitmapDescriptor.asset(
      // The ImageConfiguration is needed to find the correct asset resolutions
      // You can change the size to whatever you need
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/car-top.png', // This is the path to your asset
    );
    // You need to call setState to redraw the widget with the new icon
    notifyListeners();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _waitingForRide = true;
  bool get waitingForRide => _waitingForRide;

  LatLng? _driverPosition;
  LatLng? get driverPosition => _driverPosition;

  LatLng? _passengerPosition;
  LatLng? get passengerPosition => _passengerPosition;

  LatLng? pickupPosition; // Optionally set from constructor or API
  LatLng? destinationPosition; // Where passenger wants to go
  LatLng? get destination => destinationPosition;

  Timer? _pollingTimer;
  Timer? _uiUpdateTimer;

  List<LatLng> _polylinePoints = [];
  List<LatLng> get polylinePoints => _polylinePoints;

  bool _rideStarted = false;
  bool get rideStarted => _rideStarted;

  bool _isWebSocketConnected = false;
  bool get isWebSocketConnected => _isWebSocketConnected;

  String? _estimatedArrivalTime;
  String? get estimatedArrivalTime => _estimatedArrivalTime;

  double? _distanceToPickup;
  double? get distanceToPickup => _distanceToPickup;

  DateTime? _lastLocationUpdate;
  DateTime? get lastLocationUpdate => _lastLocationUpdate;

  static const String _googleApiKey =
      'AIzaSyCXvZ6f1LTP07lD6zhqnozAG20MzlUjis8'; // TODO: Replace with your key or env

  void _startTrackingFlow() async {
    // Connect directly to WebSocket for live tracking
    // No more polling - pure real-time updates
    _connectWebSocket();
    _isLoading = false;
    _waitingForRide = false; // Since we only show tracking when canTrack is true
    notifyListeners();
  }

  void _connectWebSocket() {
    log('📻 Connecting to live tracking channel for booking: $bookingId');
    _socketService.initSocketForPassenger(
      bookingId, 
      (locationData) {
        log('📍 Live driver location received: $locationData');
        
        try {
          // Make sure we have valid location data as per guide format
          if (locationData['latitude'] != null && locationData['longitude'] != null) {
            final newDriverPosition = LatLng(
              double.parse(locationData['latitude'].toString()), 
              double.parse(locationData['longitude'].toString())
            );
            
            // Only update if position actually changed to avoid unnecessary redraws
            if (_driverPosition != newDriverPosition) {
              _driverPosition = newDriverPosition;
              
              // Update ride status if provided
              if (locationData['rideStarted'] != null) {
                _rideStarted = locationData['rideStarted'] as bool;
              }
              
              log('🚗 Driver position updated to: ${_driverPosition?.latitude}, ${_driverPosition?.longitude}');
              log('🚦 Ride started status: $_rideStarted');
              
              // Update last location update time
              _lastLocationUpdate = DateTime.now();
              
              // Update route and notify listeners
              _updateRoutePolyline();
              notifyListeners();
            }
          } else {
            log('❌ Invalid location data received: $locationData');
          }
        } catch (e) {
          log('❌ Error processing location update: $e');
        }
      },
      onConnectionChange: (isConnected) {
        log(isConnected ? '📻 Live tracking connected!' : '📻 Live tracking disconnected...');
        _isWebSocketConnected = isConnected;
        notifyListeners();
      }
    );
  }

  Future<void> _getPassengerLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _passengerPosition = LatLng(position.latitude, position.longitude);
      _updateRoutePolyline();
      notifyListeners();
    } catch (e) {
      print('Error getting passenger location: $e');
    }
  }

  Future<void> _updateRoutePolyline() async {
    if (_driverPosition == null || _passengerPosition == null) {
      _polylinePoints = [];
      notifyListeners();
      return;
    }

    try {
      PolylinePoints polylinePoints = PolylinePoints();
      
      // Show route from driver's current position to passenger's current position
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _googleApiKey,
        request: PolylineRequest(
          origin: PointLatLng(
            _driverPosition!.latitude, 
            _driverPosition!.longitude
          ),
          destination: PointLatLng(
            _passengerPosition!.latitude, 
            _passengerPosition!.longitude
          ),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        _polylinePoints = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        // Calculate distance and estimated time between driver and passenger
        _calculateDistanceAndTime(result);
        
        log('📍 Route updated: ${result.points.length} points from driver to passenger');
      } else {
        _polylinePoints = [];
        log('❌ No route found between driver and passenger');
      }
      
      notifyListeners();
    } catch (e) {
      log('❌ Error fetching route polyline: $e');
      _polylinePoints = [];
      notifyListeners();
    }
  }

  void _calculateDistanceAndTime(PolylineResult result) {
    if (result.points.isNotEmpty && _driverPosition != null && _passengerPosition != null) {
      // Calculate total distance along the route
      double totalDistance = 0;
      for (int i = 0; i < result.points.length - 1; i++) {
        totalDistance += Geolocator.distanceBetween(
          result.points[i].latitude,
          result.points[i].longitude,
          result.points[i + 1].latitude,
          result.points[i + 1].longitude,
        );
      }

      _distanceToPickup = totalDistance / 1000; // Convert to km

      // Estimate time (assuming average speed of 30 km/h in city)
      double estimatedMinutes = (_distanceToPickup! / 30) * 60;
      _estimatedArrivalTime = '${estimatedMinutes.round()} min';
      
      log('📏 Distance from driver to passenger: ${_distanceToPickup!.toStringAsFixed(1)} km');
      log('⏱️ Estimated arrival time: $_estimatedArrivalTime');
    }
  }

  @override
  void dispose() {
    log('📻 Disposing TrackingViewModel - cleaning up live tracking');
    _pollingTimer?.cancel();
    _uiUpdateTimer?.cancel();
    
    // Leave the booking room first, then disconnect
    _socketService.leaveBookingRoom(bookingId);
    _socketService.disconnect();
    super.dispose();
  }

  // Method to manually refresh connection
  void refreshConnection() {
    log('Manually refreshing WebSocket connection');
    _socketService.forceRefresh();
  }

  // Method to check socket connection status
  bool get isSocketConnected => _socketService.isConnected;
}
