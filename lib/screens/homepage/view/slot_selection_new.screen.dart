import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/common/app_primary_button.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/screens/homepage/model/tripModel.dart';
import 'package:flutter_arch/screens/homepage/view/seat_selection.screen.dart';
import 'package:flutter_arch/screens/payment/view/paymentScreen2.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';


class ChooseSlotPage extends StatefulWidget {
  final String? selectedDate;
  final String? selectedTimePeriod;
  final String pickupAddress;
  final String destinationAddress;
  final LatLng? pickupLatLng;
  final LatLng? destinationLatLng;
  final String tripType;
  final String? returnPickupAddress;
  final String? returnDestinationAddress;
  final LatLng? returnPickupLatLng;
  final LatLng? returnDestinationLatLng;
  final String? returnDate;
  final String? returnTimePeriod;

  const ChooseSlotPage({
    super.key,
    this.selectedDate,
    this.selectedTimePeriod,
    required this.pickupAddress,
    required this.destinationAddress,
    this.pickupLatLng,
    this.destinationLatLng,
    this.tripType = "oneway",
    this.returnPickupAddress,
    this.returnDestinationAddress,
    this.returnPickupLatLng,
    this.returnDestinationLatLng,
    this.returnDate,
    this.returnTimePeriod,
  });

  @override
  State<ChooseSlotPage> createState() => _ChooseSlotPageState();
}

class _ChooseSlotPageState extends State<ChooseSlotPage> {
  List<TripModel> _onwardTrips = [];
  List<TripModel> _returnTrips = [];
  bool _isLoading = false;
  String? _selectedOnwardTripId;
  String? _selectedReturnTripId;
  late BookSeatModal _bookSeatModal;
  bool _roundTripNotAvailable = false;

  // Store selected seats for onward and return
  List<SeatInfo>? _onwardSelectedSeats;
  List<SeatInfo>? _returnSelectedSeats;

  @override
  void initState() {
    super.initState();
    _bookSeatModal = BookSeatModal(
      onBookNow: (List<SeatInfo> selectedSeats) {
        // This will be handled below for both onward and return
      },
    );
    searchTrips();
  }

  void searchTrips() async {
    setState(() {
      _isLoading = true;
      _roundTripNotAvailable = false;
    });

    final dioHttp = DioHttp();
    try {
      String searchDate = widget.selectedDate ?? 
          DateTime.now().add(Duration(days: 1)).toString().split(' ')[0];
      String searchTimePeriod = widget.selectedTimePeriod ?? (DateTime.now().hour < 12 ? 'AM' : 'PM');
      if (widget.pickupLatLng == null || widget.destinationLatLng == null) {
        toast("Location coordinates are required for trip search");
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final tripResults = await dioHttp.searchTrips(
        context,
        widget.pickupLatLng!.latitude,
        widget.pickupLatLng!.longitude,
        widget.destinationLatLng!.latitude,
        widget.destinationLatLng!.longitude,
        searchDate,
        searchTimePeriod,
        tripType: widget.tripType,
        returnOriginLatitude: widget.returnPickupLatLng?.latitude,
        returnOriginLongitude: widget.returnPickupLatLng?.longitude,
        returnDestinationLatitude: widget.returnDestinationLatLng?.latitude,
        returnDestinationLongitude: widget.returnDestinationLatLng?.longitude,
        returnDate: widget.returnDate, // Pass return date for roundtrip
        returnTimePeriod: widget.returnTimePeriod, // Pass return time period for roundtrip
      );
      setState(() {
        _onwardTrips = tripResults['onwardTrips'] ?? [];
        _returnTrips = tripResults['returnTrips'] ?? [];
        _isLoading = false;
        if (widget.tripType == 'roundtrip' && _onwardTrips.isNotEmpty && _returnTrips.isEmpty) {
          _roundTripNotAvailable = true;
        }
      });
    } catch (e) {
      print('Error searching trips: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSeatSelection({required bool isReturn}) {
    final selectedTrip = isReturn
        ? _returnTrips.firstWhere((trip) => trip.scheduledTripId == _selectedReturnTripId)
        : _onwardTrips.firstWhere((trip) => trip.scheduledTripId == _selectedOnwardTripId);
    
    BookSeatModal seatModal = BookSeatModal(
      onBookNow: (selectedSeats) {
        if (selectedSeats.isEmpty) {
          // For both onward and return, enforce at least one seat selection
          // No snackbar, just do not proceed
          return;
        }
        if (widget.tripType == 'roundtrip') {
          if (!isReturn) {
            // Store onward seats and open return seat selection
            _onwardSelectedSeats = selectedSeats;
            _showSeatSelection(isReturn: true);
          } else {
            // Store return seats and proceed to payment
            _returnSelectedSeats = selectedSeats;
            _proceedToPayment(_onwardSelectedSeats!, returnSeats: _returnSelectedSeats!);
          }
        } else {
          // One-way trip, proceed to payment
          _proceedToPayment(selectedSeats);
        }
      },
    );
    
    seatModal.show(
      context,
      routeId: selectedTrip.scheduledTripId,
      pickupId: selectedTrip.pickupStopId,
      dropoffId: selectedTrip.destinationStopId,
      pickupAddress: selectedTrip.pickupLocationName,
      destinationAddress: selectedTrip.destinationLocationName,
      price: "₹${selectedTrip.price}",
      isRoundTrip: widget.tripType == 'roundtrip',
      onwardPrice: selectedTrip.price,
      // Only pass return trip info for onward seat selection (to show info in modal, not for seat IDs)
      returnScheduledTripId: !isReturn && widget.tripType == 'roundtrip' && _selectedReturnTripId != null ? _returnTrips.firstWhere((t) => t.scheduledTripId == _selectedReturnTripId).scheduledTripId : null,
      returnPickupStopId: !isReturn && widget.tripType == 'roundtrip' && _selectedReturnTripId != null ? _returnTrips.firstWhere((t) => t.scheduledTripId == _selectedReturnTripId).pickupStopId : null,
      returnDropOffStopId: !isReturn && widget.tripType == 'roundtrip' && _selectedReturnTripId != null ? _returnTrips.firstWhere((t) => t.scheduledTripId == _selectedReturnTripId).destinationStopId : null,
      returnPickupAddress: !isReturn && widget.tripType == 'roundtrip' && _selectedReturnTripId != null ? _returnTrips.firstWhere((t) => t.scheduledTripId == _selectedReturnTripId).pickupLocationName : null,
      returnDestinationAddress: !isReturn && widget.tripType == 'roundtrip' && _selectedReturnTripId != null ? _returnTrips.firstWhere((t) => t.scheduledTripId == _selectedReturnTripId).destinationLocationName : null,
      returnPrice: !isReturn && widget.tripType == 'roundtrip' && _selectedReturnTripId != null ? _returnTrips.firstWhere((t) => t.scheduledTripId == _selectedReturnTripId).price : null,
    );
  }

  void _showReturnSeatSelection(List<SeatInfo> onwardSeats) {
    final returnTrip = _returnTrips.firstWhere((trip) => trip.scheduledTripId == _selectedReturnTripId);
    
    BookSeatModal returnSeatModal = BookSeatModal(
      onBookNow: (returnSeats) {
        if (returnSeats.isEmpty) {
          toast("Please select at least one seat for return trip.", bgColor: Colors.orange);
          return;
        }
        
        // Store both selections and proceed to payment
        _proceedToPayment(onwardSeats, returnSeats: returnSeats);
      },
    );
    
    returnSeatModal.show(
      context,
      routeId: returnTrip.scheduledTripId,
      pickupId: returnTrip.pickupStopId,
      dropoffId: returnTrip.destinationStopId,
      pickupAddress: returnTrip.pickupLocationName,
      destinationAddress: returnTrip.destinationLocationName,
      price: "₹${returnTrip.price}",
      isRoundTrip: true,
      onwardPrice: onwardSeats.isNotEmpty ? _onwardTrips.firstWhere((t) => t.scheduledTripId == _selectedOnwardTripId).price : null,
      returnPrice: returnTrip.price,
    );
  }

  void _proceedToPayment(List<SeatInfo> onwardSeats, {List<SeatInfo>? returnSeats}) {
    final onwardTrip = _onwardTrips.firstWhere((trip) => trip.scheduledTripId == _selectedOnwardTripId);
    final returnTrip = (_selectedReturnTripId != null && _returnTrips.isNotEmpty)
        ? _returnTrips.firstWhere((trip) => trip.scheduledTripId == _selectedReturnTripId)
        : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen2(
          selectedSeats: onwardSeats,
          scheduledTripId: onwardTrip.scheduledTripId,
          pickupStopId: onwardTrip.pickupStopId,
          dropOffStopId: onwardTrip.destinationStopId,
          isRoundTrip: widget.tripType == 'roundtrip' && returnSeats != null,
          returnScheduledTripId: returnTrip?.scheduledTripId,
          returnPickupStopId: returnTrip?.pickupStopId,
          returnDropOffStopId: returnTrip?.destinationStopId,
          returnSelectedSeatIds: returnSeats?.map((s) => s.id).toList() ?? [],
          price: onwardTrip.price.toString(),
        ),
      ),
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
    if (widget.tripType == 'roundtrip' && _roundTripNotAvailable) {
      return Scaffold(
        backgroundColor: AppColor.greyShade7,
        appBar: _buildAppBar(context),
        body: Center(
          child: Text(
            "Round trip is not available for this route.",
            style: AppStyle.subheading.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    if (_onwardTrips.isEmpty) {
      return Scaffold(
        backgroundColor: AppColor.greyShade7,
        appBar: _buildAppBar(context),
        body: Center(child: Text("No trips available", style: AppStyle.subheading)),
      );
    }
    // If roundtrip and both onward and return trips are present, require selection for both
    return Scaffold(
      backgroundColor: AppColor.greyShade7,
      appBar: _buildAppBar(context),
      bottomSheet: widget.tripType == 'roundtrip' && _returnTrips.isNotEmpty
          ? Container(
              child: Padding(
                padding: EdgeInsets.only(bottom: 12, left: 20, right: 20, top: 12),
                child: AppPrimaryButton(
                  text: "Select Onward & Return Seat",
                  onTap: () {
                    if (_selectedOnwardTripId == null || _selectedReturnTripId == null) {
                      toast("Please select both onward and return trips", bgColor: Colors.orange);
                      return;
                    }
                    // Start with onward seat selection
                    _showSeatSelection(isReturn: false);
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
                      _showSeatSelection(isReturn: false);
                    } else {
                      toast("Please select a trip first", bgColor: Colors.orange);
                    }
                  },
                ),
              ),
            ),
      body: widget.tripType == 'roundtrip' && _returnTrips.isNotEmpty
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
                              child: Text("Onward Trips", style: AppStyle.title3),
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
                                separatorBuilder: (context, index) => 16.height,
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
                              child: Text("Return Trips", style: AppStyle.title3),
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
                                separatorBuilder: (context, index) => 16.height,
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
              separatorBuilder: (context, index) => 16.height,
            ),
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
          style: AppStyle.title3.copyWith(color: AppColor.greyShade1)),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Image.asset(
            AppAssets.logoSmall,
            height: 24,
          ),
        ),
      ],
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
    // Format departure time
    String hour = tripData.departureDateTime.hour.toString().padLeft(2, '0');
    String minute = tripData.departureDateTime.minute.toString().padLeft(2, '0');
    String day = tripData.departureDateTime.day.toString().padLeft(2, '0');
    String month = tripData.departureDateTime.month.toString().padLeft(2, '0');
    String amPm = tripData.departureDateTime.hour >= 12 ? 'PM' : 'AM';

    final stops = tripData.stops;

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
            // Top section: DateTime, Route Name, Price, Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$day/$month/${tripData.departureDateTime.year}, $hour:$minute $amPm',
                        style: AppStyle.caption1w600.copyWith(
                            color: AppColor.greyShade2,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      8.height,
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColor.buttonColor,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          tripData.routeName,
                          style: AppStyle.caption1w600.copyWith(
                              color: AppColor.greyWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              height: 16 / 12),
                        ),
                      ),
                      4.height,
                      Text(
                        'Duration: ${tripData.durationText}',
                        style: AppStyle.caption1w400.copyWith(
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
                    6.height,
                    Text(
                      '₹${tripData.price}',
                      style: AppStyle.body.copyWith(
                        color: AppColor.buttonColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    4.height,
                    Text(
                      '${tripData.availableSeats} seats',
                      style: AppStyle.caption1w400.copyWith(
                          color: AppColor.greyShade3,
                          fontSize: 11),
                    ),
                  ],
                )
              ],
            ),
            12.height,
            Divider(color: AppColor.greyShade5.withOpacity(0.7)),
            12.height,
            // Bottom section: Pickup, Stops, Destination
            if (stops.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green, size: 18),
                  6.width,
                  Expanded(child: Text('Pickup: ${stops.first['name']}', style: AppStyle.caption1w400)),
                ],
              ),
              if (stops.length > 2)
                ...List.generate(stops.length - 2, (i) => Row(
                  children: [
                    Icon(Icons.more_vert, color: Colors.blueGrey, size: 16),
                    6.width,
                    Expanded(child: Text('Stop: ${stops[i+1]['name']}', style: AppStyle.caption1w400)),
                  ],
                )),
              Row(
                children: [
                  Icon(Icons.flag, color: Colors.red, size: 18),
                  6.width,
                  Expanded(child: Text('Destination: ${stops.last['name']}', style: AppStyle.caption1w400)),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green, size: 18),
                  6.width,
                  Expanded(child: Text('Pickup: ${tripData.pickupLocationName}', style: AppStyle.caption1w400)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.flag, color: Colors.red, size: 18),
                  6.width,
                  Expanded(child: Text('Destination: ${tripData.destinationLocationName}', style: AppStyle.caption1w400)),
                ],
              ),
            ],
            8.height,
            // Vehicle info
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.greyShade7,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_car, size: 16, color: AppColor.greyShade3),
                  8.width,
                  Expanded(
                    child: Text(
                      '${tripData.vehicleInfo.type} - ${tripData.vehicleInfo.model}',
                      style: AppStyle.caption1w400.copyWith(
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
        8.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: AppStyle.caption1w600.copyWith(
                    height: 16 / 12,
                    color: dotColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              2.height,
              Text(
                address,
                style: AppStyle.subheading.copyWith(
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