
import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/repositories/ride_repository_interface.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';

class RideRepository implements RideRepositoryInterface {
  final ApiClient apiClient;

  RideRepository({required this.apiClient});

  @override
  Future<Response?> getEstimatedFare({
    required LatLng pickupLatLng,
    required LatLng destinationLatLng,
    required LatLng currentLatLng,
    required String type,
    required String pickupAddress,
    required String destinationAddress,
    LatLng? extraOneLatLng = const LatLng(0, 0),
    LatLng? extraTwoLatLng = const LatLng(0, 0),
    LatLng? extraThreeLatLng = const LatLng(0, 0),
    bool extraOne = false,
    bool extraTwo = false,
    bool extraThree = false,
    String? parcelWeight,
    String? parcelCategoryId,
    String? rideRequestType,
    required String? scheduledAt,
  }) async {
    // Construction dynamique des coordonnées intermédiaires
    String intermediateCoordinates = '';

    if (extraOne && !extraTwo && !extraThree) {
      intermediateCoordinates =
          '[[${extraOneLatLng?.latitude},${extraOneLatLng?.longitude}]]';
    } else if (extraOne && extraTwo && !extraThree) {
      intermediateCoordinates =
          '[[${extraOneLatLng?.latitude},${extraOneLatLng?.longitude}],[${extraTwoLatLng?.latitude},${extraTwoLatLng?.longitude}]]';
    } else if (extraOne && extraTwo && extraThree) {
      intermediateCoordinates =
          '[[${extraOneLatLng?.latitude},${extraOneLatLng?.longitude}],[${extraTwoLatLng?.latitude},${extraTwoLatLng?.longitude}],[${extraThreeLatLng?.latitude},${extraThreeLatLng?.longitude}]]';
    }

    Map<String, dynamic> requestBody = {
      "pickup_coordinates":
          '[${pickupLatLng.latitude},${pickupLatLng.longitude}]',
      "destination_coordinates":
          '[${destinationLatLng.latitude},${destinationLatLng.longitude}]',
      "type": type,
      "ride_request_type": rideRequestType,
      "pickup_address": pickupAddress,
      "destination_address": destinationAddress,
      "intermediate_coordinates": intermediateCoordinates,
      "scheduled_at": scheduledAt,
    };

    // Gestion des champs colis
    if (type == 'parcel') {
      requestBody['parcel_weight'] =
          Get.find<ParcelController>().parcelWeightController.text;
      requestBody['parcel_category_id'] = Get.find<ParcelController>()
          .parcelCategoryList![
              Get.find<ParcelController>().selectedParcelCategory]
          .id;
    } else {
      if (parcelWeight != null) requestBody['parcel_weight'] = parcelWeight;
      if (parcelCategoryId != null)
        requestBody['parcel_category_id'] = parcelCategoryId;
    }

    return await apiClient.postData(AppConstants.estimatedFare, requestBody);
  }

  @override
  Future<Response> submitRideRequest({
    required String pickupLat,
    required String pickupLng,
    required String destinationLat,
    required String destinationLng,
    required String customerCurrentLat,
    required String customerCurrentLng,
    required String vehicleCategoryId,
    required String estimatedDistance,
    required String estimatedTime,
    required String estimatedFare,
    required String actualFare,
    required String note,
    required String paymentMethod,
    required String type,
    required bool bid,
    required String pickupAddress,
    required String destinationAddress,
    required String encodedPolyline,
    required List<String> middleAddress,
    required String entrance,
    double? extraEstimatedFare,
    double? extraDiscountFare,
    double? extraDiscountAmount,
    double? extraReturnFee,
    double? extraCancellationFee,
    double? extraFareAmount,
    double? extraFareFee,
    String? zoneId,
    String? areaId,
    String extraLatOne = '',
    String extraLngOne = '',
    String extraLatTwo = '',
    String extraLngTwo = '',
    String extraLatThree = '',
    String extraLngThree = '',
    bool extraOne = false,
    bool extraTwo = false,
    bool extraThree = false,
    String? senderName,
    String? senderPhone,
    String? senderAddress,
    String? receiverName,
    String? receiverPhone,
    String? receiverAddress,
    String? parcelCategoryId,
    String? weight,
    String? payer,
    String? tripRequestId,
    double? returnFee,
    double? cancellationFee,
    required String? scheduledAt,
    String? rideRequestType,
    double? surgeMultiplier,
    String? pickupCoordinates,
    String? destinationCoordinates,
    String? customerCoordinates,

   bool isRideForOther = false,
      String? beneficiaryName,
      String? beneficiaryPhone,

  }) async {
    // Construction des coordonnées intermédiaires
    String intermediateCoordinates = '';
    if (!extraOne && !extraTwo && !extraThree) {
      intermediateCoordinates = ''; // Pas d'arrêts
    }
    if (extraOne && !extraTwo && !extraThree) {
      intermediateCoordinates = '[[$extraLatOne,$extraLngOne]]';
    } else if (extraOne && extraTwo && !extraThree) {
      intermediateCoordinates =
          '[[$extraLatOne,$extraLngOne],[$extraLatTwo,$extraLngTwo]]';
    } else if (extraOne && extraTwo && extraThree) {
      intermediateCoordinates =
          '[[$extraLatOne,$extraLngOne],[$extraLatTwo,$extraLngTwo],[$extraLatThree,$extraLngThree]]';
    }

    // CORRECTION ICI : middleAddress peut être vide
    List<String> validMiddleAddresses = [];
    for (String address in middleAddress) {
      if (address.trim().isNotEmpty) {
        validMiddleAddresses.add(address);
      }
    }
    String middleAddressJson = jsonEncode(validMiddleAddresses);

    Map<String, dynamic> body = {
      "pickup_coordinates": '[$pickupLat,$pickupLng]',
      "destination_coordinates": '[$destinationLat,$destinationLng]',
      "customer_coordinates": '[$customerCurrentLat,$customerCurrentLng]',
      "customer_request_coordinates":
          '[$customerCurrentLat,$customerCurrentLng]',
      "vehicle_category_id": vehicleCategoryId,
      "estimated_distance": estimatedDistance.replaceAll('km', ''),
      "estimated_time": estimatedTime.replaceAll('min', ''),
      "estimated_fare": estimatedFare,
      "actual_fare": actualFare,
      "note": note,
      "payment_method": paymentMethod,
      "type": type,
      "bid": bid,
      "pickup_address": pickupAddress,
      "destination_address": destinationAddress,
      'intermediate_coordinates': intermediateCoordinates,
      'intermediate_addresses': middleAddressJson,
      "entrance": entrance,
      "encoded_polyline": encodedPolyline,
      "scheduled_at": scheduledAt,
      "ride_request_type": rideRequestType,

        // ✅ AJOUTER
  'is_ride_for_other': isRideForOther ? '1' : '0',
  if (beneficiaryName != null) 'beneficiary_name': beneficiaryName,
  if (beneficiaryPhone != null) 'beneficiary_phone': beneficiaryPhone,
    };

    // Ajout conditionnel des champs optionnels
    if (intermediateCoordinates.isNotEmpty) {
      body["intermediate_coordinates"] = intermediateCoordinates;
    }
    if (areaId != null) body['area_id'] = areaId;
    if (zoneId != null) body['zone_id'] = zoneId;
    if (tripRequestId != null) body['trip_request_id'] = tripRequestId;
    if (returnFee != null) body['return_fee'] = returnFee;
    if (cancellationFee != null) body['cancellation_fee'] = cancellationFee;
    if (extraEstimatedFare != null)
      body['extra_estimated_fare'] = extraEstimatedFare;
    if (extraDiscountFare != null)
      body['extra_discount_fare'] = extraDiscountFare;
    if (extraDiscountAmount != null)
      body['extra_discount_amount'] = extraDiscountAmount;
    if (extraReturnFee != null) body['extra_return_fee'] = extraReturnFee;
    if (extraCancellationFee != null)
      body['extra_cancellation_fee'] = extraCancellationFee;
    if (extraFareAmount != null) body['extra_fare_amount'] = extraFareAmount;
    if (extraFareFee != null) body['extra_fare_fee'] = extraFareFee;
    if (surgeMultiplier != null) body['surge_multiplier'] = surgeMultiplier;

    // Gestion des champs colis
    if (type == 'parcel') {
      body['sender_name'] =
          Get.find<ParcelController>().senderNameController.text;
      body['sender_phone'] =
          Get.find<ParcelController>().getSenderContactNumber;
      body['sender_address'] =
          Get.find<ParcelController>().senderAddressController.text;
      body['receiver_name'] =
          Get.find<ParcelController>().receiverNameController.text;
      body['receiver_phone'] =
          Get.find<ParcelController>().getReceiverContactNumber;
      body['receiver_address'] =
          Get.find<ParcelController>().receiverAddressController.text;
      body['parcel_category_id'] = Get.find<ParcelController>()
          .parcelCategoryList![
              Get.find<ParcelController>().selectedParcelCategory]
          .id;
      body['weight'] = Get.find<ParcelController>().parcelWeightController.text;
      body['payer'] =
          Get.find<ParcelController>().payReceiver ? 'receiver' : "sender";
    } else {
      if (senderName != null) body['sender_name'] = senderName;
      if (senderPhone != null) body['sender_phone'] = senderPhone;
      if (senderAddress != null) body['sender_address'] = senderAddress;
      if (receiverName != null) body['receiver_name'] = receiverName;
      if (receiverPhone != null) body['receiver_phone'] = receiverPhone;
      if (receiverAddress != null) body['receiver_address'] = receiverAddress;
      if (parcelCategoryId != null)
        body['parcel_category_id'] = parcelCategoryId;
      if (weight != null) body['weight'] = weight;
      if (payer != null) body['payer'] = payer;
    }
    return await apiClient.postData(AppConstants.rideRequest, body);
  }

  @override
  Future<Response> getRideDetails(String tripId) async {
    return await apiClient.getData('${AppConstants.tripDetails}$tripId');
  }

  @override
  Future<Response> tripStatusUpdate(
      String id, String status, String cancellationCause) async {
    return await apiClient.postData('${AppConstants.updateTripStatus}$id', {
      "status": status,
      "cancel_reason": cancellationCause,
      "_method": 'put'
    });
  }

  @override
  Future<Response> remainDistance(String requestID) async {
    return await apiClient
        .postData(AppConstants.remainDistance, {"trip_request_id": requestID});
  }

  @override
  Future<Response> biddingList(String tripId, int offset) async {
    return await apiClient
        .getData('${AppConstants.biddingList}$tripId?limit=10&offset=$offset');
  }

  @override
  Future<Response> nearestDriverList(String lat, String lng) async {
    return await apiClient.getData(
        '${AppConstants.nearestDriverList}?latitude=$lat&longitude=$lng');
  }

  @override
  Future<Response> tripAcceptOrReject(
      String tripId, String type, String driverId) async {
    return await apiClient.postData(AppConstants.tripAcceptOrReject,
        {"trip_request_id": tripId, "action": type, "driver_id": driverId});
  }

  @override
  Future<Response> ignoreBidding(String biddingId) async {
    return await apiClient.postData(AppConstants.ignoreBidding,
        {"_method": 'put', "bidding_id": biddingId});
  }

  @override
  Future<Response> getCurrentRegularRide() async {
    return await apiClient.getData(AppConstants.currentRideStatus);
  }

  @override
  Future<Response> getFinalFare(String id) async {
    return await apiClient
        .getData('${AppConstants.finalFare}?trip_request_id=$id');
  }

  @override
  Future<Response> getDriverLocation(String tripId) async {
    return await apiClient
        .getData('${AppConstants.arrivalPickupPoint}=$tripId');
  }

  @override
  Future<Response> getRunningRideList() async {
    return await apiClient.getData(AppConstants.getRunningRideList);
  }

  @override
  Future<Response?> getDirection(
      {required LatLng pickupLatLng,
      required LatLng destinationLatLng,
      required LatLng extraOneLatLng,
      required LatLng extraTwoLatLng,
      required LatLng extraThreeLatLng}) async {
    return await apiClient.getData(
        '/api/get-direction?origin=${pickupLatLng.latitude}'
        ',${pickupLatLng.longitude}&destination=${destinationLatLng.latitude},${destinationLatLng.longitude}'
        '&waypoints=${extraOneLatLng.latitude},${extraOneLatLng.longitude}|${extraTwoLatLng.latitude},${extraTwoLatLng.longitude}|${extraThreeLatLng.latitude},${extraThreeLatLng.longitude}');
  }

  @override
  Future<Response> parcelReceived(String tripId) async {
    return await apiClient
        .postData(AppConstants.parcelReceived + tripId, {"_method": "put"});
  }

  @override
  Future updateScheduleTripTimeDate(String? tripId, String? scheduledAt) async {
    return await apiClient.putData('${AppConstants.updateScheduleTrip}$tripId',
        {"scheduled_at": scheduledAt});
  }

  @override
  Future<Response> getScheduledRides() async {
    return await apiClient.getData(
        '${AppConstants.scheduledRidesUri}/${Get.find<ProfileController>().profileModel?.data?.id}');
  }

  @override
  Future<Response> deleteScheduledRide(String rideId) async {
    return await apiClient
        .deleteData('${AppConstants.cancelScheduledRideUri}/$rideId');
  }

  @override
  Future<Response> deleteAllScheduledRides() async {
    return await apiClient
        .deleteData('${AppConstants.scheduledRidesUri}/delete-all');
  }

  @override
  Future<Response> cancelScheduledRide(String rideId) async {
    return await apiClient
        .postData('${AppConstants.scheduledRidesUri}/$rideId/cancel', {});
  }

  // ════════════════════════════════════════════════════════════════════════
  // updateTripRoute — CORRIGÉ
  //
  // Le backend valide intermediate_addresses / intermediate_coordinates avec
  // la règle Laravel "array", qui exige un VRAI tableau JSON dans la requête.
  // L'ancienne version faisait jsonEncode(...) sur ces listes avant de les
  // mettre dans `body`, ce qui produisait une CHAÎNE (ex: '["a","b"]') au
  // lieu d'un tableau une fois le body lui-même sérialisé en JSON. Laravel
  // recevait alors une string, la validation "array" échouait (403), et
  // EditableRouteInTripWidget affichait "Échec de la mise à jour du trajet".
  //
  // Correction : assigner directement les List/objets Dart au body, sans
  // jsonEncode manuel, pour que la sérialisation JSON globale produise de
  // vrais tableaux.
  // ════════════════════════════════════════════════════════════════════════
  @override
  Future<Response> updateTripRoute({
    required String tripId,
    required String destinationAddress,
    required String destinationLat,
    required String destinationLng,
    required String estimatedFare,
    required String encodedPolyline,
    required String intermediateCoordinates,
    required String middleAddressJson,

  required String estimatedDistance, // ← NOUVEAU
  required String estimatedDuration, // ← NOUVEAU

  }) async {
    // Décodage des chaînes JSON reçues en véritables structures Dart
    List<dynamic> intermediateCoordsList = [];
    List<String> intermediateAddressesList = [];

    try {
      if (intermediateCoordinates.isNotEmpty) {
        final decoded = jsonDecode(intermediateCoordinates);
        if (decoded is List) {
          intermediateCoordsList = decoded;
        }
      }

      if (middleAddressJson.isNotEmpty) {
        final decoded = jsonDecode(middleAddressJson);
        if (decoded is List) {
          intermediateAddressesList =
              decoded.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {
      // Si le parsing échoue, on n'envoie simplement pas ces champs.
    }

    Map<String, dynamic> body = {
      '_method': 'put',
      'destination_address': destinationAddress,
      'destination_coordinates': '[$destinationLat,$destinationLng]',
      'estimated_fare': estimatedFare,
      'encoded_polyline': encodedPolyline,
    };

    // ── intermediate_coordinates : VRAI tableau de paires [lat, lng] ──────
    if (intermediateCoordsList.isNotEmpty) {
      final List<List<dynamic>> coordsArray = intermediateCoordsList
          .whereType<List>()
          .where((coord) => coord.length == 2)
          .map((coord) => [coord[0], coord[1]])
          .toList();

      if (coordsArray.isNotEmpty) {
        body['intermediate_coordinates'] = coordsArray;
      }
    }

    // ── intermediate_addresses : VRAI tableau de chaînes ──────────────────
    if (intermediateAddressesList.isNotEmpty) {
      body['intermediate_addresses'] = intermediateAddressesList;
    }

     if (estimatedDistance.isNotEmpty) {
      body['estimated_distance'] = estimatedDistance;
    }

     if (estimatedDuration.isNotEmpty) {
      body['estimated_duration'] = estimatedDuration;
    }

    return await apiClient.postData(
      '${AppConstants.updateTripRoute}$tripId',
      body,
    );
  }

  // ========== MÉTHODES DE L'INTERFACE RepositoryInterface ==========

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(String id) {
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    throw UnimplementedError();
  }

  @override
  Future update(value, {int? id}) {
    throw UnimplementedError();
  }
}