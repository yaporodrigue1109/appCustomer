
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/widget/schedule_date_time_picker_widget.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/extensin_helper.dart';
import 'package:ride_sharing_user_app/helper/ride_controller_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class PickupTimeDateWidget extends StatelessWidget {
  const PickupTimeDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController){
      return Column(children: [
        InkWell(
          onTap: (){
            if(Get.find<ConfigController>().config?.scheduleTripStatus ?? false){
              Get.bottomSheet(const ScheduleDateTimePickerWidget(fromSetDestinationScreen: true),enableDrag: false, isScrollControlled: true);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)
            ),
            child: rideController.rideType == RideType.scheduleRide ?
            // Mode programmé
            FittedBox(
              fit: BoxFit.scaleDown,
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: Dimensions.paddingSizeExtraSmall,
                      children: [
                        Icon(Icons.calendar_today_outlined, 
                          size: 18, 
                          color: Theme.of(context).primaryColor
                        ),
                        Text(
                          DateFormat('EEE, d MMM').format(
                            RideControllerHelper.dateFormatToShow(rideController.scheduleTripDate)
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    Container(
                      height: 20,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: context.customThemeColors.blackColor.withValues(alpha: 0.1),
                    ),

                    Row(
                      spacing: Dimensions.paddingSizeExtraSmall,
                      children: [
                        Icon(Icons.access_time, 
                          size: 18, 
                          color: Theme.of(context).hintColor.withValues(alpha: 0.9)
                        ),
                        Text(
                          DateFormat('hh:mm a').format(
                            RideControllerHelper.timeFormatToShow(rideController.scheduleTripTime)
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ) :
            // Mode "plus tard"
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                spacing: Dimensions.paddingSizeSmall,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(
                    'save_for_later'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 14, 
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
      ]);
    });
  }
}