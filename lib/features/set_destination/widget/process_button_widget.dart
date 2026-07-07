
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';
// import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
// import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
// import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
// import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
// import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
// import 'package:ride_sharing_user_app/helper/display_helper.dart';
// import 'package:ride_sharing_user_app/util/dimensions.dart';

// class ProcessButtonWidget extends StatelessWidget {
//   final FocusNode pickLocationFocus;
//   final FocusNode destinationLocationFocus;
//   final VoidCallback? onSearchPressed; // Nouveau paramètre
//   const ProcessButtonWidget({super.key, required this.pickLocationFocus, required this.destinationLocationFocus,  this.onSearchPressed});
 
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<RideController>(builder: (rideController){
//       return GetBuilder<LocationController>(builder: (locationController){
//         return Container(
//           color: Theme.of(context).cardColor,
//           child: Column(mainAxisSize: MainAxisSize.min,children: [
//             rideController.loading ?
//             SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0) :
//             ButtonWidget(
//               onPressed: rideController.loading ? null : () { // Désactiver si chargement
//                 if(Get.find<ConfigController>().config!.maintenanceMode != null &&
//                     Get.find<ConfigController>().config!.maintenanceMode!.maintenanceStatus == 1 &&
//                     Get.find<ConfigController>().config!.maintenanceMode!.selectedMaintenanceSystem!.userApp == 1
//                 ){
//                   showCustomSnackBar('maintenance_mode_on_for_ride'.tr,isError: true);
//                 }else{
//                   if(locationController.fromAddress == null ||
//                       locationController.fromAddress!.address == null ||
//                       locationController.fromAddress!.address!.isEmpty) {
//                     showCustomSnackBar('pickup_location_is_required'.tr);
//                     FocusScope.of(context).requestFocus(pickLocationFocus);
//                   }else if(locationController.pickupLocationController.text.isEmpty) {
//                     showCustomSnackBar('pickup_location_is_required'.tr);
//                     FocusScope.of(context).requestFocus(pickLocationFocus);
//                   }else if(locationController.toAddress == null ||
//                       locationController.toAddress!.address == null ||
//                       locationController.toAddress!.address!.isEmpty) {
//                     showCustomSnackBar('destination_location_is_required'.tr);
//                     FocusScope.of(context).requestFocus(destinationLocationFocus);
//                   }else if(locationController.destinationLocationController.text.isEmpty) {
//                     showCustomSnackBar('destination_location_is_required'.tr);
//                     FocusScope.of(context).requestFocus(destinationLocationFocus);
//                   }else{
//                     rideController.getEstimatedFare(false).then((value) {
//                       if(value.statusCode == 200) {
//                         Get.to(() => const MapScreen(
//                           fromScreen: MapScreenType.ride,
//                           isShowCurrentPosition: false,
                            
//                         ));
//                         Get.find<RideController>().updateRideCurrentState(RideState.initial);
//                       }
//                     });

//                   }
//                 }
//               },
//               buttonText: rideController.rideType == RideType.scheduleRide 
//                   ? 'detail_reservation'.tr  // Texte pour trajet programmé
//                   : 'search'.tr, 
//               margin: EdgeInsets.all(Dimensions.paddingSizeSmall),
//               backgroundColor: _isProceedButtonActive(locationController) || rideController.loading
//                   ? Theme.of(context).hintColor.withValues(alpha: 0.5)
//                   : Theme.of(context).primaryColor,
//               radius: Dimensions.paddingSizeSmall,
//             )
//           ]),
//         );
//       });
//     });
//   }
// }

// bool _isProceedButtonActive(LocationController locationController){
//   if(
//   locationController.fromAddress == null || locationController.fromAddress!.address == null ||
//       locationController.fromAddress!.address!.isEmpty || locationController.pickupLocationController.text.isEmpty ||
//       locationController.toAddress == null || locationController.toAddress!.address == null ||
//       locationController.toAddress!.address!.isEmpty || locationController.destinationLocationController.text.isEmpty
//   ){
//     return true;
//   }else{
//     return false;
//   }
// }

//   void _defaultSearchBehavior() {
//     // Comportement par défaut (peut être vide ou rediriger)
//     print('Recherche manuelle déclenchée');
//   }



import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class ProcessButtonWidget extends StatelessWidget {
  final FocusNode pickLocationFocus;
  final FocusNode destinationLocationFocus;
  final VoidCallback? onSearchPressed;
  
  const ProcessButtonWidget({
    super.key, 
    required this.pickLocationFocus, 
    required this.destinationLocationFocus,  
    this.onSearchPressed
  });
 
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        return Container(
          color: Theme.of(context).cardColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              rideController.loading
                  ? SpinKitCircle(
                      color: Theme.of(context).primaryColor, 
                      size: 40.0
                    )
                  : ButtonWidget(
                      onPressed: rideController.loading 
                          ? null 
                          : () {
                              if (onSearchPressed != null) {
                                onSearchPressed!();
                              } else {
                                _defaultSearchBehavior(
                                  context,
                                  rideController,
                                  locationController,
                                );
                              }
                            },
                      buttonText: rideController.rideType == RideType.scheduleRide 
                          ? 'detail_reservation'.tr
                          : 'search'.tr, 
                      margin: EdgeInsets.all(Dimensions.paddingSizeSmall),
                      backgroundColor: _isProceedButtonActive(locationController) || rideController.loading
                          ? Theme.of(context).hintColor.withValues(alpha: 0.5)
                          : Theme.of(context).primaryColor,
                      radius: Dimensions.paddingSizeSmall,
                    )
            ],
          ),
        );
      });
    });
  }

  void _defaultSearchBehavior(
    BuildContext context,
    RideController rideController,
    LocationController locationController,
  ) {
    if (Get.find<ConfigController>().config!.maintenanceMode != null &&
        Get.find<ConfigController>().config!.maintenanceMode!.maintenanceStatus == 1 &&
        Get.find<ConfigController>().config!.maintenanceMode!.selectedMaintenanceSystem!.userApp == 1) {
      showCustomSnackBar('maintenance_mode_on_for_ride'.tr, isError: true);
      return;
    }
    
    if (locationController.fromAddress == null ||
        locationController.fromAddress!.address == null ||
        locationController.fromAddress!.address!.isEmpty) {
      showCustomSnackBar('pickup_location_is_required'.tr);
      FocusScope.of(context).requestFocus(pickLocationFocus);
      return;
    }
    
    if (locationController.pickupLocationController.text.isEmpty) {
      showCustomSnackBar('pickup_location_is_required'.tr);
      FocusScope.of(context).requestFocus(pickLocationFocus);
      return;
    }
    
    if (locationController.toAddress == null ||
        locationController.toAddress!.address == null ||
        locationController.toAddress!.address!.isEmpty) {
      showCustomSnackBar('destination_location_is_required'.tr);
      FocusScope.of(context).requestFocus(destinationLocationFocus);
      return;
    }
    
    if (locationController.destinationLocationController.text.isEmpty) {
      showCustomSnackBar('destination_location_is_required'.tr);
      FocusScope.of(context).requestFocus(destinationLocationFocus);
      return;
    }
    
    rideController.getEstimatedFare(false).then((value) {
      if (value.statusCode == 200) {
        Get.to(() => const MapScreen(
          fromScreen: MapScreenType.ride,
          isShowCurrentPosition: false,
        ));
        Get.find<RideController>().updateRideCurrentState(RideState.initial);
      }
    });
  }
}

bool _isProceedButtonActive(LocationController locationController) {
  if (locationController.fromAddress == null || 
      locationController.fromAddress!.address == null ||
      locationController.fromAddress!.address!.isEmpty || 
      locationController.pickupLocationController.text.isEmpty ||
      locationController.toAddress == null || 
      locationController.toAddress!.address == null ||
      locationController.toAddress!.address!.isEmpty || 
      locationController.destinationLocationController.text.isEmpty) {
    return true;
  } else {
    return false;
  }
}