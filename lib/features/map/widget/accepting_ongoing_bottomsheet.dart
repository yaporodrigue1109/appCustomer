import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/common_widgets/swipable_button_widget/slider_button_widget.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_shimmer.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/widget/ride_cancelation_radio_button.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/route_widget.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/map/widget/editable_route_in_trip_widget.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/estimated_fare_and_distance.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/rider_details.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart'; 
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bottom sheet affichée pendant les états :
///  - "accepté, en route pour la prise en charge"   -> rideController.canCancelRide == true
///  - "course en cours"                              -> rideController.isRideStarted == true
///
/// Le bloc "Détails du trajet" (RouteWidget + tarif/paiement) et le bouton
/// "Modifier le trajet" sont affichés dans les DEUX états, pour une mise en
/// page identique. Le bouton "Partager mon trajet" (position en temps réel)
/// n'est lui affiché que lorsque la course est réellement démarrée.
class AcceptingAndOngoingBottomSheet extends StatefulWidget {
  final String firstRoute;
  final String secondRoute;
  final String thirdRoute;
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const AcceptingAndOngoingBottomSheet({
    super.key,
    required this.firstRoute,
    required this.secondRoute,
    required this.thirdRoute,
    required this.expandableKey,
  });

  @override
  State<AcceptingAndOngoingBottomSheet> createState() =>
      _AcceptingAndOngoingBottomSheetState();
}

class _AcceptingAndOngoingBottomSheetState
    extends State<AcceptingAndOngoingBottomSheet> {
  int currentState = 0;

  // ══════════════════════════════════════════════════════════════════
  // BOUTON PARTAGE DE POSITION (uniquement course démarrée)
  // ══════════════════════════════════════════════════════════════════

  Widget _buildSharePositionButton(RideController rideController) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showShareOptions(rideController),
        icon: const Icon(Icons.share_location_rounded, size: 20),
        label: Text(
          'share_smy_ride'.tr,
          style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
            horizontal: Dimensions.paddingSizeDefault,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // INFORMATIONS DU TRAJET POUR LE PARTAGE
  // ══════════════════════════════════════════════════════════════════

  Future<Map<String, String>> _getTripInformation(
      RideController rideController) async {
    double? currentLat;
    double? currentLng;

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        final LocationPermission permission =
            await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          currentLat = position.latitude;
          currentLng = position.longitude;
        }
      }
    } catch (_) {}

    final String googleMapsLink = currentLat != null && currentLng != null
        ? 'https://www.google.com/maps?q=$currentLat,$currentLng'
        : 'Position non disponible';

    final String driverFirstName =
        rideController.tripDetails?.driver?.firstName ?? '';
    final String driverLastName =
        rideController.tripDetails?.driver?.lastName ?? '';
    final String driverName =
        driverFirstName.isNotEmpty || driverLastName.isNotEmpty
            ? '$driverFirstName $driverLastName'.trim()
            : 'Non disponible';

    final String driverPhone = rideController.tripDetails?.driver?.phone ?? '';
    final String vehicleModel =
        rideController.tripDetails?.vehicle?.model?.engine ??
            'Non disponible';
    final String nameModel =
        rideController.tripDetails?.vehicle?.model?.name ?? 'Non disponible';
    final String vehicleBrand =
        rideController.tripDetails?.vehicle?.licencePlateNumber ??
            'Non disponible';
    final String identificationType =
        rideController.tripDetails?.driver?.vehicle?.vinNumber ??
            'Non disponible';
    final String identificationNumber =
        rideController.tripDetails?.driver?.identificationNumber ??
            'Non disponible';
    final String tripId = rideController.tripDetails?.refId ?? 'N/A';
    final String pickupAddress =
        rideController.tripDetails?.pickupAddress ?? 'Non disponible';
    final String destinationAddress =
        rideController.tripDetails?.destinationAddress ?? 'Non disponible';
    final String estimatedDistance = rideController.estimatedDistance ?? '0 km';
    final String estimatedDuration = rideController.estimatedDuration ?? '0 min';
    final String estimatedFare = PriceConverter.convertPrice(
      ((rideController.tripDetails?.discountAmount ?? 0) > 0)
          ? rideController.tripDetails?.discountActualFare ?? 0
          : rideController.tripDetails?.actualFare ?? 0,
    );

    String tripStatus = '';
    switch (rideController.currentRideState) {
      case RideState.outForPickup:
        tripStatus = '🚗 Le chauffeur arrive';
        break;
      case RideState.arrived:
        tripStatus = '🚗 Le chauffeur est arrivé';
        break;
      case RideState.ongoingRide:
        tripStatus = '🔄 Trajet en cours';
        break;
      case RideState.otpSent:
        tripStatus = '🔐 OTP envoyé';
        break;
      default:
        tripStatus = '📋 Trajet en cours';
    }

    return {
      'currentLat': currentLat?.toString() ?? '',
      'currentLng': currentLng?.toString() ?? '',
      'googleMapsLink': googleMapsLink,
      'currentAddress':
          'Cliquez sur le lien GPS ci-dessous pour voir ma position exacte',
      'driverName': driverName,
      'driverFirstName': driverFirstName,
      'driverLastName': driverLastName,
      'nameModel': nameModel,
      'driverPhone': driverPhone,
      'vehicleModel': vehicleModel,
      'vehicleBrand': vehicleBrand,
      'identificationType': identificationType,
      'identificationNumber': identificationNumber,
      'tripId': tripId,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'estimatedDistance': estimatedDistance,
      'estimatedDuration': estimatedDuration,
      'estimatedFare': estimatedFare,
      'tripStatus': tripStatus,
    };
  }

  String _generateShareMessage(Map<String, String> tripInfo) {
    final DateTime now = DateTime.now();
    final String formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final String formattedDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return '''
🚖 *PARTAGE DE MON TRAJET* 🚖

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 *MA POSITION ACTUELLE*
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 ${tripInfo['currentAddress']}
🗺️ Lien GPS: ${tripInfo['googleMapsLink']}
⏰ Heure: $formattedTime - $formattedDate

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👨‍✈️ *INFORMATIONS CHAUFFEUR*
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👤 Nom: ${tripInfo['driverName']}
📞 Téléphone: ${tripInfo['driverPhone']}
🔢 Numero Pièce: ${tripInfo['identificationNumber']}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚗 *INFORMATIONS VÉHICULE*
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏭 Marque: ${tripInfo['nameModel']}
🔢 Immatriculation: ${tripInfo['vehicleBrand']}
📐 Modèle: ${tripInfo['vehicleModel']}
🎨 Numéro vignette: ${tripInfo['identificationType']}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 *DÉTAILS DU TRAJET*
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🆔 Référence: ${tripInfo['tripId']}
📍 Départ: ${tripInfo['pickupAddress']}
🏁 Destination: ${tripInfo['destinationAddress']}
📏 Distance: ${tripInfo['estimatedDistance']}
⏱️ Durée estimée: ${tripInfo['estimatedDuration']}
💰 Prix: ${tripInfo['estimatedFare']}
📊 Statut: ${tripInfo['tripStatus']}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔒 *Partagez ce message avec vos proches pour plus de sécurité*
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
  }

  void _showShareOptions(RideController rideController) async {
    final tripInfo = await _getTripInformation(rideController);
    final shareMessage = _generateShareMessage(tripInfo);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.paddingSizeDefault),
        ),
      ),
      builder: (context) => _ShareOptionsSheet(
        shareMessage: shareMessage,
        driverPhone: tripInfo['driverPhone'] ?? '',
        googleMapsLink: tripInfo['googleMapsLink'] ?? '',
        tripInfo: tripInfo,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        // ── État 0 : Vue principale ────────────────────────────────
        if (currentState == 0) {
          return rideController.tripDetails != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    const EstimatedFareAndDistance(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    const ActivityScreenRiderDetails(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // ── Bloc "Détails du trajet" : identique que la
                    //    course soit seulement acceptée ou déjà démarrée ──
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Text(
                        'trip_details'.tr,
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),

                    if (rideController.tripDetails != null)
                      RouteWidget(
                        totalDistance: rideController.estimatedDistance,
                        fromAddress:
                            rideController.tripDetails?.pickupAddress ?? '',
                        toAddress:
                            rideController.tripDetails?.destinationAddress ??
                                '',
                        extraOneAddress: widget.firstRoute,
                        extraTwoAddress: widget.secondRoute,
                        extraThreeAddress: widget.thirdRoute,
                        entrance: rideController.tripDetails?.entrance ?? '',
                      ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // ── Section des prix (identique elle aussi) ──────
                    // Container(
                    //   decoration: BoxDecoration(
                    //     borderRadius:
                    //         BorderRadius.circular(Dimensions.radiusLarge),
                    //     color:
                    //         Theme.of(context).hintColor.withValues(alpha: 0.1),
                    //   ),
                    //   padding:
                    //       const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    //   child: Column(children: [
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Row(children: [
                    //           Image.asset(
                    //             Images.farePrice,
                    //             height: 15,
                    //             width: 15,
                    //             color: Theme.of(context)
                    //                 .textTheme
                    //                 .bodyMedium
                    //                 ?.color,
                    //           ),
                    //           const SizedBox(width: Dimensions.paddingSizeSmall),
                    //           Text(
                    //             'fare_fee'.tr,
                    //             style: textRegular.copyWith(
                    //               color: Theme.of(context)
                    //                   .textTheme
                    //                   .bodyMedium
                    //                   ?.color,
                    //               fontSize: Dimensions.fontSizeDefault,
                    //             ),
                    //           ),
                    //         ]),
                    //         Container(
                    //           decoration: BoxDecoration(
                    //             borderRadius:
                    //                 BorderRadius.circular(Dimensions.radiusSmall),
                    //             color: Theme.of(context)
                    //                 .primaryColor
                    //                 .withValues(alpha: 0.2),
                    //           ),
                    //           padding: const EdgeInsets.symmetric(
                    //             horizontal: Dimensions.paddingSizeSmall,
                    //             vertical: Dimensions.paddingSizeExtraSmall,
                    //           ),
                    //           child: Text(
                    //             PriceConverter.convertPrice(
                    //               ((rideController.tripDetails
                    //                               ?.discountAmount ??
                    //                           0) >
                    //                       0)
                    //                   ? rideController
                    //                           .tripDetails?.discountActualFare ??
                    //                       0
                    //                   : rideController.tripDetails?.actualFare ??
                    //                       0,
                    //             ),
                    //             style: textRobotoBold.copyWith(
                    //               fontSize: Dimensions.fontSizeSmall,
                    //               color: Theme.of(context)
                    //                   .textTheme
                    //                   .bodyMedium
                    //                   ?.color,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     const SizedBox(height: Dimensions.paddingSizeSmall),

                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Expanded(
                    //           child: Row(children: [
                    //             Image.asset(
                    //               Images.paymentTypeIcon,
                    //               height: 15,
                    //               width: 15,
                    //               color: Theme.of(context)
                    //                   .textTheme
                    //                   .bodyMedium
                    //                   ?.color,
                    //             ),
                    //             const SizedBox(
                    //                 width: Dimensions.paddingSizeSmall),
                    //             Text(
                    //               'payment'.tr,
                    //               style: textRegular.copyWith(
                    //                 color: Theme.of(context)
                    //                     .textTheme
                    //                     .bodyMedium
                    //                     ?.color,
                    //                 fontSize: Dimensions.fontSizeDefault,
                    //               ),
                    //             ),
                    //           ]),
                    //         ),
                    //         Text(
                    //           rideController.tripDetails?.paymentMethod
                    //                   ?.replaceAll(RegExp('[\\W_]+'), ' ')
                    //                   .capitalize ??
                    //               'cash'.tr,
                    //           style:
                    //               TextStyle(color: Theme.of(context).primaryColor),
                    //         ),
                    //       ],
                    //     ),
                    //   ]),
                    // ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // ── Bouton "Annuler la course" : uniquement avant
                    //    le démarrage (état "accepté") ───────────────
                    if (rideController.canCancelRide &&
                        rideController.tripDetails != null &&
                        rideController.tripDetails!.type !=
                            AppConstants.parcel &&
                        !rideController.tripDetails!.isPaused!)
                      Center(
                        child: SliderButton(
                          action: () {
                            currentState = 1;
                            widget.expandableKey.currentState?.expand();
                            setState(() {});
                          },
                          label: Text(
                            'cancel_ride'.tr,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                          dismissThresholds: 0.5,
                          dismissible: false,
                          shimmer: false,
                          width: 1170,
                          height: 40,
                          buttonSize: 40,
                          radius: 20,
                          icon: Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).cardColor,
                              ),
                              child: Center(
                                child: Icon(
                                  Get.find<LocalizationController>().isLtr
                                      ? Icons.arrow_forward_ios_rounded
                                      : Icons.keyboard_arrow_left,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                          isLtr: Get.find<LocalizationController>().isLtr,
                          boxShadow: const BoxShadow(blurRadius: 0),
                          buttonColor: Colors.transparent,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .error
                              .withValues(alpha: 0.15),
                          baseColor: Theme.of(context).colorScheme.error,
                        ),
                      ),

                    // ── Bouton "Modifier le trajet" : visible dès
                    //    l'acceptation ET pendant la course ────────────
                    if ((rideController.canCancelRide ||
                            rideController.isRideStarted) &&
                        rideController.tripDetails != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => DraggableScrollableSheet(
                                  initialChildSize: 0.7,
                                  minChildSize: 0.4,
                                  maxChildSize: 0.95,
                                  expand: false,
                                  builder: (_, scrollCtrl) => Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeDefault),
                                    child: Column(children: [
                                      Center(
                                        child: Container(
                                          width: 40,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          height: Dimensions.paddingSizeSmall),
                                      Row(children: [
                                        Icon(Icons.edit_road,
                                            color:
                                                Theme.of(context).primaryColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Modifier le trajet',
                                          style: textSemiBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () => Get.back(),
                                          icon: const Icon(Icons.close),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ]),
                                      const SizedBox(
                                          height: Dimensions.paddingSizeDefault),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          controller: scrollCtrl,
                                          child: EditableRouteInTripWidget(
                                            firstRoute: widget.firstRoute,
                                            secondRoute: widget.secondRoute,
                                            thirdRoute: widget.thirdRoute,
                                            onRouteChanged: () {
                                              Get.find<MapController>()
                                                  .notifyMapController();
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.edit_road,
                                color: Theme.of(context).primaryColor, size: 18),
                            label: Text(
                              'Modifier le trajet',
                              style: textMedium.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeSmall),
                            ),
                            style: OutlinedButton.styleFrom(
                              side:
                                  BorderSide(color: Theme.of(context).primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeSmall),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeSmall),
                            ),
                          ),
                        ),
                      ),

                    // ── Bouton "Partager mon trajet" : uniquement
                    //    quand la course est réellement démarrée ──────
                    if (!rideController.canCancelRide &&
                        rideController.isRideStarted &&
                        rideController.tripDetails != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault),
                        child: Column(children: [
                          _buildSharePositionButton(rideController),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Container(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeSmall),
                            ),
                            child: Row(children: [
                              const Icon(Icons.security,
                                  color: Colors.green, size: 16),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Expanded(
                                child: Text(
                                  'Partagez votre trajet avec vos proches pour plus de sécurité'
                                      .tr,
                                  style: textRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ]),
                      ),
                  ],
                )
              : const Column(children: [
                  BannerShimmer(),
                  BannerShimmer(),
                  BannerShimmer(),
                ]);
        }

        // ── État 1 : Raison d'annulation ───────────────────────────
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text(
              rideController.currentRideState == RideState.outForPickup
                  ? 'rider_is_coming'.tr
                  : 'trip_is_ongoing'.tr,
              style: textSemiBold.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            CancellationRadioButton(
              isOngoing:
                  rideController.currentRideState == RideState.outForPickup
                      ? false
                      : true,
              expandableKey: widget.expandableKey,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Row(children: [
              Expanded(
                child: ButtonWidget(
                  buttonText: 'no_continue_trip'.tr,
                  showBorder: true,
                  transparent: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  borderColor: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).cardColor,
                  radius: Dimensions.paddingSizeSmall,
                  onPressed: () {
                    currentState = 0;
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: ButtonWidget(
                  buttonText: 'submit'.tr,
                  showBorder: true,
                  transparent: true,
                  textColor: Get.isDarkMode ? Colors.white : Colors.black,
                  borderColor: Theme.of(context).hintColor,
                  radius: Dimensions.paddingSizeSmall,
                  onPressed: () {
                    if (rideController.currentRideState ==
                        RideState.outForPickup) {
                      Get.find<RideController>().stopLocationRecord();
                      rideController
                          .tripStatusUpdate(
                        rideController.tripDetails!.id!,
                        'cancelled',
                        'ride_request_cancelled_successfully',
                        (Get.find<TripController>()
                                        .rideCancellationReasonList!
                                        .data!
                                        .acceptedRide!
                                        .length -
                                    1) ==
                                Get.find<TripController>()
                                    .rideCancellationCauseCurrentIndex
                            ? Get.find<TripController>()
                                .othersCancellationController
                                .text
                            : Get.find<TripController>()
                                    .rideCancellationReasonList!
                                    .data!
                                    .acceptedRide![
                                Get.find<TripController>()
                                    .rideCancellationCauseCurrentIndex],
                      )
                          .then((value) {
                        if (value.statusCode == 200) {
                          Get.find<MapController>().notifyMapController();
                          Get.find<BottomMenuController>()
                              .navigateToDashboard();
                        }
                      });
                    } else {
                      rideController
                          .tripStatusUpdate(
                        rideController.tripDetails!.id!,
                        'cancelled',
                        'ride_request_cancelled_successfully',
                        (Get.find<TripController>()
                                        .rideCancellationReasonList!
                                        .data!
                                        .ongoingRide!
                                        .length -
                                    1) ==
                                Get.find<TripController>()
                                    .rideCancellationCauseCurrentIndex
                            ? Get.find<TripController>()
                                .othersCancellationController
                                .text
                            : Get.find<TripController>()
                                    .rideCancellationReasonList!
                                    .data!
                                    .ongoingRide![
                                Get.find<TripController>()
                                    .rideCancellationCauseCurrentIndex],
                        afterAccept: true,
                      )
                          .then((value) async {
                        if (value.statusCode == 200) {
                          Get.find<RideController>().stopLocationRecord();
                          rideController
                              .getFinalFare(rideController.tripDetails!.id!)
                              .then((value) {
                            if (value.statusCode == 200) {
                              Get.find<RideController>().updateRideCurrentState(
                                  RideState.completeRide);
                              Get.find<MapController>().notifyMapController();
                              Get.off(() => const PaymentScreen());
                            }
                          });
                        }
                      });
                    }
                  },
                ),
              ),
            ]),
          ],
        );
      });
    });
  }
}

// ══════════════════════════════════════════════════════════════════════
// WIDGET OPTIONS DE PARTAGE
// ══════════════════════════════════════════════════════════════════════

class _ShareOptionsSheet extends StatelessWidget {
  final String shareMessage;
  final String driverPhone;
  final String googleMapsLink;
  final Map<String, String> tripInfo;

  const _ShareOptionsSheet({
    required this.shareMessage,
    required this.driverPhone,
    required this.googleMapsLink,
    required this.tripInfo,
  });

  Future<void> _shareViaSMS() async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: '',
      queryParameters: {'body': shareMessage},
    );
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        _copyToClipboard();
      }
    } catch (e) {
      _copyToClipboard();
    }
  }

  Future<void> _shareViaWhatsApp() async {
    final String encodedMessage = Uri.encodeComponent(shareMessage);
    final Uri whatsappUri = Uri.parse('whatsapp://send?text=$encodedMessage');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        _showWhatsAppNotInstalledDialog();
      }
    } catch (e) {
      _showWhatsAppNotInstalledDialog();
    }
  }

  Future<void> _shareViaSystemShare() async {
    final String subject = '🚖 Partage de mon trajet - ${tripInfo['tripId']}';
    final Uri shareUri = Uri.parse(
      'mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(shareMessage)}',
    );
    try {
      if (await canLaunchUrl(shareUri)) {
        await launchUrl(shareUri);
      } else {
        _copyToClipboard();
      }
    } catch (e) {
      _copyToClipboard();
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: shareMessage));
    Get.back();
    Get.snackbar(
      'Copié !'.tr,
      'Message copié dans le presse-papier'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showWhatsAppNotInstalledDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('WhatsApp non installé'.tr),
        content: Text(
            'WhatsApp n\'est pas installé. Souhaitez-vous copier le message ?'
                .tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Annuler'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              _copyToClipboard();
            },
            child: Text('Copier'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
        top: Dimensions.paddingSizeDefault,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            Dimensions.paddingSizeLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(children: [
            Icon(Icons.share_rounded,
                color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              'share_smy_ride'.tr,
              style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            'Choisissez comment partager les informations de votre trajet'.tr,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: SingleChildScrollView(
              child: Text(
                shareMessage,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Text(
            'Partager via :'.tr,
            style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(children: [
            Expanded(
              child: _buildShareOption(
                icon: Icons.chat,
                label: 'WhatsApp',
                color: Colors.green,
                onTap: _shareViaWhatsApp,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: _buildShareOption(
                icon: Icons.sms,
                label: 'SMS',
                color: Colors.blue,
                onTap: _shareViaSMS,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: _buildShareOption(
                icon: Icons.copy,
                label: 'Copier',
                color: Colors.grey,
                onTap: _copyToClipboard,
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          OutlinedButton.icon(
            onPressed: _shareViaSystemShare,
            icon: const Icon(Icons.more_horiz, size: 18),
            label: Text('Plus d\'options'.tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              side: BorderSide(color: Theme.of(context).primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(Dimensions.paddingSizeSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            label,
            style: textMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: color,
            ),
          ),
        ]),
      ),
    );
  }
}