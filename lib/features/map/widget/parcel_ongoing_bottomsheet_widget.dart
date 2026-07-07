import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/common_widgets/swipable_button_widget/slider_button_widget.dart';
import 'package:ride_sharing_user_app/features/map/widget/parcel_cancelation_list.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/route_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/tolltip_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/estimated_fare_and_distance.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/rider_details.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/map/widget/editable_route_in_trip_widget.dart';
  import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';

class ParcelOngoingBottomSheetWidget extends StatefulWidget {
  final GlobalKey<ExpandableBottomSheetState> expandableKey;
  const ParcelOngoingBottomSheetWidget({super.key, required this.expandableKey});

  @override
  State<ParcelOngoingBottomSheetWidget> createState() =>
      _ParcelOngoingBottomSheetWidgetState();
}

class _ParcelOngoingBottomSheetWidgetState
    extends State<ParcelOngoingBottomSheetWidget> {
  int currentState = 0;

  // ── Partage de position ───────────────────────────────────────────────────

  Widget _buildSharePositionButton(RideController rideController) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _sharePosition(rideController: rideController),
        icon: const Icon(Icons.share_location_rounded, size: 20),
        label: Text(
          'share_my_position'.tr,
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

  Future<void> _sharePosition({required RideController rideController}) async {
    double? currentLat;
    double? currentLng;

    try {
      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();
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

    if (currentLat == null || currentLng == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('position_not_available'.tr),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final String tripRef = rideController.tripDetails?.refId ?? '';
    final String googleMapsLink =
        'https://www.google.com/maps?q=$currentLat,$currentLng';
    final String shareText = tripRef.isNotEmpty
        ? '${'my_current_position'.tr} (${'trip'.tr} #$tripRef) : $googleMapsLink'
        : '${'my_current_position'.tr} : $googleMapsLink';

    await Clipboard.setData(ClipboardData(text: shareText));

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
      builder: (_) => _SharePositionSheet(
        shareText: shareText,
        googleMapsLink: googleMapsLink,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParcelController>(builder: (parcelController) {
      return GetBuilder<RideController>(builder: (rideController) {

        // ── État 0 : vue principale (course en cours) ──────────────────────
        if (currentState == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TollTipWidget(
                title:
                    '${'drop_off'.tr} ${DateConverter.dateToTimeOnly(DateTime.now().add(Duration(seconds: rideController.remainingDistanceModel.isNotEmpty ? (rideController.remainingDistanceModel[0].durationSec ?? 0) : 0)))}',
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              const EstimatedFareAndDistance(isParcel: true),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              const ActivityScreenRiderDetails(),
              // Padding(
              //   padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              //   child: Text(
              //     'trip_details'.tr,
              //     style: textBold.copyWith(
              //       fontSize: Dimensions.fontSizeDefault,
              //       color: Theme.of(context).primaryColor,
              //     ),
              //   ),
              // ),

              // if (rideController.tripDetails != null)
              //   RouteWidget(
              //     totalDistance: rideController.estimatedDistance,
              //     fromAddress:
              //         rideController.tripDetails?.pickupAddress ?? '',
              //     toAddress:
              //         rideController.tripDetails?.destinationAddress ?? '',
              //     extraOneAddress: '',
              //     extraTwoAddress: '',
              //     extraThreeAddress: '',
              //     entrance: rideController.tripDetails?.entrance ?? '',
              //   ),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault,
                        top: Dimensions.paddingSizeDefault,
                        bottom: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'trip_details'.tr,
                            style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          // Indicateur visuel « modifiable »
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.edit_location_alt_outlined,
                                  size: 12, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                'modifiable'.tr,
                                style: textRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    
                    // Widget éditable — remplace RouteWidget
                    if (rideController.tripDetails != null)
                      EditableRouteInTripWidget(
                        onRouteChanged: () {
                        
                          // Optionnel : notifier la carte ou recalculer
                          Get.find<MapController>().notifyMapController();
                        },
                      ),


              const SizedBox(height: Dimensions.paddingSizeDefault),

              // ── Bouton "Partager ma position" (course démarrée = ongoing) ──
              _buildSharePositionButton(rideController),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              // ── Bouton "Annuler" en dessous, secondaire ────────────────────
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    currentState = 1;
                    widget.expandableKey.currentState?.expand();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: Theme.of(context).colorScheme.error,
                    size: 16,
                  ),
                  label: Text(
                    'cancel_parcel'.tr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // ── État 1 : sélection raison d'annulation ─────────────────────────
        if (currentState == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => setState(() => currentState = 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.only(
                    left: Dimensions.paddingSizeDefault,
                    right: Dimensions.paddingSizeDefault,
                    bottom: Dimensions.paddingSizeSmall,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Icon(Icons.arrow_back_rounded, size: 18),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault),
                child: Text(
                  Get.find<TripController>()
                              .parcelCancellationReasonList!
                              .data!
                              .ongoingRide!
                              .length >
                          1
                      ? 'please_select_your_cancel_reason'.tr
                      : 'please_write_your_cancel_reason'.tr,
                  style:
                      textBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              ParcelCancellationList(
                isOngoing: true,
                expandableKey: widget.expandableKey,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              ButtonWidget(
                buttonText: 'next'.tr,
                showBorder: true,
                transparent: true,
                backgroundColor: Theme.of(context).primaryColor,
                borderColor: Theme.of(context).primaryColor,
                textColor: Theme.of(context).cardColor,
                radius: 50,
                onPressed: () {
                  currentState = 2;
                  setState(() {});
                  widget.expandableKey.currentState?.expand(duration: 1000);
                },
              ),
            ],
          );
        }

        // ── État 2 : politique de frais de retour ──────────────────────────
        return Column(children: [
          Text(
            'return_fee_policy'.tr,
            style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeThree),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault),
            child: Text(
              'if_you_cancel_your_parcel_will_back'.tr,
              style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            PriceConverter.convertPrice(
                rideController.tripDetails?.returnFee ?? 0),
            style: textRobotoBold.copyWith(fontSize: 20),
          ),
          const SizedBox(height: Dimensions.paddingSizeThree),

          Text(
            'return_fee'.tr,
            style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          ButtonWidget(
            buttonText: 'continue_delivery'.tr,
            showBorder: true,
            transparent: true,
            width: Get.width * 0.7,
            backgroundColor: Theme.of(context).primaryColor,
            borderColor: Theme.of(context).primaryColor,
            textColor: Theme.of(context).cardColor,
            radius: Dimensions.paddingSizeSmall,
            onPressed: () => setState(() => currentState = 0),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          ButtonWidget(
            buttonText: 'yes_cancel'.tr,
            showBorder: true,
            transparent: true,
            width: Get.width * 0.7,
            textColor: Get.isDarkMode ? Colors.white : Colors.black,
            borderColor: Theme.of(context).primaryColor,
            radius: Dimensions.paddingSizeSmall,
            onPressed: () {
              Get.find<RideController>().stopLocationRecord();
              final TripController tripController =
                  Get.find<TripController>();
              final List reasons = tripController
                  .parcelCancellationReasonList!.data!.ongoingRide!;
              final int currentIndex =
                  tripController.parcelCancellationCauseCurrentIndex;
              final String reason =
                  (reasons.length - 1) == currentIndex
                      ? tripController.othersCancellationController.text
                      : reasons[currentIndex];

              rideController
                  .tripStatusUpdate(
                    rideController.tripDetails!.id!,
                    'cancelled',
                    'parcel_request_cancelled_successfully',
                    reason,
                    afterAccept: true,
                  )
                  .then((_) {
                if (rideController.tripDetails?.parcelInformation?.payer ==
                    'receiver') {
                  rideController
                      .getFinalFare(rideController.tripDetails!.id!);
                }
                Get.offAll(() => TripDetailsScreen(
                    tripId: rideController.tripDetails!.id!));
              });
            },
          ),
        ]);
      });
    });
  }
}

// ─── Bottom sheet de partage de position ──────────────────────────────────────

class _SharePositionSheet extends StatelessWidget {
  final String shareText;
  final String googleMapsLink;

  const _SharePositionSheet({
    required this.shareText,
    required this.googleMapsLink,
  });

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
            Icon(Icons.share_location_rounded,
                color: Theme.of(context).primaryColor, size: 22),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              'share_my_position'.tr,
              style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            'position_copied_to_clipboard'.tr,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(Dimensions.paddingSizeSmall),
            ),
            child: Text(
              shareText,
              style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: shareText));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('copied'.tr),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 16),
                label: Text('copy_link'.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.paddingSizeSmall),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.check, size: 16),
                label: Text('close'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.paddingSizeSmall),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}