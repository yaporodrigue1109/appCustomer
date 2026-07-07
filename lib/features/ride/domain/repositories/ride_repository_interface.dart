import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/interface/repository_interface.dart';

abstract class  RideRepositoryInterface implements RepositoryInterface{
  Future<dynamic> getEstimatedFare(
      {required LatLng pickupLatLng,
        required LatLng destinationLatLng,
        required LatLng currentLatLng,
        required String type,
        required String pickupAddress,
        required String destinationAddress,
        LatLng? extraOneLatLng = const LatLng(0, 0),
        LatLng? extraTwoLatLng = const LatLng(0, 0),
        LatLng? extraThreeLatLng = const LatLng(0, 0),
        bool extraOne = false, bool extraTwo = false,bool extraThree = false,
        String? parcelWeight,
        String? parcelCategoryId,
        String? rideRequestType,
        required String? scheduledAt,
      });


  Future<dynamic> submitRideRequest(
      {required String pickupLat,
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
        required bool bid,
        required String note,
        required String paymentMethod,
        required String type,
        required String pickupAddress,
        required String destinationAddress,
        required String encodedPolyline,
        required List<String> middleAddress,
        required String entrance,
        required double extraEstimatedFare,
        required double extraDiscountFare,
        required double extraDiscountAmount,
        required double extraReturnFee,
        required double extraCancellationFee,
        required double extraFareAmount,
        required double extraFareFee,
        required String? zoneId,
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

        // ✅ AJOUTER
      bool isRideForOther = false,
      String? beneficiaryName,
      String? beneficiaryPhone,
      });

  Future<dynamic> getRideDetails(String tripId);
  Future<dynamic> updateScheduleTripTimeDate(String? tripId, String? scheduledAt);
  Future<dynamic> tripStatusUpdate(String id, String status,String cancellationCause);
  Future<dynamic> remainDistance(String requestID);
  Future<dynamic> biddingList(String tripId, int offset);
  Future<dynamic> nearestDriverList(String  lat, String lng);
  Future<dynamic> tripAcceptOrReject(String tripId, String type, String driverId);
  Future<dynamic> ignoreBidding(String biddingId);
  Future<dynamic> getCurrentRegularRide();
  Future<dynamic> getRunningRideList();
  Future<dynamic> getFinalFare(String id);
  Future<dynamic> getDriverLocation(String tripId);
  //  Future<dynamic> getDirection({required LatLng pickupLatLng, required LatLng destinationLatLng, required LatLng extraOneLatLng, required LatLng extraTwoLatLng});
  Future<dynamic> getDirection({required LatLng pickupLatLng, required LatLng destinationLatLng, required LatLng extraOneLatLng, required LatLng extraTwoLatLng, required LatLng extraThreeLatLng});
  Future<dynamic> parcelReceived(String tripId);


    // NOUVELLES MÉTHODES
  Future<dynamic> getScheduledRides();
  Future<dynamic> deleteScheduledRide(String rideId);
  Future<dynamic> deleteAllScheduledRides(); // Optionnel
  Future<dynamic> cancelScheduledRide(String rideId); // Optionnel

// ════════════════════════════════════════════════════════════════════════════
// PATCH — ride_repository_interface.dart
// Ajouter UNE ligne à la fin de la liste des méthodes abstraites,
// juste avant la dernière accolade fermante.
// ════════════════════════════════════════════════════════════════════════════
//
// AVANT (fin du fichier) :
//
//   Future<dynamic> cancelScheduledRide(String rideId);
// }
//
// APRÈS :
//
//   Future<dynamic> cancelScheduledRide(String rideId);
//
//   /// Met à jour la destination/arrêts d'un trajet en cours
//   Future<dynamic> updateTripRoute({
//     required String tripId,
//     required String destinationAddress,
//     required String destinationLat,
//     required String destinationLng,
//     required String estimatedFare,
//     required String encodedPolyline,
//     required String intermediateCoordinates,
//     required String middleAddressJson,
//   });
// }
// ════════════════════════════════════════════════════════════════════════════

  /// Met à jour la destination et/ou les arrêts d'un trajet en cours.
  /// Appelé depuis [RideController.updateTripRoute].
  Future<dynamic> updateTripRoute({
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

  });
}