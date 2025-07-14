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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.greyWhite,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppColor.greyShade1),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text("Choose trip",
          style: TextStyle(
            color: AppColor.greyShade1,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          )),
      centerTitle: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColor.greyShade7,
        appBar: _buildAppBar(context),
        body: Center(child: CircularProgressIndicator(color: AppColor.buttonColor)),
      );
    }
    if (widget.isRoundTrip && _roundTripNotAvailable) {
      return Scaffold(
        backgroundColor: AppColor.greyShade7,
        appBar: _buildAppBar(context),
        body: Center(child: Text('Round trip is not available for this route.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))),
      );
    }
    if (_onwardTrips.isEmpty) {
      return Scaffold(
        backgroundColor: AppColor.greyShade7,
        appBar: _buildAppBar(context),
        body: Center(child: Text('No trips available', style: TextStyle(fontSize: 16))),
      );
    }
    return Scaffold(
      backgroundColor: AppColor.greyShade7,
      appBar: _buildAppBar(context),
      bottomSheet: widget.isRoundTrip && _returnTrips.isNotEmpty
          ? Container(
        child: Padding(
          padding: EdgeInsets.only(bottom: 12, left: 20, right: 20, top: 12),
          child: AppPrimaryButton(
            text: "Select Onward & Return Seat",
            onTap: () {
              if (_selectedOnwardTripId == null || _selectedReturnTripId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select both onward and return trips"), backgroundColor: Colors.orange),
                );
                return;
              }
              _proceedToSeatSelection();
            },
          ),
        ),
      )
          : Container(
        child: Padding(
          padding: EdgeInsets.only(bottom: 25, left: 20, right: 20, top: 12),
          child: AppPrimaryButton(
            text: "Select Seat",
            onTap: () {
              if (_selectedOnwardTripId != null) {
                _proceedToSeatSelection();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select a trip first"), backgroundColor: Colors.orange),
                );
              }
            },
          ),
        ),
      ),
      body: widget.isRoundTrip && _returnTrips.isNotEmpty
          ? Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Onward trips
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Onward Trips", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                          itemCount: _onwardTrips.length,
                          itemBuilder: (context, index) {
                            final trip = _onwardTrips[index];
                            return _TripCard(
                              tripData: trip,
                              isSelected: _selectedOnwardTripId == trip.scheduledTripId,
                              onTap: () {
                                setState(() {
                                  _selectedOnwardTripId = trip.scheduledTripId;
                                });
                              },
                            );
                          },
                          separatorBuilder: (context, index) => SizedBox(height: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(width: 1, color: AppColor.greyShade5),
                // Return trips
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Return Trips", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                          itemCount: _returnTrips.length,
                          itemBuilder: (context, index) {
                            final trip = _returnTrips[index];
                            return _TripCard(
                              tripData: trip,
                              isSelected: _selectedReturnTripId == trip.scheduledTripId,
                              onTap: () {
                                setState(() {
                                  _selectedReturnTripId = trip.scheduledTripId;
                                });
                              },
                            );
                          },
                          separatorBuilder: (context, index) => SizedBox(height: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )
          : ListView.separated(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: 70.0 + MediaQuery.of(context).padding.bottom,
        ),
        itemCount: _onwardTrips.length,
        itemBuilder: (context, index) {
          final trip = _onwardTrips[index];
          return _TripCard(
            tripData: trip,
            isSelected: _selectedOnwardTripId == trip.scheduledTripId,
            onTap: () {
              setState(() {
                _selectedOnwardTripId = trip.scheduledTripId;
              });
            },
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 16),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel tripData;
  final bool isSelected;
  final VoidCallback onTap;

  const _TripCard({
    required this.tripData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String hour = tripData.departureDateTime.hour.toString().padLeft(2, '0');
    String minute = tripData.departureDateTime.minute.toString().padLeft(2, '0');
    String day = tripData.departureDateTime.day.toString().padLeft(2, '0');
    String month = tripData.departureDateTime.month.toString().padLeft(2, '0');
    String amPm = tripData.departureDateTime.hour >= 12 ? 'PM' : 'AM';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColor.greyWhite,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected
                ? AppColor.buttonColor
                : AppColor.greyShade5.withOpacity(0.5),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.greyShade5.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$day/$month/${tripData.departureDateTime.year}, $hour:$minute $amPm',
                        style: TextStyle(
                            color: AppColor.greyShade2,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColor.buttonColor,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          tripData.routeName,
                          style: TextStyle(
                              color: AppColor.greyWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              height: 16 / 12),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Duration: ${tripData.durationText}',
                        style: TextStyle(
                            color: AppColor.greyShade3,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _CustomCheckbox(isSelected: isSelected),
                    SizedBox(height: 6),
                    Text(
                      '₹${tripData.price}',
                      style: TextStyle(
                        color: AppColor.buttonColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${tripData.availableSeats} seats',
                      style: TextStyle(
                          color: AppColor.greyShade3,
                          fontSize: 11),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 12),
            Divider(color: AppColor.greyShade5.withOpacity(0.7)),
            SizedBox(height: 12),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Pickup icon
                    Icon(Icons.location_on, color: Color(0xFF08875D), size: 24),
                    _buildDashedConnector(),
                    Icon(Icons.flag, color: Color(0xFFE02D3C), size: 24),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildLocationRow("Pickup", tripData.pickupLocationName, Color(0xFF08875D)),
                      SizedBox(height: 12),
                      _buildLocationRow("Destination", tripData.destinationLocationName, Color(0xFFE02D3C)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.greyShade7,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_car, size: 16, color: AppColor.greyShade3),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${tripData.vehicleInfo.type} - ${tripData.vehicleInfo.model}',
                      style: TextStyle(
                          color: AppColor.greyShade3,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String type, String address, Color dotColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: TextStyle(
                    height: 16 / 12,
                    color: dotColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 2),
              Text(
                address,
                style: TextStyle(
                    color: AppColor.greyShade2,
                    fontSize: 14,
                    height: 22 / 14,
                    fontWeight: FontWeight.w400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashedConnector() {
    const double lineHeight = 25.0;
    const double dashHeight = 4.0;
    const double dashSpace = 2.0;
    int dashCount = (lineHeight / (dashHeight + dashSpace)).floor();

    return Container(
      height: lineHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(dashCount, (index) {
          return Container(
            width: 1,
            height: dashHeight,
            color: AppColor.greyShade5.withOpacity(0.8),
            margin: const EdgeInsets.only(bottom: dashSpace),
          );
        }),
      ),
    );
  }
}

class _CustomCheckbox extends StatelessWidget {
  final bool isSelected;
  const _CustomCheckbox({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected ? AppColor.buttonColor : Colors.transparent,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: isSelected
              ? AppColor.buttonColor
              : AppColor.greyShade3.withOpacity(0.7),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : null,
    );
  }
}