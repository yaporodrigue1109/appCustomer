import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/address/widgets/address_item_card.dart';
import 'package:ride_sharing_user_app/features/home/widgets/address_shimmer.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/address/screens/add_new_address.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';

enum AddressPage{home, sender, receiver}

class HomeMyAddress extends StatefulWidget {
  final String? title;
  final AddressPage? addressPage;
final Function(Address)? onAddressSelected; 
  const HomeMyAddress({super.key, this.title, this.addressPage,this.onAddressSelected,});

  @override
  State<HomeMyAddress> createState() => _HomeMyAddressState();
}

class _HomeMyAddressState extends State<HomeMyAddress> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddressController>(builder: (addressController) {
      return Container(
        padding: const EdgeInsets.all(Dimensions.paddingSize),
        decoration: BoxDecoration(
            // color:
            // (
            //     addressController.addressList != null &&
            //         addressController.addressList!.isNotEmpty
            // ) ?
            // Theme.of(context).primaryColor.withValues(alpha:0.2) : null
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
             widget.title ?? 'address_recente'.tr,
            style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault,
            color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.9) : null),
          ),

          // if(addressController.addressList != null && addressController.addressList!.isNotEmpty)
          //   Text('saved_address_for_your_trip'.tr, style: textRegular.copyWith(
          //       fontSize: Dimensions.fontSizeSmall,
          //       color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.9) : null
          //   )),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          addressController.addressList != null ?
          addressController.addressList!.isNotEmpty ?
          // SizedBox(
          //   height: Get.width *0.15,
          //   child: ListView.builder(
          //     itemCount: addressController.addressList?.length,
          //     padding: EdgeInsets.zero,
          //     scrollDirection: Axis.horizontal,
          //     itemBuilder: (context,index) {
          //       return AddressItemCard(
          //         address: addressController.addressList![index],
          //           onAddressSelected: widget.onAddressSelected,
          //       );
          //     },
          //   ),
          // ) :
// ListView.builder(
//   itemCount: addressController.addressList?.length,
//   padding: EdgeInsets.zero,
//   shrinkWrap: true,
//   physics: const NeverScrollableScrollPhysics(),
//   itemBuilder: (context, index) {
//     final address = addressController.addressList![index];
//     return InkWell(
//       onTap: () {
//         if (widget.onAddressSelected != null) {
//           widget.onAddressSelected!(address);
//         } else {
//           Get.find<LocationController>().getZone(
//             address.latitude.toString(),
//             address.longitude.toString(),
//           ).then((value) {
//             if (value.isSuccess) {
//               Get.to(() => SetDestinationScreen(address: address));
//             } else {
//               showCustomSnackBar('service_not_available_in_this_area'.tr);
//             }
//           });
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall), 
//         padding: const EdgeInsets.symmetric(
//           horizontal: Dimensions.paddingSizeDefault,
//           vertical: Dimensions.paddingSizeSmall,
//         ),
//         decoration: BoxDecoration(
//           color: Get.isDarkMode
//               ? Theme.of(context).scaffoldBackgroundColor
//               : Theme.of(context).cardColor,
//           border: Border.all(
//             color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
//             width: 1,
//           ),
//           borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Image.asset(
//                 address.addressLabel == 'home'
//                     ? Images.homeIcon
//                     : address.addressLabel == 'office'
//                         ? Images.workIcon
//                         : Images.otherIcon,
//                 color: Theme.of(context).primaryColor,
//                 height: 18,
//                 width: 18,
//               ),
//             ),
//             const SizedBox(width: Dimensions.paddingSizeDefault),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     address.addressLabel!.tr,
//                     style: textBold.copyWith(
//                       fontSize: Dimensions.fontSizeDefault,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     address.address ?? '',
//                     style: textRegular.copyWith(
//                       fontSize: Dimensions.fontSizeSmall,
//                       color: Colors.grey[600],
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.chevron_right,
//               color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
//               size: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   },
// ):

ListView.builder(
  itemCount: math.min(5, addressController.addressList!.length), // ✅ Max 5
  padding: EdgeInsets.zero,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemBuilder: (context, index) {
    final address = addressController.addressList![index];
    return InkWell(
      onTap: () {
        if (widget.onAddressSelected != null) {
          widget.onAddressSelected!(address);
        } else {
          Get.find<LocationController>().getZone(
            address.latitude.toString(),
            address.longitude.toString(),
          ).then((value) {
            if (value.isSuccess) {
              Get.to(() => SetDestinationScreen(address: address));
            } else {
              showCustomSnackBar('service_not_available_in_this_area'.tr);
            }
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Get.isDarkMode
              ? Theme.of(context).scaffoldBackgroundColor
              : Theme.of(context).cardColor,
          border: Border.all(width: 1),
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                address.addressLabel == 'home'
                    ? Images.homeIcon
                    : address.addressLabel == 'office'
                        ? Images.workIcon
                        : Images.otherIcon,
                color: Theme.of(context).primaryColor,
                height: 18,
                width: 18,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Text(
                address.address ?? '',          // ✅ Uniquement l'adresse
                style: textBold.copyWith(       // ✅ En gras
                  fontSize: Dimensions.fontSizeDefault,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  },
):

          InkWell(
            onTap: ()=> Get.to(() =>   const AddNewAddress(address: null)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                color : Get.isDarkMode ?
                Theme.of(context).scaffoldBackgroundColor :
                Theme.of(context).colorScheme.onSecondary.withValues(alpha:.03),
                border: Border.all(
                    color: Get.isDarkMode ?
                    Theme.of(context).canvasColor :
                    Theme.of(context).primaryColor.withValues(alpha:.15),
                )
              ),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Container(
                    width: Dimensions.buttonSize, height: Dimensions.buttonSize,
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Theme.of(context).cardColor :
                      Theme.of(context).primaryColor.withValues(alpha:.07),
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    ),
                    child: Center(child: Icon(Icons.add, color: Theme.of(context).primaryColor)),
                  ),
                ),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('add_address'.tr, style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.9) : null
                  )),

                  Text(
                    'save_your_address_for_quick_trip'.tr,
                    style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.8) : null
                    ),
                  ),
                ])),

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: SizedBox(width: 100, child: Image.asset(Images.addNewAddress)),
                ),
              ]),
            ),
          ) :
          const AddressShimmer(),
        ]),
      );
    });
  }
}

