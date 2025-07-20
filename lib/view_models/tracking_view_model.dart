import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  String? _estimatedArrivalTime;
  String? get estimatedArrivalTime => _estimatedArrivalTime;

  double? _distanceToPickup;
  double? get distanceToPickup => _distanceToPickup;

  DateTime? _lastLocationUpdate;
  DateTime? get lastLocationUpdate => _lastLocationUpdate;

  static const String _googleApiKey =
      'AIzaSyCXvZ6f1LTP07lD6zhqnozAG20MzlUjis8'; // TODO: Replace with your key or env

  void _startTrackingFlow() async {
    await _fetchInitialStatus();
    // If waiting, start polling every 15 seconds
    if (_waitingForRide) {
      _pollingTimer =
          Timer.periodic(Duration(seconds: 15), (_) => _fetchInitialStatus());
    }
  }

  Future<void> _fetchInitialStatus() async {
    log('Fetching initial status for bookingId: $bookingId');
    try {
      final Uri url =
          Uri.parse('http://34.93.60.221:3001/bookings/$bookingId/track');
      log('Making API call to: $url');
      
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $userToken'},
      );
      
      log('API response status: ${response.statusCode}');
      log('API response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _waitingForRide = false;
        _rideStarted = data['rideStarted'] ?? false;
        
        log('Ride started status from API: $_rideStarted');
        
        if (data['latitude'] != null && data['longitude'] != null) {
          _driverPosition = LatLng(data['latitude'], data['longitude']);
          log('Driver position from API: ${_driverPosition?.latitude}, ${_driverPosition?.longitude}');
          _updateRoutePolyline();
        }
        
        // Optionally get pickup position from API if available
        if (data['pickupLatitude'] != null && data['pickupLongitude'] != null) {
          pickupPosition =
              LatLng(data['pickupLatitude'], data['pickupLongitude']);
          log('Pickup position: ${pickupPosition?.latitude}, ${pickupPosition?.longitude}');
        }
        
        // Get destination position from API if available
        if (data['destinationLatitude'] != null &&
            data['destinationLongitude'] != null) {
          destinationPosition =
              LatLng(data['destinationLatitude'], data['destinationLongitude']);
          log('Destination position: ${destinationPosition?.latitude}, ${destinationPosition?.longitude}');
        }
        
        // Connect to WebSocket for live updates
        _connectWebSocket();
        _pollingTimer?.cancel();
      } else if (response.statusCode == 403) {
        log('Ride has not started yet (403 response)');
        _waitingForRide = true;
        // Optionally get pickup position from API if available
        try {
          final data = json.decode(response.body);
          if (data['pickupLatitude'] != null &&
              data['pickupLongitude'] != null) {
            pickupPosition =
                LatLng(data['pickupLatitude'], data['pickupLongitude']);
          }
          if (data['destinationLatitude'] != null &&
              data['destinationLongitude'] != null) {
            destinationPosition = LatLng(
                data['destinationLatitude'], data['destinationLongitude']);
          }
        } catch (_) {}
      } else {
        log('Failed to get tracking info: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('Error starting tracking: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _connectWebSocket() {
    log('Setting up WebSocket connection for booking: $bookingId');
    _socketService.initSocketForPassenger(bookingId, (locationData) {
      log('Driver location update received: $locationData');
      
      try {
        // Make sure we have valid location data
        if (locationData['latitude'] != null && locationData['longitude'] != null) {
          _driverPosition = LatLng(
            double.parse(locationData['latitude'].toString()), 
            double.parse(locationData['longitude'].toString())
          );
          
          // Update ride status if provided
          if (locationData['rideStarted'] != null) {
            _rideStarted = locationData['rideStarted'] as bool;
          }
          
          log('Driver position updated to: ${_driverPosition?.latitude}, ${_driverPosition?.longitude}');
          log('Ride started status: $_rideStarted');
          
          // Update last location update time
          _lastLocationUpdate = DateTime.now();
          
          // Update route and notify listeners
          _updateRoutePolyline();
          notifyListeners();
        } else {
          log('Invalid location data received: $locationData');
        }
      } catch (e) {
        log('Error processing location update: $e');
      }
    });
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
    if (_driverPosition == null) {
      _polylinePoints = [];
      notifyListeners();
      return;
    }

    LatLng? destination;

    // If ride hasn't started, show route from driver to pickup location
    if (!_rideStarted && pickupPosition != null) {
      destination = pickupPosition;
    }
    // If ride has started, show route from driver to passenger destination
    else if (_rideStarted && destinationPosition != null) {
      destination = destinationPosition;
    }

    if (destination == null) {
      _polylinePoints = [];
      notifyListeners();
      return;
    }

    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _googleApiKey,
        request: PolylineRequest(
          origin: PointLatLng(
              _driverPosition!.latitude, _driverPosition!.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        _polylinePoints =
            result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();

        // Calculate distance and estimated time
        _calculateDistanceAndTime(result);
      } else {
        _polylinePoints = [];
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching polyline: $e');
      _polylinePoints = [];
      notifyListeners();
    }
  }

  void _calculateDistanceAndTime(PolylineResult result) {
    if (result.points.isNotEmpty && _driverPosition != null) {
      // Calculate total distance
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
    }
  }

  @override
  void dispose() {
    log('Disposing TrackingViewModel');
    _pollingTimer?.cancel();
    _uiUpdateTimer?.cancel();
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
