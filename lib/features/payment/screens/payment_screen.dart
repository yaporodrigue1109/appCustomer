
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_fare_summery.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/payment/controllers/payment_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing_user_app/features/payment/screens/review_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_route_widget.dart';

class PaymentScreen extends StatefulWidget {
  final bool fromParcel;

  const PaymentScreen({super.key, this.fromParcel = false,});
    

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
 
}

class _PaymentScreenState extends State<PaymentScreen>
    with WidgetsBindingObserver {

  
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);

  if (Get.find<ProfileController>().profileModel?.data?.wallet == null) {
    Get.find<ProfileController>().getProfileInfo();
  }
  Get.find<PaymentController>().initPayment();

  final rc = Get.find<RideController>();

  // ✅ Chercher dans toutes les sources possibles
  final tripId = rc.tripDetails?.id 
      ?? rc.currentTripDetails?.id 
      ?? rc.lastKnownTripId; // ✅ Fallback

  if (tripId != null && tripId.isNotEmpty) {
    rc.getRideDetails(tripId, isUpdate: false);
    rc.getFinalFare(tripId);
  } else {
    // ✅ Redirection immédiate sans délai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Get.find<BottomMenuController>().navigateToDashboard();
      }
    });
  }
}

// @override
// void initState() {
//   super.initState();
//   WidgetsBinding.instance.addObserver(this);

//   if (Get.find<ProfileController>().profileModel?.data?.wallet == null) {
//     Get.find<ProfileController>().getProfileInfo();
//   }
//   Get.find<PaymentController>().initPayment();

//   final rc = Get.find<RideController>();

//   // ✅ Chercher l'id dans tripDetails ET currentTripDetails
//   final tripId = rc.tripDetails?.id ?? rc.currentTripDetails?.id;

//   if (tripId != null) {
//     // ✅ Toujours recharger tripDetails pour avoir les données fraîches
//     rc.getRideDetails(tripId, isUpdate: false);
//     // ✅ Toujours recharger finalFare
//     rc.getFinalFare(tripId);
//   } else {
//     // ✅ Si pas d'id du tout, retourner au dashboard après un délai
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) {
//         Get.find<BottomMenuController>().navigateToDashboard();
//       }
//     });
//   }
// }
 

// @override
// void didChangeAppLifecycleState(AppLifecycleState state) {
//   super.didChangeAppLifecycleState(state);
//   if (state == AppLifecycleState.resumed) {
//     Get.find<RideController>()
//         .getRideDetails(
//             Get.find<RideController>().currentTripDetails!.id!)
//         .then((value) {
//       if (Get.find<RideController>().currentTripDetails!.paymentStatus ==
//           'paid') {
//         // ✅ Redirection vers ReviewScreen quand paiement confirmé
//         final String tripId =
//             Get.find<RideController>().currentTripDetails?.id ?? '';
//             if (tripId == null) return;
//         Get.offAll(() => ReviewScreen(tripId: tripId));
//       } else {
//         Get.find<RideController>().getFinalFare(
//             Get.find<RideController>().currentTripDetails!.id!);
//         Get.find<PaymentController>().initPayment();
//       }
//     });
//   }
// }

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);
  if (state == AppLifecycleState.resumed) {
    final rc = Get.find<RideController>();
    
    // ✅ Toutes les sources possibles
    final tripId = rc.currentTripDetails?.id 
        ?? rc.tripDetails?.id 
        ?? rc.lastKnownTripId;

    if (tripId == null || tripId.isEmpty) return; // ✅ Guard

    rc.getRideDetails(tripId).then((value) {
      if (!mounted) return;
      
      final paymentStatus = rc.currentTripDetails?.paymentStatus 
          ?? rc.tripDetails?.paymentStatus;
          
      if (paymentStatus == 'paid') {
        Get.offAll(() => ReviewScreen(tripId: tripId));
      } else {
        rc.getFinalFare(tripId);
        Get.find<PaymentController>().initPayment();
      }
    });
  }
}


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return SafeArea(
      top: false,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, val) async {
          Get.find<BottomMenuController>().navigateToDashboard();
          return;
        },
        child: Scaffold(
           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: GetBuilder<RideController>(builder: (rideController) {
              final tripId = rideController.tripDetails?.id 
      ?? rideController.currentTripDetails?.id
      ?? rideController.lastKnownTripId;
            // ✅ Loader si données pas encore chargées
            if (tripId == null || tripId.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) Get.find<BottomMenuController>().navigateToDashboard();
                });
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Center(
                    child: SpinKitCircle(
                      color: Theme.of(context).primaryColor,
                      size: 40.0,
                    ),
                  ),
                );
            }
              if (rideController.finalFare == null || rideController.tripDetails == null) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SpinKitCircle(
          color: Theme.of(context).primaryColor,
          size: 40.0,
        ),
      ),
    );
  }

            final fare = rideController.finalFare!;
            final trip = rideController.tripDetails!;
            final duration = fare.actualTime ?? 0;
            final distance = fare.actualDistance ?? 0;


            String firstRoute = '';
                String secondRoute = '';
                String thirdRoute = '';
                List<dynamic> extraRoute = [];
                if(trip.intermediateAddresses != null && trip.intermediateAddresses != '[[, ]]'){
                  extraRoute = jsonDecode(trip.intermediateAddresses!);
                  if(extraRoute.isNotEmpty){
                    firstRoute = extraRoute[0];
                  }
                  if(extraRoute.isNotEmpty && extraRoute.length>1){
                    secondRoute = extraRoute[1];
                  }
                  if(extraRoute.isNotEmpty && extraRoute.length>2){
                    thirdRoute = extraRoute[2];
                  }
              }

            return BodyWidget(
              appBar: AppBarWidget(
                title: 'payment'.tr,
                onBackPressed: () =>
                    Get.find<BottomMenuController>().navigateToDashboard(),
              ),
              body: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Temps & Distance ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault,
                        horizontal: Dimensions.paddingSizeDefault,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(children: [
                            Icon(Icons.access_time,
                                color: Theme.of(context).primaryColor,
                                size: 28),
                            const SizedBox(height: 4),
                            Text(
                              //' DateFormat('dd MMM à HH:mm').format($duration)  ${'minute'.tr}',
                               _formatDuration(duration),
                                style: textSemiBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge)),
                            Text('time_trip'.tr,
                                style: textRegular.copyWith(
                                    color: Colors.grey,
                                    fontSize: Dimensions.fontSizeSmall)),
                          ]),
                          Container(
                              width: 1,
                              height: 50,
                              color: Colors.grey.withOpacity(0.3)),
                          Column(children: [
                            Icon(Icons.social_distance,
                                color: Theme.of(context).primaryColor,
                                size: 28),
                            const SizedBox(height: 4),
                            Text('$distance km',
                                style: textSemiBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge)),
                            Text('distance'.tr,
                                style: textRegular.copyWith(
                                    color: Colors.grey,
                                    fontSize: Dimensions.fontSizeSmall)),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // ── Titre Détails du trajet ───────────────────────
                    Text('trip_details'.tr,
                        style: textSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // ── Date & Heures ─────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(
                          Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(children: [
                        Text(
                          trip.createdAt != null
                              ? _formatDate(trip.createdAt!)
                              : '',
                          style: textRegular.copyWith(
                              color: Colors.grey,
                              fontSize: Dimensions.fontSizeSmall),
                        ),
                        const SizedBox(
                            height: Dimensions.paddingSizeSmall),
                        const Divider(height: 1),
                        const SizedBox(
                            height: Dimensions.paddingSizeSmall),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: [
                            Column(children: [
                              Text(
                                trip.createdAt != null
                                    ? _formatTime(trip.createdAt!)
                                    : '--:--',
                                style: textSemiBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge),
                              ),
                              Text('pickup_time'.tr,
                                  style: textRegular.copyWith(
                                      color: Colors.grey,
                                      fontSize:
                                          Dimensions.fontSizeSmall)),
                            ]),
                            Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey.withOpacity(0.3)),
                            Column(children: [
                              Text(
                                trip.updatedAt != null
                                    ? _formatTime(trip.updatedAt!)
                                    : '--:--',
                                style: textSemiBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge),
                              ),
                              Text('dropoff_time'.tr,
                                  style: textRegular.copyWith(
                                      color: Colors.grey,
                                      fontSize:
                                          Dimensions.fontSizeSmall)),
                            ]),
                          ],
                        ),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // ── Adresses ──────────────────────────────────────
                    // Container(
                    //   padding: const EdgeInsets.all(
                    //       Dimensions.paddingSizeDefault),
                    //   decoration: BoxDecoration(
                    //     color: Theme.of(context).cardColor,
                    //     borderRadius: BorderRadius.circular(
                    //         Dimensions.radiusDefault),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.black.withOpacity(0.05),
                    //         blurRadius: 8,
                    //         offset: const Offset(0, 2),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Column(children: [
                    //     Row(children: [
                    //       Container(
                    //         width: 36,
                    //         height: 36,
                    //         decoration: BoxDecoration(
                    //           color: Theme.of(context)
                    //               .primaryColor
                    //               .withOpacity(0.1),
                    //           borderRadius: BorderRadius.circular(8),
                    //         ),
                    //         child: Icon(Icons.my_location,
                    //             color: Theme.of(context).primaryColor,
                    //             size: 18),
                    //       ),
                    //       const SizedBox(
                    //           width: Dimensions.paddingSizeSmall),
                    //       Expanded(
                    //         child: Text(
                    //           trip.pickupAddress ?? '',
                    //           style: textRegular.copyWith(
                    //               fontSize: Dimensions.fontSizeSmall),
                    //           maxLines: 2,
                    //           overflow: TextOverflow.ellipsis,
                    //         ),
                    //       ),
                    //     ]),
                    //     Padding(
                    //       padding: const EdgeInsets.only(
                    //           left: 17, top: 4, bottom: 4),
                    //       child: Column(children: [
                    //         ...List.generate(
                    //             3,
                    //             (_) => Container(
                    //                   width: 2,
                    //                   height: 4,
                    //                   margin: const EdgeInsets.only(
                    //                       bottom: 3),
                    //                   color:
                    //                       Colors.grey.withOpacity(0.5),
                    //                 )),
                    //       ]),
                    //     ),
                    //     Row(children: [
                    //       Container(
                    //         width: 36,
                    //         height: 36,
                    //         decoration: BoxDecoration(
                    //           color: Theme.of(context)
                    //               .primaryColor
                    //               .withOpacity(0.1),
                    //           borderRadius: BorderRadius.circular(8),
                    //         ),
                    //         child: Icon(Icons.location_on,
                    //             color: Theme.of(context).primaryColor,
                    //             size: 18),
                    //       ),
                    //       const SizedBox(
                    //           width: Dimensions.paddingSizeSmall),
                    //       Expanded(
                    //         child: Text(
                    //           trip.destinationAddress ?? '',
                    //           style: textRegular.copyWith(
                    //               fontSize: Dimensions.fontSizeSmall),
                    //           maxLines: 2,
                    //           overflow: TextOverflow.ellipsis,
                    //         ),
                    //       ),
                    //     ]),
                    //   ]),
                    // ),
                     Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2))
                    ),
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: TripRouteWidget(
                      pickupAddress: trip.pickupAddress!,
                      destinationAddress: trip.destinationAddress!,
                      extraOne: firstRoute,
                      extraTwo: secondRoute,
                      extraThree: thirdRoute,  
                      entrance: trip.entrance,
                    ),
                  ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // ── Infos Chauffeur ───────────────────────────────
                    if (trip.driver?.firstName != null)
                      Container(
                        padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                       
                        child: Row(children: [
                         CircleAvatar(
                              radius: 28,
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              backgroundImage: trip.driver?.profileImage != null && 
                                      trip.driver!.profileImage!.isNotEmpty
                                  ? NetworkImage(
                                      '${Get.find<ConfigController>().config!.imageBaseUrl!.profileImageDriver}'
                                      '/${trip.driver!.profileImage}'
                                    )
                                  : null,
                              child: trip.driver?.profileImage == null ||
                                      trip.driver!.profileImage!.isEmpty
                                  ? Icon(Icons.person,
                                      color: Theme.of(context).primaryColor,
                                      size: 28)
                                  : null,
                            ),
                          const SizedBox(
                              width: Dimensions.paddingSizeDefault),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${trip.driver?.firstName ?? ''} ${trip.driver?.lastName ?? ''}',
                                  style: textSemiBold.copyWith(
                                      fontSize:
                                          Dimensions.fontSizeDefault),
                                ),
                                Row(children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    trip.driverAvgRating?.toString() ??
                                        '0.0',
                                    style: textRegular.copyWith(
                                        fontSize:
                                            Dimensions.fontSizeSmall),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                          // Row(children: [
                          //   _contactButton(
                          //       icon: Icons.chat_bubble_outline,
                          //       onTap: () {}),
                          //   const SizedBox(
                          //       width: Dimensions.paddingSizeSmall),
                          //   _contactButton(
                          //       icon: Icons.phone_outlined,
                          //       onTap: () {}),
                          // ]),


Row(children: [
  // Bouton Message
  InkWell(
    onTap: () async {
      final phone = trip.driver?.phone ?? '';
      if (phone.isNotEmpty) {
        final Uri smsUri = Uri(
          scheme: 'sms',
          path: phone,
        );
        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
        }
      }
    },
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.chat_bubble_outline,
          color: Theme.of(context).primaryColor, size: 20),
    ),
  ),
  const SizedBox(width: Dimensions.paddingSizeSmall),
  // Bouton Appel
  InkWell(
    onTap: () async {
      final phone = trip.driver?.phone ?? '';
      if (phone.isNotEmpty) {
        final Uri callUri = Uri(
          scheme: 'tel',
          path: phone,
        );
        if (await canLaunchUrl(callUri)) {
          await launchUrl(callUri);
        }
      }
    },
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.phone_outlined,
          color: Theme.of(context).primaryColor, size: 20),
    ),
  ),
]),




                        ]),
                      ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // ── Détails du paiement ───────────────────────────
                    Container(
                      padding: const EdgeInsets.all(
                          Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text('payment_details'.tr,
                                style: textSemiBold.copyWith(
                                    fontSize:
                                        Dimensions.fontSizeDefault)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      Dimensions.paddingSizeSmall,
                                  vertical:
                                      Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: Text('cash'.tr,
                                  style: textMedium.copyWith(
                                      color: Theme.of(context)
                                          .primaryColor,
                                      fontSize:
                                          Dimensions.fontSizeSmall)),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height: Dimensions.paddingSizeSmall),
                        const Divider(height: 1),
                        const SizedBox(
                            height: Dimensions.paddingSizeSmall),

                        _paymentRow(context,
                            icon: Icons.directions_car,
                            label: 'fare_fee'.tr,
                            amount: PriceConverter.convertPrice(
                                fare.distanceWiseFare ?? 0)),

                        if ((fare.idleFee ?? 0) + (fare.delayFee ?? 0) > 0)
                          _paymentRow(context,icon: Icons.hourglass_empty,label:'${'frais_attente'.tr} (${fare.idleTime ?? 0} min)', amount: (PriceConverter.convertPrice((fare.idleFee ?? 0) + (fare.delayFee ?? 0))) ),

                           if ((fare.discountAmount ?? 0) + (fare.couponAmount ?? 0) != 0)
                           _paymentRow(context, icon: Icons.discount,label: 'discount'.tr,amount: (PriceConverter.convertPrice((fare.vatTax ?? 0) + (fare.couponAmount ?? 0)) )),

                        if ((fare.vatTax ?? 0) > 0)
                          _paymentRow(context, icon: Icons.receipt,label: 'vat_tax'.tr,amount: PriceConverter.convertPrice(fare.vatTax ?? 0)),

                        const SizedBox(
                            height: Dimensions.paddingSizeSmall),
                        const Divider(height: 1),
                        const SizedBox(
                            height: Dimensions.paddingSizeSmall),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text('sub_total'.tr,
                                style: textSemiBold.copyWith(
                                    color: Theme.of(context)
                                        .primaryColor)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      Dimensions.paddingSizeSmall,
                                  vertical:
                                      Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: Text(
                              PriceConverter.convertPrice( 
                                    fare.paidFare ?? 0),
                                style: textSemiBold.copyWith(
                                    color:
                                        Theme.of(context).primaryColor,
                                    fontSize:
                                        Dimensions.fontSizeDefault),
                                        
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  Widget _contactButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            Icon(icon, color: Theme.of(context).primaryColor, size: 20),
      ),
    );
  }

  Widget _paymentRow(BuildContext context,
      {required IconData icon,
      required String label,
      required String amount}) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(label,
                style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall)),
          ]),
          Text(amount,
              style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall)),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.hour.toString().padLeft(2, '0')}h${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }

 String _formatDuration(double durationInMinutes) {
  if (durationInMinutes <= 0) return '0 ${'min'.tr}';
  
  int totalSeconds = (durationInMinutes * 60).toInt();
  int hours = totalSeconds ~/ 3600;
  int minutes = (totalSeconds % 3600) ~/ 60;
  int seconds = totalSeconds % 60;
  
  // Si moins d'une minute, afficher uniquement les secondes
  if (hours == 0 && minutes == 0) {
    return '${seconds}s';
  }
  
  // Si moins d'une heure, afficher minutes et secondes
  if (hours == 0) {
    if (seconds == 0) {
      return '$minutes ${'min'.tr}';
    }
    return '$minutes ${'min'.tr} ${seconds}s';
  }
  
  // Si une heure ou plus
  String result = '${hours}h';
  if (minutes > 0 || seconds > 0) {
    result += ' ${minutes}${'min'.tr}';
  }
  if (seconds > 0 && minutes == 0) {
    result += ' ${seconds}s';
  }
  
  return result;
}

  int _roundToMultipleOf5(double value) {
    int intValue = value.ceil(); // Arrondir à l'entier supérieur
    int remainder = intValue % 5;
    
    if (remainder == 0) {
      return intValue; // Déjà multiple de 5
    } else {
      return intValue + (5 - remainder); // Ajouter pour atteindre le prochain multiple de 5
    }
  }
}



