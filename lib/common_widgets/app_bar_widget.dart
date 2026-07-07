
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/calender_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/drop_down_widget.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_menu.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showActionButton;
  final Function()? onBackPressed;
  final bool centerTitle;
  final double? fontSize;
  final bool isHome;
  final String? subTitle;
  final bool showTripHistoryFilter;
  final bool showDiscountHint;
  final bool showBonusHint;
  final Widget? expandableMenu; // NOUVEAU : Widget pour le menu extensible
  
  const AppBarWidget({
    super.key,
    required this.title,
    this.subTitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = false,
    this.showActionButton = true,
    this.isHome = false,
    this.showTripHistoryFilter = false,
    this.fontSize,
    this.showDiscountHint = false,
    this.showBonusHint = false,
    this.expandableMenu, // NOUVEAU : Paramètre optionnel
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(150.0),
      child: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        
        // Utiliser flexibleSpace pour un contrôle total
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            height: 70,
            child: Row(
              children: [
                // Partie image (40% de l'espace) - SEULEMENT quand il n'y a pas de bouton retour
                if (!showBackButton)
                  Container(
                    width: Get.width * 0.3, // 40% de l'écran pour l'image
                    height: 70,
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      Images.icon,
                      width: 100, // Taille fixe agrandie
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                
                // Bouton retour - SEULEMENT quand showBackButton est true
                if (showBackButton)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Get.isDarkMode 
                        ? Colors.white.withValues(alpha: 0.8) 
                        : Colors.white,
                    onPressed: () => onBackPressed != null 
                        ? onBackPressed!() 
                        : Navigator.canPop(context) 
                            ? Get.back() 
                             : Get.offAll(() => const ExpandableMenu()),
                        //    : Get.offAll(() => const DashboardScreen()),

                  ),
                
                // Partie titre (prend tout l'espace restant)
                Expanded(
                  child: InkWell(
                    onTap: isHome ? _onHomeTap : null,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: !showBackButton ? Dimensions.paddingSizeSmall : 0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sous-titre
                          if (subTitle != null)
                            Text(
                              subTitle ?? '',
                              style: textRegular.copyWith(
                                fontSize: fontSize ?? 
                                    (isHome ? Dimensions.fontSizeLarge : Dimensions.fontSizeLarge),
                                color: Get.isDarkMode 
                                    ? Colors.white.withValues(alpha: 0.8) 
                                    : Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          
                          // Titre principal avec filtres
                          Row(
                            mainAxisAlignment: _getAlignment(),
                            children: [
                              Expanded(
                                child: Text(
                                  title.tr,
                                  style: textBold.copyWith(
                                    fontSize: fontSize ?? Dimensions.fontSizeLarge,
                                    color: Get.isDarkMode 
                                        ? Colors.white.withValues(alpha: 0.9) 
                                        : Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (showTripHistoryFilter) const _TripHistoryFilter(),
                              if (showBonusHint) const _BonusHintWidget(),
                              if (showDiscountHint) const _DiscountHint(),
                            ],
                          ),
                          
                          // Adresse pour la page d'accueil
                          if (isHome)
                            GetBuilder<LocationController>(
                              builder: (locationController) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.place_outlined,
                                        color: Get.isDarkMode 
                                            ? Colors.white.withValues(alpha: 0.8) 
                                            : Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeSeven),
                                      Expanded(
                                        child: Text(
                                          locationController.getUserAddress()?.address ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textRegular.copyWith(
                                            color: Get.isDarkMode 
                                                ? Colors.white.withValues(alpha: 0.8) 
                                                : Colors.white,
                                            fontSize: Dimensions.fontSizeExtraSmall,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // NOUVEAU : Menu extensible à droite
                if (expandableMenu != null) ...[
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  expandableMenu!,
                ],
                
                // Espace pour équilibrer quand il n'y a pas de bouton retour ni de filtres
                if (!showBackButton && !showTripHistoryFilter && !showBonusHint && !showDiscountHint && expandableMenu == null)
                  SizedBox(width: Get.width * 0.15),
              ],
            ),
          ),
        ),
        
        // Ces propriétés doivent être vides car on utilise flexibleSpace
        title: null,
        leading: null,
        actions: null,
        centerTitle: centerTitle,
        excludeHeaderSemantics: true,
      ),
    );
  }

  // Méthode pour gérer le tap sur l'écran d'accueil
  void _onHomeTap() {
    Address? currentAddress = Get.find<LocationController>().getUserAddress();
    if (currentAddress == null || currentAddress.longitude == null) {
      Get.to(() => const AccessLocationScreen());
    } else {
      Get.find<LocationController>().updatePosition(
        LatLng(currentAddress.latitude!, currentAddress.longitude!),
        false,
        LocationType.location,
      );
      Get.to(() => PickMapScreen(
        type: LocationType.accessLocation,
        address: currentAddress,
      ));
    }
  }

  MainAxisAlignment _getAlignment() {
    if (isHome) {
      return MainAxisAlignment.start;
    } else if (showTripHistoryFilter || showBonusHint || showDiscountHint) {
      return MainAxisAlignment.spaceBetween;
    } else {
      return MainAxisAlignment.center;
    }
  }

  @override
  Size get preferredSize => const Size(Dimensions.webMaxWidth, 150);
}

// Widget pour le filtre d'historique des trajets
class _TripHistoryFilter extends StatelessWidget {
  const _TripHistoryFilter();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TripController>(builder: (tripController) {
      return SizedBox(
        width: 45,
        child: Padding(
          padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
          child: DropDownWidget<int>(
            showText: false,
            showLeftSide: false,
            menuItemWidth: 120,
            icon: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.filter_list_sharp,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
            ),
            maxListHeight: 200,
            items: tripController.filterList.map((item) => CustomDropdownMenuItem<int>(
              value: tripController.filterList.indexOf(item),
              child: Text(
                item.tr,
                style: textRegular.copyWith(
                  color: Get.isDarkMode
                      ? Get.find<TripController>().filterIndex ==
                              Get.find<TripController>().filterList.indexOf(item)
                          ? Theme.of(context).primaryColor
                          : Colors.white
                      : Get.find<TripController>().filterIndex ==
                              Get.find<TripController>().filterList.indexOf(item)
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            )).toList(),
            hintText: tripController.filterList[Get.find<TripController>().filterIndex].tr,
            borderRadius: 5,
            onChanged: (int selectedItem) {
              if (selectedItem == tripController.filterList.length - 1) {
                showDialog(
                  context: context,
                  builder: (_) => CalenderWidget(
                    onChanged: (value) => Get.back(),
                  ),
                );
              } else {
                tripController.setFilterTypeName(selectedItem);
              }
            },
          ),
        ),
      );
    });
  }
}

// Widget pour l'indice de bonus
class _BonusHintWidget extends StatelessWidget {
  const _BonusHintWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: Get.width * 0.05, left: Get.width * 0.05),
      child: InkWell(
        onTap: () => Get.bottomSheet(
          SizedBox(
            width: Get.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Text(
                  'we_do_the_best_for_you'.tr,
                  style: textSemiBold,
                ),
                Divider(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.15),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                  ),
                  child: Text(
                    'if_you_have_multiple_eligible_bonus_we_will_automatically_apply_the_maximum'.tr,
                    style: textRegular.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).cardColor,
        ),
        child: Icon(
          Icons.info,
          color: Theme.of(context).cardColor,
        ),
      ),
    );
  }
}

// Widget pour l'indice de réduction
class _DiscountHint extends StatelessWidget {
  const _DiscountHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: Get.width * 0.05, left: Get.width * 0.05),
      child: InkWell(
        onTap: () => Get.bottomSheet(
          SizedBox(
            width: Get.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Text(
                  'we_do_the_best_for_you'.tr,
                  style: textSemiBold,
                ),
                Divider(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.15),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                  ),
                  child: Text(
                    'if_you_have_multiple_eligible_discounts_we_will_automatically_apply_the_discount_that_will_save_you_the_most_to_your_next_trip'.tr,
                    style: textRegular.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).cardColor,
        ),
        child: Icon(
          Icons.info,
          color: Theme.of(context).cardColor,
        ),
      ),
    );
  }
}