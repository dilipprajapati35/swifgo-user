import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/common/app_primary_button.dart';
import 'package:flutter_arch/common/enums/trip_type.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/screens/homepage/view/date_time_pick.screen.dart';
import 'package:flutter_arch/screens/homepage/view/slot_selection_new.screen.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:nb_utils/nb_utils.dart';

enum FavoriteType { home, work, other }

class ConfirmLocation extends StatefulWidget {
  const ConfirmLocation({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLatLng,
    required this.destinationLatLng,
    required this.tripType,
    this.returnPickupAddress,
    this.returnDestinationAddress,
    this.returnPickupLatLng,
    this.returnDestinationLatLng,
    this.returnDate,
    this.returnTimePeriod,
  });
  final String pickupAddress;
  final String destinationAddress;
  final LatLng pickupLatLng;
  final LatLng destinationLatLng;
  final TripType tripType;
  final String? returnPickupAddress;
  final String? returnDestinationAddress;
  final LatLng? returnPickupLatLng;
  final LatLng? returnDestinationLatLng;
  final String? returnDate;
  final String? returnTimePeriod;

  @override
  State<ConfirmLocation> createState() => _ConfirmLocationState();
}

class _ConfirmLocationState extends State<ConfirmLocation> {
  GoogleMapController? _mapController;
  late LatLng _currentMapCenter;

  // Polyline and marker state
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  List<LatLng> _polylineCoordinates = [];
  static const String _googleApiKey = 'AIzaSyCXvZ6f1LTP07lD6zhqnozAG20MzlUjis8'; // TODO: Replace with your key

  // Use the passed location data
  final List<Map<String, dynamic>> _locationSuggestions = [];

  // State for the "Save as Favorite" modal
  // FavoriteType _selectedFavoriteType = FavoriteType.other; // Default selection
  final TextEditingController _otherFavoriteNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("ConfirmLocation initState called");
    print("tripType: \\${widget.tripType}");
    _currentMapCenter = widget.pickupLatLng;
    _locationSuggestions.addAll([
      {
        "address": widget.pickupAddress,
        "isOrigin": true,
        "isFavorite": false,
        "favoriteType": null,
        "favoriteName": null,
      },
      {
        "address": widget.destinationAddress,
        "isOrigin": false,
        "isFavorite": false,
        "favoriteType": null,
        "favoriteName": null,
      },
    ]);
    _setMapRoute();
  }

  Future<void> _setMapRoute() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: _googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(widget.pickupLatLng.latitude, widget.pickupLatLng.longitude),
        destination: PointLatLng(widget.destinationLatLng.latitude, widget.destinationLatLng.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      _polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      _polylines = {
        Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: _polylineCoordinates,
        ),
      };
    }

    _markers = {
      Marker(
        markerId: MarkerId('pickup'),
        position: widget.pickupLatLng,
        infoWindow: InfoWindow(title: 'Pickup'),
      ),
      Marker(
        markerId: MarkerId('destination'),
        position: widget.destinationLatLng,
        infoWindow: InfoWindow(title: 'Destination'),
      ),
    };

    setState(() {});
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _otherFavoriteNameController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // You might want to style the map here if needed
    // controller.setMapStyle(_mapStyleJson); // If you have a JSON map style
  }

  void _onCameraMove(CameraPosition position) {
    _currentMapCenter = position.target;
  }

  void _onCameraIdle() {
    // Called when the camera movement has ended.
    // You can fetch address for _currentMapCenter here
    log("Map moved to: $_currentMapCenter");
    // Potentially update the top suggestion text fields if they reflect current map center
  }

  final DateTimePickerModal _dateTimePickerModal = DateTimePickerModal();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyWhite,
      appBar: _buildAppBar(context),
      bottomSheet: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                _buildLocationSuggestionItem(
                  context: context,
                  address: _locationSuggestions[0]['address'],
                  isFavorite: _locationSuggestions[0]['isFavorite'],
                  onTap: () {
                    toast("Tapped suggestion 1");
                  },
                  itemIndex: 0, // ADD THIS
                  pickup: true,
                ).paddingSymmetric(
                    horizontal: 16, vertical: 0), // Keep vertical: 0 if desired
                7.height,
                _buildLocationSuggestionItem(
                        context: context,
                        address: _locationSuggestions[1]['address'],
                        isFavorite: _locationSuggestions[1]['isFavorite'],
                        onTap: () {
                          toast("Tapped suggestion 2");
                        },
                        itemIndex: 1, // ADD THIS
                        pickup: false)
                    .paddingSymmetric(horizontal: 16)
                    .paddingOnly(bottom: 12),

                // Show return trip locations if it's a round trip
                if (widget.tripType == TripType.roundTrip && widget.returnPickupAddress != null && widget.returnDestinationAddress != null) ...[
                  7.height,
                  _buildLocationSuggestionItem(
                    context: context,
                    address: widget.returnPickupAddress!,
                    isFavorite: false,
                    onTap: () {
                      toast("Return pickup location");
                    },
                    itemIndex: 2,
                    pickup: true,
                    isReturnTrip: true,
                  ).paddingSymmetric(horizontal: 16, vertical: 0),
                  7.height,
                  _buildLocationSuggestionItem(
                    context: context,
                    address: widget.returnDestinationAddress!,
                    isFavorite: false,
                    onTap: () {
                      toast("Return destination location");
                    },
                    itemIndex: 3,
                    pickup: false,
                    isReturnTrip: true,
                  ).paddingSymmetric(horizontal: 16, vertical: 0),
                ],

                16.height,
                const Divider(
                  color: AppColor.greyShade7,
                  height: 1,
                  thickness: 8,
                ).paddingSymmetric(horizontal: 16),

                16.height,
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text("passengers protection plan".toUpperCase(),
                      style: AppStyle.caption1w400.copyWith(
                          color: AppColor.greyShade1,
                          fontWeight: FontWeight.w600)),
                ),
                8.height,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 49,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColor.greyWhite,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: AppColor.greyShade6, // Make sure AppColor.greyShade6 is defined
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.greyShade5.withOpacity(0.6),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AppAssets.secure,
                          height: 24,
                          width: 24,
                        ),
                        8.width,
                        Text(
                          "Secure your booking",
                          style: AppStyle.subheading.copyWith(
                              color: AppColor.greyShade1,
                              fontSize: 16,
                              height: 21 / 16,
                              letterSpacing: 0),
                        ),
                        8.width,
                        Icon(Icons.info, color: AppColor.greyShade3, size: 16),
                        const Spacer(),
                        CupertinoSwitch(
                          value: true,
                          onChanged: (value) {},
                          activeColor: AppColor.buttonColor,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: 25,
                      left: 20,
                      right: 20,
                      top: 12),
                  child: AppPrimaryButton(
                    text: "Continue",
                    onTap: () async {
                      // Show onward date/time picker
                      _dateTimePickerModal.show(context, onSelectDateTime:
                          (DateTime selectedDate, String timePeriod) {
                        String formattedDate = "${selectedDate.year}-" +
                            "${selectedDate.month.toString().padLeft(2, '0')}-" +
                            "${selectedDate.day.toString().padLeft(2, '0')}";

                        if (widget.tripType == TripType.roundTrip) {
                          // Show return date/time picker
                          _dateTimePickerModal.show(context, onSelectDateTime: (DateTime returnDate, String returnTimePeriod) {
                            String formattedReturnDate = "${returnDate.year}-" +
                                "${returnDate.month.toString().padLeft(2, '0')}-" +
                                "${returnDate.day.toString().padLeft(2, '0')}";
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChooseSlotPage(
                                  selectedDate: formattedDate,
                                  selectedTimePeriod: timePeriod,
                                  pickupAddress: widget.pickupAddress,
                                  destinationAddress: widget.destinationAddress,
                                  pickupLatLng: widget.pickupLatLng,
                                  destinationLatLng: widget.destinationLatLng,
                                  tripType: "roundtrip",
                                  returnPickupAddress: widget.returnPickupAddress,
                                  returnDestinationAddress: widget.returnDestinationAddress,
                                  returnPickupLatLng: widget.returnPickupLatLng,
                                  returnDestinationLatLng: widget.returnDestinationLatLng,
                                  returnDate: formattedReturnDate,
                                  returnTimePeriod: returnTimePeriod,
                                ),
                              ),
                            );
                          });
                        } else {
                          // One way: just pass onward date/time
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChooseSlotPage(
                                selectedDate: formattedDate,
                                selectedTimePeriod: timePeriod,
                                pickupAddress: widget.pickupAddress,
                                destinationAddress: widget.destinationAddress,
                                pickupLatLng: widget.pickupLatLng,
                                destinationLatLng: widget.destinationLatLng,
                                tripType: "oneway",
                                returnPickupAddress: widget.returnPickupAddress,
                                returnDestinationAddress: widget.returnDestinationAddress,
                                returnPickupLatLng: widget.returnPickupLatLng,
                                returnDestinationLatLng: widget.returnDestinationLatLng,
                                returnDate: widget.returnDate,
                                returnTimePeriod: widget.returnTimePeriod,
                              ),
                            ),
                          );
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              right: 28,
              top: 43,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColor.greyWhite,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.greyShade5.withOpacity(0.6),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppAssets.alarm, height: 20, width: 20),
                    Text("Now",
                        style: AppStyle.subheading.copyWith(
                            color: AppColor.greyShade1,
                            fontSize: 13,
                            height: 18 / 13,
                            letterSpacing: 0)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // _buildLocationSuggestionItem(
              //   context: context,
              //   address: _locationSuggestions[0]['address'],
              //   isFavorite: _locationSuggestions[0]['isFavorite'],
              //   onTap: () {
              //     toast("Tapped suggestion 1");
              //   },
              //   itemIndex: 0, // ADD THIS
              //   pickup: true,
              // ).paddingSymmetric(
              //     horizontal: 16, vertical: 0), // Keep vertical: 0 if desired
              // 7.height,
              // _buildLocationSuggestionItem(
              //         context: context,
              //         address: _locationSuggestions[1]['address'],
              //         isFavorite: _locationSuggestions[1]['isFavorite'],
              //         onTap: () {
              //           toast("Tapped suggestion 2");
              //         },
              //         itemIndex: 1, // ADD THIS
              //         pickup: false)
              //     .paddingSymmetric(horizontal: 16)
              //     .paddingOnly(bottom: 12),

              // Map takes the remaining space
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _currentMapCenter,
                        zoom: 15.0,
                      ),
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      zoomControlsEnabled: true,
                      onCameraMove: _onCameraMove,
                      onCameraIdle: _onCameraIdle,
                      polylines: _polylines,
                      markers: _markers,
                    ),
                    IgnorePointer(
                      child: Image.asset(
                        AppAssets.pin,
                        height: 29,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Confirm Button positioned at the bottom
          // Positioned(
          //   left: 20,
          //   right: 20,
          //   bottom: 20 +
          //       MediaQuery.of(context).padding.bottom, // Adjust for safe area
          //   child: AppPrimaryButton(
          //     text: "Confirm Location",
          //     onTap: () {
          //       toast("Confirmed Location: $_currentMapCenter");
          //       // Navigator.pop(context, _currentMapCenter); // Example: return selected LatLng
          //     },
          //   ),
          // ),
          // Bottom home indicator like bar
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 60, // Center it
            right: MediaQuery.of(context).size.width / 2 - 60,
            bottom: 8,
            child: Container(
              height: 5,
              width: 120,
              decoration: BoxDecoration(
                color: AppColor.greyShade5.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Or AppColor.greyWhite
        statusBarIconBrightness: Brightness.dark, // For dark icons
      ),
      backgroundColor: AppColor.greyWhite,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppColor.greyShade1),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text("Confirm Ride", style: AppStyle.title3),
      centerTitle: false, // Aligns title to the left of center (after leading)
      actions: [
        Container(
          decoration: BoxDecoration(
            color: AppColor.buttonColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Text(
              widget.tripType == TripType.roundTrip ? "Round Trip" : "One Way",
              style: AppStyle.subheading.copyWith(color: AppColor.greyWhite),
            ),
          ),
        ),
        16.width,
      ],
    );
  }

  Widget _buildLocationSuggestionItem({
    required BuildContext context,
    required String address,
    // required Color dotColor, // Replaced by pickup/destination asset
    required bool isFavorite,
    required VoidCallback onTap,
    // required VoidCallback onFavoriteTap, // Replaced by _handleFavoriteTap(index)
    required int
        itemIndex, // Pass index to identify which item is being favorited
    required bool pickup,
    bool isReturnTrip = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Min height to ensure consistent row height even with no vertical padding
        constraints: const BoxConstraints(minHeight: 50), // Adjust as needed
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 0), // Added some vertical padding
        decoration: BoxDecoration(
          color: AppColor.greyWhite,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: AppColor
                .greyShade6, // Make sure AppColor.greyShade6 is defined
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.greyShade5.withOpacity(0.6),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              pickup ? AppAssets.pickupLocation : AppAssets.destination,
              height: 24,
              width: 24,
            ),
            6.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isReturnTrip)
                    Text(
                      pickup ? "Return Pickup" : "Return Destination",
                      style: AppStyle.caption1w400.copyWith(
                        color: AppColor.greyShade3,
                        fontSize: 11,
                      ),
                    ),
                  Text(
                    address,
                    style: AppStyle.subheading.copyWith(
                        color: AppColor.greyShade1,
                        fontSize: 16,
                        height: 21 / 16,
                        letterSpacing: 0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1, // Ensure it doesn't wrap excessively
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
