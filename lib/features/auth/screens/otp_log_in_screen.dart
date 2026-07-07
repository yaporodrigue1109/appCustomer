

/*

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/settings/domain/html_enum_types.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';
import 'package:ride_sharing_user_app/helper/svg_image_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/screens/verification_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';

class OtpLoginScreen extends StatefulWidget {
  final bool fromSignIn;
  const OtpLoginScreen({super.key, this.fromSignIn = false});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  TextEditingController phoneController = TextEditingController();
  FocusNode phoneNode = FocusNode();
  bool _termsAccepted = false;
  
  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().countryDialCode = CountryCode.fromCountryCode(
      Get.find<ConfigController>().config!.countryCode!
    ).dialCode!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false, 
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        body: GetBuilder<AuthController>(builder: (authController){
          final bool isButtonEnabled = _isButtonEnabled(authController);
          
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Image.asset(Images.logoWithName, height: 75, width: 200)),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    FutureBuilder<String>(
                        future: loadSvgAndChangeColors(Images.logoWithName, Theme.of(context).primaryColor),
                        builder: (context, snapshot){
                          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                            return SvgPicture.string(
                                snapshot.data!
                            );
                          }
                          return SvgPicture.asset(Images.logoWithName);
                        }
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                   Center(child: Text(
                      'log_in'.tr,
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeTwenty),
                    ),), 
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(
                      'please_enter_your_mobile_number_to_continue'.tr,
                      style: textMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),fontSize: Dimensions.fontSizeSmall),
                      maxLines: 2,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSignUp),

                    CustomTextField(
                      isCodePicker: true,
                      hintText: 'phone'.tr,
                      inputType: TextInputType.number,
                      countryDialCode: authController.countryDialCode,
                      controller: phoneController,
                      focusNode: phoneNode,
                      inputAction: TextInputAction.done,
                      onCountryChanged: (CountryCode countryCode){
                        authController.countryDialCode = countryCode.dialCode!;
                        authController.setCountryCode(countryCode.dialCode!);
                      },
                      autoFocus: phoneController.text.isEmpty,
                      onChanged: (value) {
                        setState(() {}); // Pour recalculer l'état du bouton
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Case à cocher pour les conditions générales
                    Row(
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                          activeColor: Theme.of(context).primaryColor,
                          checkColor: Colors.white,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => PolicyScreen(
                                htmlType: HtmlType.termsAndConditions, 
                                image: Get.find<ConfigController>().config?.termsAndConditions?.image??''
                              ));
                            },
                            child: Text(
                              'please_accept_terms_and_conditions'.tr,
                              style: textMedium.copyWith(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                                decorationColor: Theme.of(context).primaryColor,
                              ),
                              maxLines: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // BOUTON avec vérification d'activation
                    authController.isOtpSending
                        ? Center(
                            child: SpinKitCircle(
                              color: Theme.of(context).primaryColor,
                              size: 40.0,
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isButtonEnabled ? () async {
                                await _handleContinueButton(authController);
                              } : null,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.disabled)) {
                                      return Colors.grey.shade300;
                                    }
                                    return Theme.of(context).primaryColor;
                                  },
                                ),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                              child: Text(
                                'continue'.tr,
                                style: textMedium.copyWith(
                                  color: isButtonEnabled ? Colors.white : Colors.grey.shade600,
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                              ),
                            ),
                          ),

                    SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
  
  // Méthode pour vérifier si le bouton doit être activé
  bool _isButtonEnabled(AuthController authController) {
    String phone = phoneController.text.trim();
    String fullPhone = authController.countryDialCode + phone;
    
    return phone.isNotEmpty && 
           GetUtils.isPhoneNumber(fullPhone) && 
           _termsAccepted &&
           !authController.isOtpSending;
  }

  // Méthode pour gérer l'action du bouton
  Future<void> _handleContinueButton(AuthController authController) async {
    String phone = phoneController.text.trim();
    
    // Validation
    if (phone.isEmpty) {
      showCustomSnackBar('enter_your_phone_number'.tr);
      FocusScope.of(context).requestFocus(phoneNode);
      return;
    }
    
    String fullPhone = authController.countryDialCode + phone;
    
    if (!GetUtils.isPhoneNumber(fullPhone)) {
      showCustomSnackBar('phone_number_is_not_valid'.tr);
      return;
    }
    
    // Vérifier que les conditions sont acceptées
    if (!_termsAccepted) {
      showCustomSnackBar('please_accept_terms_and_conditions'.tr);
      return;
    }
    
    // Envoyer l'OTP
    try {
      var response = await authController.sendOtp(fullPhone);
      
      if (response.statusCode == 200) {
        Get.to(() => VerificationScreen(
          number: fullPhone,
          fromOtpLogin: widget.fromSignIn,
        ));
      } else {
        Get.to(() => VerificationScreen(
          number: fullPhone,
          fromOtpLogin: widget.fromSignIn,
        ));
      }
    } catch (e) {
      Get.to(() => VerificationScreen(
        number: fullPhone,
        fromOtpLogin: widget.fromSignIn,
      ));
    }
  }

  // Méthode utilitaire pour afficher les snackbars
  void showCustomSnackBar(String message, {bool isError = true}) {
    Get.showSnackbar(GetSnackBar(
      backgroundColor: isError ? Colors.red : Colors.green,
      message: message,
      duration: Duration(seconds: 3),
      snackStyle: SnackStyle.FLOATING,
      margin: EdgeInsets.all(10),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    ));
  }
}


*/


import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/settings/domain/html_enum_types.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';
import 'package:ride_sharing_user_app/helper/svg_image_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/screens/verification_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';

class OtpLoginScreen extends StatefulWidget {
  final bool fromSignIn;
  const OtpLoginScreen({super.key, this.fromSignIn = false});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  TextEditingController phoneController = TextEditingController();
  FocusNode phoneNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().countryDialCode = CountryCode.fromCountryCode(
      Get.find<ConfigController>().config!.countryCode!
    ).dialCode!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false, 
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        body: GetBuilder<AuthController>(builder: (authController){
          final bool isButtonEnabled = _isButtonEnabled(authController);
          
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Image.asset(Images.logoWithName, height: 75, width: 200)),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    FutureBuilder<String>(
                        future: loadSvgAndChangeColors(Images.logoWithName, Theme.of(context).primaryColor),
                        builder: (context, snapshot){
                          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                            return SvgPicture.string(
                                snapshot.data!
                            );
                          }
                          return SvgPicture.asset(Images.logoWithName);
                        }
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                   Center(child: Text(
                      'log_in'.tr,
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeTwenty),
                    ),), 
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(
                      'please_enter_your_mobile_number_to_continue'.tr,
                      style: textMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),fontSize: Dimensions.fontSizeSmall),
                      maxLines: 2,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSignUp),

                    CustomTextField(
                      isCodePicker: true,
                      hintText: 'phone'.tr,
                      inputType: TextInputType.number,
                      countryDialCode: authController.countryDialCode,
                      controller: phoneController,
                      focusNode: phoneNode,
                      inputAction: TextInputAction.done,
                      onCountryChanged: (CountryCode countryCode){
                        authController.countryDialCode = countryCode.dialCode!;
                        authController.setCountryCode(countryCode.dialCode!);
                        setState(() {}); // Recalculer l'état du bouton
                      },
                      autoFocus: phoneController.text.isEmpty,
                      onChanged: (value) {
                        setState(() {}); // Pour recalculer l'état du bouton
                      },
                    ),
                    
                   
                    
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // BOUTON avec vérification d'activation
                    authController.isOtpSending
                        ? Center(
                            child: SpinKitCircle(
                              color: Theme.of(context).primaryColor,
                              size: 40.0,
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isButtonEnabled ? () async {
                                await _handleContinueButton(authController);
                              } : null,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.disabled)) {
                                      return Colors.grey.shade300;
                                    }
                                    return Theme.of(context).primaryColor;
                                  },
                                ),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                              child: Text(
                                'continue'.tr,
                                style: textMedium.copyWith(
                                  color: isButtonEnabled ? Colors.white : Colors.grey.shade600,
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                              ),
                            ),
                          ),

                    SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
  
  // Méthode pour vérifier si le bouton doit être activé
  bool _isButtonEnabled(AuthController authController) {
    String phone = phoneController.text.trim();
    
    // Vérifier que le numéro a exactement 10 chiffres
    bool hasTenDigits = phone.length == 10 && _containsOnlyDigits(phone);
    
    return phone.isNotEmpty && 
           hasTenDigits &&
           !authController.isOtpSending;
  }

  // Méthode pour vérifier si la chaîne ne contient que des chiffres
  bool _containsOnlyDigits(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }

  // Méthode pour gérer l'action du bouton
  Future<void> _handleContinueButton(AuthController authController) async {
    String phone = phoneController.text.trim();
    
    // Validation
    if (phone.isEmpty) {
      showCustomSnackBar('enter_your_phone_number'.tr);
      FocusScope.of(context).requestFocus(phoneNode);
      return;
    }
    
    // Vérifier que le numéro a exactement 10 chiffres
    if (phone.length != 10 || !_containsOnlyDigits(phone)) {
      showCustomSnackBar('phone_number_must_be_10_digits'.tr);
      return;
    }
    
    String fullPhone = authController.countryDialCode + phone;
    
    // Envoyer l'OTP
    try {
      var response = await authController.sendOtp(fullPhone);
      
      if (response.statusCode == 200) {
        Get.to(() => VerificationScreen(
          number: fullPhone,
          fromOtpLogin: widget.fromSignIn,
        ));
      } else {
        Get.to(() => VerificationScreen(
          number: fullPhone,
          fromOtpLogin: widget.fromSignIn,
        ));
      }
    } catch (e) {
      Get.to(() => VerificationScreen(
        number: fullPhone,
        fromOtpLogin: widget.fromSignIn,
      ));
    }
  }

  // Méthode utilitaire pour afficher les snackbars
  void showCustomSnackBar(String message, {bool isError = true}) {
    Get.showSnackbar(GetSnackBar(
      backgroundColor: isError ? Colors.red : Colors.green,
      message: message,
      duration: Duration(seconds: 3),
      snackStyle: SnackStyle.FLOATING,
      margin: EdgeInsets.all(10),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    ));
  }
}




















