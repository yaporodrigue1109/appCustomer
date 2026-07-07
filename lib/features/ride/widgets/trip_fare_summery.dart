
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ride_sharing_user_app/features/payment/widget/payment_item_info_widget.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/payment/controllers/payment_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

class TripFareSummery extends StatefulWidget {
  final bool fromPayment;
  final bool fromParcel;
  final double? tripFare;
  final double? discountFare;
  final double? discountAmount;
  
  const TripFareSummery({
    super.key, 
    this.fromPayment = false,  
    this.tripFare, 
    required this.fromParcel,
    this.discountFare,
    this.discountAmount,
  }); 

  @override
  State<TripFareSummery> createState() => _TripFareSummeryState();
}

class _TripFareSummeryState extends State<TripFareSummery> {
  bool _isShareLoading = false;

  // Fonction pour partager la position
  Future<void> _shareLocation() async {
    try {
      setState(() => _isShareLoading = true);
      
      // Demander la permission de localisation
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Erreur',
          'Permission de localisation requise',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Obtenir la position actuelle
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Créer le lien de partage (Google Maps)
      String googleMapsUrl = 
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
      
      // Partager
      await Share.share(
        '📍 Ma position actuelle:\n\nLatitude: ${position.latitude}\nLongitude: ${position.longitude}\n\nOuvrir sur Google Maps:\n$googleMapsUrl',
        subject: 'Partage de position',
      );

      Get.snackbar(
        'Succès',
        'Position partagée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors du partage: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isShareLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      return GetBuilder<CouponController>(builder: (couponController) {
        return GetBuilder<PaymentController>(builder: (paymentController) {
          double total = 0;
          if (widget.fromPayment) {
            total = rideController.finalFare!.paidFare! + double.parse(paymentController.tipAmount);
          } else {
            total = rideController.tripDetails?.paidFare ?? 0;
          }

          // ✅ IMPORTANT: Utiliser directement le getter du RideController
          // Ce getter se met à jour automatiquement via GetBuilder
          bool isRideStarted = rideController.isRideStarted;
          
          // 🔍 DEBUG - À LAISSER temporairement pour vérifier
          print('═' * 60);
          print('🔍 DEBUG TripFareSummery - VALEURS ACTUELLES:');
          print('   • isRideStarted (getter): $isRideStarted');
          print('   • currentRideState: ${rideController.currentRideState}');
          print('   • tripDetails?.currentStatus: ${rideController.tripDetails?.currentStatus}');
          print('   • fromPayment: ${widget.fromPayment}');
          print('   • tripDetails != null: ${rideController.tripDetails != null}');
          print('═' * 60);

          return Column(
            children: [
              // ✅ BOUTON DE PARTAGE DE POSITION
              // Visible SEULEMENT si: fromPayment=true ET isRideStarted=true
              if (widget.fromPayment && isRideStarted &&
    rideController.finalFare?.currentStatus != 'completed')
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  child: GestureDetector(
                    onTap: _isShareLoading ? null : _shareLocation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault,
                        horizontal: Dimensions.paddingSizeDefault,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isShareLoading)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          else
                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text(
                            'Partager ma position'.tr,
                            style: textMedium.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  color: widget.fromPayment ? null : Theme.of(context).hintColor.withValues(alpha:0.07),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(children: [
                  if(!widget.fromPayment)
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        Image.asset(Images.farePrice, height: 15, width: 15, color: Theme.of(context).textTheme.bodyMedium?.color),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Text('fare'.tr, style: textRegular.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: Dimensions.fontSizeDefault,
                        )),
                      ]),

                      Row(children: [
                        if(widget.discountAmount != null && widget.discountAmount!.toDouble() > 0)
                          Text(PriceConverter.convertPrice(widget.tripFare!),
                            style: textRobotoBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Theme.of(context).hintColor,
                            ),
                          ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
                          ),
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          child: Text(' ${PriceConverter.convertPrice(
                              widget.discountAmount != null && widget.discountAmount!.toDouble() > 0 ? widget.discountFare! : widget.tripFare!)}',
                            style: textRobotoBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ])
                    ]),

                  if(widget.fromPayment)...[
                    rideController.finalFare!.discountAmount!.toDouble() > 0 ?
                    Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      child: Row(children: [
                        SizedBox(width: Dimensions.iconSizeSmall, child: Image.asset(
                          Images.farePrice, color: Theme.of(context).primaryColor,
                        )),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(child: Row(children: [
                          Text('fare_fee'.tr, style: textMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                          )),

                          Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error.withValues(alpha:0.10),
                                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeExtraSmall,
                              ),
                              margin: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                              child: Text(
                                (rideController.finalFare?.discount == null) && ((rideController.finalFare?.discountAmount ?? 0 ) > 0) ?
                                '${PriceConverter.convertPrice(rideController.finalFare!.discountAmount!.toDouble())} ${'off'.tr}' :
                                rideController.finalFare!.discount!.discountAmountType == 'percentage' ?
                                '${rideController.finalFare!.discount!.discountAmount}% ${'off'.tr}' :
                                '${PriceConverter.convertPrice(rideController.finalFare!.discount!.discountAmount!.toDouble())} ${'off'.tr}',
                                style: textRobotoRegular.copyWith(color: Theme.of(context).colorScheme.error),
                              )
                          )
                        ])),

                        Text(
                          PriceConverter.convertPrice(rideController.finalFare?.distanceWiseFare ?? 0),
                          style: textRobotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            decorationColor: Theme.of(context).hintColor,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),

                        Text(
                          ' ${PriceConverter.convertPrice(
                              rideController.finalFare!.distanceWiseFare! -
                                  rideController.finalFare!.discountAmount!)}',
                          style: textRobotoRegular.copyWith(color: Theme.of(context).primaryColor),
                        ),

                      ]),
                    ) :

                    PaymentItemInfoWidget(
                      icon: Images.farePrice,
                      title: 'fare_fee'.tr,
                      amount: rideController.finalFare?.distanceWiseFare ?? 0,
                    ),
                  ],

                  if(widget.fromPayment && !widget.fromParcel && rideController.finalFare!.cancellationFee!.toDouble() > 0)
                    PaymentItemInfoWidget(
                      icon: Images.idleHourIcon,
                      title: 'cancellation_price'.tr,
                      amount: rideController.finalFare?.cancellationFee ?? 0,
                    ),

                  if(widget.fromPayment && !widget.fromParcel && rideController.finalFare!.idleFee!.toDouble() > 0)
                    PaymentItemInfoWidget(
                      icon: Images.idleHourIcon,
                      title: 'idle_price'.tr,
                      amount: rideController.finalFare?.idleFee ?? 0,
                    ),

                  if(widget.fromPayment && !widget.fromParcel && rideController.finalFare!.delayFee!.toDouble() > 0)
                    PaymentItemInfoWidget(
                      icon: Images.waitingPrice,
                      title: 'delay_price'.tr,
                      amount: rideController.finalFare?.delayFee ?? 0,
                    ),

                  if(widget.fromPayment && rideController.finalFare!.couponAmount!.toDouble() > 0)
                    PaymentItemInfoWidget(
                      icon: Images.profileMyWallet,
                      title: 'coupon_discount'.tr,
                      amount: rideController.finalFare?.couponAmount ?? 0,
                      discount: true,
                    ),

                  if(widget.fromPayment && rideController.finalFare!.vatTax!.toDouble() > 0)
                    PaymentItemInfoWidget(
                      icon: Images.farePrice,
                      title: 'vat_tax'.tr,
                      amount: rideController.finalFare?.vatTax ?? 0,
                    ),

                  if(widget.fromPayment && double.parse(paymentController.tipAmount) > 0)
                    PaymentItemInfoWidget(
                      icon: Images.farePrice, title: 'tips'.tr,
                      amount: double.parse(paymentController.tipAmount),
                      toolTipText: 'tips_tooltip',
                    ),

                  if(widget.fromPayment)
                    PaymentItemInfoWidget(title: 'sub_total'.tr, amount: total, isSubTotal: true),

                  if(!widget.fromPayment)
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                  if(widget.fromPayment)
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                ]),
              ),

              // ✅ BOUTON D'ANNULATION - Visible SEULEMENT si la course n'a PAS démarré
              if (widget.fromPayment && !isRideStarted)
                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                  child: GestureDetector(
                    onTap: () {
                      // Logique d'annulation
                      Get.back();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                      child: Center(
                        child: Text(
                          'Annuler la course'.tr,
                          style: textMedium.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ✅ MESSAGE D'AVERTISSEMENT - Visible SEULEMENT si la course a démarré
              if (widget.fromPayment && isRideStarted)
                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Colors.orange),
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Text(
                            'La course a démarré. Annulation non disponible.'.tr,
                            style: textRegular.copyWith(
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        });
      });
    });
  }
}

