import 'package:flutter/material.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:flutter_arch/screens/homepage/model/tripModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_arch/common/app_primary_button.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:nb_utils/nb_utils.dart';

class SubscriptionSlotSelectionPage extends StatefulWidget {
  final LatLng pickupLatLng;
  final LatLng destinationLatLng;
  final LatLng? returnPickupLatLng;
  final LatLng? returnDestinationLatLng;
  final bool isRoundTrip;
  const SubscriptionSlotSelectionPage({
    super.key,
    required this.pickupLatLng,
    required this.destinationLatLng,
    this.returnPickupLatLng,
    this.returnDestinationLatLng,
    this.isRoundTrip = false,
  });

  @override
  State<SubscriptionSlotSelectionPage> createState() => _SubscriptionSlotSelectionPageState();
}

class _SubscriptionSlotSelectionPageState extends State<SubscriptionSlotSelectionPage> {
  List<TripModel> _onwardTrips = [];
  List<TripModel> _returnTrips = [];
  bool _isLoading = false;
  TripModel? _selectedOnwardTrip;
  TripModel? _selectedReturnTrip;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    setState(() { _isLoading = true; });
    final dioHttp = DioHttp();
    try {
      // Fetch trips using new API response format
      final tripResults = await dioHttp.searchTrips(
        context,
        widget.pickupLatLng.latitude,
        widget.pickupLatLng.longitude,
        widget.destinationLatLng.latitude,
        widget.destinationLatLng.longitude,
        '', // date
        '', // timePeriod
        tripType: widget.isRoundTrip ? 'roundtrip' : 'oneway',
        returnOriginLatitude: widget.returnPickupLatLng?.latitude,
        returnOriginLongitude: widget.returnPickupLatLng?.longitude,
        returnDestinationLatitude: widget.returnDestinationLatLng?.latitude,
        returnDestinationLongitude: widget.returnDestinationLatLng?.longitude,
      );
      setState(() {
        _onwardTrips = tripResults['onwardTrips'] ?? [];
        _returnTrips = tripResults['returnTrips'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      toast('Error fetching trips');
    }
  }

  void _confirmSelection() {
    if (_selectedOnwardTrip == null) {
      toast('Please select an onward trip');
      return;
    }
    if (widget.isRoundTrip && _selectedReturnTrip == null) {
      toast('Please select a return trip');
      return;
    }
    Navigator.pop(context, {
      'onwardTripId': _selectedOnwardTrip!.scheduledTripId,
      'onwardPickupStopId': _selectedOnwardTrip!.pickupStopId,
      'onwardDropOffStopId': _selectedOnwardTrip!.destinationStopId,
      'returnTripId': _selectedReturnTrip?.scheduledTripId,
      'returnPickupStopId': _selectedReturnTrip?.pickupStopId,
      'returnDropOffStopId': _selectedReturnTrip?.destinationStopId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyShade7,
      appBar: AppBar(
        backgroundColor: AppColor.greyWhite,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColor.greyShade1),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Select Trip', style: AppStyle.title3.copyWith(color: AppColor.greyShade1)),
      ),
      bottomSheet: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(bottom: 12, left: 20, right: 20, top: 12),
          child: AppPrimaryButton(
            text: 'Continue',
            onTap: _confirmSelection,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColor.buttonColor))
          : ListView(
              padding: EdgeInsets.only(bottom: 80, top: 16, left: 16, right: 16),
              children: [
                Text('Onward Trips', style: AppStyle.title.copyWith(fontSize: 16)),
                ..._onwardTrips.map((trip) => _TripCard(
                      trip: trip,
                      isSelected: _selectedOnwardTrip?.scheduledTripId == trip.scheduledTripId,
                      onTap: () => setState(() => _selectedOnwardTrip = trip),
                    )),
                if (widget.isRoundTrip) ...[
                  SizedBox(height: 24),
                  Text('Return Trips', style: AppStyle.title.copyWith(fontSize: 16)),
                  ..._returnTrips.map((trip) => _TripCard(
                        trip: trip,
                        isSelected: _selectedReturnTrip?.scheduledTripId == trip.scheduledTripId,
                        onTap: () => setState(() => _selectedReturnTrip = trip),
                      )),
                ],
              ],
            ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  final bool isSelected;
  final VoidCallback onTap;
  const _TripCard({required this.trip, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.buttonColor.withOpacity(0.1) : AppColor.greyWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColor.buttonColor : AppColor.greyShade5.withOpacity(0.5),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trip.routeName, style: AppStyle.title.copyWith(fontSize: 15)),
            4.height,
            Text('Pickup: ${trip.pickupLocationName}', style: AppStyle.caption1w400),
            Text('Destination: ${trip.destinationLocationName}', style: AppStyle.caption1w400),
            4.height,
            Text('Price: ₹${trip.price}', style: AppStyle.caption1w600.copyWith(color: AppColor.buttonColor)),
            Text('Available seats: ${trip.availableSeats}', style: AppStyle.caption1w400),
          ],
        ),
      ),
    );
  }
} 