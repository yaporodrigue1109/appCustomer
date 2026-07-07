

import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_asset_image_widget.dart';
import 'package:ride_sharing_user_app/features/settings/widget/language_select_bottomsheet.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/screens/reset_password_screen.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/settings/domain/html_enum_types.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_bottomsheet_widget.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  @override
  void initState() {
    Get.find<LocalizationController>().setInitialIndex();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String languageName = '';
    AppConstants.languages.any((element){
      if(element.languageCode == Get.find<LocalizationController>().locale.languageCode ){
        languageName = element.languageName;
        return true;
      }
      return false;
    });
    return SafeArea(
      top: false,
      child: Scaffold(body: BodyWidget(
        appBar: AppBarWidget(title: 'settings'.tr, showBackButton: true),
        body: SingleChildScrollView(  // SEUL CHANGEMENT ICI
          padding: const EdgeInsets.all(13),
          child: Column(children: [
            // LIGNE LANGUE
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.paddingSize),
                border: Border.all(color: Theme.of(context).primaryColor, width: .5)
              ),
              child: Row(
                children: [
                  // Icône
                  CustomAssetImageWidget(
                    Images.languageSetting,  
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeLarge),
                  
                  // Texte "Language" avec Expanded
                  Expanded(
                    child: Text(
                      'language'.tr, 
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  
                  // Langue sélectionnée + flèche
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        isDismissible: false, 
                        enableDrag: false,
                        backgroundColor: Theme.of(context).cardColor, 
                        context: context, 
                        builder: (context) => const LanguageSelectBottomSheet(),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 80,
                          ),
                          child: Text(
                            languageName,
                            style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Icon(
                          Icons.arrow_forward_ios_outlined,
                          size: Dimensions.fontSizeLarge,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: Dimensions.paddingSize),

            // LIGNE THÈME
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.paddingSize),
                border: Border.all(color: Theme.of(context).primaryColor, width: .5)
              ),
              child: Row(children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      'theme'.tr,
                      style: textRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    leading: CustomAssetImageWidget(
                      Images.themeLogo, 
                      width: 20, 
                      color: Theme.of(context).primaryColor
                    ),
                  ),
                ),

                GetBuilder<ThemeController>(builder: (themeController){
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FlutterSwitch(
                      value: themeController.darkTheme,
                      onToggle: (value){
                        themeController.changeThemeSetting(value);
                      },
                      width: 60, 
                      height: 30,
                      activeIcon: Image.asset(
                        Images.darkThemeIcon, 
                        color: Theme.of(context).primaryColor
                      ),
                      activeToggleColor: Theme.of(context).cardColor,
                      inactiveToggleColor: Theme.of(context).cardColor,
                      inactiveIcon: Image.asset(
                        Images.lightThemeIcon, 
                        color: Theme.of(context).primaryColor, 
                        height: 60, 
                        width: 60, 
                        scale: 0.5
                      ),
                      inactiveColor: Colors.grey.withOpacity(0.25),
                      activeColor: Theme.of(context).primaryColor.withOpacity(0.25),
                    ),
                  );
                })
              ]),
            ),

            // ListTile(
            //   onTap: () => Get.to(() =>  const ResetPasswordScreen(
            //     fromChangePassword: true, 
            //     phoneNumber: ''
            //   )),
            //   title: Text(
            //     'change_password'.tr,
            //     style: textMedium.copyWith(
            //       color: Theme.of(context).textTheme.bodyLarge!.color
            //     )
            //   ),
            //   leading: CustomAssetImageWidget(
            //     Images.passwordSvg, 
            //     width: 20, 
            //     height: 20, 
            //     color: Theme.of(context).primaryColor
            //   ),
            // ),

            ListTile(
              onTap: () => Get.to(() =>  PolicyScreen(
                htmlType: HtmlType.privacyPolicy,
                image: Get.find<ConfigController>().config?.privacyPolicy?.image??'',
              )),
              title: Text(
                'privacy_policy'.tr,
                style: textMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge!.color
                )
              ),
              leading: CustomAssetImageWidget(
                Images.privacyPolicyIcon, 
                width: 20, 
                height: 20, 
                color: Theme.of(context).primaryColor
              ),
            ),
            
            ListTile(
              onTap: () => Get.to(() =>  PolicyScreen(
                htmlType: HtmlType.termsAndConditions
              )),
              title: Text(
                'terms_and_condition'.tr,
                style: textMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge!.color
                )
              ),
              leading: CustomAssetImageWidget(
                Images.termsAndCondition, 
                width: 20, 
                height: 20, 
                color: Theme.of(context).primaryColor
              ),
            ),
            
             ListTile(
                onTap: () => Get.to(() =>  PolicyScreen(
                  htmlType: HtmlType.legal,
                  image: Get.find<ConfigController>().config?.legal?.image??'',
                )),
              title: Text(
                'legal'.tr,
                style: textMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge!.color
                )
              ),
              leading: CustomAssetImageWidget(
                Images.privacyPolicy, 
                width: 20, 
                height: 20, 
                color: Theme.of(context).primaryColor
              ),
            ),

            ListTile(
              onTap: () {
                Get.bottomSheet(
                  GetBuilder<AuthController>(builder: (authController){
                    return ConfirmationBottomsheetWidget(
                      icon: Images.exitIcon,
                      title: 'logout'.tr,
                      description: 'do_you_want_to_log_out_this_account'.tr,
                      iconColor: Theme.of(context).cardColor,
                      isLoading: authController.isLoading,
                      onYesPressed: (){
                        Get.find<AuthController>().logOut();
                      },
                      onNoPressed: () => Get.back(),
                    );
                  })
                );
              },
              title: Text(
                'logout'.tr,
                style: textMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge!.color
                )
              ),
              leading: CustomAssetImageWidget(
                Images.profileLogout, 
                width: 20, 
                height: 20, 
                color: Theme.of(context).primaryColor
              ),
            ),
            
            // ListTile(
            //   onTap: () { 
            //     Get.bottomSheet(
            //       GetBuilder<AuthController>(builder: (authController){
            //         return ConfirmationBottomsheetWidget(
            //           icon: Images.exitIcon,
            //           title: 'delete_account'.tr,
            //           description: 'are_you_sure_permanent_delete_smg'.tr,
            //           iconColor: Theme.of(context).cardColor,
            //           isLoading: authController.isLoading,
            //           onYesPressed: (){
            //             Get.find<AuthController>().permanentlyDelete();
            //           },
            //           onNoPressed: () => Get.back(),
            //         );
            //       })
            //     );
            //   },
            //   title: Text(
            //     'permanently_delete_account'.tr,
            //     style: textMedium.copyWith(
            //       color: Theme.of(context).textTheme.bodyLarge!.color
            //     )
            //   ),
            //   leading: CustomAssetImageWidget(
            //     Images.deleteAccountIcon, 
            //     width: 20, 
            //     height: 20, 
            //     color: Theme.of(context).primaryColor
            //   ),
            // ),
          ]),
        ),
      )),
    );
  }
}