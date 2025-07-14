import 'package:flutter/material.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/common/app_primary_button.dart';
import 'package:flutter_arch/common/enums/trip_type.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/screens/homepage/model/subscriptionPlanModel.dart';
import 'package:flutter_arch/screens/homepage/view/confirm_location.dart';
import 'package:flutter_arch/screens/homepage/view/pickup_location.screen.dart';
import 'package:flutter_arch/screens/homepage/view/premium/getPremium.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:flutter_arch/widget/searchable_location_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedPickupAddress = "From";
  String selectedDestinationAddress = "To";
  LatLng? pickupLatLng;
  LatLng? destinationLatLng;
  TripType selectedTripType = TripType.oneWay;
  
  // Round trip data
  String? returnPickupAddress;
  String? returnDestinationAddress;
  LatLng? returnPickupLatLng;
  LatLng? returnDestinationLatLng;
  String? returnDate;
  String? returnTimePeriod;

  void _onPickupLocationSelected(String address, LatLng latLng) {
    setState(() {
      selectedPickupAddress = address;
      pickupLatLng = latLng;
    });
  }

  void _onDestinationLocationSelected(String address, LatLng latLng) {
    setState(() {
      selectedDestinationAddress = address;
      destinationLatLng = latLng;
    });
  }

  void _onReturnPickupLocationSelected(String address, LatLng latLng) {
    setState(() {
      returnPickupAddress = address;
      returnPickupLatLng = latLng;
    });
  }

  void _onReturnDestinationLocationSelected(String address, LatLng latLng) {
    setState(() {
      returnDestinationAddress = address;
      returnDestinationLatLng = latLng;
    });
  }

  void _onPickupFieldTap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickupLocationPage(
          isPickup: true,
          initialAddress: selectedPickupAddress != "From" ? selectedPickupAddress : null,
        ),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // Update pickup location
        selectedPickupAddress = result['pickupAddress'] ?? selectedPickupAddress;
        pickupLatLng = result['pickupLatLng'];
        
        // Update destination location if provided
        if (result['destinationAddress'] != null) {
          selectedDestinationAddress = result['destinationAddress'];
          destinationLatLng = result['destinationLatLng'];
        }
        
        selectedTripType = result['tripType'] ?? TripType.oneWay;
        
        // Handle round trip data
        if (result['tripType'] == TripType.roundTrip) {
          returnPickupAddress = result['returnPickupAddress'];
          returnDestinationAddress = result['returnDestinationAddress'];
          returnPickupLatLng = result['returnPickupLatLng'];
          returnDestinationLatLng = result['returnDestinationLatLng'];
        } else {
          // Clear round trip data for one-way trips
          returnPickupAddress = null;
          returnDestinationAddress = null;
          returnPickupLatLng = null;
          returnDestinationLatLng = null;
        }
      });
    }
  }

  void _onDestinationFieldTap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickupLocationPage(
          isPickup: false, // Changed to false for destination
          initialAddress: selectedDestinationAddress != "To" ? selectedDestinationAddress : null,
        ),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // Update pickup location if provided
        if (result['pickupAddress'] != null) {
          selectedPickupAddress = result['pickupAddress'];
          pickupLatLng = result['pickupLatLng'];
        }
        
        // Update destination location
        selectedDestinationAddress = result['destinationAddress'] ?? selectedDestinationAddress;
        destinationLatLng = result['destinationLatLng'];
        
        selectedTripType = result['tripType'] ?? TripType.oneWay;
        
        // Handle round trip data
        if (result['tripType'] == TripType.roundTrip) {
          returnPickupAddress = result['returnPickupAddress'];
          returnDestinationAddress = result['returnDestinationAddress'];
          returnPickupLatLng = result['returnPickupLatLng'];
          returnDestinationLatLng = result['returnDestinationLatLng'];
        } else {
          // Clear round trip data for one-way trips
          returnPickupAddress = null;
          returnDestinationAddress = null;
          returnPickupLatLng = null;
          returnDestinationLatLng = null;
        }
      });
    }
  }

  void _onReturnPickupFieldTap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickupLocationPage(
          isPickup: true,
          initialAddress: returnPickupAddress,
        ),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        returnPickupAddress = result['pickupAddress'];
        returnPickupLatLng = result['pickupLatLng'];
      });
    }
  }

  void _onReturnDestinationFieldTap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickupLocationPage(
          isPickup: false,
          initialAddress: returnDestinationAddress,
        ),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        returnDestinationAddress = result['destinationAddress'];
        returnDestinationLatLng = result['destinationLatLng'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyShade7,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset(AppAssets.logoSmall, height: 32)),
              // Navigation is now handled by bottom navigation bar
              16.height,
              
              // Trip Type Toggle
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFEEF0EB)),
                  color: AppColor.greyWhite,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTripType = TripType.oneWay;
                            returnPickupAddress = null;
                            returnDestinationAddress = null;
                            returnPickupLatLng = null;
                            returnDestinationLatLng = null;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedTripType == TripType.oneWay 
                                ? AppColor.buttonColor 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "One Way",
                              style: AppStyle.caption1w600.copyWith(
                                color: selectedTripType == TripType.oneWay 
                                    ? Colors.white 
                                    : AppColor.greyShade1,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTripType = TripType.roundTrip;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedTripType == TripType.roundTrip 
                                ? AppColor.buttonColor 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "Round Trip",
                              style: AppStyle.caption1w600.copyWith(
                                color: selectedTripType == TripType.roundTrip 
                                    ? Colors.white 
                                    : AppColor.greyShade1,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              16.height,
              
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFFEEF0EB),
                      ),
                      color: AppColor.greyWhite,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(1, 1),
                          spreadRadius: 0,
                          blurRadius: 3.3,
                          color: Color.fromRGBO(186, 186, 186, 0.25),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: Column(
                      children: [
                        // Pickup location field
                        SearchableLocationField(
                          label: "Pickup",
                          hint: "From",
                          initialValue: selectedPickupAddress != "From" ? selectedPickupAddress : null,
                          isPickup: true,
                          onLocationSelected: _onPickupLocationSelected,
                          onTap: _onPickupFieldTap,
                        ),
                        Divider(
                          color: Color(0xFFEEF0EB),
                        ),
                        // Destination location field
                        SearchableLocationField(
                          label: "Destination",
                          hint: "To",
                          initialValue: selectedDestinationAddress != "To" ? selectedDestinationAddress : null,
                          isPickup: false,
                          onLocationSelected: _onDestinationLocationSelected,
                          onTap: _onDestinationFieldTap,
                        ),
                        
                        // Show return trip fields only for round trip
                        if (selectedTripType == TripType.roundTrip) ...[
                          Divider(
                            color: Color(0xFFEEF0EB),
                          ),
                          // Return pickup location field
                          SearchableLocationField(
                            label: "Return Pickup",
                            hint: "Return From",
                            initialValue: returnPickupAddress,
                            isPickup: true,
                            onLocationSelected: _onReturnPickupLocationSelected,
                            onTap: _onReturnPickupFieldTap,
                          ),
                          Divider(
                            color: Color(0xFFEEF0EB),
                          ),
                          // Return destination location field
                          SearchableLocationField(
                            label: "Return Destination",
                            hint: "Return To",
                            initialValue: returnDestinationAddress,
                            isPickup: false,
                            onLocationSelected: _onReturnDestinationLocationSelected,
                            onTap: _onReturnDestinationFieldTap,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              18.height,

              AppPrimaryButton(
                text: "Search ride",
                onTap: () {
                  if (selectedPickupAddress == "From" ||
                      selectedDestinationAddress == "To") {
                    toast("Please select pickup and destination locations");
                    return;
                  }

                  // For round trip, validate return locations
                  if (selectedTripType == TripType.roundTrip) {
                    if (returnPickupAddress == null || returnDestinationAddress == null) {
                      toast("Please select return pickup and destination locations");
                      return;
                    }
                  }

                  // Both locations are selected, proceed to confirm
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConfirmLocation(
                        pickupAddress: selectedPickupAddress,
                        destinationAddress: selectedDestinationAddress,
                        pickupLatLng: pickupLatLng!,
                        destinationLatLng: destinationLatLng!,
                        tripType: selectedTripType,
                        returnPickupAddress: returnPickupAddress,
                        returnDestinationAddress: returnDestinationAddress,
                        returnPickupLatLng: returnPickupLatLng,
                        returnDestinationLatLng: returnDestinationLatLng,
                        returnDate: returnDate,
                        returnTimePeriod: returnTimePeriod,
                      ),
                    ),
                  );
                },
              ),
              22.height,

              // Recent Searches
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your recent search",
                    style: AppStyle.title.copyWith(
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    "Clear all",
                    style: AppStyle.title.copyWith(
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w400,
                      color: AppColor.buttonColor,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              10.height,
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(
                    color: Color(0xFFEEF0EB),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Jakarta (CGK) → Bali (DPS)",
                        style: AppStyle.title.copyWith(
                            fontSize: 14,
                            height: 22 / 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0)),
                    8.height,
                    Text("24 Feb 2023  •  1 Passenger  •  Economy",
                        style: AppStyle.caption1w400),
                  ],
                ),
              ),
              22.height,
              _buildPromoSection(),
              24.height,
              SubscriptionPlansWidget(
                onSubscribeTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Getpremium()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoSection() {
    final promos = [
      {
        "image": AppAssets.intro1,
        "text1": "Get",
        "text2": "30% OFF",
        "text3": "for new users"
      },
      {
        "image": AppAssets.logoSmall,
        "text1": "Save Big",
        "text2": "Weekend Deal",
        "text3": "limited time offer"
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          "Get Attractive Promo!",
          actionIcon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColor.greyShade5.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward_ios,
                size: 12, color: AppColor.buttonColor),
          ),
          onActionTap: () {
            toast("See all promos");
          },
        ),
        10.height,
        SizedBox(
          height: 165,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: promos.length,
            separatorBuilder: (context, index) => 10.width,
            itemBuilder: (context, index) {
              final promo = promos[index];
              return _buildPromoCard(promo["image"]!, promo["text1"]!,
                  promo["text2"]!, promo["text3"]!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard(
      String imageAsset, String text1, String text2, String text3) {
    return Container(
      width: 280, // Adjust width for promo cards
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        image: DecorationImage(
          image: AssetImage(imageAsset),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // Gradient overlay
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.7)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 1.0])),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(text1,
                style: AppStyle.body
                    .copyWith(color: AppColor.greyWhite, fontSize: 18)),
            Text(text2,
                style: AppStyle.largeTitle.copyWith(
                    color: AppColor.greyWhite, fontSize: 28, height: 1.2)),
            Text(text3,
                style: AppStyle.subheading
                    .copyWith(color: AppColor.greyShade5, fontSize: 14)),
            4.height,
            Text(
              "*Terms and Conditions apply",
              style: AppStyle.caption1w400.copyWith(
                  color: AppColor.greyShade5.withOpacity(0.8), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title,
      {String? actionText, VoidCallback? onActionTap, Widget? actionIcon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: AppStyle.subheading.copyWith(
                fontSize: 16,
                height: 24 / 16,
                color: AppColor.greyShade1,
                fontWeight: FontWeight.w700)),
        if (actionText != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionText,
              style: AppStyle.body.copyWith(
                  color: AppColor.buttonColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          )
        else if (actionIcon != null && onActionTap != null)
          IconButton(
            icon: actionIcon,
            onPressed: onActionTap,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          )
      ],
    );
  }
}

class SubscriptionPlansWidget extends StatefulWidget {
  final VoidCallback onSubscribeTap;

  const SubscriptionPlansWidget({
    super.key,
    required this.onSubscribeTap,
  });

  @override
  State<SubscriptionPlansWidget> createState() =>
      _SubscriptionPlansWidgetState();
}

class _SubscriptionPlansWidgetState extends State<SubscriptionPlansWidget> {
  List<SubscriptionPlanModel> _plans = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionPlans();
  }

  Future<void> _fetchSubscriptionPlans() async {
    try {
      final dioHttp = DioHttp();
      final plans = await dioHttp.getSubscriptionPlans(context);
      final activePlans = plans.where((plan) => plan.isActive).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      setState(() {
        _plans = activePlans;
        _isLoading = false;
        if (_plans.isNotEmpty) {
          _selectedPlanId = _plans.first.id;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load subscription plans';
        _isLoading = false;
      });
      print('Error fetching subscription plans: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                  3,
                  (index) => Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                          decoration: BoxDecoration(
                            color: AppColor.greyShade5.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColor.buttonColor,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      )),
            ),
          ),
          20.height,
          _buildTrySubscribeButton(),
        ],
      );
    }

    if (_error != null || _plans.isEmpty) {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _error ?? 'No subscription plans available',
                      style:
                          AppStyle.body.copyWith(color: AppColor.greyShade3),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          20.height,
          _buildTrySubscribeButton(),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _plans.take(3).map((plan) {
                final isHighlighted = plan.trialDays > 0;
                final isSelected = plan.id == _selectedPlanId;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlanId = plan.id;
                      });
                    },
                    child: _buildSubscriptionCard(
                        plan: plan,
                        isHighlighted: isHighlighted,
                        isSelected: isSelected),
                  ),
                );
              }).toList(),
            ),
          ),
          20.height,
          _buildTrySubscribeButton(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
      {required SubscriptionPlanModel plan,
      required bool isHighlighted,
      required bool isSelected}) {
    Color cardBgColor =
        isHighlighted ? AppColor.buttonColor : AppColor.greyWhite;
    if (isSelected) {
      cardBgColor = AppColor.buttonColor.withOpacity(0.15);
    }
    String title = plan.name;
    if (title.contains('(')) {
      title = title.split('(')[0].trim();
    }
    String price = '₹${plan.price}';
    String duration =
        '${plan.durationValue} ${plan.durationUnit}${plan.durationValue > 1 ? 's' : ''}';
    String details = '${plan.ridesIncluded} rides';
    if (plan.trialDays > 0) {
      details += ' • ${plan.trialDays}-day trial';
    }
    BoxDecoration borderDecoration = BoxDecoration(
      color: cardBgColor,
      borderRadius: BorderRadius.circular(isHighlighted ? 6.0 : 4.0),
      border: Border.all(
        color: isSelected
            ? AppColor.buttonColor
            : (isHighlighted
                ? AppColor.buttonColor
                : AppColor.greyShade5.withOpacity(0.7)),
        width: isSelected ? 2 : 1,
      ),
    );
    if (isHighlighted) {
      return Container(
        decoration: borderDecoration,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 26,
                decoration: BoxDecoration(
                  color: AppColor.buttonColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6.0),
                    topRight: Radius.circular(6.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${plan.trialDays}-day free trial',
                    textAlign: TextAlign.center,
                    style: AppStyle.caption1w600.copyWith(
                      color: AppColor.greyWhite,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0,
                      height: 20 / 11,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColor.greyWhite,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(6.0),
                    bottomRight: Radius.circular(6.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 6, 12, 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.lato(
                          color: AppColor.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          height: 22 / 12,
                          letterSpacing: 0.12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      6.height,
                      Text(
                        price,
                        style: GoogleFonts.lato(
                          color: AppColor.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          height: 24 / 18,
                          letterSpacing: 0,
                        ),
                      ),
                      Text(
                        duration,
                        style: GoogleFonts.lato(
                          color: AppColor.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 20 / 12,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        details,
                        style: GoogleFonts.lato(
                          color: AppColor.grey,
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          height: 20 / 10,
                          letterSpacing: 0,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Container(
        decoration: borderDecoration,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    color: AppColor.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    height: 22 / 12,
                    letterSpacing: 0.12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                  6.height,
                  Text(
                    price,
                    style: GoogleFonts.lato(
                      color: AppColor.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      height: 24 / 18,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    duration,
                    style: GoogleFonts.lato(
                      color: AppColor.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 20 / 12,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    details,
                    style: GoogleFonts.lato(
                      color: AppColor.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      height: 20 / 10,
                      letterSpacing: 0,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildTrySubscribeButton() {
    return Center(
      child: TextButton(
        onPressed: widget.onSubscribeTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          "TRY 7 DAYS AND SUBSCRIBE",
          style: AppStyle.body.copyWith(
            color: AppColor.buttonColor,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
