import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/common/app_primary_button.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/screens/homepage/view/seat_selection.screen.dart';
import 'package:flutter_arch/screens/payment/view/paymentScreen1.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';


enum FavoriteType { home, work, other }

class ConfirmRideDetails extends StatefulWidget {
  final List<SeatInfo> selectedSeats;
  final String scheduledTripId;
  final String pickupStopId;
  final String dropOffStopId;
  final String pickupAddress;
  final String destinationAddress;
  final String price;
  final bool isRoundTrip;
  final String? returnPickupAddress;
  final String? returnDestinationAddress;
  final String? returnScheduledTripId;
  final String? returnPickupStopId;
  final String? returnDropOffStopId;
  final List<SeatInfo>? returnSelectedSeats;

  const ConfirmRideDetails({
    super.key,
    required this.selectedSeats,
    required this.scheduledTripId,
    required this.pickupStopId,
    required this.dropOffStopId,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.price,
    this.isRoundTrip = false,
    this.returnPickupAddress,
    this.returnDestinationAddress,
    this.returnScheduledTripId,
    this.returnPickupStopId,
    this.returnDropOffStopId,
    this.returnSelectedSeats,
  });

  @override
  State<ConfirmRideDetails> createState() => _ConfirmRideDetailsState();
}

class _ConfirmRideDetailsState extends State<ConfirmRideDetails> {
  GoogleMapController? _mapController;
  LatLng _currentMapCenter =
      const LatLng(17.3753, 78.4744); // Example: Hyderabad

  // Dummy data for location suggestions - Consider making this a List<LocationSuggestionModel>
  // if complexity grows, where LocationSuggestionModel has address, isFavorite, favoriteType, favoriteName etc.
  final List<Map<String, dynamic>> _locationSuggestions = [
    {
      "address": "C95F+J2M, Manikonda Jagir, Hyder...",
      "isOrigin": true,
      "isFavorite": false,
      "favoriteType": null, // To store type if it becomes favorite
      "favoriteName": null, // To store custom name if it becomes favorite
    },
    {
      "address": "C95F+J2M, Manikonda Jagir, Hyder...",
      "isOrigin": false,
      "isFavorite": true, // Let's assume this one is already a favorite
      "favoriteType": FavoriteType.work, // Example
      "favoriteName": null, // Not needed if type is not 'other'
    },
  ];

  // State for the "Save as Favorite" modalselection
  final TextEditingController _otherFavoriteNameController =
      TextEditingController();

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

  _item(String name, String asset) {
    return Row(
      children: [
        Image.asset(
          asset,
          height: 24,
          width: 24,
        ),
        8.width,
        Text(
          "Payment",
          style: AppStyle.caption1w400.copyWith(
            color: AppColor.greyShade1,
            fontSize: 15,
            height: 20 / 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

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
                // Onward trip locations
                _buildLocationSuggestionItem(
                  context: context,
                  address: widget.pickupAddress,
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
                        address: widget.destinationAddress,
                        isFavorite: _locationSuggestions[1]['isFavorite'],
                        onTap: () {
                          toast("Tapped suggestion 2");
                        },
                        itemIndex: 1, // ADD THIS
                        pickup: false)
                    .paddingSymmetric(horizontal: 16)
                    .paddingOnly(bottom: 12),

                // Show return trip locations if it's a round trip
                if (widget.isRoundTrip && widget.returnPickupAddress != null && widget.returnDestinationAddress != null) ...[
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _item('Payment', AppAssets.payment),
                      Spacer(),
                      VerticalDivider(
                        color: AppColor.greyShade6,
                        thickness: 1,
                      ),
                      Spacer(),
                      _item('Coupon', AppAssets.coupon),
                      Spacer(),
                      VerticalDivider(
                        color: AppColor.greyShade6,
                        thickness: 1,
                      ),
                      Spacer(),
                      _item('Personal', AppAssets.person),
                    ],
                  ),
                ),
                16.height,
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Text(
                    "FARE",
                    style: AppStyle.caption1w400.copyWith(
                      color: AppColor.greyShade1,
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(bottom: 12, left: 20, right: 20, top: 12),
                  child: AppPrimaryButton(
                    text: widget.price, // Use the passed price
                    onTap: () {
                      // Navigate to PaymentScreen1
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Paymentscreen1(
                            selectedSeats: widget.selectedSeats,
                            scheduledTripId: widget.scheduledTripId,
                            pickupStopId: widget.pickupStopId,
                            dropOffStopId: widget.dropOffStopId,
                            pickupAddress: widget.pickupAddress,
                            destinationAddress: widget.destinationAddress,
                            price: widget.price,
                            isRoundTrip: widget.isRoundTrip,
                            returnPickupAddress: widget.returnPickupAddress,
                            returnDestinationAddress: widget.returnDestinationAddress,
                            returnScheduledTripId: widget.returnScheduledTripId,
                            returnPickupStopId: widget.returnPickupStopId,
                            returnDropOffStopId: widget.returnDropOffStopId,
                            returnSelectedSeats: widget.returnSelectedSeats,
                          ),
                        ),
                      );
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
                      myLocationButtonEnabled:
                          true, // Shows the "My Location" button
                      myLocationEnabled:
                          true, // Shows the blue dot for current location (requires permission)
                      zoomControlsEnabled: true, // Shows zoom + / - buttons
                      onCameraMove: _onCameraMove,
                      onCameraIdle: _onCameraIdle,
                      // markers: { // Example of adding a marker if needed
                      //   Marker(
                      //     markerId: MarkerId("someId"),
                      //     position: _currentMapCenter,
                      //   )
                      // },
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
              widget.isRoundTrip ? "Round Trip" : "One Way",
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
