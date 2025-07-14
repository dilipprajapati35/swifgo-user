import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_arch/common/app_primary_button.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_arch/common/enums/trip_type.dart';
import 'package:flutter_arch/widget/searchable_location_field.dart';
import 'package:flutter_arch/screens/homepage/view/date_time_pick.screen.dart';
import 'dart:async';
import 'package:flutter_arch/screens/homepage/view/premium/subscription_trip_selection_screen.dart';

class SubscriptionLocationPickerPage extends StatefulWidget {
  final TripType tripType;
  const SubscriptionLocationPickerPage({super.key, required this.tripType});

  @override
  State<SubscriptionLocationPickerPage> createState() => _SubscriptionLocationPickerPageState();
}

class _SubscriptionLocationPickerPageState extends State<SubscriptionLocationPickerPage> {
  GoogleMapController? _mapController;
  LatLng _currentMapCenter = const LatLng(19.0760, 72.8777);

  // State for locations
  String? _pickupAddress;
  String? _destinationAddress;
  LatLng? _pickupLatLng;
  LatLng? _destinationLatLng;
  String? _returnPickupAddress;
  String? _returnDestinationAddress;
  LatLng? _returnPickupLatLng;
  LatLng? _returnDestinationLatLng;
  int _currentLocationIndex = 0; // 0: pickup, 1: destination, 2: return pickup, 3: return destination
  String _currentMapAddress = "Loading address...";
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _getAddressFromCoordinates(_currentMapCenter);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _currentMapCenter = position.target;
  }

  void _onCameraIdle() {
    _getAddressFromCoordinates(_currentMapCenter);
  }

  Future<void> _getAddressFromCoordinates(LatLng coordinates) async {
    if (_isLoadingAddress) return;
    setState(() { _isLoadingAddress = true; });
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(coordinates.latitude, coordinates.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = _formatAddress(place);
        setState(() {
          _currentMapAddress = address;
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _currentMapAddress = "Address not found";
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentMapAddress = "Error getting address";
        _isLoadingAddress = false;
      });
    }
  }

  String _formatAddress(Placemark place) {
    List<String> addressParts = [];
    if (place.street != null && place.street!.isNotEmpty) addressParts.add(place.street!);
    if (place.subLocality != null && place.subLocality!.isNotEmpty) addressParts.add(place.subLocality!);
    if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) addressParts.add(place.administrativeArea!);
    return addressParts.join(', ');
  }

  void _selectCurrentMapLocation() {
    if (_isLoadingAddress || _currentMapAddress == "Loading address..." || _currentMapAddress == "Address not found" || _currentMapAddress == "Error getting address") {
      toast("Please wait for address to load or move the map to a different location");
      return;
    }
    if (widget.tripType == TripType.oneWay) {
      if (_pickupAddress == null) {
        setState(() {
          _pickupAddress = _currentMapAddress;
          _pickupLatLng = _currentMapCenter;
        });
        toast("Pickup location selected. Now select destination.");
      } else if (_destinationAddress == null) {
        setState(() {
          _destinationAddress = _currentMapAddress;
          _destinationLatLng = _currentMapCenter;
        });
        toast("Destination selected. Ready to continue.");
      }
    } else {
      // Round trip
      switch (_currentLocationIndex) {
        case 0:
          setState(() {
            _pickupAddress = _currentMapAddress;
            _pickupLatLng = _currentMapCenter;
            _currentLocationIndex = 1;
          });
          toast("Pickup location selected. Now select destination.");
          break;
        case 1:
          setState(() {
            _destinationAddress = _currentMapAddress;
            _destinationLatLng = _currentMapCenter;
            _currentLocationIndex = 2;
          });
          toast("Destination selected. Now select return pickup location.");
          break;
        case 2:
          setState(() {
            _returnPickupAddress = _currentMapAddress;
            _returnPickupLatLng = _currentMapCenter;
            _currentLocationIndex = 3;
          });
          toast("Return pickup location selected. Now select return destination.");
          break;
        case 3:
          setState(() {
            _returnDestinationAddress = _currentMapAddress;
            _returnDestinationLatLng = _currentMapCenter;
          });
          toast("All four locations selected!");
          break;
      }
    }
  }

  String _getBottomButtonText() {
    if (widget.tripType == TripType.oneWay) {
      if (_pickupAddress == null) return "Select Pickup Location";
      if (_destinationAddress == null) return "Select Destination Location";
      return "Continue";
    } else {
      switch (_currentLocationIndex) {
        case 0: return "Select Pickup Location";
        case 1: return "Select Destination Location";
        case 2: return "Select Return Pickup Location";
        case 3: return "Select Return Destination Location";
        default:
          if (_pickupAddress != null && _destinationAddress != null && _returnPickupAddress != null && _returnDestinationAddress != null) {
            return "Continue";
          } else {
            return "Select Return Destination Location";
          }
      }
    }
  }

  VoidCallback _getBottomButtonAction() {
    if (widget.tripType == TripType.oneWay) {
      if (_pickupAddress == null || _destinationAddress == null) {
        return _selectCurrentMapLocation;
      } else {
        return _confirmLocations;
      }
    } else {
      if (_pickupAddress != null && _destinationAddress != null && _returnPickupAddress != null && _returnDestinationAddress != null) {
        return _confirmLocations;
      } else {
        return _selectCurrentMapLocation;
      }
    }
  }

  void _confirmLocations() async {
    if (widget.tripType == TripType.oneWay) {
      if (_pickupAddress == null || _destinationAddress == null) {
        toast("Please select both pickup and destination locations");
        return;
      }
      // Show date/time picker and wait for result
      DateTime? selectedDateTime = await _pickDateTime(context);
      if (selectedDateTime == null) return;
      Navigator.pop(context, {
        'pickupAddress': _pickupAddress,
        'destinationAddress': _destinationAddress,
        'pickupLatLng': _pickupLatLng,
        'destinationLatLng': _destinationLatLng,
        'subscriptionStartDate': selectedDateTime.toUtc().toIso8601String(),
      });
    } else {
      if (_pickupAddress == null || _destinationAddress == null || _returnPickupAddress == null || _returnDestinationAddress == null) {
        toast("Please select all four locations for round trip");
        return;
      }
      // Show date/time picker and wait for result
      DateTime? selectedDateTime = await _pickDateTime(context);
      if (selectedDateTime == null) return;
      Navigator.pop(context, {
        'pickupAddress': _pickupAddress,
        'destinationAddress': _destinationAddress,
        'returnPickupAddress': _returnPickupAddress,
        'returnDestinationAddress': _returnDestinationAddress,
        'pickupLatLng': _pickupLatLng,
        'destinationLatLng': _destinationLatLng,
        'returnPickupLatLng': _returnPickupLatLng,
        'returnDestinationLatLng': _returnDestinationLatLng,
        'subscriptionStartDate': selectedDateTime.toUtc().toIso8601String(),
      });
    }
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    final completer = Completer<DateTime?>();
    DateTimePickerModal().show(context, onSelectDateTime: (date, _) {
      completer.complete(date);
    });
    return await completer.future;
  }

  // Location selection handlers for searchable fields
  void _onPickupLocationSelected(String address, LatLng latLng) {
    setState(() {
      _pickupAddress = address;
      _pickupLatLng = latLng;
    });
    // Move map to selected location
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  void _onDestinationLocationSelected(String address, LatLng latLng) {
    setState(() {
      _destinationAddress = address;
      _destinationLatLng = latLng;
    });
    // Move map to selected location
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  void _onReturnPickupLocationSelected(String address, LatLng latLng) {
    setState(() {
      _returnPickupAddress = address;
      _returnPickupLatLng = latLng;
    });
    // Move map to selected location
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  void _onReturnDestinationLocationSelected(String address, LatLng latLng) {
    setState(() {
      _returnDestinationAddress = address;
      _returnDestinationLatLng = latLng;
    });
    // Move map to selected location
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyWhite,
      appBar: AppBar(
        backgroundColor: AppColor.greyWhite,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColor.greyShade1),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.tripType == TripType.oneWay
              ? (_pickupAddress == null ? "Select Pickup Location" : (_destinationAddress == null ? "Select Destination Location" : "Confirm Locations"))
              : (() {
                  switch (_currentLocationIndex) {
                    case 0: return "Select Pickup Location";
                    case 1: return "Select Destination Location";
                    case 2: return "Select Return Pickup Location";
                    case 3: return "Select Return Destination Location";
                    default: return "Select Location";
                  }
                })(),
          style: AppStyle.title3,
        ),
        centerTitle: false,
      ),
      bottomSheet: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(bottom: 12, left: 20, right: 20, top: 12),
          child: AppPrimaryButton(
            text: _getBottomButtonText(),
            onTap: _getBottomButtonAction(),
          ),
        ),
      ),
      body: Column(
        children: [
          // Searchable location fields
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(color: Color(0xFFEEF0EB)),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Pickup location field
                SearchableLocationField(
                  label: "Pickup",
                  hint: "Enter pickup location",
                  initialValue: _pickupAddress,
                  isPickup: true,
                  onLocationSelected: _onPickupLocationSelected,
                  onTap: null, // Disable tap to prevent navigation
                ),
                12.height,
                // Destination location field
                SearchableLocationField(
                  label: "Destination",
                  hint: "Enter destination location",
                  initialValue: _destinationAddress,
                  isPickup: false,
                  onLocationSelected: _onDestinationLocationSelected,
                  onTap: null, // Disable tap to prevent navigation
                ),
                
                // Show return trip fields only for round trip
                if (widget.tripType == TripType.roundTrip) ...[
                  12.height,
                  // Return pickup location field
                  SearchableLocationField(
                    label: "Return Pickup",
                    hint: "Enter return pickup location",
                    initialValue: _returnPickupAddress,
                    isPickup: true,
                    onLocationSelected: _onReturnPickupLocationSelected,
                    onTap: null, // Disable tap to prevent navigation
                  ),
                  12.height,
                  // Return destination location field
                  SearchableLocationField(
                    label: "Return Destination",
                    hint: "Enter return destination location",
                    initialValue: _returnDestinationAddress,
                    isPickup: false,
                    onLocationSelected: _onReturnDestinationLocationSelected,
                    onTap: null, // Disable tap to prevent navigation
                  ),
                ],
              ],
            ),
          ),
          
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
                ),
                IgnorePointer(
                  child: Icon(Icons.location_on, size: 40, color: AppColor.buttonColor),
                ),
                // Floating action button to select current map location
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _selectCurrentMapLocation,
                    backgroundColor: AppColor.buttonColor,
                    child: Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 