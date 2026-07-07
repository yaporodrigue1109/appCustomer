/*
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/widgets/test_field_title.dart';
import 'package:ride_sharing_user_app/features/auth/screens/forgot_password_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/svg_image_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/domain/models/sign_up_body.dart';
import 'package:ride_sharing_user_app/features/settings/domain/html_enum_types.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final bool fromChangePassword;
  final String phoneNumber;
  const ResetPasswordScreen({super.key,  this.fromChangePassword = false, required this.phoneNumber});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController referralCodeController = TextEditingController();

  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final FocusNode oldPasswordFocus = FocusNode();
  final FocusNode phoneNode = FocusNode();
  final FocusNode fNameNode = FocusNode();
  final FocusNode lNameNode = FocusNode();
  final FocusNode referralNode = FocusNode();

  bool _isPhoneLocked = false;
    bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();

    final authController = Get.find<AuthController>();
    
    // Définir le code pays pour la Côte d'Ivoire
    authController.countryDialCode = '+225';
    
    // Si un numéro de téléphone est fourni, le traiter
    if (widget.phoneNumber.isNotEmpty) {
      _isPhoneLocked = true;
      _processPhoneNumber(widget.phoneNumber, authController);
    }
  }

  void _processPhoneNumber(String phoneNumber, AuthController authController) {
    // Le numéro vient sous la forme 225XXXXXXXXX
    // On veut enlever le 225 pour garder juste XXXXXXXXX
    
    print("Numéro reçu: $phoneNumber"); // Pour debug
    
    // Vérifier si le numéro commence par 225
    if (phoneNumber.startsWith('225')) {
      // Extraire le numéro sans le code pays
      String localNumber = phoneNumber.substring(1,4); // Enlève "225"
      
      print("Numéro local extrait: $localNumber"); // Pour debug
      
      // Définir le code pays comme +225
      authController.countryDialCode = '+225';
      
      // Mettre à jour le contrôleur avec le numéro local
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            phoneController.text = localNumber;
          });
        }
      });
    } else {
      // Si le numéro ne commence pas par 225, on le met tel quel
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            phoneController.text = phoneNumber;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: BodyWidget(
          appBar: AppBarWidget(
            title: widget.fromChangePassword ? 'change_password'.tr : 'sign_up'.tr, // 'reset_password'.tr,
            showBackButton: true, 
            centerTitle: true,
            onBackPressed: (){
              if(widget.fromChangePassword){
                Get.back();
              }else{
                Get.off(()=> const ForgotPasswordScreen());
              }
            },
          ),
          body: SingleChildScrollView(
            child: GetBuilder<AuthController>(builder: (authController){
              return Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                 /* FutureBuilder<String>(
                   // future: loadSvgAndChangeColors(Images.forgetPasswordGraphics, Theme.of(context).primaryColor),
                    future: loadSvgAndChangeColors(Images.signUpScreenLogoSvg, Theme.of(context).primaryColor),
                    builder: (context, snapshot){
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        return SvgPicture.string(snapshot.data!);
                      }
                   //   return SvgPicture.asset(Images.forgetPasswordGraphics);
                      return SvgPicture.asset(Images.signUpScreenLogoSvg);
                    }
                  ),*/
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Center(child: Text(
                   // 'set_your_password'.tr,
                   'sign_up'.tr,
                    style: textBold.copyWith(fontSize: Dimensions.fontSizeTwenty),
                  )),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(
                    //'create_a_new_password_to_secure_your_account'.tr,
                    'sign_up_message'.tr,
                    style: textMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),fontSize: Dimensions.fontSizeSmall),
                    maxLines: 2,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSignUp),

                  widget.fromChangePassword ?
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    TextFieldTitle(title: 'old_password'.tr),
                    CustomTextField(
                      hintText: 'password_hint'.tr,
                      inputType: TextInputType.text,
                      prefixIcon: Images.password,
                      isPassword: true,
                      controller: oldPasswordController,
                      focusNode: oldPasswordFocus,
                      nextFocus: passwordFocusNode,
                      inputAction: TextInputAction.next,
                    ),
                  ]) : const SizedBox(),

              TextFieldTitle(title: 'phone'.tr, isRequired: true),

                  // Utiliser un widget conditionnel pour verrouiller le champ
                  _isPhoneLocked 
                      ? _buildLockedPhoneField(authController)
                      : CustomTextField(
                         isCodePicker: true,
                          hintText: 'phone'.tr,
                          inputType: TextInputType.number,
                         countryDialCode: authController.countryDialCode,
                          controller: phoneController,
                          focusNode: phoneNode,
                          nextFocus: passwordFocusNode,
                          inputAction: TextInputAction.next,
                         onCountryChanged: (CountryCode countryCode){
                           authController.countryDialCode = countryCode.dialCode!;
                            authController.setCountryCode(countryCode.dialCode!);
                            FocusScope.of(context).requestFocus(phoneNode);
                          },
                        ),
 if (_isPhoneLocked) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, 
                               color: Theme.of(context).primaryColor, 
                               size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'phone_number_is_locked_for_security'.tr,
                              style: textRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],

                  TextFieldTitle(title: 'first_name'.tr, isRequired: true), 

                  CustomTextField(
                    capitalization: TextCapitalization.words,
                    hintText: 'first_name'.tr,
                    inputType: TextInputType.name,
                    prefixIcon: Images.person,
                    controller: fNameController,
                    focusNode: fNameNode,
                    nextFocus: lNameNode,
                    inputAction: TextInputAction.next,
                    autoFocus: fNameController.text.isEmpty,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  TextFieldTitle(title: 'last_name'.tr, isRequired: true),

                  CustomTextField(
                    capitalization: TextCapitalization.words,
                    hintText: 'last_name'.tr,
                    inputType: TextInputType.name,
                    prefixIcon: Images.person,
                    controller: lNameController,
                    focusNode: lNameNode,
                    nextFocus: phoneNode,
                    inputAction: TextInputAction.next,
                  ),

                 

                  // Message informatif si le numéro est verrouillé
                 
                  
                  if(Get.find<ConfigController>().config?.referralEarningStatus ?? false)...[
                    TextFieldTitle(title: 'refer_code'.tr),

                    CustomTextField(
                      hintText: 'refer_code'.tr,
                      inputType: TextInputType.text,
                      controller: referralCodeController,
                      focusNode: referralNode,
                      inputAction: TextInputAction.done,
                      prefixIcon: Images.referIcon,
                    ),
                  ],
const SizedBox(height: Dimensions.paddingSizeDefault),
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

                widget.fromChangePassword ?
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TextFieldTitle(title: 'password'.tr),
                  CustomTextField(
                    hintText: 'password_hint'.tr,
                    inputType: TextInputType.text,
                    prefixIcon: Images.password,
                    isPassword: true,
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    nextFocus: confirmPasswordFocusNode,
                    inputAction: TextInputAction.next,
                  ), 
                   ]) : const SizedBox(),

                  widget.fromChangePassword ?
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TextFieldTitle(title: 'confirm_password'.tr),
                  CustomTextField(
                    hintText: 'confirm_password'.tr,
                    inputType: TextInputType.text,
                    prefixIcon: Images.password,
                    controller: confirmPasswordController,
                    focusNode: confirmPasswordFocusNode,
                    inputAction: TextInputAction.done,
                    isPassword: true,
                  ),
                   ]) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeDefault * 3),

                  authController.isLoading ? 
                  Center(child: SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0)) : 
                  ButtonWidget(
                    buttonText: widget.fromChangePassword ? 'update'.tr : 'save'.tr,
                    onPressed: () {
                      String oldPassword = oldPasswordController.text;
                      String password = passwordController.text;
                      String confirmPassword = confirmPasswordController.text;
                      String fName = fNameController.text.trim();
                      String lName = lNameController.text.trim();
                      String phone = phoneController.text.trim();

                      // Vérifier que les conditions sont acceptées
                        if (!_termsAccepted) {
                          showCustomSnackBar('please_accept_terms_and_conditions'.tr);
                          return;
                        }
                      // Validation des champs
                      if(fName.isEmpty) {
                        showCustomSnackBar('first_name_is_required'.tr);
                        FocusScope.of(context).requestFocus(fNameNode);
                      } else if(lName.isEmpty) {
                        showCustomSnackBar('last_name_is_required'.tr);
                        FocusScope.of(context).requestFocus(lNameNode);
                      } else if(phone.isEmpty) {
                        showCustomSnackBar('phone_is_required'.tr);
                        FocusScope.of(context).requestFocus(phoneNode);
                      } else if(password.isEmpty && widget.fromChangePassword) {
                        showCustomSnackBar('password_is_required'.tr);
                        FocusScope.of(context).requestFocus(passwordFocusNode);
                      } else if(password.length < 8 && widget.fromChangePassword) {
                        showCustomSnackBar('minimum_password_length_is_8'.tr);
                        FocusScope.of(context).requestFocus(passwordFocusNode);
                      } else if(confirmPassword.isEmpty && widget.fromChangePassword) {
                        showCustomSnackBar('confirm_password_is_required'.tr);
                        FocusScope.of(context).requestFocus(confirmPasswordFocusNode);
                      } else if(password != confirmPassword) {
                        showCustomSnackBar('password_is_mismatch'.tr);
                        FocusScope.of(context).requestFocus(confirmPasswordFocusNode);
                      } else if(oldPassword.isEmpty && widget.fromChangePassword) {
                        showCustomSnackBar('previous_password_is_required'.tr);
                        FocusScope.of(context).requestFocus(oldPasswordFocus);
                      } else {
                        if(widget.fromChangePassword) {
                          authController.changePassword(oldPassword, password);
                        } else {
                         
                         
                          print("Numéro complet envoyés: $phone"); // Pour debug
                          
                          authController.register(SignUpBody(
                            fName: fName,
                            lName: lName,
                            phone: phone, // Envoyer +225XXXXXXXXX
                            password: '12345678',
                            confirmPassword: '12345678',
                            referralCode: referralCodeController.text.trim()
                          ));
                        }
                      }
                    },
                    radius: 50,
                  ),

                ]),
              );
            }),
          ),
        ),
      ),
    );
  }

  // Méthode pour créer un champ téléphone verrouillé
  Widget _buildLockedPhoneField(AuthController authController) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: 2,
      ),
      child: Row(
        children: [
          // Code pays fixe
       /*   Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              authController.countryDialCode,
              style: textMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ),*/
          const SizedBox(width: Dimensions.paddingSizeSmall),
          
          // Numéro de téléphone en lecture seule
          Expanded(
            child: TextFormField(
              controller: phoneController,
              enabled: false, // Désactivé
              style: textMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'phone'.tr,
                hintStyle: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).hintColor,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          
          // Icône de verrou
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              Icons.lock_outline,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

*/


import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/widgets/test_field_title.dart';
import 'package:ride_sharing_user_app/features/auth/screens/forgot_password_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/svg_image_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/domain/models/sign_up_body.dart';
import 'package:ride_sharing_user_app/features/settings/domain/html_enum_types.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final bool fromChangePassword;
  final String phoneNumber;
  const ResetPasswordScreen({super.key,  this.fromChangePassword = false, required this.phoneNumber});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController referralCodeController = TextEditingController();

  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final FocusNode oldPasswordFocus = FocusNode();
  final FocusNode phoneNode = FocusNode();
  final FocusNode fNameNode = FocusNode();
  final FocusNode lNameNode = FocusNode();
  final FocusNode referralNode = FocusNode();

  bool _isPhoneLocked = false;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();

    final authController = Get.find<AuthController>();
    
    // Définir le code pays pour la Côte d'Ivoire
    authController.countryDialCode = '+225';
    
    // Si un numéro de téléphone est fourni, le traiter
    if (widget.phoneNumber.isNotEmpty) {
      _isPhoneLocked = true;
      _processPhoneNumber(widget.phoneNumber, authController);
    }
  }

  void _processPhoneNumber(String phoneNumber, AuthController authController) {
    // Le numéro vient sous la forme 225XXXXXXXXX
    // On veut enlever le 225 pour garder juste XXXXXXXXX
    
    print("Numéro reçu: $phoneNumber"); // Pour debug
    
    // Vérifier si le numéro commence par 225
    if (phoneNumber.startsWith('225')) {
      // Extraire le numéro sans le code pays
      String localNumber = phoneNumber.substring(3); // Enlève "225"
      
      print("Numéro local extrait: $localNumber"); // Pour debug
      
      // Définir le code pays comme +225
      authController.countryDialCode = '+225';
      
      // Mettre à jour le contrôleur avec le numéro local
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            phoneController.text = localNumber;
          });
        }
      });
    } else {
      // Si le numéro ne commence pas par 225, on le met tel quel
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            phoneController.text = phoneNumber;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: BodyWidget(
          appBar: AppBarWidget(
            title: widget.fromChangePassword ? 'change_password'.tr : 'sign_up'.tr,
            showBackButton: true, 
            centerTitle: true,
            onBackPressed: (){
              if(widget.fromChangePassword){
                Get.back();
              }else{
                Get.off(()=> const ForgotPasswordScreen());
              }
            },
          ),
          body: SingleChildScrollView(
            child: GetBuilder<AuthController>(builder: (authController){
              // Vérifier si tous les champs sont remplis et la case cochée
              final bool isButtonEnabled = _areAllFieldsValid(authController);
              
              return Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  /* FutureBuilder<String>(
                    future: loadSvgAndChangeColors(Images.signUpScreenLogoSvg, Theme.of(context).primaryColor),
                    builder: (context, snapshot){
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        return SvgPicture.string(snapshot.data!);
                      }
                      return SvgPicture.asset(Images.signUpScreenLogoSvg);
                    }
                  ),*/
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Center(child: Text(
                    'sign_up'.tr,
                    style: textBold.copyWith(fontSize: Dimensions.fontSizeTwenty),
                  )),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(
                    'sign_up_message'.tr,
                    style: textMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),fontSize: Dimensions.fontSizeSmall),
                    maxLines: 2,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSignUp),

                  widget.fromChangePassword ?
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    TextFieldTitle(title: 'old_password'.tr),
                    CustomTextField(
                      hintText: 'password_hint'.tr,
                      inputType: TextInputType.text,
                      prefixIcon: Images.password,
                      isPassword: true,
                      controller: oldPasswordController,
                      focusNode: oldPasswordFocus,
                      nextFocus: passwordFocusNode,
                      inputAction: TextInputAction.next,
                    ),
                  ]) : const SizedBox(),

                  TextFieldTitle(title: 'phone'.tr, isRequired: true),

                  // Utiliser un widget conditionnel pour verrouiller le champ
                  _isPhoneLocked 
                      ? _buildLockedPhoneField(authController)
                      : CustomTextField(
                         isCodePicker: true,
                          hintText: 'phone'.tr,
                          inputType: TextInputType.number,
                         countryDialCode: authController.countryDialCode,
                          controller: phoneController,
                          focusNode: phoneNode,
                          nextFocus: passwordFocusNode,
                          inputAction: TextInputAction.next,
                         onCountryChanged: (CountryCode countryCode){
                           authController.countryDialCode = countryCode.dialCode!;
                            authController.setCountryCode(countryCode.dialCode!);
                            FocusScope.of(context).requestFocus(phoneNode);
                          },
                          onChanged: (value) {
                            setState(() {}); // Recalculer l'état du bouton
                          },
                        ),
                  if (_isPhoneLocked) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, 
                               color: Theme.of(context).primaryColor, 
                               size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'phone_number_is_locked_for_security'.tr,
                              style: textRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],

                  TextFieldTitle(title: 'first_name'.tr, isRequired: true), 

                  CustomTextField(
                    capitalization: TextCapitalization.words,
                    hintText: 'first_name'.tr,
                    inputType: TextInputType.name,
                    prefixIcon: Images.person,
                    controller: fNameController,
                    focusNode: fNameNode,
                    nextFocus: lNameNode,
                    inputAction: TextInputAction.next,
                    autoFocus: fNameController.text.isEmpty,
                    onChanged: (value) {
                      setState(() {}); // Recalculer l'état du bouton
                    },
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  TextFieldTitle(title: 'last_name'.tr, isRequired: true),

                  CustomTextField(
                    capitalization: TextCapitalization.words,
                    hintText: 'last_name'.tr,
                    inputType: TextInputType.name,
                    prefixIcon: Images.person,
                    controller: lNameController,
                    focusNode: lNameNode,
                    nextFocus: phoneNode,
                    inputAction: TextInputAction.next,
                    onChanged: (value) {
                      setState(() {}); // Recalculer l'état du bouton
                    },
                  ),

                  if(Get.find<ConfigController>().config?.referralEarningStatus ?? false)...[
                    TextFieldTitle(title: 'refer_code'.tr),

                    CustomTextField(
                      hintText: 'refer_code'.tr,
                      inputType: TextInputType.text,
                      controller: referralCodeController,
                      focusNode: referralNode,
                      inputAction: TextInputAction.done,
                      prefixIcon: Images.referIcon,
                    ),
                  ],
                  
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  
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

                  widget.fromChangePassword ?
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    TextFieldTitle(title: 'password'.tr),
                    CustomTextField(
                      hintText: 'password_hint'.tr,
                      inputType: TextInputType.text,
                      prefixIcon: Images.password,
                      isPassword: true,
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      nextFocus: confirmPasswordFocusNode,
                      inputAction: TextInputAction.next,
                      onChanged: (value) {
                        setState(() {}); // Recalculer l'état du bouton
                      },
                    ), 
                  ]) : const SizedBox(),

                  widget.fromChangePassword ?
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    TextFieldTitle(title: 'confirm_password'.tr),
                    CustomTextField(
                      hintText: 'confirm_password'.tr,
                      inputType: TextInputType.text,
                      prefixIcon: Images.password,
                      controller: confirmPasswordController,
                      focusNode: confirmPasswordFocusNode,
                      inputAction: TextInputAction.done,
                      isPassword: true,
                      onChanged: (value) {
                        setState(() {}); // Recalculer l'état du bouton
                      },
                    ),
                  ]) : const SizedBox(),
                  
                  const SizedBox(height: Dimensions.paddingSizeDefault * 3),

                  authController.isLoading ? 
                  Center(child: SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0)) : 
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isButtonEnabled ? () {
                        _handleSignUp(authController);
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
                        widget.fromChangePassword ? 'update'.tr : 'save'.tr,
                        style: textMedium.copyWith(
                          color: isButtonEnabled ? Colors.white : Colors.grey.shade600,
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                    ),
                  ),

                ]),
              );
            }),
          ),
        ),
      ),
    );
  }

  // Méthode pour vérifier si tous les champs sont valides
  bool _areAllFieldsValid(AuthController authController) {
    // Pour l'inscription (sign up)
    if (!widget.fromChangePassword) {
      return fNameController.text.trim().isNotEmpty &&
             lNameController.text.trim().isNotEmpty &&
             phoneController.text.trim().isNotEmpty &&
             _termsAccepted &&
             !authController.isLoading;
    }
    
    // Pour le changement de mot de passe
    return oldPasswordController.text.trim().isNotEmpty &&
           passwordController.text.trim().isNotEmpty &&
           confirmPasswordController.text.trim().isNotEmpty &&
           passwordController.text == confirmPasswordController.text &&
           !authController.isLoading;
  }

  // Méthode pour gérer l'inscription
  void _handleSignUp(AuthController authController) {
    String fName = fNameController.text.trim();
    String lName = lNameController.text.trim();
    String phone = phoneController.text.trim();

    // Validation des champs (au cas où, même si le bouton est déjà désactivé)
    if(fName.isEmpty) {
      showCustomSnackBar('first_name_is_required'.tr);
      FocusScope.of(context).requestFocus(fNameNode);
      return;
    }
    
    if(lName.isEmpty) {
      showCustomSnackBar('last_name_is_required'.tr);
      FocusScope.of(context).requestFocus(lNameNode);
      return;
    }
    
    if(phone.isEmpty) {
      showCustomSnackBar('phone_is_required'.tr);
      FocusScope.of(context).requestFocus(phoneNode);
      return;
    }
    
    if(!_termsAccepted) {
      showCustomSnackBar('please_accept_terms_and_conditions'.tr);
      return;
    }
    
    // Vérifier que le numéro a 10 chiffres
   

    print("Numéro complet envoyé: $phone"); // Pour debug
    
    // Effectuer l'inscription
    authController.register(SignUpBody(
      fName: fName,
      lName: lName,
      phone: phone, // Le numéro est déjà au format local (10 chiffres)
      password: '12345678',
      confirmPassword: '12345678',
      
      referralCode: referralCodeController.text.trim()
    ));
  }

  // Méthode pour vérifier si la chaîne ne contient que des chiffres
  bool _containsOnlyDigits(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }

  // Méthode pour créer un champ téléphone verrouillé
  Widget _buildLockedPhoneField(AuthController authController) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: phoneController,
              enabled: false,
              style: textMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'phone'.tr,
                hintStyle: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).hintColor,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              Icons.lock_outline,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
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
