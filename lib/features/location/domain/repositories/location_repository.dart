// import 'dart:convert';

// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:ride_sharing_user_app/data/api_client.dart';
// import 'package:ride_sharing_user_app/features/location/domain/repositories/location_repository_interface.dart';
// import 'package:ride_sharing_user_app/util/app_constants.dart';
// import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';


// class LocationRepository implements LocationRepositoryInterface{
//   final ApiClient apiClient;
//   final SharedPreferences sharedPreferences;
//   LocationRepository({required this.apiClient, required this.sharedPreferences});

//   @override
//   Future<Response> getZone(String lat, String lng) async {
//     return await apiClient.getData('${AppConstants.getZone}?lat=$lat&lng=$lng');
//   }

//   @override
//   Future<Response> getAddressFromGeocode(LatLng? latLng) async {
//     return await apiClient.getData('${AppConstants.geoCodeURI}?lat=${latLng!.latitude}&lng=${latLng.longitude}');
//   }

//  // @override
//   // Future<Response> searchLocation(String text) async {
//   //   return await apiClient.getData('${AppConstants.searchLocationUri}?search_text=${text.replaceAll('#', '')}');
//   // }

//   @override

// @override
// Future<Response> searchLocation(String text, {String? countryCode, String? location, String? radius}) async {
//   // Encoder le texte de recherche
//   String encodedText = Uri.encodeComponent(text.replaceAll('#', ''));
  
//   // Utiliser votre endpoint spécifique
//   String url = '${AppConstants.searchLocationUri}?search_text=$encodedText';
  
//   // FORCER les paramètres pour la Côte d'Ivoire
//   url += '&country=CI';
  
//   // Centrer sur Abidjan (coordonnées actuelles)
//   url += '&location=5.3556,-3.8731';
  
//   // Rayon de 50km
//   url += '&radius=50000';
  
//   // Langue française
//   url += '&language=fr';
  
//   // Limite de résultats
//   url += '&limit=20';
  
//   print('🔍 URL recherche Côte d\'Ivoire: $url');
  
//   try {
//     Response response = await apiClient.getData(url);
//     print('📡 Status: ${response.statusCode}');
//     return response;
//   } catch (e) {
//     print('❌ Erreur: $e');
//     return Response(statusCode: 500, statusText: e.toString());
//   }
// }

//   @override
//   Future<Response> getPlaceDetails(String placeID) async {
//     return await apiClient.getData('${AppConstants.placeApiDetails}?placeid=$placeID');
//   }

//   @override
//   Future<bool> saveUserAddress(Address? address) async {
//     apiClient.updateHeader(
//       sharedPreferences.getString(AppConstants.token) ?? '', address,
//     );
//     if(address == null) {
//       if(sharedPreferences.containsKey(AppConstants.userAddress)) {
//         return await sharedPreferences.remove(AppConstants.userAddress);
//       }else {
//         return true;
//       }
//     }else {
//       return await sharedPreferences.setString(AppConstants.userAddress, jsonEncode(address.toJson()));
//     }
//   }

//   @override
//   String? getUserAddress() {
//     return sharedPreferences.getString(AppConstants.userAddress);
//   }

//   @override
//   Future add(value) {
//     // TODO: implement add
//     throw UnimplementedError();
//   }

//   @override
//   Future delete(String id) {
//     // TODO: implement delete
//     throw UnimplementedError();
//   }

//   @override
//   Future get(String id) {
//     // TODO: implement get
//     throw UnimplementedError();
//   }

//   @override
//   Future getList({int? offset = 1}) {
//     // TODO: implement getList
//     throw UnimplementedError();
//   }

//   @override
//   Future update(value, {int? id}) {
//     // TODO: implement update
//     throw UnimplementedError();
//   }

// }



import 'dart:convert';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/location/domain/repositories/location_repository_interface.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LocationRepository implements LocationRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  LocationRepository(
      {required this.apiClient, required this.sharedPreferences});

  @override
  Future<Response> getZone(String lat, String lng) async {
    return await apiClient
        .getData('${AppConstants.getZone}?lat=$lat&lng=$lng');
  }

  @override
  Future<Response> getAddressFromGeocode(LatLng? latLng) async {
    return await apiClient.getData(
        '${AppConstants.geoCodeURI}?lat=${latLng!.latitude}&lng=${latLng.longitude}');
  }

  @override
  Future<Response> searchLocation(
    String text, {
    String? countryCode,
    String? location,   // format : "lat,lng" — transmis par LocationController
    String? radius,
  }) async {
    // ── Texte de recherche ──────────────────────────────────────────────────
    final String encodedText = Uri.encodeComponent(text.replaceAll('#', ''));

    // ── URL de base ──────────────────────────────────────────────────────────
    String url =
        '${AppConstants.searchLocationUri}?search_text=$encodedText'
        '&country=CI'
        '&location=5.3556,-3.8731'
        '&radius=50000'
        '&language=fr'
        '&limit=20';

    // ── user_location : nécessaire pour que le backend appelle Distance Matrix
    //   Le backend lit $request->input('user_location') sous forme de tableau,
    //   ce qui correspond aux paramètres GET user_location[lat]=...&user_location[lng]=...
    //   On extrait lat/lng depuis le paramètre `location` (format "lat,lng").
    if (location != null && location.contains(',')) {
      final parts = location.split(',');
      if (parts.length == 2) {
        final String lat = parts[0].trim();
        final String lng = parts[1].trim();
        url += '&user_location[lat]=$lat&user_location[lng]=$lng';
      }
    }

    print('🔍 URL recherche: $url');

    try {
      final Response response = await apiClient.getData(url);
      print('📡 Status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Erreur searchLocation: $e');
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  @override
  Future<Response> getPlaceDetails(String placeID) async {
    return await apiClient
        .getData('${AppConstants.placeApiDetails}?placeid=$placeID');
  }

  @override
  Future<bool> saveUserAddress(Address? address) async {
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token) ?? '',
      address,
    );
    if (address == null) {
      if (sharedPreferences.containsKey(AppConstants.userAddress)) {
        return await sharedPreferences.remove(AppConstants.userAddress);
      } else {
        return true;
      }
    } else {
      return await sharedPreferences.setString(
          AppConstants.userAddress, jsonEncode(address.toJson()));
    }
  }

  @override
  String? getUserAddress() {
    return sharedPreferences.getString(AppConstants.userAddress);
  }

  @override
  Future add(value) => throw UnimplementedError();

  @override
  Future delete(String id) => throw UnimplementedError();

  @override
  Future get(String id) => throw UnimplementedError();

  @override
  Future getList({int? offset = 1}) => throw UnimplementedError();

  @override
  Future update(value, {int? id}) => throw UnimplementedError();
}