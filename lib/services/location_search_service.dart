import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceSearch {
  final String placeId;
  final String name;
  final String formattedAddress;
  final double? lat;
  final double? lng;

  PlaceSearch({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    this.lat,
    this.lng,
  });

  factory PlaceSearch.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    
    return PlaceSearch(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      lat: location?['lat']?.toDouble(),
      lng: location?['lng']?.toDouble(),
    );
  }
}

class LocationSearchService {
  static const String _apiKey = "AIzaSyCXvZ6f1LTP07lD6zhqnozAG20MzlUjis8";
  static const String _baseUrl = "https://maps.googleapis.com/maps/api/place";

  /// Search for places using Google Places API
  static Future<List<PlaceSearch>> searchPlaces(String input) async {
    try {
      if (input.isEmpty) return [];

      final url = Uri.parse(
        '$_baseUrl/textsearch/json?query=${Uri.encodeComponent(input)}&key=$_apiKey&components=country:in'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results.map((json) => PlaceSearch.fromJson(json)).toList();
        } else {
          print('Places API Error: ${data['status']} - ${data['error_message']}');
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  /// Get place details including coordinates
  static Future<LatLng?> getPlaceCoordinates(String placeId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/details/json?place_id=$placeId&fields=geometry&key=$_apiKey'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final result = data['result'] as Map<String, dynamic>;
          final geometry = result['geometry'] as Map<String, dynamic>;
          final location = geometry['location'] as Map<String, dynamic>;
          
          final lat = location['lat'] as double;
          final lng = location['lng'] as double;
          
          return LatLng(lat, lng);
        }
      }
      return null;
    } catch (e) {
      print('Error getting place coordinates: $e');
      return null;
    }
  }

  /// Get formatted address from place
  static String getFormattedAddress(PlaceSearch place) {
    return place.formattedAddress.isNotEmpty ? place.formattedAddress : place.name;
  }

  /// Get place name
  static String getPlaceName(PlaceSearch place) {
    return place.name;
  }
} 