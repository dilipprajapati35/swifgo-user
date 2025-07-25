import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/ride/view/ride_call_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../view_models/tracking_view_model.dart';

// --- UPDATED --- Converted to a StatefulWidget
class TrackingScreen extends StatefulWidget {
  final String bookingId;
  final String userToken;
  final LatLng? pickupPosition;
  final LatLng? destinationPosition;

  const TrackingScreen({
    Key? key,
    required this.bookingId,
    required this.userToken,
    this.pickupPosition,
    this.destinationPosition,
  }) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // --- NEW --- Controller to programmatically move the map
  GoogleMapController? _mapController;

  // --- NEW --- Keep track of the last known position to prevent redundant animations
  LatLng? _lastKnownDriverPosition;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackingViewModel(
        bookingId: widget.bookingId,
        userToken: widget.userToken,
        pickupPosition: widget.pickupPosition,
        destinationPosition: widget.destinationPosition,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Live Tracking'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          actions: [
            Consumer<TrackingViewModel>(
              builder: (context, viewModel, child) {
                return Container(
                  margin: EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: viewModel.isWebSocketConnected ? Colors.red : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.white),
                            SizedBox(width: 4),
                            Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => viewModel.refreshConnection(),
                        child: Icon(Icons.refresh, size: 20),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<TrackingViewModel>(
          builder: (context, viewModel, child) {

            // --- UPDATED --- Logic to move the camera when the driver's position updates
            if (viewModel.driverPosition != null && 
                viewModel.passengerPosition != null && 
                _mapController != null && 
                viewModel.driverPosition != _lastKnownDriverPosition) {
              
              // Calculate bounds to show both driver and passenger
              _fitBothPositions(viewModel.driverPosition!, viewModel.passengerPosition!);
              
              // Update the last known position
              _lastKnownDriverPosition = viewModel.driverPosition;
            }

            if (viewModel.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Connecting to live tracking...'),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                _buildTrackingMap(viewModel),
                _buildTrackingInfo(context, viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrackingMap(TrackingViewModel viewModel) {
    Set<Marker> markers = {};

    // Add driver marker
    if (viewModel.driverPosition != null) {
      markers.add(
        Marker(
          markerId: MarkerId('driver'),
          position: viewModel.driverPosition!,
          icon: viewModel.driverIcon,
          infoWindow: InfoWindow(
            title: 'Driver',
            snippet: 'Coming to pick you up',
          ),
          anchor: Offset(0.5, 0.5), // Center the icon on the coordinate
          rotation: 0, // You can later add bearing/rotation data here
        ),
      );
    }

    // Add passenger marker (your location)
    if (viewModel.passengerPosition != null) {
      markers.add(
        Marker(
          markerId: MarkerId('passenger'),
          position: viewModel.passengerPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: 'You',
            snippet: 'Your current location',
          ),
        ),
      );
    }
    
    // Add pickup/destination markers for reference
    if (!viewModel.rideStarted && viewModel.pickupPosition != null) {
      markers.add(
        Marker(
          markerId: MarkerId('pickup'),
          position: viewModel.pickupPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'Pickup Location'),
        ),
      );
    } else if (viewModel.rideStarted && viewModel.destination != null) {
      markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: viewModel.destination!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'Destination'),
        ),
      );
    }

    Set<Polyline> polylines = {};
    if (viewModel.polylinePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: PolylineId('driver-to-passenger-route'),
          color: Colors.blue,
          width: 6,
          points: viewModel.polylinePoints,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)], // Dashed line for better visibility
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        // The blue dot you see is your own location, not the driver. We will center on it initially.
        target: viewModel.passengerPosition ?? LatLng(28.6139, 77.2090),
        zoom: 15,
      ),
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true, // This creates the blue dot for the user's own location
      myLocationButtonEnabled: true,
      // --- UPDATED --- Store the controller when the map is created
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
    );
  }

  Widget _buildTrackingInfo(BuildContext context, TrackingViewModel viewModel) {
    // This widget's code is correct and does not need changes.
    // It's included here for completeness of the file.
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Driver is coming to your location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (viewModel.distanceToPickup != null &&
                viewModel.estimatedArrivalTime != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Distance to You', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text('${viewModel.distanceToPickup!.toStringAsFixed(1)} km', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Arrival Time', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(viewModel.estimatedArrivalTime!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue)),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RideCallScreen()),
                  );
                },
                icon: Icon(Icons.phone, color: Colors.white),
                label: Text('Call Driver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to fit both driver and passenger positions in camera view
  void _fitBothPositions(LatLng driverPos, LatLng passengerPos) {
    if (_mapController == null) return;

    // Calculate bounds to include both positions
    double minLat = driverPos.latitude < passengerPos.latitude ? driverPos.latitude : passengerPos.latitude;
    double maxLat = driverPos.latitude > passengerPos.latitude ? driverPos.latitude : passengerPos.latitude;
    double minLng = driverPos.longitude < passengerPos.longitude ? driverPos.longitude : passengerPos.longitude;
    double maxLng = driverPos.longitude > passengerPos.longitude ? driverPos.longitude : passengerPos.longitude;

    // Add padding to bounds
    double padding = 0.01; // Adjust this value for more/less padding
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat - padding, minLng - padding),
      northeast: LatLng(maxLat + padding, maxLng + padding),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0), // 100.0 is edge padding
    );
  }
}