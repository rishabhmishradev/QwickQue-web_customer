import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LocationStatus { initial, loading, granted, denied, deniedForever, manual }

class LocationState {
  final LocationStatus status;
  final double? latitude;
  final double? longitude;
  final String? cityName;
  final String? stateName;
  final String? error;

  LocationState({
    required this.status,
    this.latitude,
    this.longitude,
    this.cityName,
    this.stateName,
    this.error,
  });

  factory LocationState.initial() => LocationState(status: LocationStatus.initial);
  
  LocationState copyWith({
    LocationStatus? status,
    double? latitude,
    double? longitude,
    String? cityName,
    String? stateName,
    String? error,
  }) {
    return LocationState(
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      stateName: stateName ?? this.stateName,
      error: error ?? this.error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState.initial());

  Future<void> determinePosition() async {
    state = state.copyWith(status: LocationStatus.loading);

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(status: LocationStatus.denied, error: 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(status: LocationStatus.denied, error: 'Location permissions are denied');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(status: LocationStatus.deniedForever, error: 'Location permissions are permanently denied.');
      return;
    } 

    try {
      print('AUTO_LOCATION: Fetching coordinates...');
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw 'Location request timed out. Check your GPS.';
      });

      print('AUTO_LOCATION: Coordinates found: ${position.latitude}, ${position.longitude}');

      // Reverse Geocoding to get City/State name
      String? city;
      String? stateName;
      
      try {
        print('AUTO_LOCATION: Reverse geocoding...');
        final List<geocode.Placemark> placemarks = await geocode.placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        if (placemarks.isNotEmpty) {
          final geocode.Placemark place = placemarks[0];
          city = place.locality ?? place.subLocality ?? place.name;
          stateName = place.administrativeArea;
          print('AUTO_LOCATION: Found $city, $stateName');
        } else {
          print('AUTO_LOCATION: No placemarks found');
        }
      } catch (e) {
        print('AUTO_LOCATION: Reverse Geocoding failed: $e');
        // We still have coordinates, so we can continue
      }

      state = state.copyWith(
        status: LocationStatus.granted,
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: city ?? 'Detected Location',
        stateName: stateName,
      );
    } catch (e) {
      print('AUTO_LOCATION: Critical error: $e');
      state = state.copyWith(status: LocationStatus.denied, error: e.toString());
    }
  }

  Future<void> setManualLocation({required String city, required String stateName}) async {
    state = state.copyWith(status: LocationStatus.loading, cityName: city, stateName: stateName);
    
    try {
      print('MANUAL_LOCATION: Fetching coordinates for $city, $stateName...');
      List<geocode.Location> locations = await geocode.locationFromAddress('$city, $stateName, India');
      
      if (locations.isNotEmpty) {
        final loc = locations[0];
        print('MANUAL_LOCATION: Coordinates found: ${loc.latitude}, ${loc.longitude}');
        state = state.copyWith(
          status: LocationStatus.manual,
          latitude: loc.latitude,
          longitude: loc.longitude,
        );
      } else {
        throw 'Coordinates not found for selected city';
      }
    } catch (e) {
      print('MANUAL_LOCATION: Error fetching coordinates: $e');
      // Fallback to default but mark as manual so UI doesn't hang
      state = state.copyWith(
        status: LocationStatus.manual,
        latitude: 28.6139, 
        longitude: 77.2090,
        error: 'Could not get exact coordinates. Using default.',
      );
    }
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

final locationDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final String response = await rootBundle.loadString('assets/india_states_cities.json');
  return json.decode(response);
});
