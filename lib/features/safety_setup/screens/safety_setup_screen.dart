
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
// import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
// import 'package:ride_sharing_user_app/features/home/widgets/banner_shimmer.dart';
// import 'package:ride_sharing_user_app/features/safety_setup/controllers/safety_alert_controller.dart';
// import 'package:ride_sharing_user_app/util/dimensions.dart';
// import 'package:ride_sharing_user_app/util/images.dart';
// import 'package:ride_sharing_user_app/util/styles.dart';
// import 'package:url_launcher/url_launcher.dart';

// class SafetySetupScreen extends StatefulWidget {
//   const SafetySetupScreen({super.key});

//   @override
//   State<SafetySetupScreen> createState() => _SafetySetupScreenState();
// }

// class _SafetySetupScreenState extends State<SafetySetupScreen> {

//   @override
//   void initState() {
//     Get.find<SafetyAlertController>().getPrecautionList();
//     super.initState();
//   }

//   // Liste des conseils de sécurité
//   final List<String> _safetyTips = [
//     'Vérifier que le véhicule et le chauffeur correspondent avec les infos de l\'application (marque, modèle, plaque et photo).',
//     'Attacher la ceinture de sécurité (obligatoire, même à l\'arrière).',
//     'Partager son trajet via l\'application avec un proche.',
//     'S\'installer à l\'arrière (souvent recommandé pour plus de sécurité).',
//     'Rester attentif au trajet : vérifier que l\'itinéraire est cohérent.',
//     'Bouton d\'urgence pour contacter les secours et/ou un proche.',
//     'Éviter de monter dans un véhicule non réservé via l\'application.',
//     'En cas de comportement suspect, signaler immédiatement via l\'application.',
//   ];

//   void _onSOSPressed() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.paddingSizeLarge)),
//       ),
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: Dimensions.paddingSizeDefault),

//               Text(
//                 'sos_options'.tr,
//                 style: textBold.copyWith(fontSize: 18),
//               ),
//               const SizedBox(height: Dimensions.paddingSizeLarge),

//               // Option Message
//               ListTile(
//                 leading: Container(
//                   padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(Icons.message, color: Colors.blue, size: 24),
//                 ),
//                 title: Text(
//                   'send_sos_message'.tr,
//                   style: textMedium.copyWith(fontSize: 16),
//                 ),
//                 subtitle: Text(
//                   'send_emergency_message'.tr,
//                   style: textRegular.copyWith(fontSize: 12, color: Colors.grey),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _openMessagingApp();
//                 },
//               ),

//               const SizedBox(height: Dimensions.paddingSizeSmall),

//               // Option Appel
//               ListTile(
//                 leading: Container(
//                   padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(Icons.phone, color: Colors.red, size: 24),
//                 ),
//                 title: Text(
//                   'make_sos_call'.tr,
//                   style: textMedium.copyWith(fontSize: 16),
//                 ),
//                 subtitle: Text(
//                   'call_emergency_services'.tr,
//                   style: textRegular.copyWith(fontSize: 12, color: Colors.grey),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _openPhoneApp();
//                 },
//               ),

//               const SizedBox(height: Dimensions.paddingSizeDefault),

//               // Bouton Annuler
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   'cancel'.tr,
//                   style: textMedium.copyWith(color: Colors.grey),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _openMessagingApp() async {
//     const phoneNumber = '112';
//     const message = 'URGENCE SOS - Je suis en danger. Besoin d\'aide immédiate!';

//     final Uri smsUri = Uri(
//       scheme: 'sms',
//       path: phoneNumber,
//       queryParameters: {'body': message},
//     );

//     try {
//       if (await canLaunchUrl(smsUri)) {
//         await launchUrl(smsUri);
//       } else {
//         Get.snackbar(
//           'error'.tr,
//           'cannot_open_messaging_app'.tr,
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       debugPrint('Erreur lors de l\'ouverture de l\'application de messagerie: $e');
//     }
//   }

//   Future<void> _openPhoneApp() async {
//     const phoneNumber = '112';

//     final Uri phoneUri = Uri(
//       scheme: 'tel',
//       path: phoneNumber,
//     );

//     try {
//       if (await canLaunchUrl(phoneUri)) {
//         await launchUrl(phoneUri);
//       } else {
//         Get.snackbar(
//           'error'.tr,
//           'cannot_open_phone_app'.tr,
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       debugPrint('Erreur lors de l\'ouverture de l\'application téléphone: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       top: false,
//       child: Scaffold(
//         body: BodyWidget(
//           appBar: AppBarWidget(title: 'safety'.tr, showBackButton: true, centerTitle: true),
//           body: GetBuilder<SafetyAlertController>(builder: (safetyAlertController) {
//             return Padding(
//               padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//               child: Column(
//                 spacing: Dimensions.paddingSizeSmall,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [

//                   // Bloc de sécurité de trajet
//                   Container(
//                     width: Get.width,
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.error.withValues(alpha: 0.10),
//                       borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//                       child: Column(
//                         spacing: Dimensions.paddingSizeSmall,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [

//                           // Icône + Titre centré
//                           Center(child: Image.asset(Images.safelyShieldIcon1, height: 80, width: 80)),

//                           Center(
//                             child: Text(
//                               'safety_precautions'.tr,
//                               style: textSemiBold.copyWith(fontSize: 22), // ← Agrandi (était 16)
//                               textAlign: TextAlign.center,
//                             ),
//                           ),

//                           const SizedBox(height: Dimensions.paddingSizeSmall),

//                           // Liste des conseils de sécurité
//                           ..._safetyTips.map((tip) => Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 4.0, right: 6.0),
//                                 child: Icon(
//                                   Icons.circle,
//                                   size: 7,
//                                   color: Theme.of(context).colorScheme.error,
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   tip,
//                                   style: textRegular.copyWith(fontSize: 14),
//                                 ),
//                               ),
//                             ],
//                           )),

//                           const SizedBox(height: Dimensions.paddingSizeSmall),
//                         ],
//                       ),
//                     ),
//                   ),

//                ///   Text('safety_precautions'.tr, style: textSemiBold),

//                   Expanded(
//                     child: safetyAlertController.precautionListModel != null
//                         ? ListView.separated(
//                             padding: EdgeInsets.zero,
//                             itemCount: safetyAlertController.precautionListModel?.data?.length ?? 0,
//                             shrinkWrap: true,
//                             itemBuilder: (context, index) {
//                               return Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//                                   border: Border.all(
//                                     color: Theme.of(context).hintColor.withValues(alpha: 0.2),
//                                   ),
//                                 ),
//                                 child: ExpansionTile(
//                                   collapsedIconColor: Theme.of(context).textTheme.bodyMedium!.color,
//                                   iconColor: Theme.of(context).textTheme.bodyMedium!.color,
//                                   title: Row(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '${index + 1}.',
//                                         style: textRegular.copyWith(
//                                           color: Theme.of(context).textTheme.bodyMedium?.color,
//                                         ),
//                                       ),
//                                       Flexible(
//                                         child: Text(
//                                           '${safetyAlertController.precautionListModel?.data?[index].title}',
//                                           style: textRegular.copyWith(
//                                             color: Theme.of(context).textTheme.bodyMedium?.color,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   shape: Border(),
//                                   expandedAlignment: Alignment.centerLeft,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: Dimensions.paddingSizeSmall,
//                                         horizontal: Dimensions.paddingSizeExtraLarge,
//                                       ),
//                                       child: Text(
//                                         '${safetyAlertController.precautionListModel?.data?[index].description}',
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                             separatorBuilder: (context, index) {
//                               return SizedBox(height: Dimensions.paddingSizeSmall);
//                             },
//                           )
//                         : const BannerShimmer(),
//                   ),

//                   // Bouton SOS
//                   Container(
//                     width: double.infinity,
//                     margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
//                     child: ElevatedButton(
//                       onPressed: _onSOSPressed,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//                         ),
//                         elevation: 5,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.warning_amber_rounded, color: Colors.white),
//                           const SizedBox(width: Dimensions.paddingSizeSmall),
//                           Text(
//                             'SOS',
//                             style: textBold.copyWith(fontSize: 18, color: Colors.white),
//                           ),
//                           const SizedBox(width: Dimensions.paddingSizeSmall),
//                           Text(
//                             'emergency'.tr,
//                             style: textRegular.copyWith(color: Colors.white.withOpacity(0.9)),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_shimmer.dart';
import 'package:ride_sharing_user_app/features/safety_setup/controllers/safety_alert_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class SafetySetupScreen extends StatefulWidget {
  const SafetySetupScreen({super.key});

  @override
  State<SafetySetupScreen> createState() => _SafetySetupScreenState();
}

class _SafetySetupScreenState extends State<SafetySetupScreen> {

  @override
  void initState() {
    Get.find<SafetyAlertController>().getPrecautionList();
    super.initState();
  }

  // Liste des conseils de sécurité
  final List<String> _safetyTips = [
    'Vérifier que le véhicule et le chauffeur correspondent avec les infos de l\'application (marque, modèle, plaque et photo).',
    'Attacher la ceinture de sécurité (obligatoire, même à l\'arrière).',
    'Partager son trajet via l\'application avec un proche.',
    'S\'installer à l\'arrière (souvent recommandé pour plus de sécurité).',
    'Rester attentif au trajet : vérifier que l\'itinéraire est cohérent.',
    'Bouton d\'urgence pour contacter les secours et/ou un proche.',
    'Éviter de monter dans un véhicule non réservé via l\'application.',
    'En cas de comportement suspect, signaler immédiatement via l\'application.',
  ];

  void _onSOSPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permet le défilement si le contenu est trop grand
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.paddingSizeLarge)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: SingleChildScrollView( // Ajout de SingleChildScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Text(
                  'sos_options'.tr,
                  style: textBold.copyWith(fontSize: 18),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Option Message
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.message, color: Colors.blue, size: 24),
                  ),
                  title: Text(
                    'send_sos_message'.tr,
                    style: textMedium.copyWith(fontSize: 16),
                  ),
                  subtitle: Text(
                    'send_emergency_message'.tr,
                    style: textRegular.copyWith(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _openMessagingApp();
                  },
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                // Option Appel
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.phone, color: Colors.red, size: 24),
                  ),
                  title: Text(
                    'make_sos_call'.tr,
                    style: textMedium.copyWith(fontSize: 16),
                  ),
                  subtitle: Text(
                    'call_emergency_services'.tr,
                    style: textRegular.copyWith(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _openPhoneApp();
                  },
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Bouton Annuler
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'cancel'.tr,
                    style: textMedium.copyWith(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openMessagingApp() async {
    const phoneNumber = '112';
    const message = 'URGENCE SOS - Je suis en danger. Besoin d\'aide immédiate!';

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        Get.snackbar(
          'error'.tr,
          'cannot_open_messaging_app'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture de l\'application de messagerie: $e');
    }
  }

  Future<void> _openPhoneApp() async {
    const phoneNumber = '112';

    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          'error'.tr,
          'cannot_open_phone_app'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture de l\'application téléphone: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: BodyWidget(
          appBar: AppBarWidget(title: 'safety'.tr, showBackButton: true, centerTitle: true),
          body: GetBuilder<SafetyAlertController>(builder: (safetyAlertController) {
            return SingleChildScrollView( // Ajout de SingleChildScrollView pour permettre le défilement
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Bloc de sécurité de trajet
                  Container(
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Icône + Titre centré
                          Center(child: Image.asset(Images.safelyShieldIcon1, height: 80, width: 80)),

                          Center(
                            child: Text(
                              'safety_precautions'.tr,
                              style: textSemiBold.copyWith(fontSize: 22),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          // Liste des conseils de sécurité
                          ..._safetyTips.map((tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, right: 6.0),
                                  child: Icon(
                                    Icons.circle,
                                    size: 7,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: textRegular.copyWith(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          )),

                          const SizedBox(height: Dimensions.paddingSizeSmall),
                        ],
                      ),
                    ),
                  ),

                 // const SizedBox(height: Dimensions.paddingSizeLarge),

                
                  // Liste dynamique des précautions
                  safetyAlertController.precautionListModel != null
                      ? Column(
                          children: [
                            ...List.generate(
                              safetyAlertController.precautionListModel?.data?.length ?? 0,
                              (index) => Container(
                                margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                  border: Border.all(
                                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: ExpansionTile(
                                  collapsedIconColor: Theme.of(context).textTheme.bodyMedium!.color,
                                  iconColor: Theme.of(context).textTheme.bodyMedium!.color,
                                  title: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${index + 1}.',
                                        style: textRegular.copyWith(
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          '${safetyAlertController.precautionListModel?.data?[index].title}',
                                          style: textRegular.copyWith(
                                            color: Theme.of(context).textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  shape: Border(),
                                  expandedAlignment: Alignment.centerLeft,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: Dimensions.paddingSizeSmall,
                                        horizontal: Dimensions.paddingSizeExtraLarge,
                                      ),
                                      child: Text(
                                        '${safetyAlertController.precautionListModel?.data?[index].description}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : const BannerShimmer(),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Bouton SOS
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault), // Changé top en bottom
                    child: ElevatedButton(
                      onPressed: _onSOSPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                        ),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.white),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text(
                            'SOS',
                            style: textBold.copyWith(fontSize: 22, color: Colors.white),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text(
                            'emergency'.tr,
                            style: textRegular.copyWith(color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}