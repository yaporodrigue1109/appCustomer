
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ride_sharing_user_app/util/dimensions.dart';
// import 'package:ride_sharing_user_app/util/images.dart';
// import 'package:ride_sharing_user_app/util/styles.dart';
// import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
// import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
// import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
// import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';

// class RouteWidget extends StatefulWidget {
//   final String totalDistance; 
//   final String fromAddress;
//   final String toAddress;
//   final String extraOneAddress;
//   final String extraTwoAddress;
//    final String extraThreeAddress;
//   final String entrance;
//   final bool fromParcelOngoing;
//   const RouteWidget({super.key, required this.totalDistance,
//     required this.fromAddress, required this.toAddress,
//     required this.extraOneAddress, required this.extraTwoAddress, required this.extraThreeAddress,
//     required this.entrance, this.fromParcelOngoing = false});

//   @override
//   State<RouteWidget> createState() => _RouteWidgetState();
// }

// class _RouteWidgetState extends State<RouteWidget> {
//   String totalDistance = '0', estDistance = '0', removeComma= '0';
  
//   @override
//   Widget build(BuildContext context) {
//     if(widget.totalDistance.contains("km")){
//       removeComma = widget.totalDistance.replaceAll("km", '');
//       totalDistance = removeComma.replaceAll(",", '');
//     }
//     estDistance = double.parse(totalDistance).toStringAsFixed(2);

//     return GetBuilder<ParcelController>(builder: (parcelController) {
//       return GetBuilder<LocationController>(builder: (locationController) {
//         // Vérifier si c'est une commande pour quelqu'un d'autre
//         bool isRideForOther = locationController.isRideForOther;
//         String beneficiaryPhone = locationController.beneficiaryPhone;
//         String beneficiaryName = locationController.beneficiaryName;
        
//         return Column(children: [
//           // Afficher les informations du bénéficiaire si c'est pour quelqu'un d'autre
//           if (isRideForOther)
//             Container(
//               width: double.infinity,
//               margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
//               padding: const EdgeInsets.symmetric(
//                 horizontal: Dimensions.paddingSizeSmall,
//                 vertical: Dimensions.paddingSizeExtraSmall,
//               ),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).primaryColor.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//                 border: Border.all(
//                   color: Theme.of(context).primaryColor.withOpacity(0.2),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.person,
//                     size: 14,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//                   Expanded(
//                     child: Text(
//                       beneficiaryName.isNotEmpty
//                           ? 'Pour: $beneficiaryName - $beneficiaryPhone'
//                           : 'Bénéficiaire: $beneficiaryPhone',
//                       style: textRegular.copyWith(
//                         fontSize: Dimensions.fontSizeExtraSmall,
//                         color: Theme.of(context).primaryColor,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
          
//           // Le reste du widget reste identique
//           Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
//               child: Column(children:  [
//                 SizedBox(
//                   width: Dimensions.iconSizeMedium,
//                   child: Image.asset(Images.currentLocation, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
//                 ),

//                 SizedBox(height:65 , width: 10, child: CustomDivider(
//                   height: 2,dashWidth: 1, axis: Axis.vertical,color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
//                 )),

//                 SizedBox(
//                   width: Dimensions.iconSizeMedium,
//                   child: Image.asset(Images.activityDirection, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
//                 ),
//               ]),
//             ),

//             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               SizedBox(height: 40 , child: Text(
//                 widget.fromAddress,
//                 style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.7)),
//                 overflow: TextOverflow.ellipsis,maxLines: 2,
//               )),
//               const SizedBox(height: Dimensions.paddingSizeSmall),

//               Text('to'.tr,style: textRegular.copyWith(color: Theme.of(context).primaryColor)),

//               SizedBox(height: widget.extraOneAddress.isNotEmpty ? Dimensions.paddingSizeSmall : 0),

//               widget.extraOneAddress.isNotEmpty ?
//               Padding(
//                 padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
//                 child: Text(
//                   widget.extraOneAddress,
//                   style: textRegular.copyWith(
//                       color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7),
//                       fontSize: Dimensions.fontSizeSmall
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ) :
//               const SizedBox(),

//               widget.extraOneAddress.isNotEmpty && widget.extraTwoAddress.isNotEmpty ?
//               Padding(
//                 padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
//                 child: SizedBox(height:20 , width: 10, child: CustomDivider(
//                   height: 2,dashWidth: 1,axis: Axis.vertical,
//                   color: Get.isDarkMode ? Colors.white : Colors.black,
//                 )),
//               ) :
//               const SizedBox(),

//               widget.extraTwoAddress.isNotEmpty ?
//               Padding(
//                 padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
//                 child: Text(
//                   widget.extraTwoAddress,
//                   style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7), fontSize: Dimensions.fontSizeSmall),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ) :
//               const SizedBox(),
//               const SizedBox(height: Dimensions.paddingSizeSmall),



// widget.extraOneAddress.isNotEmpty && widget.extraTwoAddress.isNotEmpty && widget.extraThreeAddress.isNotEmpty?
//               Padding(
//                 padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
//                 child: SizedBox(height:20 , width: 10, child: CustomDivider(
//                   height: 2,dashWidth: 1,axis: Axis.vertical,
//                   color: Get.isDarkMode ? Colors.white : Colors.black,
//                 )),
//               ) :
//               const SizedBox(),

//               widget.extraThreeAddress.isNotEmpty ?
//               Padding(
//                 padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
//                 child: Text(
//                   widget.extraThreeAddress,
//                   style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7), fontSize: Dimensions.fontSizeSmall),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ) :
//               const SizedBox(),
//               const SizedBox(height: Dimensions.paddingSizeSmall),





//               Text(
//                   widget.toAddress,overflow: TextOverflow.ellipsis,maxLines: 2,
//                 style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7)),
//               ),

//               if(widget.entrance.isNotEmpty)
//                 Divider(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),

//               if(widget.entrance.isNotEmpty)
//                 Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
//                   SizedBox(height: 25, child: Image.asset(Images.curvedArrow, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7))),
//                   const SizedBox(width: Dimensions.paddingSizeSmall),

//                   Container(
//                     transform: Matrix4.translationValues(0, 10, 0),
//                     child: Text(widget.entrance, style: textRegular.copyWith(
//                         fontSize: Dimensions.fontSizeDefault,
//                         color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.4)
//                     )),
//                   ),
//                 ]),
//             ])),
//           ]),
//           const SizedBox(height: Dimensions.paddingSizeDefault),

//           if(!widget.fromParcelOngoing)
//             GetBuilder<RideController>(builder: (rideController) {
//               return Padding(
//                 padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                 child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                   Row(children: [
//                     SizedBox(
//                       width: Dimensions.iconSizeMedium,
//                       child: Image.asset(Images.distanceCalculated, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
//                     ),
//                     const SizedBox(width: Dimensions.paddingSizeSmall),

//                     Text("total_distance".tr, style: textRegular.copyWith(
//                         color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7),
//                     )),
//                   ]),
//                   const SizedBox(width: Dimensions.paddingSizeSmall),

//                   Text(
//                     widget.totalDistance.contains('km') ?
//                     widget.totalDistance :
//                     '${double.parse(widget.totalDistance).toStringAsFixed(2)} km',
//                     style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7)),
//                   ),



                  
//                 ]),
                
//               );
//             }),
//         ]);
//       });
//     });
//   }
// }




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';
import 'package:intl/intl.dart';

class RouteWidget extends StatefulWidget {
  final String totalDistance; 
  final String fromAddress;
  final String toAddress;
  final String extraOneAddress;
  final String extraTwoAddress;
  final String extraThreeAddress;
  final String entrance;
  final bool fromParcelOngoing;
  const RouteWidget({super.key, required this.totalDistance,
    required this.fromAddress, required this.toAddress,
    required this.extraOneAddress, required this.extraTwoAddress, required this.extraThreeAddress,
    required this.entrance, this.fromParcelOngoing = false});

  @override
  State<RouteWidget> createState() => _RouteWidgetState();
}

class _RouteWidgetState extends State<RouteWidget> {
  String totalDistance = '0', estDistance = '0', removeComma= '0';
  
  // Fonction pour calculer l'heure d'arrivée estimée
  String _getEstimatedArrivalTime() {
    try {
      // Récupérer l'heure actuelle
      DateTime now = DateTime.now();
      
      // Extraire la durée estimée en minutes depuis le contrôleur
      final rideController = Get.find<RideController>();
      double estimatedMinutes = 0;
      
      if (rideController.rideDetails?.estimatedTime != null) {
        // Si rideDetails existe, utiliser estimatedTime
        String timeStr = rideController.rideDetails!.estimatedTime.toString();
        // Nettoyer la chaîne (enlever "min" si présent)
        timeStr = timeStr.replaceAll('min', '').trim();
        estimatedMinutes = double.tryParse(timeStr) ?? 0;
      } else if (rideController.estimatedDuration != null) {
        // Sinon utiliser estimatedTime du contrôleur
        String timeStr = rideController.estimatedDuration.toString();
        timeStr = timeStr.replaceAll('min', '').trim();
        estimatedMinutes = double.tryParse(timeStr) ?? 0;
      }
      
      // Si aucune durée estimée, utiliser une estimation basée sur la distance
      if (estimatedMinutes == 0) {
        // Estimer environ 2 minutes par km
        double distance = double.tryParse(totalDistance) ?? 0;
        estimatedMinutes = distance * 2;
      }
      
      // Ajouter les minutes à l'heure actuelle
      DateTime arrivalTime = now.add(Duration(minutes: estimatedMinutes.toInt()));
      
      // Formater l'heure
      return DateFormat('HH:mm').format(arrivalTime);
    } catch (e) {
      debugPrint('Erreur de calcul de l\'heure d\'arrivée: $e');
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.totalDistance.contains("km")){
      removeComma = widget.totalDistance.replaceAll("km", '');
      totalDistance = removeComma.replaceAll(",", '');
    }
    estDistance = double.parse(totalDistance).toStringAsFixed(2);

    return GetBuilder<ParcelController>(builder: (parcelController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        // Vérifier si c'est une commande pour quelqu'un d'autre
        bool isRideForOther = locationController.isRideForOther;
        String beneficiaryPhone = locationController.beneficiaryPhone;
        String beneficiaryName = locationController.beneficiaryName;
        
        return Column(children: [
          // Afficher les informations du bénéficiaire si c'est pour quelqu'un d'autre
          if (isRideForOther)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeExtraSmall,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Expanded(
                    child: Text(
                      beneficiaryName.isNotEmpty
                          ? 'Pour: $beneficiaryName - $beneficiaryPhone'
                          : 'Bénéficiaire: $beneficiaryPhone',
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Le reste du widget reste identique
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
              child: Column(children:  [
                SizedBox(
                  width: Dimensions.iconSizeMedium,
                  child: Image.asset(Images.currentLocation, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                ),

                SizedBox(height:65 , width: 10, child: CustomDivider(
                  height: 2,dashWidth: 1, axis: Axis.vertical,color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
                )),

                SizedBox(
                  width: Dimensions.iconSizeMedium,
                  child: Image.asset(Images.activityDirection, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                ),
              ]),
            ),

            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 40 , child: Text(
                widget.fromAddress,
                style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.7)),
                overflow: TextOverflow.ellipsis,maxLines: 2,
              )),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text('to'.tr,style: textRegular.copyWith(color: Theme.of(context).primaryColor)),

              SizedBox(height: widget.extraOneAddress.isNotEmpty ? Dimensions.paddingSizeSmall : 0),

              widget.extraOneAddress.isNotEmpty ?
              Padding(
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                child: Text(
                  widget.extraOneAddress,
                  style: textRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7),
                      fontSize: Dimensions.fontSizeSmall
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ) :
              const SizedBox(),

              widget.extraOneAddress.isNotEmpty && widget.extraTwoAddress.isNotEmpty ?
              Padding(
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                child: SizedBox(height:20 , width: 10, child: CustomDivider(
                  height: 2,dashWidth: 1,axis: Axis.vertical,
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                )),
              ) :
              const SizedBox(),

              widget.extraTwoAddress.isNotEmpty ?
              Padding(
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                child: Text(
                  widget.extraTwoAddress,
                  style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7), fontSize: Dimensions.fontSizeSmall),
                  overflow: TextOverflow.ellipsis,
                ),
              ) :
              const SizedBox(),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              widget.extraOneAddress.isNotEmpty && widget.extraTwoAddress.isNotEmpty && widget.extraThreeAddress.isNotEmpty?
              Padding(
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                child: SizedBox(height:20 , width: 10, child: CustomDivider(
                  height: 2,dashWidth: 1,axis: Axis.vertical,
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                )),
              ) :
              const SizedBox(),

              widget.extraThreeAddress.isNotEmpty ?
              Padding(
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                child: Text(
                  widget.extraThreeAddress,
                  style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7), fontSize: Dimensions.fontSizeSmall),
                  overflow: TextOverflow.ellipsis,
                ),
              ) :
              const SizedBox(),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                  widget.toAddress,overflow: TextOverflow.ellipsis,maxLines: 2,
                style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7)),
              ),

              if(widget.entrance.isNotEmpty)
                Divider(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),

              if(widget.entrance.isNotEmpty)
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  SizedBox(height: 25, child: Image.asset(Images.curvedArrow, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7))),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Container(
                    transform: Matrix4.translationValues(0, 10, 0),
                    child: Text(widget.entrance, style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.4)
                    )),
                  ),
                ]),
            ])),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          if(!widget.fromParcelOngoing)
            GetBuilder<RideController>(builder: (rideController) {
              // Calculer l'heure d'arrivée estimée
              String arrivalTime = _getEstimatedArrivalTime();
              
              return Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Column(
                  children: [
                    // Ligne 1: Distance totale
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        SizedBox(
                          width: Dimensions.iconSizeMedium,
                          child: Image.asset(Images.distanceCalculated, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Text("total_distance".tr, style: textRegular.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7),
                        )),
                      ]),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Text(
                        widget.totalDistance.contains('km') ?
                        widget.totalDistance :
                        '${double.parse(widget.totalDistance).toStringAsFixed(2)} km',
                        style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7)),
                      ),
                    ]),
                    
                    // Ligne 2: Heure d'arrivée estimée
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                     const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        Icon(
                          Icons.access_time,
                          size: Dimensions.iconSizeSmall,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Text(
                          "estimated_time".tr,
                          style: textRegular.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7),
                          ),
                        ),
                      ]),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Text(
                        arrivalTime,
                        style: textRegular.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                  ],
                ),
              );
            }),
        ]);
      });
    });
  }
}
