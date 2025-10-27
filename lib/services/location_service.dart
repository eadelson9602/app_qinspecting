import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_qinspecting/providers/db_provider.dart';
import 'package:app_qinspecting/models/models.dart';
import 'dart:convert';

class LocationService {
  /// Obtiene la ubicación GPS actual
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Verificar conectividad a internet
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternetConnection = connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);
      
      if (!hasInternetConnection) {
        return LocationResult.error(
          'No hay conexión a internet. Selecciona la ciudad manualmente.',
        );
      }

      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.error(
          'El servicio de ubicación está deshabilitado',
        );
      }

      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();

      // Si el permiso está denegado permanentemente
      if (permission == LocationPermission.deniedForever) {
        return LocationResult.error(
          'Permisos de ubicación denegados permanentemente',
        );
      }

      // Si el permiso está denegado, solicitarlo
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return LocationResult.error(
            'Permisos de ubicación denegados',
          );
        }

        // Si después de solicitar el permiso, este fue denegado permanentemente
        if (permission == LocationPermission.deniedForever) {
          return LocationResult.error(
            'Permisos de ubicación denegados permanentemente',
          );
        }
      }

      // Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Obtener dirección desde coordenadas
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String cityName = place.locality ?? place.administrativeArea ?? '';

        if (cityName.isNotEmpty) {
          // Buscar la ciudad en la base de datos local
          CitySearchResult cityResult = await findCityInDatabase(cityName);

          if (cityResult.found) {
            return LocationResult.success(
              position: position,
              cityName: cityResult.cityName,
              cityId: cityResult.cityId!,
              departmentId: cityResult.departmentId ?? 0,
            );
          } else {
            return LocationResult.error(
              'Ciudad "$cityName" no encontrada en la base de datos. Por favor, selecciona manualmente.',
            );
          }
        } else {
          return LocationResult.error(
            'No se pudo determinar la ciudad',
          );
        }
      } else {
        return LocationResult.error(
          'No se encontró información de ubicación',
        );
      }
    } catch (e) {
      return LocationResult.error(
        'Error al obtener ubicación: $e',
      );
    }
  }

  /// Busca la ciudad en la base de datos SQLite local
  Future<CitySearchResult> findCityInDatabase(String cityName) async {
    try {
      // Buscar ciudad directamente en SQLite sin filtro de departamento
      List<Ciudades> ciudades = await DBProvider.db.getAllCiudades();

      // Buscar ciudad por nombre (case insensitive)
      Ciudades? foundCity;
      try {
        foundCity = ciudades.firstWhere(
          (city) =>
              city.label.toLowerCase().contains(cityName.toLowerCase()) ||
              cityName.toLowerCase().contains(city.label.toLowerCase()),
        );
      } catch (e) {
        // No se encontró la ciudad
        foundCity = null;
      }

      if (foundCity != null && foundCity.value != 0) {
        print(
            '[GPS] Ciudad encontrada: ${foundCity.label} (ID: ${foundCity.value}, Departamento: ${foundCity.idDepartamento})');

        return CitySearchResult(
          found: true,
          cityName: foundCity.label,
          cityId: foundCity.value,
          departmentId: foundCity.idDepartamento,
        );
      } else {
        return CitySearchResult(
          found: false,
          cityName: cityName,
        );
      }
    } catch (e) {
      throw Exception('Error al buscar ciudad: $e');
    }
  }
}

/// Resultado de la búsqueda de ubicación
class LocationResult {
  final bool success;
  final String? error;
  final Position? position;
  final String? cityName;
  final int? cityId;
  final int? departmentId;

  LocationResult._({
    required this.success,
    this.error,
    this.position,
    this.cityName,
    this.cityId,
    this.departmentId,
  });

  factory LocationResult.success({
    required Position position,
    required String cityName,
    required int cityId,
    required int? departmentId,
  }) {
    return LocationResult._(
      success: true,
      position: position,
      cityName: cityName,
      cityId: cityId,
      departmentId: departmentId,
    );
  }

  factory LocationResult.error(String error) {
    return LocationResult._(
      success: false,
      error: error,
    );
  }

  /// Convierte la posición GPS a JSON
  String? get positionGpsJson {
    if (position == null) return null;
    return jsonEncode({
      'latitude': position!.latitude,
      'longitude': position!.longitude,
    });
  }
}

/// Resultado de la búsqueda de ciudad
class CitySearchResult {
  final bool found;
  final String cityName;
  final int? cityId;
  final int? departmentId;

  CitySearchResult({
    required this.found,
    required this.cityName,
    this.cityId,
    this.departmentId,
  });
}
