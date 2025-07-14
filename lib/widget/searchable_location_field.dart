import 'package:flutter/material.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/services/location_search_service.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

class SearchableLocationField extends StatefulWidget {
  final String label;
  final String hint;
  final String? initialValue;
  final bool isPickup;
  final Function(String address, LatLng latLng) onLocationSelected;
  final VoidCallback? onTap;

  const SearchableLocationField({
    super.key,
    required this.label,
    required this.hint,
    this.initialValue,
    required this.isPickup,
    required this.onLocationSelected,
    this.onTap,
  });

  @override
  State<SearchableLocationField> createState() => _SearchableLocationFieldState();
}

class _SearchableLocationFieldState extends State<SearchableLocationField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<PlaceSearch> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _showResults = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(SearchableLocationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the controller text when the initialValue changes from parent
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await LocationSearchService.searchPlaces(query);
      setState(() {
        _searchResults = results;
        _showResults = true;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _showResults = false;
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _searchPlaces(value);
  }

  void _onPlaceSelected(PlaceSearch place) async {
    setState(() {
      _controller.text = LocationSearchService.getFormattedAddress(place);
      _showResults = false;
    });

    // Get coordinates if not already available
    LatLng? coordinates;
    if (place.lat != null && place.lng != null) {
      coordinates = LatLng(place.lat!, place.lng!);
    } else {
      coordinates = await LocationSearchService.getPlaceCoordinates(place.placeId);
    }

    if (coordinates != null) {
      widget.onLocationSelected(
        LocationSearchService.getFormattedAddress(place),
        coordinates,
      );
    } else {
      toast("Could not get location coordinates");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced vertical padding
            child: Row(
              children: [
                Image.asset(
                  widget.isPickup ? AppAssets.adjust : AppAssets.locationOn,
                  height: 16, // Reduced icon size
                ),
                6.width, // Reduced spacing
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: AppStyle.caption1w400.copyWith(
                        color: Color(0xFF8C8D89),
                        fontSize: 13, // Reduced font size
                        height: 20 / 13, // Adjusted line height
                        letterSpacing: 0,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true, // Makes the field more compact
                    ),
                    style: AppStyle.caption1w400.copyWith(
                      color: _controller.text.isEmpty
                          ? Color(0xFF8C8D89)
                          : AppColor.greyShade1,
                      fontSize: 13, // Reduced font size
                      height: 20 / 13, // Adjusted line height
                      letterSpacing: 0,
                    ),
                  ),
                ),
                if (_isSearching)
                  SizedBox(
                    width: 14, // Reduced size
                    height: 14, // Reduced size
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.buttonColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_showResults && _searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final place = _searchResults[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Reduced padding
                  leading: Icon(
                    Icons.location_on,
                    color: AppColor.buttonColor,
                    size: 18, // Reduced icon size
                  ),
                  title: Text(
                    LocationSearchService.getPlaceName(place),
                    style: AppStyle.caption1w400.copyWith(
                      color: AppColor.greyShade1,
                      fontSize: 13, // Reduced font size
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    LocationSearchService.getFormattedAddress(place),
                    style: AppStyle.caption1w400.copyWith(
                      color: AppColor.greyShade3,
                      fontSize: 11, // Reduced font size
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _onPlaceSelected(place),
                );
              },
            ),
          ),
      ],
    );
  }
} 