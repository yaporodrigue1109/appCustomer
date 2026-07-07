// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:phone_numbers_parser/phone_numbers_parser.dart';
// import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
// import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dart';
// import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
// import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
// import 'package:ride_sharing_user_app/helper/country_code_helper.dart';
// import 'package:ride_sharing_user_app/helper/display_helper.dart';
// import 'package:ride_sharing_user_app/helper/route_helper.dart';
// import 'package:ride_sharing_user_app/theme/theme_controller.dart';
// import 'package:ride_sharing_user_app/util/dimensions.dart';
// import 'package:ride_sharing_user_app/util/images.dart';
// import 'package:ride_sharing_user_app/features/auth/widgets/test_field_title.dart';
// import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
// import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
// import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
// import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
// import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
// import 'package:ride_sharing_user_app/util/styles.dart';


// class ParcelInfoWidget extends StatefulWidget {
//   final bool isSender;
//   final GlobalKey<ExpandableBottomSheetState> expandableKey;
//   const ParcelInfoWidget({super.key, required this.isSender, required this.expandableKey});

//   @override
//   State<ParcelInfoWidget> createState() => _ParcelInfoWidgetState();
// }

// class _ParcelInfoWidgetState extends State<ParcelInfoWidget> {

//   @override
//   void initState() {
//     super.initState();

//     final ParcelController parcelController = Get.find<ParcelController>();

//     if(widget.isSender) {
//       String? senderPhoneNumber = Get.find<ProfileController>().profileModel?.data?.phone;

//       if(senderPhoneNumber != null) {
//        parcelController.onChangeSenderCountryCode(CountryCodeHelper.getCountryCode(senderPhoneNumber), isUpdate: false);
//       }

//       parcelController.senderContactController.text = senderPhoneNumber?.replaceAll(parcelController.getSenderCountryCode ?? '', '') ?? '';
//       parcelController.senderNameController.text = Get.find<ProfileController>().customerName();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ParcelController>(builder: (parcelController) {
//       return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

//         TextFieldTitle(title: 'contact'.tr, textOpacity: 0.8),
//         CustomTextField(
//           isCodePicker: true,
//           isCodePickerFillColor: false,
//           borderRadius: 10,
//           showBorder: false,
//           hintText: 'contact_number'.tr,
//           fillColor:  Get.isDarkMode? Theme.of(context).cardColor : Theme.of(context).primaryColor.withValues(alpha:0.04),
//           controller: widget.isSender ? parcelController.senderContactController : parcelController.receiverContactController,
//           focusNode: widget.isSender ? parcelController.senderContactNode : parcelController.receiverContactNode,
//           nextFocus: widget.isSender ? parcelController.senderNameNode : parcelController.receiverNameNode,
//           inputType: TextInputType.phone,
//           countryDialCode: widget.isSender
//               ? parcelController.getSenderCountryCode
//               : parcelController.getReceiverCountryDialCode,

//           onCountryChanged: (CountryCode countryCode){
//             if(widget.isSender) {
//               parcelController.onChangeSenderCountryCode(countryCode.dialCode);

//             }else {
//               parcelController.onChangeReceiverCountryCode(countryCode.dialCode);

//             }
//           },
//           ),

//         // TextFieldTitle(title: 'name'.tr, textOpacity: 0.8),
//         // CustomTextField(
//         //   prefixIcon: Images.editProfilePhone,
//         //   borderRadius: 10,
//         //   showBorder: false,
//         //   prefix: false,
//         //   capitalization: TextCapitalization.words,
//         //   hintText: 'name'.tr,
//         //   fillColor: Get.isDarkMode? Theme.of(context).cardColor : Theme.of(context).primaryColor.withValues(alpha:0.04),
//         //   controller: widget.isSender ? parcelController.senderNameController : parcelController.receiverNameController,
//         //   focusNode: widget.isSender ? parcelController.senderNameNode : parcelController.receiverNameNode,
//         //   nextFocus: widget.isSender ? parcelController.senderAddressNode : parcelController.receiverAddressNode,
//         //   inputType: TextInputType.text,
//         //   onTap: () => parcelController.focusOnBottomSheet(widget.expandableKey)),

//         TextFieldTitle(title: 'Adress_livraison'.tr, textOpacity: 0.8),

//         InkWell(
//           onTap: () => RouteHelper.goPageAndHideTextField(context, PickMapScreen(
//             type: widget.isSender? LocationType.senderLocation : LocationType.receiverLocation,
//             address: widget.isSender? Get.find<LocationController>().parcelSenderAddress : Get.find<LocationController>().parcelReceiverAddress,
//           )),
//           child: CustomTextField(
//             prefix: false,
//             suffixIcon: Images.location,
//             borderRadius: 10,
//             isEnabled: false,
//             showBorder: false,
//             textColor: Theme.of(context).textTheme.bodyLarge!.color,
//             hintText: 'location'.tr,
//             fillColor:  Get.isDarkMode? Theme.of(context).cardColor : Theme.of(context).primaryColor.withValues(alpha:0.04),
//             controller: widget.isSender ? parcelController.senderAddressController : parcelController.receiverAddressController,
//             focusNode: widget.isSender ? parcelController.senderAddressNode : parcelController.receiverAddressNode,
//             inputType: TextInputType.text,
//             inputAction: TextInputAction.done,
//             onTap: () => parcelController.focusOnBottomSheet(widget.expandableKey),
//           ),
//         ),

//         if(Get.find<AddressController>().addressList?.isNotEmpty ?? false)
//           TextFieldTitle(title: 'saved_address'.tr, textOpacity: 0.8),

//         GetBuilder<AddressController>(builder: (addressController){
//           return addressController.addressList != null ?
//           addressController.addressList!.isNotEmpty ?
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
//             child: SizedBox(
//               height: Get.width * 0.075,
//               child: ListView.builder(
//                 itemCount: addressController.addressList?.length,
//                 padding: EdgeInsets.zero,
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (context,index) {
//                   return InkWell(
//                     onTap: () {
//                       final locationController = Get.find<LocationController>();
//                       locationController.getZone(addressController.addressList![index].latitude.toString(), addressController.addressList![index].longitude.toString()).then((value){
//                         if(value.isSuccess){
//                           if(widget.isSender) {
//                             locationController.setSenderAddress(addressController.addressList?[index]);
//                           }else {
//                             locationController.setReceiverAddress(addressController.addressList?[index]);
//                           }
//                         }else{
//                           showCustomSnackBar('service_not_available_in_this_area'.tr);
//                         }
//                       });

//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
//                       padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize),
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).cardColor,
//                         border: Border.all(
//                           color:Get.isDarkMode ?
//                           Theme.of(context).hintColor :
//                           Theme.of(context).primaryColor.withValues(alpha:0.4),width:0.5,
//                         ),
//                         borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//                       ),
//                       child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//                         Image.asset(
//                           addressController.addressList?[index].addressLabel == 'home' ? Images.homeIcon :
//                           addressController.addressList?[index].addressLabel == 'office' ? Images.workIcon : Images.otherIcon,
//                           color: Get.find<ThemeController>().darkTheme ?
//                           Theme.of(context).primaryColor :
//                           Theme.of(context).hintColor,
//                           height: 16,width: 16,
//                         ),
//                         const SizedBox(width: Dimensions.paddingSizeSmall),

//                         Text(addressController.addressList![index].addressLabel!.tr,style: textBold),

//                       ]),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ) :
//           const SizedBox(height: Dimensions.paddingSizeSmall) :
//           const SizedBox(height: Dimensions.paddingSizeSmall);
//         }),


//         ButtonWidget(buttonText: "next".tr,
//           onPressed: () {
//             PhoneNumber senderNumber = PhoneNumber.parse('${parcelController.getSenderCountryCode}${parcelController.senderContactController.text}');


//             if(parcelController.tabController.index == 0) {
//               if(parcelController.senderContactController.text.isEmpty){
//                 showCustomSnackBar('enter_sender_contact_number'.tr);
//                 FocusScope.of(context).requestFocus(parcelController.senderContactNode);

//               }else if(!senderNumber.isValid(type: PhoneNumberType.mobile)) {
//                 showCustomSnackBar('enter_valid_contact_number'.tr);
//                 FocusScope.of(context).requestFocus(parcelController.senderContactNode);

//               }
//               // else if(parcelController.senderNameController.text.isEmpty){
//               //   showCustomSnackBar('enter_sender_name'.tr);
//               //   FocusScope.of(context).requestFocus(parcelController.senderNameNode);
//               //   parcelController.focusOnBottomSheet(widget.expandableKey);

//               // }
//                else if(parcelController.senderAddressController.text.isEmpty){
//                 showCustomSnackBar('enter_sender_address'.tr);
//                 RouteHelper.goPageAndHideTextField(context, PickMapScreen(
//                   type: LocationType.senderLocation,
//                   address: Get.find<LocationController>().parcelSenderAddress,
//                 ));

//               }else {
//                 parcelController.updateTabControllerIndex(1);

//                 if(parcelController.getReceiverCountryDialCode == null) {
//                   parcelController.onChangeReceiverCountryCode(parcelController.getSenderCountryCode);
//                 }
//               }
//             }
//             else {
//               PhoneNumber reviverNumber = PhoneNumber.parse('${parcelController.getReceiverCountryDialCode}${parcelController.receiverContactController.text}');

//               if(parcelController.receiverContactController.text.isEmpty){
//                 showCustomSnackBar('enter_receiver_contact_number'.tr);
//                 FocusScope.of(context).requestFocus(parcelController.receiverContactNode);
//               }else if(!reviverNumber.isValid(type: PhoneNumberType.mobile)){
//                 showCustomSnackBar('enter_valid_contact_number'.tr);
//                 FocusScope.of(context).requestFocus(parcelController.receiverContactNode);

//               } 
//               // else if(parcelController.receiverNameController.text.isEmpty){
//               //   showCustomSnackBar('enter_receiver_name'.tr);
//               //   FocusScope.of(context).requestFocus(parcelController.receiverNameNode);
//               //   parcelController.focusOnBottomSheet(widget.expandableKey);

//               // } 
//               else if(parcelController.receiverAddressController.text.isEmpty){
//                 showCustomSnackBar('enter_receiver_address'.tr);
//                 RouteHelper.goPageAndHideTextField(context, PickMapScreen(
//                   type: LocationType.receiverLocation,
//                   address: Get.find<LocationController>().parcelReceiverAddress,
//                 ));

//               }else if(parcelController.senderContactController.text.isEmpty){
//                 showCustomSnackBar('enter_sender_contact_number'.tr);

//               }else if(parcelController.senderNameController.text.isEmpty){
//                 showCustomSnackBar('enter_sender_name'.tr);

//               } else if(parcelController.senderAddressController.text.isEmpty){
//                 showCustomSnackBar('enter_sender_address'.tr);
//                 parcelController.updateTabControllerIndex(0);
//                 RouteHelper.goPageAndHideTextField(context, PickMapScreen(
//                     type: LocationType.senderLocation,
//                     address: Get.find<LocationController>().parcelSenderAddress
//                 ));

//               }else {
//                 Get.find<MapController>().notifyMapController();
//                 parcelController.updateParcelState(ParcelDeliveryState.addOtherParcelDetails);

//               }
//             }
//           },
//         ),

//       ]);
//     });
//   }
// }


/*
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts_lib;
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/helper/country_code_helper.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/auth/widgets/test_field_title.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

// ═══════════════════════════════════════════════════════════════════════════
// FIX CRITIQUE — Dans SenderReceiverInfoWidget, remplace :
//
//   ParcelInfoWidget(isSender: parcelController.tabController.index == 0, ...)
//
// Par un IndexedStack avec deux instances séparées et des ValueKey :
//
//   IndexedStack(
//     index: parcelController.tabController.index,
//     children: [
//       ParcelInfoWidget(key: const ValueKey('sender'), isSender: true, expandableKey: widget.expandableKey),
//       ParcelInfoWidget(key: const ValueKey('receiver'), isSender: false, expandableKey: widget.expandableKey),
//     ],
//   )
//
// Sans ça, Flutter réutilise le même State → les controllers sont partagés.
// ═══════════════════════════════════════════════════════════════════════════

class ParcelInfoWidget extends StatefulWidget {
  final bool isSender;
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const ParcelInfoWidget({
    super.key,
    required this.isSender,
    required this.expandableKey,
  });

  @override
  State<ParcelInfoWidget> createState() => _ParcelInfoWidgetState();
}

class _ParcelInfoWidgetState extends State<ParcelInfoWidget> {
  // ── Contacts (destinataire uniquement) ────────────────────────────────────
  List<contacts_lib.Contact> _cachedContacts = [];
  bool _hasLoadedContacts = false;
  List<contacts_lib.Contact> _filteredContacts = [];
  bool _showContactSuggestions = false;

  // ── Adresse : controller propre à chaque instance ─────────────────────────
  // FIX : chaque ParcelInfoWidget a son propre _addressSearchController
  // → plus de partage entre l'onglet expéditeur et l'onglet destinataire
  late TextEditingController _addressSearchController;
  late FocusNode _addressFocusNode;
  bool _showAddressSuggestions = false;

  // ── Helpers ────────────────────────────────────────────────────────────────
  LocationType get _locationType =>
      widget.isSender ? LocationType.senderLocation : LocationType.receiverLocation;

  TextEditingController get _phoneCtrl {
    final p = Get.find<ParcelController>();
    return widget.isSender ? p.senderContactController : p.receiverContactController;
  }

  // FIX : pointe vers le bon controller parcel selon l'instance
  TextEditingController get _parcelAddressCtrl {
    final p = Get.find<ParcelController>();
    return widget.isSender ? p.senderAddressController : p.receiverAddressController;
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Chaque instance crée ses propres objets → pas de partage
    _addressSearchController = TextEditingController();
    _addressFocusNode = FocusNode();

    final parcelController = Get.find<ParcelController>();
    final locationController = Get.find<LocationController>();

    if (widget.isSender) {
      // ── Auto-remplissage expéditeur depuis le profil ──────────────────────
      final senderPhone = Get.find<ProfileController>().profileModel?.data?.phone;
      if (senderPhone != null) {
        parcelController.onChangeSenderCountryCode(
          CountryCodeHelper.getCountryCode(senderPhone),
          isUpdate: false,
        );
        parcelController.senderContactController.text =
            senderPhone.replaceAll(parcelController.getSenderCountryCode ?? '', '');
      }
      parcelController.senderNameController.text =
          Get.find<ProfileController>().customerName();

      // Adresse depuis la position actuelle
      final currentAddress = locationController.address;
      if (currentAddress != null && currentAddress.isNotEmpty) {
        _addressSearchController.text = currentAddress;
        parcelController.senderAddressController.text = currentAddress;
      } else {
        _tryAutoFillSenderAddress(parcelController, locationController);
      }
    } else {
      // ── Destinataire : restaurer uniquement receiverAddressController ──────
      // FIX : on ne touche JAMAIS senderAddressController ici
      _addressSearchController.text = parcelController.receiverAddressController.text;

      // Activer la recherche contacts pour le destinataire
      _phoneCtrl.addListener(_onPhoneChanged);
      _preloadContacts();
    }
  }

  Future<void> _tryAutoFillSenderAddress(
    ParcelController parcelController,
    LocationController locationController,
  ) async {
    try {
      final address = locationController.parcelSenderAddress;
      if (address?.address != null && address!.address!.isNotEmpty) {
        if (mounted) {
          setState(() {
            _addressSearchController.text = address.address!;
            // FIX : uniquement senderAddressController
            parcelController.senderAddressController.text = address.address!;
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur adresse expéditeur: $e');
    }
  }

  // ── Contacts ───────────────────────────────────────────────────────────────

  Future<void> _preloadContacts() async {
    final status = await perm.Permission.contacts.status;
    if (status == perm.PermissionStatus.granted) await _loadContacts();
  }

  Future<void> _loadContacts() async {
    if (_hasLoadedContacts) return;
    try {
      final all = await contacts_lib.FlutterContacts.getAll(
        properties: {
          contacts_lib.ContactProperty.phone,
          contacts_lib.ContactProperty.name,
        },
      );
      if (!mounted) return;
      setState(() {
        _cachedContacts = all.where((c) => c.phones.isNotEmpty).toList();
        _hasLoadedContacts = true;
      });
    } catch (e) {
      debugPrint('Erreur chargement contacts: $e');
    }
  }

  void _onPhoneChanged() {
    final query = _phoneCtrl.text.trim();
    if (query.isEmpty) {
      if (mounted) setState(() => _showContactSuggestions = false);
      return;
    }
    if (!_hasLoadedContacts) {
      _requestPermissionThenFilter(query);
    } else {
      _filterContacts(query);
    }
  }

  Future<void> _requestPermissionThenFilter(String query) async {
    final status = await perm.Permission.contacts.request();
    if (status == perm.PermissionStatus.granted) {
      await _loadContacts();
      if (mounted) _filterContacts(query);
    }
  }

  void _filterContacts(String query) {
    final lower = query.toLowerCase();
    final results = _cachedContacts.where((c) {
      final nameMatch = c.displayName?.toLowerCase().contains(lower) ?? false;
      final phoneMatch = c.phones
          .any((p) => p.number.replaceAll(RegExp(r'\s+'), '').contains(lower));
      return nameMatch || phoneMatch;
    }).take(6).toList();

    if (mounted) {
      setState(() {
        _filteredContacts = results;
        _showContactSuggestions = results.isNotEmpty;
      });
    }
  }

  void _selectContact(contacts_lib.Contact contact) {
    final rawPhone = contact.phones.first.number.replaceAll(RegExp(r'\s+'), '');
    _phoneCtrl.removeListener(_onPhoneChanged);
    _phoneCtrl.text = rawPhone;
    _phoneCtrl.addListener(_onPhoneChanged);
    setState(() {
      _showContactSuggestions = false;
      _filteredContacts = [];
    });
    Get.find<ParcelController>().update();
  }

  // ── Adresse ────────────────────────────────────────────────────────────────

  void _onAddressChanged(String text) {
    if (text.trim().length < 2) {
      setState(() => _showAddressSuggestions = false);
      return;
    }
    // FIX : recherche avec le locationType propre à cette instance
    Get.find<LocationController>()
        .searchLocation(context, text, type: _locationType);
    setState(() => _showAddressSuggestions = true);
  }

  

  Future<void> _selectAddress(String placeId, String addressText) async {
    final locationController = Get.find<LocationController>();
    final parcelController = Get.find<ParcelController>();

    // FIX : setLocation avec le bon _locationType
    await locationController.setLocation(
      fromSearch: true,
      placeId,
      addressText,
      null,
      type: _locationType,
    );

    // FIX : mise à jour uniquement du controller dédié à cette instance
    _addressSearchController.text = addressText;
    _parcelAddressCtrl.text = addressText;

    locationController.setSearchResultShowHide(show: false);
    _addressFocusNode.unfocus();
    setState(() => _showAddressSuggestions = false);
    parcelController.update();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParcelController>(builder: (parcelController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        final predictions = locationController
            .predictionList?.data?.suggestions
            ?.where((s) => s.placePrediction != null)
            .toList();
        final hasPredictions =
            _showAddressSuggestions && predictions != null && predictions.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            if (widget.isSender) ...[
              // ══════════════════════════════════════════════════════════════
              // EXPÉDITEUR
              // ══════════════════════════════════════════════════════════════

              // Contact auto-rempli → lecture seule
              TextFieldTitle(title: 'contact_expediteur'.tr, textOpacity: 0.8),
              CustomTextField(
                isCodePicker: true,
                isCodePickerFillColor: false,
                borderRadius: 10,
                showBorder: false,
                isEnabled: false, // non modifiable
                hintText: 'contact_number'.tr,
                fillColor: Get.isDarkMode
                    ? Theme.of(context).cardColor
                    : Theme.of(context).primaryColor.withValues(alpha: 0.04),
                controller: parcelController.senderContactController,
                focusNode: parcelController.senderContactNode,
                inputType: TextInputType.phone,
                countryDialCode: parcelController.getSenderCountryCode,
                onCountryChanged: (_) {},
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Adresse expéditeur depuis position actuelle
              TextFieldTitle(title: 'adresse_expediteur'.tr, textOpacity: 0.8),
              _AddressField(
                controller: _addressSearchController,
                focusNode: _addressFocusNode,
                hintText: 'position_actuelle'.tr,
                onChanged: _onAddressChanged,
                onTap: () =>
                    parcelController.focusOnBottomSheet(widget.expandableKey),
                onMapTap: () => RouteHelper.goPageAndHideTextField(
                  context,
                  PickMapScreen(
                    type: LocationType.senderLocation,
                    address: locationController.parcelSenderAddress,
                  ),
                ),
              ),

            ] else ...[
              // ══════════════════════════════════════════════════════════════
              // DESTINATAIRE
              // ══════════════════════════════════════════════════════════════

              // Contact avec autocomplétion répertoire
              TextFieldTitle(title: 'contact_destinataire'.tr, textOpacity: 0.8),
              CustomTextField(
                isCodePicker: true,
                isCodePickerFillColor: false,
                borderRadius: 10,
                showBorder: false,
                hintText: 'contact_number'.tr,
                fillColor: Get.isDarkMode
                    ? Theme.of(context).cardColor
                    : Theme.of(context).primaryColor.withValues(alpha: 0.04),
                controller: parcelController.receiverContactController,
                focusNode: parcelController.receiverContactNode,
                nextFocus: parcelController.receiverNameNode,
                inputType: TextInputType.phone,
                countryDialCode: parcelController.getReceiverCountryDialCode,
                onCountryChanged: (CountryCode countryCode) {
                  parcelController
                      .onChangeReceiverCountryCode(countryCode.dialCode);
                },
              ),

              // Suggestions contacts répertoire
              if (_showContactSuggestions && _filteredContacts.isNotEmpty)
                _ContactSuggestionPanel(
                  contacts: _filteredContacts,
                  onSelect: _selectContact,
                  onDismiss: () =>
                      setState(() => _showContactSuggestions = false),
                ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Lieu de destination
              TextFieldTitle(title: 'lieu_destination'.tr, textOpacity: 0.8),
              _AddressField(
                controller: _addressSearchController,
                focusNode: _addressFocusNode,
                hintText: 'search_destination'.tr,
                onChanged: _onAddressChanged,
                onTap: () =>
                    parcelController.focusOnBottomSheet(widget.expandableKey),
                onMapTap: () => RouteHelper.goPageAndHideTextField(
                  context,
                  PickMapScreen(
                    type: LocationType.receiverLocation,
                    address: locationController.parcelReceiverAddress,
                  ),
                ),
              ),

              // Adresses sauvegardées
              const SizedBox(height: Dimensions.paddingSizeSmall),
              if (Get.find<AddressController>().addressList?.isNotEmpty ?? false) ...[
                TextFieldTitle(title: 'saved_address'.tr, textOpacity: 0.8),
                GetBuilder<AddressController>(builder: (addressController) {
                  final list = addressController.addressList;
                  if (list == null || list.isEmpty) {
                    return const SizedBox(height: Dimensions.paddingSizeSmall);
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeSmall),
                    child: SizedBox(
                      height: Get.width * 0.075,
                      child: ListView.builder(
                        itemCount: list.length,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              locationController
                                  .getZone(
                                    list[index].latitude.toString(),
                                    list[index].longitude.toString(),
                                  )
                                  .then((value) {
                                if (value.isSuccess) {
                                  // FIX : setReceiverAddress uniquement
                                  locationController.setReceiverAddress(list[index]);
                                  final addr = list[index].address ?? '';
                                  _addressSearchController.text = addr;
                                  // FIX : uniquement receiverAddressController
                                  parcelController.receiverAddressController.text = addr;
                                  parcelController.update();
                                } else {
                                  showCustomSnackBar(
                                      'service_not_available_in_this_area'.tr);
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  right: Dimensions.paddingSizeSmall),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSize),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                border: Border.all(
                                  color: Get.isDarkMode
                                      ? Theme.of(context).hintColor
                                      : Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.4),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeSmall),
                              ),
                              child: Row(children: [
                                Image.asset(
                                  list[index].addressLabel == 'home'
                                      ? Images.homeIcon
                                      : list[index].addressLabel == 'office'
                                          ? Images.workIcon
                                          : Images.otherIcon,
                                  color: Get.find<ThemeController>().darkTheme
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).hintColor,
                                  height: 16,
                                  width: 16,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Text(list[index].addressLabel!.tr,
                                    style: textBold),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ],
            ],

            // Suggestions adresses (propres à chaque instance grâce au ValueKey)
            if (hasPredictions)
              _AddressSuggestionPanel(
                predictions: predictions!,
                onSelect: _selectAddress,
                onDismiss: () {
                  locationController.setSearchResultShowHide(show: false);
                  setState(() => _showAddressSuggestions = false);
                },
              ),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            ButtonWidget(
              buttonText: 'next'.tr,
              onPressed: () => _onNextPressed(parcelController),
            ),
          ],
        );
      });
    });
  }

  void _onNextPressed(ParcelController parcelController) {
    if (widget.isSender) {
      if (parcelController.senderContactController.text.isEmpty) {
        showCustomSnackBar('enter_sender_contact_number'.tr);
        return;
      }
      final senderNumber = PhoneNumber.parse(
          '${parcelController.getSenderCountryCode}${parcelController.senderContactController.text}');
      if (!senderNumber.isValid(type: PhoneNumberType.mobile)) {
        showCustomSnackBar('enter_valid_contact_number'.tr);
        return;
      }
      if (parcelController.senderAddressController.text.isEmpty) {
        showCustomSnackBar('enter_sender_address'.tr);
        RouteHelper.goPageAndHideTextField(
          context,
          PickMapScreen(
            type: LocationType.senderLocation,
            address: Get.find<LocationController>().parcelSenderAddress,
          ),
        );
        return;
      }
      parcelController.updateTabControllerIndex(1);
      if (parcelController.getReceiverCountryDialCode == null) {
        parcelController
            .onChangeReceiverCountryCode(parcelController.getSenderCountryCode);
      }
    } else {
      if (parcelController.receiverContactController.text.isEmpty) {
        showCustomSnackBar('enter_receiver_contact_number'.tr);
        FocusScope.of(context).requestFocus(parcelController.receiverContactNode);
        return;
      }
      final receiverNumber = PhoneNumber.parse(
          '${parcelController.getReceiverCountryDialCode}${parcelController.receiverContactController.text}');
      if (!receiverNumber.isValid(type: PhoneNumberType.mobile)) {
        showCustomSnackBar('enter_valid_contact_number'.tr);
        FocusScope.of(context).requestFocus(parcelController.receiverContactNode);
        return;
      }
      if (parcelController.receiverAddressController.text.isEmpty) {
        showCustomSnackBar('enter_receiver_address'.tr);
        RouteHelper.goPageAndHideTextField(
          context,
          PickMapScreen(
            type: LocationType.receiverLocation,
            address: Get.find<LocationController>().parcelReceiverAddress,
          ),
        );
        return;
      }
      Get.find<MapController>().notifyMapController();
      parcelController
          .updateParcelState(ParcelDeliveryState.addOtherParcelDetails);
    }
  }

  @override
  void dispose() {
    if (!widget.isSender) {
      _phoneCtrl.removeListener(_onPhoneChanged);
    }
    _addressSearchController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widget champ adresse réutilisable
// ═══════════════════════════════════════════════════════════════════════════
class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;
  final VoidCallback onMapTap;

  const _AddressField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    required this.onTap,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.isDarkMode
            ? Theme.of(context).cardColor
            : Theme.of(context).primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: textRegular.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .color!
                      .withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
              ),
              style: textRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ),
          GestureDetector(
            onTap: onMapTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault),
              child: Image.asset(
                Images.location,
                height: 20,
                width: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Panneau suggestions contacts
// ═══════════════════════════════════════════════════════════════════════════
class _ContactSuggestionPanel extends StatelessWidget {
  final List<contacts_lib.Contact> contacts;
  final void Function(contacts_lib.Contact) onSelect;
  final VoidCallback onDismiss;

  const _ContactSuggestionPanel({
    required this.contacts,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
        border:
            Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall),
            child: Row(
              children: [
                Icon(Icons.contacts,
                    size: 13, color: Theme.of(context).primaryColor),
                const SizedBox(width: 6),
                Text('contacts_correspondants'.tr,
                    style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).primaryColor)),
                const Spacer(),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close, size: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: contacts.length,
              itemBuilder: (_, index) {
                final contact = contacts[index];
                final name = contact.displayName ?? 'Sans nom';
                final phone = contact.phones.first.number;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelect(contact),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall),
                      decoration: index < contacts.length - 1
                          ? BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey.withOpacity(0.1))))
                          : null,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: textMedium.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeSmall),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: textMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text(phone,
                                    style: textRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Colors.grey[600]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Icon(Icons.north_west,
                              size: 13, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Panneau suggestions adresses
// ═══════════════════════════════════════════════════════════════════════════
class _AddressSuggestionPanel extends StatelessWidget {
  final List<dynamic> predictions;
  final void Function(String placeId, String addressText) onSelect;
  final VoidCallback onDismiss;

  const _AddressSuggestionPanel({
    required this.predictions,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: Get.isDarkMode
            ? Theme.of(context).canvasColor
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall),
            child: Row(
              children: [
                Icon(Icons.location_on,
                    size: 13, color: Theme.of(context).primaryColor),
                const SizedBox(width: 6),
                Text('suggestions_adresses'.tr,
                    style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).primaryColor)),
                const Spacer(),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close, size: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: predictions.length,
              itemBuilder: (_, index) {
                final prediction = predictions[index].placePrediction;
                if (prediction == null) return const SizedBox.shrink();
                final mainText =
                    prediction.structuredFormat?.mainText?.text ?? '';
                final secondaryText =
                    prediction.structuredFormat?.secondaryText?.text ?? '';
                final fullText = prediction.text?.text ?? mainText;
                final placeId = prediction.placeId ?? '';

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelect(placeId, fullText),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeDefault,
                          horizontal: Dimensions.paddingSizeDefault),
                      decoration: index < predictions.length - 1
                          ? BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey.withOpacity(0.08))))
                          : null,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(Icons.location_on,
                                color: Theme.of(context).primaryColor,
                                size: 18),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mainText.isNotEmpty ? mainText : fullText,
                                  style: textMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (secondaryText.isNotEmpty)
                                  Text(secondaryText,
                                      style: textRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Colors.grey[500]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

*/




// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_contacts/flutter_contacts.dart' as contacts_lib;
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart' as perm;
// import 'package:phone_numbers_parser/phone_numbers_parser.dart';
// import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
// import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dart';
// import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
// import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
// import 'package:ride_sharing_user_app/helper/country_code_helper.dart';
// import 'package:ride_sharing_user_app/helper/display_helper.dart';
// import 'package:ride_sharing_user_app/helper/route_helper.dart';
// import 'package:ride_sharing_user_app/theme/theme_controller.dart';
// import 'package:ride_sharing_user_app/util/dimensions.dart';
// import 'package:ride_sharing_user_app/util/images.dart';
// import 'package:ride_sharing_user_app/features/auth/widgets/test_field_title.dart';
// import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
// import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
// import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
// import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
// import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
// import 'package:ride_sharing_user_app/util/styles.dart';

// class ParcelInfoWidget extends StatefulWidget {
//   final bool isSender;
//   final GlobalKey<ExpandableBottomSheetState> expandableKey;

//   const ParcelInfoWidget({
//     super.key,
//     required this.isSender,
//     required this.expandableKey,
//   });

//   @override
//   State<ParcelInfoWidget> createState() => _ParcelInfoWidgetState();
// }

// class _ParcelInfoWidgetState extends State<ParcelInfoWidget> {
//   // ── Contacts (destinataire uniquement) ────────────────────────────────────
//   List<contacts_lib.Contact> _cachedContacts = [];
//   bool _hasLoadedContacts = false;
//   List<contacts_lib.Contact> _filteredContacts = [];
//   bool _showContactSuggestions = false;

//   // ── Adresse : controller propre à chaque instance ─────────────────────────
//   late TextEditingController _addressSearchController;
//   late FocusNode _addressFocusNode;
//   bool _showAddressSuggestions = false;

//   // ── Helpers ────────────────────────────────────────────────────────────────
//   LocationType get _locationType =>
//       widget.isSender ? LocationType.senderLocation : LocationType.receiverLocation;

//   TextEditingController get _phoneCtrl {
//     final p = Get.find<ParcelController>();
//     return widget.isSender ? p.senderContactController : p.receiverContactController;
//   }

//   TextEditingController get _parcelAddressCtrl {
//     final p = Get.find<ParcelController>();
//     return widget.isSender ? p.senderAddressController : p.receiverAddressController;
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();

//     _addressSearchController = TextEditingController();
//     _addressFocusNode = FocusNode();

//     final parcelController = Get.find<ParcelController>();
//     final locationController = Get.find<LocationController>();

//     if (widget.isSender) {
//       // ── Auto-remplissage expéditeur depuis le profil ──────────────────────
//       final senderPhone = Get.find<ProfileController>().profileModel?.data?.phone;
//       if (senderPhone != null) {
//         parcelController.onChangeSenderCountryCode(
//           CountryCodeHelper.getCountryCode(senderPhone),
//           isUpdate: false,
//         );
//         parcelController.senderContactController.text =
//             senderPhone.replaceAll(parcelController.getSenderCountryCode ?? '', '');
//       }
//       parcelController.senderNameController.text =
//           Get.find<ProfileController>().customerName();

//       // Adresse depuis la position actuelle
//       final currentAddress = locationController.address;
//       if (currentAddress != null && currentAddress.isNotEmpty) {
//         _addressSearchController.text = currentAddress;
//         parcelController.senderAddressController.text = currentAddress;
//       } else {
//         _tryAutoFillSenderAddress(parcelController, locationController);
//       }
//     } else {
//       // ── Destinataire : restaurer uniquement receiverAddressController ──────
//       _addressSearchController.text = parcelController.receiverAddressController.text;

//       // Activer la recherche contacts pour le destinataire
//       _phoneCtrl.addListener(_onPhoneChanged);
//       _preloadContacts();
//     }
//   }

//   Future<void> _tryAutoFillSenderAddress(
//     ParcelController parcelController,
//     LocationController locationController,
//   ) async {
//     try {
//       final address = locationController.parcelSenderAddress;
//       if (address?.address != null && address!.address!.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             _addressSearchController.text = address.address!;
//             parcelController.senderAddressController.text = address.address!;
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Erreur adresse expéditeur: $e');
//     }
//   }

//   // ── Contacts ───────────────────────────────────────────────────────────────

//   Future<void> _preloadContacts() async {
//     final status = await perm.Permission.contacts.status;
//     if (status == perm.PermissionStatus.granted) await _loadContacts();
//   }

//   Future<void> _loadContacts() async {
//     if (_hasLoadedContacts) return;
//     try {
//       final all = await contacts_lib.FlutterContacts.getAll(
//         properties: {
//           contacts_lib.ContactProperty.phone,
//           contacts_lib.ContactProperty.name,
//         },
//       );
//       if (!mounted) return;
//       setState(() {
//         _cachedContacts = all.where((c) => c.phones.isNotEmpty).toList();
//         _hasLoadedContacts = true;
//       });
//     } catch (e) {
//       debugPrint('Erreur chargement contacts: $e');
//     }
//   }

//   void _onPhoneChanged() {
//     final query = _phoneCtrl.text.trim();
//     if (query.isEmpty) {
//       if (mounted) setState(() => _showContactSuggestions = false);
//       return;
//     }
//     if (!_hasLoadedContacts) {
//       _requestPermissionThenFilter(query);
//     } else {
//       _filterContacts(query);
//     }
//   }

//   Future<void> _requestPermissionThenFilter(String query) async {
//     final status = await perm.Permission.contacts.request();
//     if (status == perm.PermissionStatus.granted) {
//       await _loadContacts();
//       if (mounted) _filterContacts(query);
//     }
//   }

//   void _filterContacts(String query) {
//     final lower = query.toLowerCase();
//     final results = _cachedContacts.where((c) {
//       final nameMatch = c.displayName?.toLowerCase().contains(lower) ?? false;
//       final phoneMatch = c.phones
//           .any((p) => p.number.replaceAll(RegExp(r'\s+'), '').contains(lower));
//       return nameMatch || phoneMatch;
//     }).take(6).toList();

//     if (mounted) {
//       setState(() {
//         _filteredContacts = results;
//         _showContactSuggestions = results.isNotEmpty;
//       });
//     }
//   }

//   void _selectContact(contacts_lib.Contact contact) {
//     final rawPhone = contact.phones.first.number.replaceAll(RegExp(r'\s+'), '');
//     _phoneCtrl.removeListener(_onPhoneChanged);
//     _phoneCtrl.text = rawPhone;
//     _phoneCtrl.addListener(_onPhoneChanged);
//     setState(() {
//       _showContactSuggestions = false;
//       _filteredContacts = [];
//     });
//     Get.find<ParcelController>().update();
//   }

//   // ── Adresse ────────────────────────────────────────────────────────────────

//   void _onAddressChanged(String text) {
//     if (text.trim().length < 2) {
//       setState(() => _showAddressSuggestions = false);
//       return;
//     }
//     // Recherche avec le locationType propre à cette instance
//     Get.find<LocationController>()
//         .searchLocation(context, text, type: _locationType);
//     setState(() => _showAddressSuggestions = true);
//   }

//   Future<void> _selectAddress(String placeId, String addressText) async {
//     final locationController = Get.find<LocationController>();
//     final parcelController = Get.find<ParcelController>();

//     // Set location avec le bon _locationType
//     await locationController.setLocation(
//       fromSearch: true,
//       placeId,
//       addressText,
//       null,
//       type: _locationType,
//     );

//     // Mise à jour uniquement du controller dédié à cette instance
//     _addressSearchController.text = addressText;
//     _parcelAddressCtrl.text = addressText;

//     // Cache les suggestions uniquement pour ce type
//     locationController.setSearchResultShowHide(show: false, type: _locationType);
//     _addressFocusNode.unfocus();
//     setState(() => _showAddressSuggestions = false);
//     parcelController.update();
//   }

//   // ── Build ──────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ParcelController>(builder: (parcelController) {
//       return GetBuilder<LocationController>(builder: (locationController) {
//         // Récupère les prédictions spécifiques à ce type
//         final predictions = locationController.getPredictions(_locationType);
//         final predictionList = predictions?.data?.suggestions
//             ?.where((s) => s.placePrediction != null)
//             .toList();
//         final hasPredictions = _showAddressSuggestions &&
//             predictionList != null &&
//             predictionList.isNotEmpty;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (widget.isSender) ...[
//               // ══════════════════════════════════════════════════════════════
//               // EXPÉDITEUR
//               // ══════════════════════════════════════════════════════════════

//               TextFieldTitle(title: 'contact_expediteur'.tr, textOpacity: 0.8),
//               CustomTextField(
//                 isCodePicker: true,
//                 isCodePickerFillColor: false,
//                 borderRadius: 10,
//                 showBorder: false,
//                 isEnabled: false,
//                 hintText: 'contact_number'.tr,
//                 fillColor: Get.isDarkMode
//                     ? Theme.of(context).cardColor
//                     : Theme.of(context).primaryColor.withValues(alpha: 0.04),
//                 controller: parcelController.senderContactController,
//                 focusNode: parcelController.senderContactNode,
//                 inputType: TextInputType.phone,
//                 countryDialCode: parcelController.getSenderCountryCode,
//                 onCountryChanged: (_) {},
//               ),

//               const SizedBox(height: Dimensions.paddingSizeSmall),

//               TextFieldTitle(title: 'adresse_expediteur'.tr, textOpacity: 0.8),
//               _AddressField(
//                 controller: _addressSearchController,
//                 focusNode: _addressFocusNode,
//                 hintText: 'position_actuelle'.tr,
//                 onChanged: _onAddressChanged,
//                 onTap: () =>
//                     parcelController.focusOnBottomSheet(widget.expandableKey),
//                 onMapTap: () => RouteHelper.goPageAndHideTextField(
//                   context,
//                   PickMapScreen(
//                     type: LocationType.senderLocation,
//                     address: locationController.parcelSenderAddress,
//                   ),
//                 ),
//               ),
//             ] else ...[
//               // ══════════════════════════════════════════════════════════════
//               // DESTINATAIRE
//               // ══════════════════════════════════════════════════════════════

//               TextFieldTitle(title: 'contact_destinataire'.tr, textOpacity: 0.8),
//               CustomTextField(
//                 isCodePicker: true,
//                 isCodePickerFillColor: false,
//                 borderRadius: 10,
//                 showBorder: false,
//                 hintText: 'contact_number'.tr,
//                 fillColor: Get.isDarkMode
//                     ? Theme.of(context).cardColor
//                     : Theme.of(context).primaryColor.withValues(alpha: 0.04),
//                 controller: parcelController.receiverContactController,
//                 focusNode: parcelController.receiverContactNode,
//                 nextFocus: parcelController.receiverNameNode,
//                 inputType: TextInputType.phone,
//                 countryDialCode: parcelController.getReceiverCountryDialCode,
//                 onCountryChanged: (CountryCode countryCode) {
//                   parcelController
//                       .onChangeReceiverCountryCode(countryCode.dialCode);
//                 },
//               ),

//               if (_showContactSuggestions && _filteredContacts.isNotEmpty)
//                 _ContactSuggestionPanel(
//                   contacts: _filteredContacts,
//                   onSelect: _selectContact,
//                   onDismiss: () =>
//                       setState(() => _showContactSuggestions = false),
//                 ),

//               const SizedBox(height: Dimensions.paddingSizeSmall),

//               TextFieldTitle(title: 'lieu_destination'.tr, textOpacity: 0.8),
//               _AddressField(
//                 controller: _addressSearchController,
//                 focusNode: _addressFocusNode,
//                 hintText: 'search_destination'.tr,
//                 onChanged: _onAddressChanged,
//                 onTap: () =>
//                     parcelController.focusOnBottomSheet(widget.expandableKey),
//                 onMapTap: () => RouteHelper.goPageAndHideTextField(
//                   context,
//                   PickMapScreen(
//                     type: LocationType.receiverLocation,
//                     address: locationController.parcelReceiverAddress,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: Dimensions.paddingSizeSmall),
//               if (Get.find<AddressController>().addressList?.isNotEmpty ?? false) ...[
//                 TextFieldTitle(title: 'saved_address'.tr, textOpacity: 0.8),
//                 GetBuilder<AddressController>(builder: (addressController) {
//                   final list = addressController.addressList;
//                   if (list == null || list.isEmpty) {
//                     return const SizedBox(height: Dimensions.paddingSizeSmall);
//                   }
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: Dimensions.paddingSizeSmall),
//                     child: SizedBox(
//                       height: Get.width * 0.075,
//                       child: ListView.builder(
//                         itemCount: list.length,
//                         padding: EdgeInsets.zero,
//                         scrollDirection: Axis.horizontal,
//                         itemBuilder: (context, index) {
//                           return InkWell(
//                             onTap: () {
//                               locationController
//                                   .getZone(
//                                     list[index].latitude.toString(),
//                                     list[index].longitude.toString(),
//                                   )
//                                   .then((value) {
//                                 if (value.isSuccess) {
//                                   locationController.setReceiverAddress(list[index]);
//                                   final addr = list[index].address ?? '';
//                                   _addressSearchController.text = addr;
//                                   parcelController.receiverAddressController.text = addr;
//                                   parcelController.update();
//                                 } else {
//                                   showCustomSnackBar(
//                                       'service_not_available_in_this_area'.tr);
//                                 }
//                               });
//                             },
//                             child: Container(
//                               margin: const EdgeInsets.only(
//                                   right: Dimensions.paddingSizeSmall),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: Dimensions.paddingSize),
//                               decoration: BoxDecoration(
//                                 color: Theme.of(context).cardColor,
//                                 border: Border.all(
//                                   color: Get.isDarkMode
//                                       ? Theme.of(context).hintColor
//                                       : Theme.of(context)
//                                           .primaryColor
//                                           .withValues(alpha: 0.4),
//                                   width: 0.5,
//                                 ),
//                                 borderRadius: BorderRadius.circular(
//                                     Dimensions.paddingSizeSmall),
//                               ),
//                               child: Row(children: [
//                                 Image.asset(
//                                   list[index].addressLabel == 'home'
//                                       ? Images.homeIcon
//                                       : list[index].addressLabel == 'office'
//                                           ? Images.workIcon
//                                           : Images.otherIcon,
//                                   color: Get.find<ThemeController>().darkTheme
//                                       ? Theme.of(context).primaryColor
//                                       : Theme.of(context).hintColor,
//                                   height: 16,
//                                   width: 16,
//                                 ),
//                                 const SizedBox(width: Dimensions.paddingSizeSmall),
//                                 Text(list[index].addressLabel!.tr,
//                                     style: textBold),
//                               ]),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   );
//                 }),
//               ],
//             ],

//             // Suggestions adresses propres à chaque instance
//             if (hasPredictions)
//               _AddressSuggestionPanel(
//                 predictions: predictionList!,
//                 onSelect: _selectAddress,
//                 onDismiss: () {
//                   Get.find<LocationController>()
//                       .setSearchResultShowHide(show: false, type: _locationType);
//                   setState(() => _showAddressSuggestions = false);
//                 },
//               ),

//             const SizedBox(height: Dimensions.paddingSizeSmall),

//             ButtonWidget(
//               buttonText: 'next'.tr,
//               onPressed: () => _onNextPressed(parcelController),
//             ),
//           ],
//         );
//       });
//     });
//   }

//   void _onNextPressed(ParcelController parcelController) {
//     if (widget.isSender) {
//       if (parcelController.senderContactController.text.isEmpty) {
//         showCustomSnackBar('enter_sender_contact_number'.tr);
//         return;
//       }
//       final senderNumber = PhoneNumber.parse(
//           '${parcelController.getSenderCountryCode}${parcelController.senderContactController.text}');
//       if (!senderNumber.isValid(type: PhoneNumberType.mobile)) {
//         showCustomSnackBar('enter_valid_contact_number'.tr);
//         return;
//       }
//       if (parcelController.senderAddressController.text.isEmpty) {
//         showCustomSnackBar('enter_sender_address'.tr);
//         RouteHelper.goPageAndHideTextField(
//           context,
//           PickMapScreen(
//             type: LocationType.senderLocation,
//             address: Get.find<LocationController>().parcelSenderAddress,
//           ),
//         );
//         return;
//       }
//       parcelController.updateTabControllerIndex(1);
//       if (parcelController.getReceiverCountryDialCode == null) {
//         parcelController
//             .onChangeReceiverCountryCode(parcelController.getSenderCountryCode);
//       }
//     } else {
//       if (parcelController.receiverContactController.text.isEmpty) {
//         showCustomSnackBar('enter_receiver_contact_number'.tr);
//         FocusScope.of(context).requestFocus(parcelController.receiverContactNode);
//         return;
//       }
//       final receiverNumber = PhoneNumber.parse(
//           '${parcelController.getReceiverCountryDialCode}${parcelController.receiverContactController.text}');
//       if (!receiverNumber.isValid(type: PhoneNumberType.mobile)) {
//         showCustomSnackBar('enter_valid_contact_number'.tr);
//         FocusScope.of(context).requestFocus(parcelController.receiverContactNode);
//         return;
//       }
//       if (parcelController.receiverAddressController.text.isEmpty) {
//         showCustomSnackBar('enter_receiver_address'.tr);
//         RouteHelper.goPageAndHideTextField(
//           context,
//           PickMapScreen(
//             type: LocationType.receiverLocation,
//             address: Get.find<LocationController>().parcelReceiverAddress,
//           ),
//         );
//         return;
//       }
//       Get.find<MapController>().notifyMapController();
//       parcelController
//           .updateParcelState(ParcelDeliveryState.addOtherParcelDetails);
//     }
//   }

//   @override
//   void dispose() {
//     if (!widget.isSender) {
//       _phoneCtrl.removeListener(_onPhoneChanged);
//     }
//     _addressSearchController.dispose();
//     _addressFocusNode.dispose();
//     super.dispose();
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════
// // Widget champ adresse réutilisable
// // ═══════════════════════════════════════════════════════════════════════════
// class _AddressField extends StatelessWidget {
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final String hintText;
//   final ValueChanged<String> onChanged;
//   final VoidCallback onTap;
//   final VoidCallback onMapTap;

//   const _AddressField({
//     required this.controller,
//     required this.focusNode,
//     required this.hintText,
//     required this.onChanged,
//     required this.onTap,
//     required this.onMapTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Get.isDarkMode
//             ? Theme.of(context).cardColor
//             : Theme.of(context).primaryColor.withValues(alpha: 0.04),
//         borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: controller,
//               focusNode: focusNode,
//               onChanged: onChanged,
//               onTap: onTap,
//               decoration: InputDecoration(
//                 hintText: hintText,
//                 hintStyle: textRegular.copyWith(
//                   color: Theme.of(context)
//                       .textTheme
//                       .bodyMedium!
//                       .color!
//                       .withOpacity(0.5),
//                 ),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: Dimensions.paddingSizeDefault,
//                   vertical: Dimensions.paddingSizeSmall,
//                 ),
//               ),
//               style: textRegular.copyWith(
//                 color: Theme.of(context).textTheme.bodyLarge!.color,
//                 fontSize: Dimensions.fontSizeDefault,
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: onMapTap,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: Dimensions.paddingSizeDefault),
//               child: Image.asset(
//                 Images.location,
//                 height: 20,
//                 width: 20,
//                 color: Theme.of(context).primaryColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════
// // Panneau suggestions contacts
// // ═══════════════════════════════════════════════════════════════════════════
// class _ContactSuggestionPanel extends StatelessWidget {
//   final List<contacts_lib.Contact> contacts;
//   final void Function(contacts_lib.Contact) onSelect;
//   final VoidCallback onDismiss;

//   const _ContactSuggestionPanel({
//     required this.contacts,
//     required this.onSelect,
//     required this.onDismiss,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(top: 4),
//       constraints: const BoxConstraints(maxHeight: 220),
//       decoration: BoxDecoration(
//         color: Get.isDarkMode ? Theme.of(context).cardColor : Colors.white,
//         borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 8,
//               offset: const Offset(0, 3)),
//         ],
//         border:
//             Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: Dimensions.paddingSizeDefault,
//                 vertical: Dimensions.paddingSizeSmall),
//             child: Row(
//               children: [
//                 Icon(Icons.contacts,
//                     size: 13, color: Theme.of(context).primaryColor),
//                 const SizedBox(width: 6),
//                 Text('contacts_correspondants'.tr,
//                     style: textRegular.copyWith(
//                         fontSize: Dimensions.fontSizeExtraSmall,
//                         color: Theme.of(context).primaryColor)),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: onDismiss,
//                   child: Icon(Icons.close, size: 14, color: Colors.grey[400]),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           Flexible(
//             child: ListView.builder(
//               shrinkWrap: true,
//               padding: EdgeInsets.zero,
//               itemCount: contacts.length,
//               itemBuilder: (_, index) {
//                 final contact = contacts[index];
//                 final name = contact.displayName ?? 'Sans nom';
//                 final phone = contact.phones.first.number;
//                 return Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () => onSelect(contact),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: Dimensions.paddingSizeDefault,
//                           vertical: Dimensions.paddingSizeSmall),
//                       decoration: index < contacts.length - 1
//                           ? BoxDecoration(
//                               border: Border(
//                                   bottom: BorderSide(
//                                       color: Colors.grey.withOpacity(0.1))))
//                           : null,
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 17,
//                             backgroundColor:
//                                 Theme.of(context).primaryColor.withOpacity(0.1),
//                             child: Text(
//                               name.isNotEmpty ? name[0].toUpperCase() : '?',
//                               style: textMedium.copyWith(
//                                   color: Theme.of(context).primaryColor,
//                                   fontSize: Dimensions.fontSizeSmall),
//                             ),
//                           ),
//                           const SizedBox(width: Dimensions.paddingSizeSmall),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(name,
//                                     style: textMedium.copyWith(
//                                         fontSize: Dimensions.fontSizeDefault),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis),
//                                 Text(phone,
//                                     style: textRegular.copyWith(
//                                         fontSize: Dimensions.fontSizeSmall,
//                                         color: Colors.grey[600]),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis),
//                               ],
//                             ),
//                           ),
//                           Icon(Icons.north_west,
//                               size: 13, color: Colors.grey[400]),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════
// // Panneau suggestions adresses
// // ═══════════════════════════════════════════════════════════════════════════
// class _AddressSuggestionPanel extends StatelessWidget {
//   final List<dynamic> predictions;
//   final void Function(String placeId, String addressText) onSelect;
//   final VoidCallback onDismiss;

//   const _AddressSuggestionPanel({
//     required this.predictions,
//     required this.onSelect,
//     required this.onDismiss,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(top: 4),
//       constraints: const BoxConstraints(maxHeight: 260),
//       decoration: BoxDecoration(
//         color: Get.isDarkMode
//             ? Theme.of(context).canvasColor
//             : Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.grey.withOpacity(0.15),
//               blurRadius: 8,
//               offset: const Offset(0, 3)),
//         ],
//         border: Border.all(color: Colors.grey.withOpacity(0.1)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: Dimensions.paddingSizeDefault,
//                 vertical: Dimensions.paddingSizeSmall),
//             child: Row(
//               children: [
//                 Icon(Icons.location_on,
//                     size: 13, color: Theme.of(context).primaryColor),
//                 const SizedBox(width: 6),
//                 Text('suggestions_adresses'.tr,
//                     style: textRegular.copyWith(
//                         fontSize: Dimensions.fontSizeExtraSmall,
//                         color: Theme.of(context).primaryColor)),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: onDismiss,
//                   child: Icon(Icons.close, size: 14, color: Colors.grey[400]),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           Flexible(
//             child: ListView.builder(
//               shrinkWrap: true,
//               padding: EdgeInsets.zero,
//               itemCount: predictions.length,
//               itemBuilder: (_, index) {
//                 final prediction = predictions[index].placePrediction;
//                 if (prediction == null) return const SizedBox.shrink();
//                 final mainText =
//                     prediction.structuredFormat?.mainText?.text ?? '';
//                 final secondaryText =
//                     prediction.structuredFormat?.secondaryText?.text ?? '';
//                 final fullText = prediction.text?.text ?? mainText;
//                 final placeId = prediction.placeId ?? '';

//                 return Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () => onSelect(placeId, fullText),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: Dimensions.paddingSizeDefault,
//                           horizontal: Dimensions.paddingSizeDefault),
//                       decoration: index < predictions.length - 1
//                           ? BoxDecoration(
//                               border: Border(
//                                   bottom: BorderSide(
//                                       color: Colors.grey.withOpacity(0.08))))
//                           : null,
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(top: 2),
//                             child: Icon(Icons.location_on,
//                                 color: Theme.of(context).primaryColor,
//                                 size: 18),
//                           ),
//                           const SizedBox(width: Dimensions.paddingSizeSmall),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   mainText.isNotEmpty ? mainText : fullText,
//                                   style: textMedium.copyWith(
//                                       fontSize: Dimensions.fontSizeDefault),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 if (secondaryText.isNotEmpty)
//                                   Text(secondaryText,
//                                       style: textRegular.copyWith(
//                                           fontSize: Dimensions.fontSizeSmall,
//                                           color: Colors.grey[500]),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts_lib;
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/helper/country_code_helper.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/auth/widgets/test_field_title.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ParcelInfoWidget extends StatefulWidget {
  final bool isSender;
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const ParcelInfoWidget({
    super.key,
    required this.isSender,
    required this.expandableKey,
  });

  @override
  State<ParcelInfoWidget> createState() => _ParcelInfoWidgetState();
}

class _ParcelInfoWidgetState extends State<ParcelInfoWidget> {
  // ── Contacts (destinataire uniquement) ────────────────────────────────────
  List<contacts_lib.Contact> _cachedContacts = [];
  bool _hasLoadedContacts = false;
  List<contacts_lib.Contact> _filteredContacts = [];
  bool _showContactSuggestions = false;

  // ── Adresse : controller propre à chaque instance ─────────────────────────
  late TextEditingController _addressSearchController;
  late FocusNode _addressFocusNode;
  bool _showAddressSuggestions = false;

  // ── Helpers ────────────────────────────────────────────────────────────────
  LocationType get _locationType =>
      widget.isSender ? LocationType.senderLocation : LocationType.receiverLocation;

  TextEditingController get _phoneCtrl {
    final p = Get.find<ParcelController>();
    return widget.isSender ? p.senderContactController : p.receiverContactController;
  }

  TextEditingController get _parcelAddressCtrl {
    final p = Get.find<ParcelController>();
    return widget.isSender ? p.senderAddressController : p.receiverAddressController;
  }

  TextEditingController get _nameCtrl {
    final p = Get.find<ParcelController>();
    return widget.isSender ? p.senderNameController : p.receiverNameController;
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _addressSearchController = TextEditingController();
    _addressFocusNode = FocusNode();

    final parcelController = Get.find<ParcelController>();
    final locationController = Get.find<LocationController>();
    final profileController = Get.find<ProfileController>();

    if (widget.isSender) {
      // ── Auto-remplissage expéditeur depuis le profil ──────────────────────
      final senderPhone = profileController.profileModel?.data?.phone;
      if (senderPhone != null) {
        parcelController.onChangeSenderCountryCode(
          CountryCodeHelper.getCountryCode(senderPhone),
          isUpdate: false,
        );
        parcelController.senderContactController.text =
            senderPhone.replaceAll(parcelController.getSenderCountryCode ?? '', '');
      }

      parcelController.senderNameController.text = profileController.customerName();

      // Adresse depuis la position actuelle
      final currentAddress = locationController.address;
      if (currentAddress != null && currentAddress.isNotEmpty) {
        _addressSearchController.text = currentAddress;
        parcelController.senderAddressController.text = currentAddress;
      } else {
        _tryAutoFillSenderAddress(parcelController, locationController);
      }
    } else {
      // ── Destinataire : restaurer uniquement receiverAddressController ──────
      _addressSearchController.text = parcelController.receiverAddressController.text;

      // Activer la recherche contacts pour le destinataire
      _phoneCtrl.addListener(_onPhoneChanged);
      _preloadContacts();
    }
  }

  Future<void> _tryAutoFillSenderAddress(
    ParcelController parcelController,
    LocationController locationController,
  ) async {
    try {
      final address = locationController.parcelSenderAddress;
      if (address?.address != null && address!.address!.isNotEmpty) {
        if (mounted) {
          setState(() {
            _addressSearchController.text = address.address!;
            parcelController.senderAddressController.text = address.address!;
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur adresse expéditeur: $e');
    }
  }

  // ── Contacts ───────────────────────────────────────────────────────────────

  Future<void> _preloadContacts() async {
    final status = await perm.Permission.contacts.status;
    if (status == perm.PermissionStatus.granted) await _loadContacts();
  }

  Future<void> _loadContacts() async {
    if (_hasLoadedContacts) return;
    try {
      final all = await contacts_lib.FlutterContacts.getAll(
        properties: {
          contacts_lib.ContactProperty.phone,
          contacts_lib.ContactProperty.name,
        },
      );
      if (!mounted) return;
      setState(() {
        _cachedContacts = all.where((c) => c.phones.isNotEmpty).toList();
        _hasLoadedContacts = true;
      });
    } catch (e) {
      debugPrint('Erreur chargement contacts: $e');
    }
  }

  void _onPhoneChanged() {
    final query = _phoneCtrl.text.trim();
    if (query.isEmpty) {
      if (mounted) setState(() => _showContactSuggestions = false);
      return;
    }
    if (!_hasLoadedContacts) {
      _requestPermissionThenFilter(query);
    } else {
      _filterContacts(query);
    }
  }

  Future<void> _requestPermissionThenFilter(String query) async {
    final status = await perm.Permission.contacts.request();
    if (status == perm.PermissionStatus.granted) {
      await _loadContacts();
      if (mounted) _filterContacts(query);
    }
  }

  void _filterContacts(String query) {
    final lower = query.toLowerCase();
    final results = _cachedContacts.where((c) {
      final nameMatch = c.displayName?.toLowerCase().contains(lower) ?? false;
      final phoneMatch = c.phones
          .any((p) => p.number.replaceAll(RegExp(r'\s+'), '').contains(lower));
      return nameMatch || phoneMatch;
    }).take(6).toList();

    if (mounted) {
      setState(() {
        _filteredContacts = results;
        _showContactSuggestions = results.isNotEmpty;
      });
    }
  }

  void _selectContact(contacts_lib.Contact contact) {
    final rawPhone = contact.phones.first.number.replaceAll(RegExp(r'\s+'), '');
    _phoneCtrl.removeListener(_onPhoneChanged);
    _phoneCtrl.text = rawPhone;
    _phoneCtrl.addListener(_onPhoneChanged);
    
    // Remplir aussi le nom du destinataire si vide
    if (_nameCtrl.text.isEmpty && contact.displayName != null) {
      _nameCtrl.text = contact.displayName!;
    }
    
    setState(() {
      _showContactSuggestions = false;
      _filteredContacts = [];
    });
    Get.find<ParcelController>().update();
  }

  // ── Adresse ────────────────────────────────────────────────────────────────

  void _onAddressChanged(String text) {
    if (text.trim().length < 2) {
      setState(() => _showAddressSuggestions = false);
      return;
    }
    // Recherche avec le locationType propre à cette instance
    Get.find<LocationController>()
        .searchLocation(context, text, type: _locationType);
    setState(() => _showAddressSuggestions = true);
  }

  Future<void> _selectAddress(String placeId, String addressText) async {
    final locationController = Get.find<LocationController>();
    final parcelController = Get.find<ParcelController>();

    // Set location avec le bon _locationType
    await locationController.setLocation(
      fromSearch: true,
      placeId,
      addressText,
      null,
      type: _locationType,
    );

    // Mise à jour uniquement du controller dédié à cette instance
    _addressSearchController.text = addressText;
    _parcelAddressCtrl.text = addressText;

    // Cache les suggestions uniquement pour ce type
    locationController.setSearchResultShowHide(show: false, type: _locationType);
    _addressFocusNode.unfocus();
    setState(() => _showAddressSuggestions = false);
    parcelController.update();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParcelController>(builder: (parcelController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        // Récupère les prédictions spécifiques à ce type
        final predictions = locationController.getPredictions(_locationType);
        final predictionList = predictions?.data?.suggestions
            ?.where((s) => s.placePrediction != null)
            .toList();
        final hasPredictions = _showAddressSuggestions &&
            predictionList != null &&
            predictionList.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isSender) ...[
              // ══════════════════════════════════════════════════════════════
              // EXPÉDITEUR
              // ══════════════════════════════════════════════════════════════

              TextFieldTitle(title: 'contact_expediteur'.tr, textOpacity: 0.8),
              
              // Champ contact expéditeur (désactivé - pré-rempli)
              _buildPhoneField(
                controller: parcelController.senderContactController,
                focusNode: parcelController.senderContactNode,
                hintText: 'contact_number'.tr,
                countryCode: parcelController.getSenderCountryCode,
                isEnabled: false,
                onCountryChanged: (_) {},
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              TextFieldTitle(title: 'adresse_expediteur'.tr, textOpacity: 0.8),
              _AddressField(
                controller: _addressSearchController,
                focusNode: _addressFocusNode,
                hintText: 'position_actuelle'.tr,
                onChanged: _onAddressChanged,
                onTap: () =>
                    parcelController.focusOnBottomSheet(widget.expandableKey),
                onMapTap: () => RouteHelper.goPageAndHideTextField(
                  context,
                  PickMapScreen(
                    type: LocationType.senderLocation,
                    address: locationController.parcelSenderAddress,
                  ),
                ),
              ),
            ] else ...[
              // ══════════════════════════════════════════════════════════════
              // DESTINATAIRE
              // ══════════════════════════════════════════════════════════════

              // Titre et description
              Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFieldTitle(
                      title: 'destinataire'.tr,
                      textOpacity: 0.8,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'send_tracking_link'.tr,
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Placeholder texte
              Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: Text(
                  'enter_name_or_phone'.tr,
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.grey[500],
                  ),
                ),
              ),

              // Champ contact destinataire (actif - recherche)
              _buildPhoneField(
                controller: parcelController.receiverContactController,
                focusNode: parcelController.receiverContactNode,
                hintText: 'contact_number'.tr,
                countryCode: parcelController.getReceiverCountryDialCode,
                isEnabled: true,
                onCountryChanged: (CountryCode countryCode) {
                  parcelController.onChangeReceiverCountryCode(countryCode.dialCode);
                },
              ),

              // Panel suggestions contacts
              if (_showContactSuggestions && _filteredContacts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeSmall,
                  ),
                  child: _ContactSuggestionPanel(
                    contacts: _filteredContacts,
                    onSelect: _selectContact,
                    onDismiss: () =>
                        setState(() => _showContactSuggestions = false),
                  ),
                ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Divider
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                ),
                height: 1,
                color: Colors.grey[300],
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              TextFieldTitle(
                title: 'lieu_destination'.tr,
                textOpacity: 0.8,
              ),
              _AddressField(
                controller: _addressSearchController,
                focusNode: _addressFocusNode,
                hintText: 'search_destination'.tr,
                onChanged: _onAddressChanged,
                onTap: () =>
                    parcelController.focusOnBottomSheet(widget.expandableKey),
                onMapTap: () => RouteHelper.goPageAndHideTextField(
                  context,
                  PickMapScreen(
                    type: LocationType.receiverLocation,
                    address: locationController.parcelReceiverAddress,
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Adresses sauvegardées
              if (Get.find<AddressController>().addressList?.isNotEmpty ?? false) ...[
                TextFieldTitle(
                  title: 'saved_address'.tr,
                  textOpacity: 0.8,
                ),
                GetBuilder<AddressController>(builder: (addressController) {
                  final list = addressController.addressList;
                  if (list == null || list.isEmpty) {
                    return const SizedBox(height: Dimensions.paddingSizeSmall);
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeSmall),
                    child: SizedBox(
                      height: Get.width * 0.075,
                      child: ListView.builder(
                        itemCount: list.length,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              locationController
                                  .getZone(
                                    list[index].latitude.toString(),
                                    list[index].longitude.toString(),
                                  )
                                  .then((value) {
                                if (value.isSuccess) {
                                  locationController.setReceiverAddress(list[index]);
                                  final addr = list[index].address ?? '';
                                  _addressSearchController.text = addr;
                                  parcelController.receiverAddressController.text =
                                      addr;
                                  parcelController.update();
                                } else {
                                  showCustomSnackBar(
                                      'service_not_available_in_this_area'.tr);
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  right: Dimensions.paddingSizeSmall),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSize),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                border: Border.all(
                                  color: Get.isDarkMode
                                      ? Theme.of(context).hintColor
                                      : Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.4),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeSmall),
                              ),
                              child: Row(children: [
                                Image.asset(
                                  list[index].addressLabel == 'home'
                                      ? Images.homeIcon
                                      : list[index].addressLabel == 'office'
                                          ? Images.workIcon
                                          : Images.otherIcon,
                                  color: Get.find<ThemeController>().darkTheme
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).hintColor,
                                  height: 16,
                                  width: 16,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Text(list[index].addressLabel!.tr,
                                    style: textBold),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ],
            ],

            // Suggestions adresses propres à chaque instance
            if (hasPredictions)
              Padding(
                padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeSmall,
                ),
                child: _AddressSuggestionPanel(
                  predictions: predictionList!,
                  onSelect: _selectAddress,
                  onDismiss: () {
                    Get.find<LocationController>().setSearchResultShowHide(
                        show: false, type: _locationType);
                    setState(() => _showAddressSuggestions = false);
                  },
                ),
              ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            ButtonWidget(
              buttonText: 'next'.tr,
              onPressed: () => _onNextPressed(parcelController),
            ),
          ],
        );
      });
    });
  }

  Widget _buildPhoneField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String? countryCode,
    required bool isEnabled,
    required Function(CountryCode) onCountryChanged,
  }) {
    return CustomTextField(
      isCodePicker: true,
      isCodePickerFillColor: false,
      borderRadius: 10,
      showBorder: false,
      isEnabled: isEnabled,
      hintText: hintText,
      fillColor: Get.isDarkMode
          ? Theme.of(context).cardColor
          : Theme.of(context).primaryColor.withValues(alpha: 0.04),
      controller: controller,
      focusNode: focusNode,
      inputType: TextInputType.phone,
      countryDialCode: countryCode,
      onCountryChanged: onCountryChanged,
    );
  }

  void _onNextPressed(ParcelController parcelController) {
    if (widget.isSender) {
      if (parcelController.senderContactController.text.isEmpty) {
        showCustomSnackBar('enter_sender_contact_number'.tr);
        return;
      }
      final senderNumber = PhoneNumber.parse(
          '${parcelController.getSenderCountryCode}${parcelController.senderContactController.text}');
      if (!senderNumber.isValid(type: PhoneNumberType.mobile)) {
        showCustomSnackBar('enter_valid_contact_number'.tr);
        return;
      }
      if (parcelController.senderAddressController.text.isEmpty) {
        showCustomSnackBar('enter_sender_address'.tr);
        RouteHelper.goPageAndHideTextField(
          context,
          PickMapScreen(
            type: LocationType.senderLocation,
            address: Get.find<LocationController>().parcelSenderAddress,
          ),
        );
        return;
      }
      parcelController.updateTabControllerIndex(1);
      if (parcelController.getReceiverCountryDialCode == null) {
        parcelController
            .onChangeReceiverCountryCode(parcelController.getSenderCountryCode);
      }
    } else {
      if (parcelController.receiverContactController.text.isEmpty) {
        showCustomSnackBar('enter_receiver_contact_number'.tr);
        FocusScope.of(context).requestFocus(parcelController.receiverContactNode);
        return;
      }
      final receiverNumber = PhoneNumber.parse(
          '${parcelController.getReceiverCountryDialCode}${parcelController.receiverContactController.text}');
      if (!receiverNumber.isValid(type: PhoneNumberType.mobile)) {
        showCustomSnackBar('enter_valid_contact_number'.tr);
        FocusScope.of(context).requestFocus(parcelController.receiverContactNode);
        return;
      }
      if (parcelController.receiverAddressController.text.isEmpty) {
        showCustomSnackBar('enter_receiver_address'.tr);
        RouteHelper.goPageAndHideTextField(
          context,
          PickMapScreen(
            type: LocationType.receiverLocation,
            address: Get.find<LocationController>().parcelReceiverAddress,
          ),
        );
        return;
      }
      Get.find<MapController>().notifyMapController();
      parcelController
          .updateParcelState(ParcelDeliveryState.addOtherParcelDetails);
    }
  }

  @override
  void dispose() {
    if (!widget.isSender) {
      _phoneCtrl.removeListener(_onPhoneChanged);
    }
    _addressSearchController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widget champ adresse réutilisable
// ═══════════════════════════════════════════════════════════════════════════
class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;
  final VoidCallback onMapTap;

  const _AddressField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    required this.onTap,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.isDarkMode
            ? Theme.of(context).cardColor
            : Theme.of(context).primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: textRegular.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .color!
                      .withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
              ),
              style: textRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ),
          GestureDetector(
            onTap: onMapTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault),
              child: Image.asset(
                Images.location,
                height: 20,
                width: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Panneau suggestions contacts
// ═══════════════════════════════════════════════════════════════════════════
class _ContactSuggestionPanel extends StatelessWidget {
  final List<contacts_lib.Contact> contacts;
  final void Function(contacts_lib.Contact) onSelect;
  final VoidCallback onDismiss;

  const _ContactSuggestionPanel({
    required this.contacts,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
        border:
            Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall),
            child: Row(
              children: [
                Icon(Icons.contacts,
                    size: 13, color: Theme.of(context).primaryColor),
                const SizedBox(width: 6),
                Text('contacts_correspondants'.tr,
                    style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).primaryColor)),
                const Spacer(),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close, size: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: contacts.length,
              itemBuilder: (_, index) {
                final contact = contacts[index];
                final name = contact.displayName ?? 'Sans nom';
                final phone = contact.phones.first.number;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelect(contact),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall),
                      decoration: index < contacts.length - 1
                          ? BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey.withOpacity(0.1))))
                          : null,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: textMedium.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeSmall),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: textMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text(phone,
                                    style: textRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Colors.grey[600]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Icon(Icons.north_west,
                              size: 13, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Panneau suggestions adresses
// ═══════════════════════════════════════════════════════════════════════════
class _AddressSuggestionPanel extends StatelessWidget {
  final List<dynamic> predictions;
  final void Function(String placeId, String addressText) onSelect;
  final VoidCallback onDismiss;

  const _AddressSuggestionPanel({
    required this.predictions,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: Get.isDarkMode
            ? Theme.of(context).canvasColor
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall),
            child: Row(
              children: [
                Icon(Icons.location_on,
                    size: 13, color: Theme.of(context).primaryColor),
                const SizedBox(width: 6),
                Text('suggestions_adresses'.tr,
                    style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).primaryColor)),
                const Spacer(),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close, size: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: predictions.length,
              itemBuilder: (_, index) {
                final prediction = predictions[index].placePrediction;
                if (prediction == null) return const SizedBox.shrink();
                final mainText =
                    prediction.structuredFormat?.mainText?.text ?? '';
                final secondaryText =
                    prediction.structuredFormat?.secondaryText?.text ?? '';
                final fullText = prediction.text?.text ?? mainText;
                final placeId = prediction.placeId ?? '';

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelect(placeId, fullText),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeDefault,
                          horizontal: Dimensions.paddingSizeDefault),
                      decoration: index < predictions.length - 1
                          ? BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey.withOpacity(0.08))))
                          : null,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(Icons.location_on,
                                color: Theme.of(context).primaryColor,
                                size: 18),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mainText.isNotEmpty ? mainText : fullText,
                                  style: textMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (secondaryText.isNotEmpty)
                                  Text(secondaryText,
                                      style: textRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Colors.grey[500]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}