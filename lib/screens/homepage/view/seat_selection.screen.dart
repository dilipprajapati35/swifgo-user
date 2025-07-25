import 'package:flutter/material.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/common/app_primary_button.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/screens/homepage/view/confirm_ride_details.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';


class BookSeatModal {
  late List<SeatInfo> _seats;
  final Function(List<SeatInfo> selectedSeats) onBookNow;
  String? scheduledTripId;
  String? pickupStopId;
  String? dropOffStopId;

  BookSeatModal({required this.onBookNow}) {
    _initializeSeats();
  }

  void _initializeSeats() {
    _seats = [];
  }

  Future<void> fetchSeatLayout(BuildContext context, String tripId) async {
    try {
      final dioHttp = DioHttp();
      final response = await dioHttp.getSeatLayout(context, tripId);

      if (response.data != null) {
        scheduledTripId = response.data['scheduledTripId'];
        List<dynamic> seatsData = response.data['seats'] ?? [];

        _seats = seatsData.map((seatData) {
          return SeatInfo(
            id: seatData['seatId'] ?? "",
            label: seatData['description'] ?? "Seat",
            description: seatData['description'] ?? "",
            status: seatData['status'] ?? "unknown",
            isBookable: seatData['isBookable'] ?? false,
            positionPercentage: _getSeatPosition(seatData['seatId']),
            isSelected: false,
          );
        }).toList();
      }
    } catch (e) {
      print('Error fetching seat layout: $e');
      // Set default seats if API fails
      _seats = [
        SeatInfo(
            id: "FP",
            label: "Seat 1",
            positionPercentage: const Offset(0.27, 0.25)),
        SeatInfo(
            id: "RL",
            label: "Seat 2",
            positionPercentage: const Offset(0.27, 0.65)),
        SeatInfo(
            id: "RR",
            label: "Seat 3",
            positionPercentage: const Offset(0.65, 0.65)),
      ];
    }
  }

  Offset _getSeatPosition(String seatId) {
    switch (seatId) {
      case "FP":
        return const Offset(0.27, 0.25);
      case "RL":
        return const Offset(0.27, 0.65);
      case "RR":
        return const Offset(0.65, 0.65);
      default:
        return const Offset(0.5, 0.5);
    }
  }

void show(BuildContext pageContext, {
  required String routeId,
  required String pickupId,
  required String dropoffId,
  required String pickupAddress,
  required String destinationAddress,
  required String price,
  bool isRoundTrip = false,
  String? returnPickupAddress,
  String? returnDestinationAddress,
  String? returnScheduledTripId,
  String? returnPickupStopId,
  String? returnDropOffStopId,
  List<SeatInfo>? returnSelectedSeats,
  int? onwardPrice,
  int? returnPrice,
}) async {
  this.pickupStopId = pickupId;
  this.dropOffStopId = dropoffId;
  this.scheduledTripId = routeId; // Use the routeId as scheduledTripId since it's already the trip ID
  
  // Show loading dialog for seat layout
  showDialog(
    context: pageContext,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text("Loading seats..."),
        ],
      ),
    ),
  );
  
  // Fetch seat layout directly using the trip ID
  await fetchSeatLayout(pageContext, routeId);
  
  // Close loading dialog
  Navigator.pop(pageContext);
  
  // Show seat selection modal
  showModalBottomSheet(
    context: pageContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext modalContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          void toggleSeatSelection(String seatId) {
            setModalState(() {
              final seat = _seats.firstWhere((s) => s.id == seatId);
              if (seat.isBookable && seat.status == "available") {
                seat.isSelected = !seat.isSelected;
              } else {
                toast("This seat is not available for booking", bgColor: Colors.orange);
              }
            });
          }

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 75),
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                  decoration: const BoxDecoration(
                    color: AppColor.greyWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Book seat",
                        style: AppStyle.title3.copyWith(
                            fontSize: 22, color: AppColor.greyShade1),
                      ),
                      20.height,
                      _buildSeatImageLayout((seatId) => toggleSeatSelection(seatId), context),
                      24.height,
                      _buildSeatCheckboxes(
                          (seatId) => toggleSeatSelection(seatId), setModalState),
                      30.height,
                      AppPrimaryButton(
                        text: "Book now",
                        onTap: () {
                          List<SeatInfo> selected = _seats.where((s) => s.isSelected).toList();
                          if (selected.isEmpty) {
                            toast("Please select at least one seat.", bgColor: Colors.orange);
                            return;
                          }
                          Navigator.pop(modalContext); // Close modal
                          
                          Navigator.push(
                            pageContext,
                            MaterialPageRoute(
                              builder: (context) => ConfirmRideDetails(
                                selectedSeats: selected,
                                scheduledTripId: scheduledTripId ?? "",
                                pickupStopId: pickupStopId ?? "",
                                dropOffStopId: dropOffStopId ?? "",
                                pickupAddress: pickupAddress,
                                destinationAddress: destinationAddress,
                                onwardPrice: onwardPrice ?? int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                                returnPrice: returnPrice,
                                isRoundTrip: isRoundTrip,
                                returnPickupAddress: returnPickupAddress,
                                returnDestinationAddress: returnDestinationAddress,
                                returnScheduledTripId: returnScheduledTripId,
                                returnPickupStopId: returnPickupStopId,
                                returnDropOffStopId: returnDropOffStopId,
                                returnSelectedSeats: returnSelectedSeats,
                              ),
                            ),
                          );
                        },
                      ),
                      20.height,
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  child: InkWell(
                    onTap: () => Navigator.pop(modalContext),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppColor.greyShade1,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: const Offset(0, 2))
                          ]),
                      child: const Icon(Icons.close,
                          color: AppColor.greyWhite, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
  // Update these methods to work with string IDs instead of int IDs
  Widget _buildSeatImageLayout(
      Function(String seatId) onSeatTap, BuildContext context) {
    const double imageHeight = 428;

    return Container(
      height: imageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                AppAssets.seatView,
                fit: BoxFit.contain,
              ),
            ),
            ..._seats.map((seat) {
              Color seatColor = seat.isBookable
                  ? (seat.isSelected
                      ? AppColor.buttonColor
                      : AppColor.greyShade1.withOpacity(0.8))
                  : Colors.red.withOpacity(0.6);

              return Positioned(
                left: seat.positionPercentage.dx * imageHeight - 30,
                top: seat.positionPercentage.dy * imageHeight,
                child: GestureDetector(
                  onTap: () => seat.isBookable ? onSeatTap(seat.id) : null,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: seatColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColor.greyWhite, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        seat.id,
                        style: AppStyle.body.copyWith(
                          color: AppColor.greyWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatCheckboxes(
      Function(String seatId) onCheckboxTap, StateSetter setModalState) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Changed from spaceAround
        children: _seats.map((seat) {
          return InkWell(
            onTap: () => seat.isBookable ? onCheckboxTap(seat.id) : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: seat.isSelected,
                      onChanged: (bool? value) {
                        if (seat.isBookable) onCheckboxTap(seat.id);
                      },
                      activeColor: AppColor.buttonColor,
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(color: AppColor.greyShade3, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  6.width,
                  Text(
                    seat.label,
                    style: AppStyle.body.copyWith(
                      color:
                          seat.isBookable ? AppColor.greyShade1 : Colors.grey,
                      fontSize: 15,
                      fontWeight:
                          seat.isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SeatInfo {
  final String id;
  final String label;
  final String description;
  final String status;
  final bool isBookable;
  final Offset positionPercentage;
  bool isSelected;

  SeatInfo({
    required this.id,
    required this.label,
    required this.positionPercentage,
    this.description = "",
    this.status = "available",
    this.isBookable = true,
    this.isSelected = false,
  });
}
