import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_arch/screens/homepage/model/tripModel.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:flutter_arch/common/app_primary_button.dart';
import 'package:flutter_arch/screens/homepage/view/premium/subscription_seat_selection_modal.dart';

class SubscriptionTripSelectionScreen extends StatefulWidget {
  final LatLng pickupLatLng;
  final LatLng destinationLatLng;
  final String selectedDate;
  final String selectedTimePeriod;
  final bool isRoundTrip;
  final LatLng? returnPickupLatLng;
  final LatLng? returnDestinationLatLng;
  final String? returnDate;
  final String? returnTimePeriod;
  final String planId;

  const SubscriptionTripSelectionScreen({
    super.key,
    required this.pickupLatLng,
    required this.destinationLatLng,
    required this.selectedDate,
    required this.selectedTimePeriod,
    this.isRoundTrip = false,
    this.returnPickupLatLng,
    this.returnDestinationLatLng,
    this.returnDate,
    this.returnTimePeriod,
    required this.planId,
  });

  @override
  State<SubscriptionTripSelectionScreen> createState() => _SubscriptionTripSelectionScreenState();
}

class _SubscriptionTripSelectionScreenState extends State<SubscriptionTripSelectionScreen> {
  List<TripModel> _onwardTrips = [];
  List<TripModel> _returnTrips = [];
  bool _isLoading = false;
  String? _selectedOnwardTripId;
  String? _selectedReturnTripId;
  bool _roundTripNotAvailable = false;

  @override
  void initState() {
    super.initState();
    _searchTrips();
  }

  void _searchTrips() async {
    setState(() {
      _isLoading = true;
      _roundTripNotAvailable = false;
    });
    final dioHttp = DioHttp();
    try {
      final tripResults = await dioHttp.searchTrips(
        context,
        widget.pickupLatLng.latitude,
        widget.pickupLatLng.longitude,
        widget.destinationLatLng.latitude,
        widget.destinationLatLng.longitude,
        widget.selectedDate,
        widget.selectedTimePeriod,
        tripType: widget.isRoundTrip ? 'roundtrip' : 'oneway',
        returnOriginLatitude: widget.returnPickupLatLng?.latitude,
        returnOriginLongitude: widget.returnPickupLatLng?.longitude,
        returnDestinationLatitude: widget.returnDestinationLatLng?.latitude,
        returnDestinationLongitude: widget.returnDestinationLatLng?.longitude,
        returnDate: widget.returnDate,
        returnTimePeriod: widget.returnTimePeriod,
      );
      setState(() {
        _onwardTrips = tripResults['onwardTrips'] ?? [];
        _returnTrips = tripResults['returnTrips'] ?? [];
        _isLoading = false;
        if (widget.isRoundTrip && _onwardTrips.isNotEmpty && _returnTrips.isEmpty) {
          _roundTripNotAvailable = true;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _proceedToSeatSelection() {
    final onwardTrip = _onwardTrips.firstWhere((t) => t.scheduledTripId == _selectedOnwardTripId);
    TripModel? returnTrip;
    if (widget.isRoundTrip && _selectedReturnTripId != null) {
      returnTrip = _returnTrips.firstWhere((t) => t.scheduledTripId == _selectedReturnTripId);
    }
    SubscriptionSeatSelectionModal.show(
      context,
      onwardTrip: onwardTrip,
      returnTrip: returnTrip,
      isRoundTrip: widget.isRoundTrip,
      planId: widget.planId,
      commuteType: widget.isRoundTrip ? 'roundtrip' : 'oneway',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColor.greyShade7,
        appBar: AppBar(title: Text('Choose Trip')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (widget.isRoundTrip && _roundTripNotAvailable) {
      return Scaffold(
        backgroundColor: AppColor.greyShade7,
        appBar: AppBar(title: Text('Choose Trip')),
        body: Center(child: Text('Round trip is not available for this route.', style: TextStyle(color: Colors.red))),
      );
    }
    if (_onwardTrips.isEmpty) {
      return Scaffold(
        backgroundColor: AppColor.greyShade7,
        appBar: AppBar(title: Text('Choose Trip')),
        body: Center(child: Text('No trips available')),
      );
    }
    return Scaffold(
      backgroundColor: AppColor.greyShade7,
      appBar: AppBar(title: Text('Choose Trip')),
      bottomSheet: Container(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: AppPrimaryButton(
            text: widget.isRoundTrip ? 'Select Onward & Return Seat' : 'Select Seat',
            onTap: () {
              if (_selectedOnwardTripId == null || (widget.isRoundTrip && _selectedReturnTripId == null)) {
                // Show error
                return;
              }
              _proceedToSeatSelection();
            },
          ),
        ),
      ),
      body: widget.isRoundTrip && _returnTrips.isNotEmpty
          ? Row(
              children: [
                // Onward trips
                Expanded(
                  child: ListView.builder(
                    itemCount: _onwardTrips.length,
                    itemBuilder: (context, index) {
                      final trip = _onwardTrips[index];
                      return ListTile(
                        title: Text(trip.routeName),
                        subtitle: Text('₹${trip.price}'),
                        selected: _selectedOnwardTripId == trip.scheduledTripId,
                        onTap: () => setState(() => _selectedOnwardTripId = trip.scheduledTripId),
                      );
                    },
                  ),
                ),
                VerticalDivider(),
                // Return trips
                Expanded(
                  child: ListView.builder(
                    itemCount: _returnTrips.length,
                    itemBuilder: (context, index) {
                      final trip = _returnTrips[index];
                      return ListTile(
                        title: Text(trip.routeName),
                        subtitle: Text('₹${trip.price}'),
                        selected: _selectedReturnTripId == trip.scheduledTripId,
                        onTap: () => setState(() => _selectedReturnTripId = trip.scheduledTripId),
                      );
                    },
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: _onwardTrips.length,
              itemBuilder: (context, index) {
                final trip = _onwardTrips[index];
                return ListTile(
                  title: Text(trip.routeName),
                  subtitle: Text('₹${trip.price}'),
                  selected: _selectedOnwardTripId == trip.scheduledTripId,
                  onTap: () => setState(() => _selectedOnwardTripId = trip.scheduledTripId),
                );
              },
            ),
    );
  }
} 