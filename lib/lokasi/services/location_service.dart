import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_data.dart';

enum LocationProvider { network, gps }

class LocationService {
  Stream<LocationData>? _locationStream;
  StreamSubscription<Position>? _positionSubscription;
  StreamController<LocationData>? _streamController;
  LocationProvider? _currentProvider;

  Future<bool> requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    // Optional: Request precise accuracy permission explicitly for Android 12+
    // Tapi untuk experiment ini, standard request sudah cukup.
    return true;
  }

  // Helper untuk membuat settings agar tidak duplikasi code
  LocationSettings _getSettings(LocationProvider provider) {
    if (Platform.isAndroid) {
      if (provider == LocationProvider.network) {
        return AndroidSettings(
          // PERUBAHAN UTAMA DI SINI:
          // Gunakan 'balanced' atau 'high'. 'balanced' menggunakan WiFi & Cell Towers (sekitar 100m - 40m).
          // 'high' dengan forceLocationManager: false akan menggunakan WiFi sangat agresif (bisa sampai 10-20m).
          accuracy: LocationAccuracy.high, 
          distanceFilter: 0, 
          forceLocationManager: false, // False = Gunakan Google Play Services (Fused Location) -> Bagus untuk Indoor
          intervalDuration: const Duration(seconds: 2),
        );
      } else {
        return AndroidSettings(
          // GPS Murni
          accuracy: LocationAccuracy.best,
          distanceFilter: 0, 
          forceLocationManager: true, // True = Paksa Hardware GPS (Akan sulit lock di Indoor)
          intervalDuration: const Duration(seconds: 2),
        );
      }
    } else {
      // iOS
      if (provider == LocationProvider.network) {
        return AppleSettings(
          accuracy: LocationAccuracy.best, // iOS smart enough to switch
          activityType: ActivityType.fitness,
          pauseLocationUpdatesAutomatically: true,
        );
      } else {
        return AppleSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          activityType: ActivityType.automotiveNavigation,
        );
      }
    }
  }

  Stream<LocationData> getLocationStream(LocationProvider provider) {
    stopLocationStream();
    _currentProvider = provider;
    
    final locationSettings = _getSettings(provider);

    _streamController = StreamController<LocationData>.broadcast();
    
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        if (_streamController != null && !_streamController!.isClosed) {
          _streamController!.add(
            LocationData(
              latitude: position.latitude,
              longitude: position.longitude,
              accuracy: position.accuracy,
              timestamp: position.timestamp,
              provider: provider == LocationProvider.network ? 'Network (Fused)' : 'GPS (Hardware)',
            ),
          );
        }
      },
      onError: (error) {
        debugPrint('Location stream error: $error');
        if (_streamController != null && !_streamController!.isClosed) {
          _streamController!.addError(error);
        }
      },
    );

    _locationStream = _streamController!.stream;
    return _locationStream!;
  }

  Future<LocationData?> getCurrentLocation(LocationProvider provider) async {
    try {
      final locationSettings = _getSettings(provider);

      // Tambahkan timeout. 
      // GPS murni di indoor mungkin tidak akan pernah dapat fix (timeout).
      // Network di indoor akan cepat dapat fix.
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(const Duration(seconds: 60), onTimeout: () {
        throw TimeoutException("Gagal mendapatkan lokasi dalam 60 detik. Mungkin sinyal lemah.");
      });

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
        provider: provider == LocationProvider.network ? 'Network (Fused)' : 'GPS (Hardware)',
      );
    } catch (e) {
      debugPrint("Error getCurrentLocation: $e");
      return null; // Controller akan menangani null ini sebagai error
    }
  }

  void stopLocationStream() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    
    if (_streamController != null && !_streamController!.isClosed) {
      _streamController!.close();
    }
    _streamController = null;
    _locationStream = null;
    _currentProvider = null;
  }

  LocationProvider? get currentProvider => _currentProvider;
}