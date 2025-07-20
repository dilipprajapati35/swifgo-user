import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/ride/view/ride_call_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../view_models/tracking_view_model.dart';

class TrackingScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Use ChangeNotifierProvider to provide the ViewModel to the widget tree
    return ChangeNotifierProvider(
      create: (_) => TrackingViewModel(
        bookingId: bookingId,
        userToken: userToken,
        pickupPosition: pickupPosition,
        destinationPosition: destinationPosition,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Track Your Ride'),
          actions: [
            // Connection status indicator
            Consumer<TrackingViewModel>(
              builder: (context, viewModel, child) {
                return Container(
                  margin: EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: viewModel.isSocketConnected ? Colors.green : Colors.red,
                      ),
                      SizedBox(width: 4),
                      Text(
                        viewModel.isSocketConnected ? 'Live (2s)' : 'Offline',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(width: 8),
                      // Refresh button
                      GestureDetector(
                        onTap: () {
                          viewModel.refreshConnection();
                        },
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
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (viewModel.waitingForRide) {
              // Waiting state: show map with overlay message
              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target:
                          viewModel.pickupPosition ?? LatLng(28.6139, 77.2090),
                      zoom: 16,
                    ),
                    markers: {},
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: EdgeInsets.only(top: 40, left: 24, right: 24),
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'The ride has not started yet.\nTracking will begin once your ride starts.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Live tracking: show different UI based on ride status
              return Stack(
                children: [
                  _buildTrackingMap(viewModel),
                  _buildTrackingInfo(context, viewModel),
                ],
              );
            }
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
          infoWindow: InfoWindow(title: 'Driver'),
        ),
      );
    }

    // Add pickup/destination marker based on ride status
    if (!viewModel.rideStarted && viewModel.pickupPosition != null) {
      // Show pickup location when driver is coming to pick you up
      markers.add(
        Marker(
          markerId: MarkerId('pickup'),
          position: viewModel.pickupPosition!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'Pickup Location'),
        ),
      );
    } else if (viewModel.rideStarted && viewModel.destination != null) {
      // Show destination when ride has started
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
          polylineId: PolylineId('route'),
          color: viewModel.rideStarted ? Colors.green : Colors.blue,
          width: 5,
          points: viewModel.polylinePoints,
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: viewModel.driverPosition ??
            viewModel.pickupPosition ??
            viewModel.destination ??
            LatLng(28.6139, 77.2090),
        zoom: 15,
      ),
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        // Auto-fit bounds to show both driver and destination
        _fitMapBounds(controller, viewModel);
      },
    );
  }

  Widget _buildTrackingInfo(BuildContext context, TrackingViewModel viewModel) {
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
            // Status indicator
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),

            // Driver status
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: viewModel.rideStarted ? Colors.green : Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    viewModel.rideStarted
                        ? 'Ride in Progress'
                        : 'Driver is coming to pick you up',
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

            // Distance and time info
            if (viewModel.distanceToPickup != null &&
                viewModel.estimatedArrivalTime != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distance',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${viewModel.distanceToPickup!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Estimated Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        viewModel.estimatedArrivalTime!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            SizedBox(height: 20),           

            // Call driver button
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
                label: Text(
                  'Call Driver',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
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

  void _fitMapBounds(
      GoogleMapController controller, TrackingViewModel viewModel) {
    if (viewModel.driverPosition != null) {
      LatLng destination = viewModel.rideStarted
          ? (viewModel.destination ?? viewModel.driverPosition!)
          : (viewModel.pickupPosition ?? viewModel.driverPosition!);

      // Calculate bounds to include both driver and destination
      double minLat = viewModel.driverPosition!.latitude < destination.latitude
          ? viewModel.driverPosition!.latitude
          : destination.latitude;
      double maxLat = viewModel.driverPosition!.latitude > destination.latitude
          ? viewModel.driverPosition!.latitude
          : destination.latitude;
      double minLng =
          viewModel.driverPosition!.longitude < destination.longitude
              ? viewModel.driverPosition!.longitude
              : destination.longitude;
      double maxLng =
          viewModel.driverPosition!.longitude > destination.longitude
              ? viewModel.driverPosition!.longitude
              : destination.longitude;

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat - 0.005, minLng - 0.005),
            northeast: LatLng(maxLat + 0.005, maxLng + 0.005),
          ),
          100.0, // padding
        ),
      );
    }
  }
}
