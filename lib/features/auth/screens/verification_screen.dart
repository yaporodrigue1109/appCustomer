
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/otp_push_helper.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class VerificationScreen extends StatefulWidget {
  final String number;
  final bool fromOtpLogin;
  final String? session;
  const VerificationScreen(
      {super.key,
      required this.number,
      this.fromOtpLogin = false,
      this.session});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  Timer? _timer;
  int? _seconds = 0;
  String errorText = '';
  List<TextEditingController> controllers = [];
  List<FocusNode> focusNodes = [];
  String otpCode = '';
  StreamSubscription<String>? _otpSubscription;

  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().updateVerificationCode('', isUpdate: false);
    _startTimer();

    // Initialiser les 6 contrôleurs
    for (int i = 0; i < 6; i++) {
      controllers.add(TextEditingController());
      focusNodes.add(FocusNode());
    }

    _otpSubscription = OtpPushHelper.otpStream.listen(_applyOtpCode);
    OtpPushHelper.getPendingOtp().then((code) {
      if (code != null && code.isNotEmpty) {
        _applyOtpCode(code);
      }
    });
  }

  void _applyOtpCode(String code) {
    debugPrint('[OTP_TRACE][verify] _applyOtpCode received="$code" mounted=$mounted');
    if (!mounted || code.length != 6) {
      debugPrint('[OTP_TRACE][verify] ignored: mounted=$mounted length=${code.length}');
      return;
    }

    for (int i = 0; i < controllers.length; i++) {
      controllers[i].text = code[i];
    }

    otpCode = code;
    errorText = '';
    Get.find<AuthController>().updateVerificationCode(otpCode);
    debugPrint('[OTP_TRACE][verify] otp applied to input and controller');
    FocusScope.of(context).unfocus();
    OtpPushHelper.clearPendingOtp();

    setState(() {});
  }

  void _startTimer() {
    _seconds = Get.find<ConfigController>().config!.otpResendTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    _otpSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    setState(() {
      errorText = '';
    });

    if (value.length == 1 && index < 5) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }

    // Mettre à jour le code OTP complet
    otpCode = controllers.map((c) => c.text).join();
    Get.find<AuthController>().updateVerificationCode(otpCode);
  }

  void _onVerifyPressed(AuthController authController) {
    // Éviter les doubles appels
    if (authController.otpVerifying) return;

    authController
        .otpVerification(widget.number, otpCode,
            accountVerification: widget.fromOtpLogin, session: widget.session)
        .then((value) {
      if (value.statusCode == 200) {
        OtpPushHelper.clearPendingOtp();
      } else {
        setState(() {
          errorText = 'incorrect_otp'.tr;
        });
        // Effacer les champs en cas d'erreur
        for (var controller in controllers) {
          controller.clear();
        }
        otpCode = '';
        FocusScope.of(context).requestFocus(focusNodes[0]);
      }
    });
  }

  // Méthode pour gérer le collage
  void _handlePaste() async {
    final ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData?.text != null) {
      final pastedText = clipboardData!.text!;

      // Extraire uniquement les chiffres
      final codeRegex = RegExp(r'\d');
      final digits =
          codeRegex.allMatches(pastedText).map((m) => m.group(0)).join();

      if (digits.isNotEmpty) {
        // Prendre les 6 premiers chiffres ou moins
        final otpDigits = digits
            .substring(0, digits.length > 6 ? 6 : digits.length)
            .split('');

        // Remplir les champs
        for (int i = 0; i < controllers.length; i++) {
          if (i < otpDigits.length) {
            controllers[i].text = otpDigits[i];
          } else {
            controllers[i].clear();
          }
        }

        // Mettre à jour le code OTP
        otpCode = controllers.map((c) => c.text).join();
        Get.find<AuthController>().updateVerificationCode(otpCode);

        // Focus sur le dernier champ rempli ou défocus si complet
        if (otpDigits.length == 6) {
          FocusScope.of(context).unfocus();
          // Vérifier automatiquement
          if (!Get.find<AuthController>().otpVerifying) {
            _onVerifyPressed(Get.find<AuthController>());
          }
        } else if (otpDigits.length < 6 && otpDigits.length > 0) {
          FocusScope.of(context).requestFocus(focusNodes[otpDigits.length]);
        }

        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: BodyWidget(
          appBar: AppBarWidget(
              title: 'verification'.tr,
              showBackButton: true,
              centerTitle: true),
          body: Center(
              child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge),
            child: GetBuilder<AuthController>(builder: (authController) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Center(
                      child: Text(
                    'verification'.tr,
                    style:
                        textBold.copyWith(fontSize: Dimensions.fontSizeTwenty),
                  )),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(
                    '${'we_have_send_a_varification_code_to'.tr} ${widget.number.substring(0, 5)}*****${widget.number.substring(widget.number.length - 3, widget.number.length)}',
                    style: textMedium.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.7),
                        fontSize: Dimensions.fontSizeSmall),
                    maxLines: 2,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSignUp),

                  (Get.find<ConfigController>().config?.isDemo ?? true)
                      ? Padding(
                          padding:
                              const EdgeInsets.all(Dimensions.paddingSizeSmall)
                                  .copyWith(
                            bottom: Dimensions.paddingSizeOverLarge,
                          ),
                          child: Text('for_demo_purpose_use'.tr,
                              style: textSemiBold.copyWith(
                                color: Theme.of(context).disabledColor,
                              )),
                        )
                      : const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Champs OTP personnalisés
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 45,
                          height: 45,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(
                              color: errorText.isNotEmpty
                                  ? Colors.red
                                  : Theme.of(context)
                                      .hintColor
                                      .withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: controllers[index],
                            focusNode: focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: textSemiBold.copyWith(fontSize: 18),
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) => _onOtpChanged(index, value),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(1),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: Dimensions.paddingSizeDefault),
                  // Bouton pour coller le code
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                  //   child: InkWell(
                  //     onTap: _handlePaste,
                  //     borderRadius:
                  //         BorderRadius.circular(Dimensions.radiusDefault),
                  //     child: Container(
                  //       padding: const EdgeInsets.symmetric(
                  //         horizontal: Dimensions.paddingSizeDefault,
                  //         vertical: Dimensions.paddingSizeSmall,
                  //       ),
                  //       decoration: BoxDecoration(
                  //         color:
                  //             Theme.of(context).primaryColor.withOpacity(0.1),
                  //         borderRadius:
                  //             BorderRadius.circular(Dimensions.radiusDefault),
                  //         border: Border.all(
                  //           color:
                  //               Theme.of(context).primaryColor.withOpacity(0.3),
                  //         ),
                  //       ),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Icon(
                  //             Icons.content_paste,
                  //             color: Theme.of(context).primaryColor,
                  //             size: 20,
                  //           ),
                  //           const SizedBox(width: Dimensions.paddingSizeSmall),
                  //           Text(
                  //             'Coller le code de vérification',
                  //             style: textMedium.copyWith(
                  //               color: Theme.of(context).primaryColor,
                  //               fontSize: Dimensions.fontSizeDefault,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // Indication pour le collage automatique
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  //   child: Text(
                  //     'Appuyez sur "Coller" pour coller automatiquement le code reçu par SMS',
                  //     style: textRegular.copyWith(
                  //       fontSize: Dimensions.fontSizeSmall,
                  //       color: Colors.grey[600],
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),

                  if (errorText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeSmall),
                      child: Center(
                        child: Text(errorText,
                            style: textRegular.copyWith(
                                color: Theme.of(context).colorScheme.error)),
                      ),
                    ),

                  !authController.otpVerifying
                      ? Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeSmall),
                          child: ButtonWidget(
                            buttonText: 'verify'.tr,
                            radius: 50,
                            textColor: otpCode.length == 6
                                ? Theme.of(context).cardColor
                                : Theme.of(context).textTheme.bodyMedium?.color,
                            onPressed: otpCode.length == 6
                                ? () => _onVerifyPressed(authController)
                                : null,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeSmall),
                          child: Center(
                            child: SpinKitCircle(
                              color: Theme.of(context).primaryColor,
                              size: 40.0,
                            ),
                          ),
                        ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'did_not_receive_the_code'.tr,
                        style: textMedium.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withValues(alpha: .6)),
                      ),
                      _seconds! <= 0
                          ? TextButton(
                              onPressed: () async {
                                if (Get.find<ConfigController>()
                                        .config
                                        ?.isFirebaseOtpVerification ??
                                    false) {
                                  await authController.firebaseOtpSend(
                                      widget.number,
                                      canRoute: false);
                                  showCustomSnackBar('otp_sent_successfully'.tr,
                                      isError: false);
                                  _startTimer();
                                } else if (Get.find<ConfigController>()
                                        .config
                                        ?.isSmsGateway ??
                                    false) {
                                  authController
                                      .sendOtp(widget.number)
                                      .then((value) {
                                    if (value.statusCode == 200) {
                                      _startTimer();
                                    }
                                  });
                                } else {
                                  showCustomSnackBar(
                                      'sms_gateway_not_integrate'.tr);
                                }
                              },
                              child: Text(
                                'resend_code'.tr,
                                style: textBold.copyWith(
                                    color: Theme.of(context)
                                        .primaryColorDark
                                        .withValues(alpha: .6)),
                                textAlign: TextAlign.end,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${'resend_it'.tr} ',
                                  style: textRegular.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.6)),
                                ),
                                Text(
                                  '(${_seconds}s)',
                                  style: textRegular.copyWith(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ],
                            )
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                ],
              );
            }),
          )),
        ),
      ),
    );
  }
}
