// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';
// import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
// import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dart';
// import 'package:ride_sharing_user_app/common_widgets/swipable_button_widget/slider_button_widget.dart';
// import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
// import 'package:ride_sharing_user_app/features/home/widgets/banner_shimmer.dart';
// import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
// import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
// import 'package:ride_sharing_user_app/features/map/widget/ride_cancelation_radio_button.dart';
// import 'package:ride_sharing_user_app/features/parcel/widgets/otp_widget.dart';
// import 'package:ride_sharing_user_app/features/parcel/widgets/route_widget.dart';
// import 'package:ride_sharing_user_app/features/parcel/widgets/tolltip_widget.dart';
// import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
// import 'package:ride_sharing_user_app/features/ride/widgets/estimated_fare_and_distance.dart';
// import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
// import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
// import 'package:ride_sharing_user_app/features/trip/widgets/rider_details.dart';
// import 'package:ride_sharing_user_app/localization/localization_controller.dart';
// import 'package:ride_sharing_user_app/util/dimensions.dart';
// import 'package:ride_sharing_user_app/util/styles.dart';
// import 'package:ride_sharing_user_app/features/map/widget/editable_route_in_trip_widget.dart';


// class OtpSentBottomSheet extends StatefulWidget {
//   final String firstRoute;
//   final String secondRoute;
//   final String thirdRoute;
//   final GlobalKey<ExpandableBottomSheetState> expandableKey;

//   const OtpSentBottomSheet({super.key,required this.firstRoute,required this.secondRoute,required this.thirdRoute,required this.expandableKey});

//   @override
//   State<OtpSentBottomSheet> createState() => _OtpSentBottomSheetState();
// }

// class _OtpSentBottomSheetState extends State<OtpSentBottomSheet> {
//   int currentState = 0;
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<RideController>(builder: (rideController){
//       return GetBuilder<LocationController>(builder: (locationController){
//         return currentState == 0 ? rideController.tripDetails != null ?
//         Column(children: [
//           TollTipWidget(title: '${ (rideController.remainingDistanceModel.isNotEmpty) ?  (rideController.remainingDistanceModel[0].duration)?? '0' : '0'} ${'away'.tr}'),
//           const SizedBox(height: Dimensions.paddingSizeDefault),

//           if(Get.find<ConfigController>().config?.otpConfirmationForTrip ?? false)
//           const OtpWidget(isParcel: true),

//           const ActivityScreenRiderDetails(),
//           const SizedBox(height: Dimensions.paddingSizeDefault),

//           const EstimatedFareAndDistance(),
//           const SizedBox(height: Dimensions.paddingSizeDefault),

//           // RouteWidget(totalDistance: rideController.tripDetails?.estimatedDistance.toString() ?? '',
//           //     fromAddress: rideController.tripDetails?.pickupAddress??"",
//           //     toAddress: rideController.tripDetails?.destinationAddress??'',
//           //     extraOneAddress: widget.firstRoute,
//           //     extraTwoAddress: widget.secondRoute,
//           //     extraThreeAddress: widget.thirdRoute,
//           //     entrance:  rideController.tripDetails?.entrance??''),
      
//             EditableRouteInTripWidget(
//     onRouteChanged: () => Get.find<MapController>().notifyMapController(),
//   ),
//           const SizedBox(height: Dimensions.paddingSizeDefault), 


//           Center(
//             child:SliderButton(
//               action: (){
//                 currentState = 1;
//                 widget.expandableKey.currentState?.expand();
//                 setState(() {});
//               },
//               label: Text('cancel_ride'.tr,style: TextStyle(color: Theme.of(context).colorScheme.error,fontSize: Dimensions.fontSizeLarge)),
//               dismissThresholds: 0.5, dismissible: false, shimmer: false,
//               width: 1170, height: 40, buttonSize: 40, radius: 20,
//               icon: Center(child: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor),
//                 child: Center(
//                   child: Icon(
//                     Get.find<LocalizationController>().isLtr ? Icons.arrow_forward_ios_rounded : Icons.keyboard_arrow_left,
//                     color: Theme.of(context).colorScheme.error, size: 20.0,
//                   ),
//                 ),
//               )),
//               isLtr: Get.find<LocalizationController>().isLtr,
//               boxShadow: const BoxShadow(blurRadius: 0),
//               buttonColor: Colors.transparent,
//               backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha:0.15),
//               baseColor: Theme.of(context).primaryColor,
//             ),
//           ),

//         ]) :
//         const Column(children: [BannerShimmer(), BannerShimmer()]) :
//         Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const SizedBox(height: Dimensions.paddingSizeSmall,),
//           Text('rider_arrived'.tr,style: textSemiBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),),

//           const SizedBox(height: Dimensions.paddingSizeSmall,),

//           CancellationRadioButton(isOngoing: false,expandableKey: widget.expandableKey),

//           const SizedBox(height: Dimensions.paddingSizeLarge),
//           rideController.isLoading ?
//           SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0) :
//           Row(children: [
//             Expanded(child: ButtonWidget(buttonText: 'no_continue_trip'.tr,
//                 showBorder: true,
//                 transparent: true,
//                 backgroundColor: Theme.of(context).primaryColor,
//                 borderColor: Theme.of(context).primaryColor,
//                 textColor: Theme.of(context).cardColor,
//                 radius: Dimensions.paddingSizeSmall,
//                 onPressed: (){
//                   currentState = 0;
//                   setState(() {});
//                 })),

//             const SizedBox(width: Dimensions.paddingSizeSmall,),
//             Expanded(child: ButtonWidget(buttonText: 'submit'.tr,
//                 showBorder: true,
//                 transparent: true,
//                 textColor: Get.isDarkMode ? Colors.white : Colors.black,
//                 borderColor: Theme.of(context).hintColor,
//                 radius: Dimensions.paddingSizeSmall,
//                 onPressed: (){
//                   Get.find<RideController>().stopLocationRecord();
//                   rideController.tripStatusUpdate(rideController.tripDetails!.id!, 'cancelled', 'ride_request_cancelled_successfully',
//                       (Get.find<TripController>().rideCancellationReasonList!.data!.acceptedRide!.length - 1) == Get.find<TripController>().rideCancellationCauseCurrentIndex ?
//                       Get.find<TripController>().othersCancellationController.text :
//                       Get.find<TripController>().rideCancellationReasonList!.data!.acceptedRide![Get.find<TripController>().rideCancellationCauseCurrentIndex]
//                   ).then((value){
//                     if(value.statusCode == 200){
//                       Get.find<MapController>().notifyMapController();
//                       Get.find<BottomMenuController>().navigateToDashboard();
//                     }
//                   });

//                 },
//             )),
//           ])
//         ],);
//       });
//     });
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/common_widgets/swipable_button_widget/slider_button_widget.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_shimmer.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/widget/ride_cancelation_radio_button.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/otp_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/route_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/tolltip_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/estimated_fare_and_distance.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/rider_details.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/map/widget/editable_route_in_trip_widget.dart';


class OtpSentBottomSheet extends StatefulWidget {
  final String firstRoute;
  final String secondRoute;
  final String thirdRoute;
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const OtpSentBottomSheet({super.key,required this.firstRoute,required this.secondRoute,required this.thirdRoute,required this.expandableKey});

  @override
  State<OtpSentBottomSheet> createState() => _OtpSentBottomSheetState();
}

class _OtpSentBottomSheetState extends State<OtpSentBottomSheet> {
  int currentState = 0;

  // ── Ouvre la modification du trajet dans une modale, comme sur l'écran
  //    "course en cours", au lieu de l'afficher en permanence à l'écran ──
  void _openEditRouteSheet() {
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(children: [
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
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(children: [
              Icon(Icons.edit_road, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text('Modifier le trajet',
                  style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const Spacer(),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                child: EditableRouteInTripWidget(
                  firstRoute: widget.firstRoute,
                  secondRoute: widget.secondRoute,
                  thirdRoute: widget.thirdRoute,
                  onRouteChanged: () {
                    Get.find<MapController>().notifyMapController();
                    setState(() {});
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController){
      return GetBuilder<LocationController>(builder: (locationController){
        return currentState == 0 ? rideController.tripDetails != null ?
        Column(children: [
          TollTipWidget(title: '${ (rideController.remainingDistanceModel.isNotEmpty) ?  (rideController.remainingDistanceModel[0].duration)?? '0' : '0'} ${'away'.tr}'),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          if(Get.find<ConfigController>().config?.otpConfirmationForTrip ?? false)
          const OtpWidget(isParcel: true),

          const ActivityScreenRiderDetails(),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          const EstimatedFareAndDistance(),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // ── Bloc "Détails du trajet" : même affichage statique que sur
          //    l'écran "course en cours" (colonne d'icônes + ligne pointillée) ──
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Text(
              'trip_details'.tr,
              style: textBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

          RouteWidget(
            totalDistance: rideController.tripDetails?.estimatedDistance.toString() ?? '',
            fromAddress: rideController.tripDetails?.pickupAddress ?? "",
            toAddress: rideController.tripDetails?.destinationAddress ?? '',
            extraOneAddress: widget.firstRoute,
            extraTwoAddress: widget.secondRoute,
            extraThreeAddress: widget.thirdRoute,
            entrance: rideController.tripDetails?.entrance ?? '',
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // ── Bouton "Modifier le trajet" : ouvre l'édition dans une modale ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openEditRouteSheet,
                icon: Icon(Icons.edit_road, color: Theme.of(context).primaryColor, size: 18),
                label: Text(
                  'Modifier le trajet',
                  style: textMedium.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                ),
              ),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault), 


          Center(
            child:SliderButton(
              action: (){
                currentState = 1;
                widget.expandableKey.currentState?.expand();
                setState(() {});
              },
              label: Text('cancel_ride'.tr,style: TextStyle(color: Theme.of(context).colorScheme.error,fontSize: Dimensions.fontSizeLarge)),
              dismissThresholds: 0.5, dismissible: false, shimmer: false,
              width: 1170, height: 40, buttonSize: 40, radius: 20,
              icon: Center(child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor),
                child: Center(
                  child: Icon(
                    Get.find<LocalizationController>().isLtr ? Icons.arrow_forward_ios_rounded : Icons.keyboard_arrow_left,
                    color: Theme.of(context).colorScheme.error, size: 20.0,
                  ),
                ),
              )),
              isLtr: Get.find<LocalizationController>().isLtr,
              boxShadow: const BoxShadow(blurRadius: 0),
              buttonColor: Colors.transparent,
              backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha:0.15),
              baseColor: Theme.of(context).primaryColor,
            ),
          ),

        ]) :
        const Column(children: [BannerShimmer(), BannerShimmer()]) :
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: Dimensions.paddingSizeSmall,),
          Text('rider_arrived'.tr,style: textSemiBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),),

          const SizedBox(height: Dimensions.paddingSizeSmall,),

          CancellationRadioButton(isOngoing: false,expandableKey: widget.expandableKey),

          const SizedBox(height: Dimensions.paddingSizeLarge),
          rideController.isLoading ?
          SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0) :
          Row(children: [
            Expanded(child: ButtonWidget(buttonText: 'no_continue_trip'.tr,
                showBorder: true,
                transparent: true,
                backgroundColor: Theme.of(context).primaryColor,
                borderColor: Theme.of(context).primaryColor,
                textColor: Theme.of(context).cardColor,
                radius: Dimensions.paddingSizeSmall,
                onPressed: (){
                  currentState = 0;
                  setState(() {});
                })),

            const SizedBox(width: Dimensions.paddingSizeSmall,),
            Expanded(child: ButtonWidget(buttonText: 'submit'.tr,
                showBorder: true,
                transparent: true,
                textColor: Get.isDarkMode ? Colors.white : Colors.black,
                borderColor: Theme.of(context).hintColor,
                radius: Dimensions.paddingSizeSmall,
                onPressed: (){
                  Get.find<RideController>().stopLocationRecord();
                  rideController.tripStatusUpdate(rideController.tripDetails!.id!, 'cancelled', 'ride_request_cancelled_successfully',
                      (Get.find<TripController>().rideCancellationReasonList!.data!.acceptedRide!.length - 1) == Get.find<TripController>().rideCancellationCauseCurrentIndex ?
                      Get.find<TripController>().othersCancellationController.text :
                      Get.find<TripController>().rideCancellationReasonList!.data!.acceptedRide![Get.find<TripController>().rideCancellationCauseCurrentIndex]
                  ).then((value){
                    if(value.statusCode == 200){
                      Get.find<MapController>().notifyMapController();
                      Get.find<BottomMenuController>().navigateToDashboard();
                    }
                  });

                },
            )),
          ])
        ],);
      });
    });
  }
}
