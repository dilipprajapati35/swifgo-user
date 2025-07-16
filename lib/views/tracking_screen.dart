import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../view_models/tracking_view_model.dart';

class TrackingScreen extends StatelessWidget {
  final String bookingId;
  final String userToken;

  const TrackingScreen({Key? key, required this.bookingId, required this.userToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use ChangeNotifierProvider to provide the ViewModel to the widget tree
    return ChangeNotifierProvider(
      create: (_) => TrackingViewModel(bookingId: bookingId, userToken: userToken),
      child: Scaffold(
        appBar: AppBar(title: Text('Track Your Ride')),
        body: Consumer<TrackingViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                // Center the map on the driver or a default location
                target: viewModel.driverPosition ?? LatLng(28.6139, 77.2090),
                zoom: 16,
              ),
              markers: {
                // Show marker only if driver position is known
                if (viewModel.driverPosition != null)
                  Marker(
                    markerId: MarkerId('driver'),
                    position: viewModel.driverPosition!,
                    // You can use a custom icon for the car
                    // icon: yourCustomCarIcon, 
                  ),
              },
            );
          },
        ),
      ),
    );
  }
} 