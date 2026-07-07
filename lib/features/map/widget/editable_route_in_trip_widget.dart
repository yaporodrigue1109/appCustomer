
// import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';
// import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
// import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
// import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
// import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
// import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
// import 'package:ride_sharing_user_app/features/set_destination/widget/pick_location_widget.dart';
// import 'package:ride_sharing_user_app/helper/display_helper.dart';
// import 'package:ride_sharing_user_app/helper/route_helper.dart';
// import 'package:ride_sharing_user_app/localization/localization_controller.dart';
// import 'package:ride_sharing_user_app/util/dimensions.dart';
// import 'package:ride_sharing_user_app/util/images.dart';
// import 'package:ride_sharing_user_app/util/styles.dart';

// /// Widget de trajet éditable utilisé dans les bottom sheets de course
// class EditableRouteInTripWidget extends StatefulWidget {
//   final String firstRoute;
//   final String secondRoute;
//   final String thirdRoute;
//   final VoidCallback? onRouteChanged;

//   const EditableRouteInTripWidget({
//     super.key,
//     this.firstRoute = '',
//     this.secondRoute = '',
//     this.thirdRoute = '',
//     this.onRouteChanged,
//   });

//   @override
//   State<EditableRouteInTripWidget> createState() =>
//       _EditableRouteInTripWidgetState();
// }

// class _EditableRouteInTripWidgetState extends State<EditableRouteInTripWidget> {
//   // ── Focus nodes ─────────────────────────────────────────────────────────
//   late FocusNode _extraOneFocus;
//   late FocusNode _extraTwoFocus;
//   late FocusNode _extraThreeFocus;
//   late FocusNode _destinationFocus;
//   late FocusNode _pickupFocus; // Pour le champ départ (lecture seule)

//   final ScrollController _scrollController = ScrollController();

//   Timer? _debounceSearchTimer;
//   Timer? _autoCalcTimer;
//   bool _isCalculating = false;
//   bool _prefilled = false;

//   // Suivi de l'état « en cours de mise à jour » pour l'UI
//   bool _isUpdatingRoute = false;
//   String? _updateError;

//   // ─────────────────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _extraOneFocus = FocusNode();
//     _extraTwoFocus = FocusNode();
//     _extraThreeFocus = FocusNode();
//     _destinationFocus = FocusNode();
//     _pickupFocus = FocusNode();

//     _setupFocusListeners();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _prefillControllers();
//       _setupTextListeners();
//     });
//   }

//   // ══════════════════════════════════════════════════════════════════════════
//   // PRÉ-REMPLISSAGE
//   // ══════════════════════════════════════════════════════════════════════════

//   void _prefillControllers() {
//     if (_prefilled) return;
//     _prefilled = true;

//     final loc = Get.find<LocationController>();
//     final ride = Get.find<RideController>();
//     final trip = ride.tripDetails;

//     if (loc.fromAddress == null && trip?.pickupCoordinates != null) {
//       loc.fromAddress = Address(
//         address: trip?.pickupAddress ?? '',
//         latitude: trip?.pickupCoordinates?.coordinates?[1],
//         longitude: trip?.pickupCoordinates?.coordinates?[0],
//       );
//     }

//     if (loc.toAddress == null && trip?.destinationCoordinates != null) {
//       loc.toAddress = Address(
//         address: trip?.destinationAddress ?? '',
//         latitude: trip?.destinationCoordinates?.coordinates?[1],
//         longitude: trip?.destinationCoordinates?.coordinates?[0],
//       );
//     }

//     // Départ (controller)
//     if (loc.pickupLocationController.text.isEmpty) {
//       final pickup = trip?.pickupAddress ?? '';
//       if (pickup.isNotEmpty) loc.pickupLocationController.text = pickup;
//     }

//     // Destination (controller)
//     if (loc.destinationLocationController.text.isEmpty) {
//       final dest = trip?.destinationAddress ?? '';
//       if (dest.isNotEmpty) loc.destinationLocationController.text = dest;
//     }

//     // Arrêts intermédiaires transmis par le parent
//     bool changed = false;

//     if (widget.firstRoute.isNotEmpty && !loc.extraOneRoute) {
//       loc.extraOneRoute = true;
//       loc.extraRouteOneController.text = widget.firstRoute;
//       changed = true;
//     }
//     if (widget.secondRoute.isNotEmpty && !loc.extraTwoRoute) {
//       loc.extraTwoRoute = true;
//       loc.extraRouteTwoController.text = widget.secondRoute;
//       changed = true;
//     }
//     if (widget.thirdRoute.isNotEmpty && !loc.extraThreeRoute) {
//       loc.extraThreeRoute = true;
//       loc.extraRouteThreeController.text = widget.thirdRoute;
//       changed = true;
//     }

//     if (changed) {
//       loc.update();
//       if (mounted) setState(() {});
//     }
//   }

//   // ══════════════════════════════════════════════════════════════════════════
//   // FOCUS LISTENERS
//   // ══════════════════════════════════════════════════════════════════════════

//   void _setupFocusListeners() {
//     void onFocus(FocusNode fn, LocationType type, double scroll) {
//       fn.addListener(() {
//         if (fn.hasFocus) {
//           _clearIfPrefilled(type);
//           _scrollTo(scroll);
//           Get.find<LocationController>().locationType = type;
//           // Afficher les suggestions si le champ a du texte
//           final loc = Get.find<LocationController>();
//           final ctrl = _getControllerForType(type);
//           if (ctrl != null && ctrl.text.length > 2) {
//             loc.setSearchResultShowHide(show: true);
//           }
//         } else {
//           // Ne pas cacher immédiatement pour permettre la sélection
//           Future.delayed(const Duration(milliseconds: 300), () {
//             if (mounted) {
//               final loc = Get.find<LocationController>();
//               // Ne cacher que si aucun autre champ n'a le focus
//               if (!_extraOneFocus.hasFocus &&
//                   !_extraTwoFocus.hasFocus &&
//                   !_extraThreeFocus.hasFocus &&
//                   !_destinationFocus.hasFocus) {
//                 loc.setSearchResultShowHide(show: false);
//               }
//             }
//           });
//         }
//       });
//     }

//     onFocus(_extraOneFocus, LocationType.extraOne, 300);
//     onFocus(_extraTwoFocus, LocationType.extraTwo, 340);
//     onFocus(_extraThreeFocus, LocationType.extraThree, 380);
//     onFocus(_destinationFocus, LocationType.to, 420);
//   }

//   TextEditingController? _getControllerForType(LocationType type) {
//     final loc = Get.find<LocationController>();
//     switch (type) {
//       case LocationType.extraOne:
//         return loc.extraRouteOneController;
//       case LocationType.extraTwo:
//         return loc.extraRouteTwoController;
//       case LocationType.extraThree:
//         return loc.extraRouteThreeController;
//       case LocationType.to:
//         return loc.destinationLocationController;
//       default:
//         return null;
//     }
//   }

//   // ══════════════════════════════════════════════════════════════════════════
//   // TEXT LISTENERS (autocomplete)
//   // ══════════════════════════════════════════════════════════════════════════

//   void _setupTextListeners() {
//     final loc = Get.find<LocationController>();

//     void listen(TextEditingController ctrl, FocusNode fn, LocationType type) {
//       ctrl.addListener(() {
//         if (!fn.hasFocus) return;
//         final text = ctrl.text;
//         if (text.length > 2) {
//           _debounceSearch(text, type);
//         } else {
//           loc.setSearchResultShowHide(show: false);
//         }
//       });
//     }

//     listen(loc.extraRouteOneController, _extraOneFocus, LocationType.extraOne);
//     listen(loc.extraRouteTwoController, _extraTwoFocus, LocationType.extraTwo);
//     listen(loc.extraRouteThreeController, _extraThreeFocus,
//         LocationType.extraThree);
//     listen(loc.destinationLocationController, _destinationFocus,
//         LocationType.to);
//   }

//   void _debounceSearch(String query, LocationType type) {
//     _debounceSearchTimer?.cancel();
//     final loc = Get.find<LocationController>();
//     loc.locationType = type;
//     loc.setSearchResultShowHide(show: true);
//     _debounceSearchTimer = Timer(const Duration(milliseconds: 500), () {
//       if (query.trim().isNotEmpty) {
//         loc.searchLocation(context, query, type: type, fromMap: false);
//       } else {
//         loc.setSearchResultShowHide(show: false);
//       }
//     });
//   }

//   // ══════════════════════════════════════════════════════════════════════════
//   // RECALCUL TARIF + PERSISTANCE EN BASE
//   // ══════════════════════════════════════════════════════════════════════════

//   Future<void> _triggerRouteUpdate() async {
//     final loc = Get.find<LocationController>();
//     final ride = Get.find<RideController>();

//     if (loc.toAddress == null) return;
//     if (_isCalculating) return;

//     _autoCalcTimer?.cancel();
//     _autoCalcTimer = Timer(const Duration(milliseconds: 700), () async {
//       _isCalculating = true;

//       if (mounted) setState(() {
//         _isUpdatingRoute = true;
//         _updateError = null;
//       });

//       try {
//         // ── 1. Recalcul du tarif ────────────────────────────────────────
//         final fareResponse = await ride.getEstimatedFare(false);
//         if (fareResponse.statusCode != 200) {
//           _setError('fare_calculation_failed'.tr);
//           return;
//         }

//         // ── 2. Persistance en base ──────────────────────────────────────
//         if (ride.tripDetails?.id != null) {
//           final updateResponse = await ride.updateTripRoute(
//             tripId: ride.tripDetails!.id!,
//             newFare: ride.estimatedFare,
//             encodedPoly: ride.encodedPolyLine,
//           );

//           if (updateResponse.statusCode == 200) {
//             // ── Recharger tripDetails depuis le serveur plutôt que de
//             //    parser la réponse du PUT. La forme de la réponse de
//             //    l'endpoint de mise à jour peut différer de celle attendue
//             //    par TripDetailsModel.fromJson, ce qui provoquait l'erreur
//             //    "Null check operator used on a null value" et empêchait
//             //    le tarif/la distance affichés de se mettre à jour.
//             await ride.getRideDetails(ride.tripDetails!.id!);
//           } else {
//             _setError('route_update_failed'.tr);
//             return;
//           }
//         }

//         // ── 3. Rafraîchissement carte ────────────────────────────────────
//         await _refreshMap();

//         ride.update();
//         loc.update();
//         if (mounted) setState(() {});
//         widget.onRouteChanged?.call();
//       } catch (e) {
//         _setError('an_error_occurred'.tr);
//         debugPrint('EditableRouteInTripWidget._triggerRouteUpdate error: $e');
//       } finally {
//         _isCalculating = false;
//         if (mounted) setState(() {
//           _isUpdatingRoute = false;
//         });
//       }
//     });
//   }

//   void _setError(String msg) {
//     if (mounted) setState(() {
//       _updateError = msg;
//       _isUpdatingRoute = false;
//     });
//     showCustomSnackBar(msg, isError: true);
//   }

//   Future<void> _refreshMap() async {
//     final mapCtrl = Get.find<MapController>();
//     final loc = Get.find<LocationController>();
//     final points = <LatLng>[];

//     void add(Address? a) {
//       if (a?.latitude != null && a?.longitude != null) {
//         points.add(LatLng(a!.latitude!, a.longitude!));
//       }
//     }

//     add(loc.fromAddress);
//     add(loc.extraRouteAddress);
//     add(loc.extraRouteTwoAddress);
//     add(loc.extraRouteThreeAddress);
//     add(loc.toAddress);

//     if (points.length >= 2) await mapCtrl.showMultipleMarkersOnMap(points);
//   }

//   // ══════════════════════════════════════════════════════════════════════════
//   // HELPERS
//   // ══════════════════════════════════════════════════════════════════════════

//   void _scrollTo(double position) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           position,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   void _clearIfPrefilled(LocationType type) {
//     final loc = Get.find<LocationController>();
//     switch (type) {
//       case LocationType.extraOne:
//         if (loc.extraRouteOneController.text.isNotEmpty) {
//           loc.extraRouteOneController.clear();
//           loc.extraRouteAddress = null;
//         }
//         break;
//       case LocationType.extraTwo:
//         if (loc.extraRouteTwoController.text.isNotEmpty) {
//           loc.extraRouteTwoController.clear();
//           loc.extraRouteTwoAddress = null;
//         }
//         break;
//       case LocationType.extraThree:
//         if (loc.extraRouteThreeController.text.isNotEmpty) {
//           loc.extraRouteThreeController.clear();
//           loc.extraRouteThreeAddress = null;
//         }
//         break;
//       case LocationType.to:
//         if (loc.destinationLocationController.text.isNotEmpty) {
//           loc.destinationLocationController.clear();
//           loc.toAddress = null;
//         }
//         break;
//       default:
//         break;
//     }
//     loc.update();
//   }

//   int _stopsCount(LocationController loc) =>
//       (loc.extraOneRoute ? 1 : 0) +
//       (loc.extraTwoRoute ? 1 : 0) +
//       (loc.extraThreeRoute ? 1 : 0);

//   void _removeStop(LocationType type) {
//     final loc = Get.find<LocationController>();
//     switch (type) {
//       case LocationType.extraOne:
//         loc.extraOneRoute = false;
//         loc.extraRouteOneController.clear();
//         loc.extraRouteAddress = null;
//         break;
//       case LocationType.extraTwo:
//         loc.extraTwoRoute = false;
//         loc.extraRouteTwoController.clear();
//         loc.extraRouteTwoAddress = null;
//         break;
//       case LocationType.extraThree:
//         loc.extraThreeRoute = false;
//         loc.extraRouteThreeController.clear();
//         loc.extraRouteThreeAddress = null;
//         break;
//       default:
//         return;
//     }
//     loc.update();
//     Get.find<RideController>().update();
//     setState(() {});
//     _triggerRouteUpdate();
//   }

//   void _confirmRemoveStop(LocationType type) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('supprimer_arret'.tr),
//         content: Text('voulez_vous_supprimer_cet_arret'.tr),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: Text('annuler'.tr)),
//           TextButton(
//             onPressed: () {
//               Get.back();
//               _removeStop(type);
//             },
//             child: Text('supprimer'.tr, style: const TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ══════════════════════════════════════════════════════════════════════════
//   // BOUTON « + Ajouter un arrêt »
//   // ══════════════════════════════════════════════════════════════════════════

//   Widget _buildAddStopButton(LocationController locationController) {
//     return InkWell(
//       onTap: _canAddMoreStops(locationController)
//           ? () => _addNewRoute(locationController)
//           : null,
//       child: Container(
//         padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//         decoration: BoxDecoration(
//           color: _canAddMoreStops(locationController)
//               ? Theme.of(context).primaryColor
//               : Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//         ),
//         child: const Icon(Icons.add, color: Colors.white, size: 20),
//       ),
//     );
//   }

//   bool _canAddMoreStops(LocationController locationController) {
//     return true;
//   }

//   void _addNewRoute(LocationController locationController) {
//     if (!locationController.extraOneRoute) {
//       locationController.extraOneRoute = true;
//     } else if (!locationController.extraTwoRoute) {
//       locationController.extraTwoRoute = true;
//     } else if (!locationController.extraThreeRoute) {
//       locationController.extraThreeRoute = true;
//     }
//     locationController.update();
//     setState(() {});
//   }

//   // ══════════════════════════════════════════════════════════════════════════
//   // ITEMS RÉORDONNABLES
//   // ══════════════════════════════════════════════════════════════════════════

//   List<Map<String, dynamic>> _buildItems(LocationController loc) {
//     return [
//       if (loc.extraOneRoute)
//         {
//           'type': LocationType.extraOne,
//           'hint': 'extra_route_one'.tr,
//           'ctrl': loc.extraRouteOneController,
//           'addr': loc.extraRouteAddress,
//           'focus': _extraOneFocus,
//           'isDest': false,
//         },
//       if (loc.extraTwoRoute)
//         {
//           'type': LocationType.extraTwo,
//           'hint': 'extra_route_two'.tr,
//           'ctrl': loc.extraRouteTwoController,
//           'addr': loc.extraRouteTwoAddress,
//           'focus': _extraTwoFocus,
//           'isDest': false,
//         },
//       if (loc.extraThreeRoute)
//         {
//           'type': LocationType.extraThree,
//           'hint': 'extra_route_three'.tr,
//           'ctrl': loc.extraRouteThreeController,
//           'addr': loc.extraRouteThreeAddress,
//           'focus': _extraThreeFocus,
//           'isDest': false,
//         },
//       {
//         'type': LocationType.to,
//         'hint': 'destination'.tr,
//         'ctrl': loc.destinationLocationController,
//         'addr': loc.toAddress,
//         'focus': _destinationFocus,
//         'isDest': true,
//       },
//     ];
//   }

//   void _onReorder(List<Map<String, dynamic>> items, int old, int next,
//       LocationController loc) {
//     if (next > old) next -= 1;
//     final destIdx = items.indexWhere((i) => i['isDest'] == true);
//     if (old == destIdx || next >= destIdx) return;
//     final item = items.removeAt(old);
//     items.insert(next, item);
//     _applyOrder(items, loc);
//   }

//   void _applyOrder(List<Map<String, dynamic>> items, LocationController loc) {
//     final stops = items.where((i) => i['isDest'] == false).toList();
//     final sText =
//         stops.map((r) => (r['ctrl'] as TextEditingController).text).toList();
//     final sAddr = stops.map((r) => r['addr'] as Address?).toList();
//     final dest = items.firstWhere((i) => i['isDest'] == true);

//     loc
//       ..extraOneRoute = false
//       ..extraTwoRoute = false
//       ..extraThreeRoute = false;
//     loc.extraRouteOneController.clear();
//     loc.extraRouteTwoController.clear();
//     loc.extraRouteThreeController.clear();
//     loc.extraRouteAddress = null;
//     loc.extraRouteTwoAddress = null;
//     loc.extraRouteThreeAddress = null;

//     for (int i = 0; i < stops.length; i++) {
//       if (i == 0) {
//         loc.extraOneRoute = true;
//         loc.extraRouteOneController.text = sText[i];
//         loc.extraRouteAddress = sAddr[i];
//       }
//       if (i == 1) {
//         loc.extraTwoRoute = true;
//         loc.extraRouteTwoController.text = sText[i];
//         loc.extraRouteTwoAddress = sAddr[i];
//       }
//       if (i == 2) {
//         loc.extraThreeRoute = true;
//         loc.extraRouteThreeController.text = sText[i];
//         loc.extraRouteThreeAddress = sAddr[i];
//       }
//     }

//     loc.destinationLocationController.text =
//         (dest['ctrl'] as TextEditingController).text;
//     loc.toAddress = dest['addr'] as Address?;

//     loc.update();
//     Get.find<RideController>().update();
//     setState(() {});
//     _triggerRouteUpdate();
//   }

//   // ══════════════════════════════════════════════════════════════════════════
//   // BUILD
//   // ══════════════════════════════════════════════════════════════════════════

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<LocationController>(builder: (loc) {
//       return GetBuilder<RideController>(builder: (ride) {
//         final items = _buildItems(loc);

//         // Vérifier si les suggestions doivent être affichées
//         final bool showSuggestions = loc.resultShow &&
//             loc.predictionList?.data?.suggestions != null &&
//             loc.predictionList!.data!.suggestions!.isNotEmpty &&
//             (_extraOneFocus.hasFocus ||
//                 _extraTwoFocus.hasFocus ||
//                 _extraThreeFocus.hasFocus ||
//                 _destinationFocus.hasFocus);

//         return Stack(
//           clipBehavior: Clip.none,
//           children: [
//             // ── Contenu principal ──────────────────────────────────────────
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Indicateur de mise à jour
//                 if (_isUpdatingRoute)
//                   Padding(
//                     padding:
//                         const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
//                     child: Row(children: [
//                       SizedBox(
//                         width: 14,
//                         height: 14,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'updating_route'.tr,
//                         style: textRegular.copyWith(
//                           fontSize: Dimensions.fontSizeSmall,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                       ),
//                     ]),
//                   ),

//                 // Bloc principal
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).hintColor.withValues(alpha: 0.07),
//                     borderRadius:
//                         BorderRadius.circular(Dimensions.paddingSizeSmall),
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Colonne icônes
//                       _RouteIconsColumn(stopsCount: _stopsCount(loc)),

//                       // Colonne champs
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(
//                             top: Dimensions.paddingSizeDefault,
//                             right: Dimensions.paddingSizeDefault,
//                             bottom: Dimensions.paddingSizeDefault,
//                           ),
//                           child: SingleChildScrollView(
//                             controller: _scrollController,
//                             physics: const NeverScrollableScrollPhysics(),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Départ (lecture seule)
//                                 PickLocationWidget(
//                                   locationType: LocationType.from,
//                                   textFieldHint: 'pick_location'.tr,
//                                   rideDetails: ride.rideDetails,
//                                   focusNode: _pickupFocus,
//                                   textEditingController:
//                                       loc.pickupLocationController,
//                                   isShowCrossButton: false,
//                                   locationIconTap: () {},
//                                   textFieldTap: () {},
//                                   onSuggestionSelected: () {},
//                                 ),

//                                 const _FieldDivider(),

//                                 // Arrêts + destination
//                                 if (items.length > 1)
//                                   _buildReorderable(items, loc, ride)
//                                 else
//                                   _buildDestinationOnly(loc, ride),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Nouveau tarif estimé après modification
//                 if (!_isUpdatingRoute &&
//                     ride.estimatedFare > 0 &&
//                     ride.tripDetails != null)
//                   _FareUpdateBadge(
//                     newFare: ride.estimatedFare,
//                     originalFare:
//                         (ride.tripDetails!.estimatedFare ?? 0).toDouble(),
//                   ),
//               ],
//             ),

//             // ── Suggestions d'adresses ──────────────────────────────────────
//             // if (showSuggestions)
//             //   Positioned(
//             //     top: 180,
//             //     left: 0,
//             //     right: 0,
//             //     child: Container(
//             //       height: MediaQuery.of(context).size.height * 0.6,
//             //       decoration: BoxDecoration(
//             //         color: Get.isDarkMode
//             //             ? Theme.of(context).canvasColor
//             //             : Theme.of(context).cardColor,
//             //         borderRadius: const BorderRadius.vertical(
//             //           top: Radius.circular(Dimensions.paddingSizeDefault),
//             //         ),
//             //         boxShadow: [
//             //           BoxShadow(
//             //             color: Colors.grey.withOpacity(0.2),
//             //             blurRadius: 10,
//             //             offset: const Offset(0, -2),
//             //           ),
//             //         ],
//             //       ),
//             //       child: Column(
//             //         crossAxisAlignment: CrossAxisAlignment.start,
//             //         children: [
//             //           Padding(
//             //             padding:
//             //                 const EdgeInsets.all(Dimensions.paddingSizeDefault),
//             //             child: Row(
//             //               children: [
//             //                 Text(
//             //                   'Indiquer votre itinéraire',
//             //                   style: textBold.copyWith(
//             //                     fontSize: Dimensions.fontSizeLarge,
//             //                   ),
//             //                 ),
//             //                 const Spacer(),
//             //                 IconButton(
//             //                   onPressed: () {
//             //                     loc.setSearchResultShowHide(show: false);
//             //                   },
//             //                   icon: const Icon(Icons.close),
//             //                   padding: EdgeInsets.zero,
//             //                   constraints: const BoxConstraints(),
//             //                 ),
//             //               ],
//             //             ),
//             //           ),
//             //           Expanded(
//             //             child: ListView.builder(
//             //               itemCount: loc
//             //                   .predictionList!.data!.suggestions!.length,
//             //               padding: EdgeInsets.zero,
//             //               itemBuilder: (context, index) {
//             //                 final suggestion = loc
//             //                     .predictionList!.data!.suggestions![index];
//             //                 final prediction = suggestion.placePrediction;

//             //                 if (prediction == null)
//             //                   return const SizedBox.shrink();

//             //                 return InkWell(
//             //                   onTap: () {
//             //                     _selectSuggestion(
//             //                       loc,
//             //                       prediction,
//             //                       loc.locationType,
//             //                     );
//             //                   },
//             //                   child: Container(
//             //                     padding: const EdgeInsets.symmetric(
//             //                       vertical: Dimensions.paddingSizeDefault,
//             //                       horizontal: Dimensions.paddingSizeDefault,
//             //                     ),
//             //                     decoration: BoxDecoration(
//             //                       border: Border(
//             //                         bottom: BorderSide(
//             //                           color: Colors.grey.withOpacity(0.1),
//             //                           width: 1,
//             //                         ),
//             //                       ),
//             //                     ),
//             //                     child: Row(
//             //                       crossAxisAlignment:
//             //                           CrossAxisAlignment.start,
//             //                       children: [
//             //                         Container(
//             //                           margin: const EdgeInsets.only(top: 2),
//             //                           child: Icon(
//             //                             Icons.location_on,
//             //                             color: Theme.of(context).primaryColor,
//             //                             size: 20,
//             //                           ),
//             //                         ),
//             //                         const SizedBox(
//             //                             width: Dimensions.paddingSizeSmall),
//             //                         Expanded(
//             //                           child: Column(
//             //                             crossAxisAlignment:
//             //                                 CrossAxisAlignment.start,
//             //                             children: [
//             //                               // Ligne principale : nom du lieu
//             //                               // (ex: "Route du Zoo")
//             //                               Text(
//             //                                 prediction.structuredFormat
//             //                                         ?.mainText?.text ??
//             //                                     prediction.text?.text ??
//             //                                     '',
//             //                                 style: textBold.copyWith(
//             //                                   fontSize:
//             //                                       Dimensions.fontSizeDefault,
//             //                                 ),
//             //                                 maxLines: 2,
//             //                                 overflow: TextOverflow.ellipsis,
//             //                               ),
//             //                               // Ligne secondaire : localisation
//             //                               // (ex: "Abidjan, Côte d'Ivoire")
//             //                               if (prediction.structuredFormat
//             //                                       ?.secondaryText?.text !=
//             //                                   null)
//             //                                 Padding(
//             //                                   padding:
//             //                                       const EdgeInsets.only(top: 2),
//             //                                   child: Text(
//             //                                     prediction.structuredFormat!
//             //                                         .secondaryText!.text!,
//             //                                     style: textBold.copyWith(
//             //                                       fontSize:
//             //                                           Dimensions.fontSizeSmall,
//             //                                       color: Colors.grey[700],
//             //                                     ),
//             //                                     maxLines: 2,
//             //                                     overflow: TextOverflow.ellipsis,
//             //                                   ),
//             //                                 ),
//             //                               // Chips distance / durée
//             //                               if (suggestion.distanceText != null || suggestion.durationText != null)
//             //                                 Padding(
//             //                                   padding: const EdgeInsets.only(top: 5),
//             //                                   child: Row(
//             //                                     children: [
//             //                                       if (suggestion.distanceText != null)
//             //                                         _InfoChip(
//             //                                           icon: Icons.straighten,
//             //                                           label: suggestion.distanceText!,
//             //                                         ),
//             //                                       if (suggestion.distanceText != null && suggestion.durationText != null)
//             //                                         const SizedBox(width: 6),
//             //                                       if (suggestion.durationText != null)
//             //                                         _InfoChip(
//             //                                           icon: Icons.access_time,
//             //                                           label: suggestion.durationText!,
//             //                                         ),
//             //                                     ],
//             //                                   ),
//             //                                 ),
//             //                             ],
//             //                           ),
//             //                         ),
//             //                       ],
//             //                     ),
//             //                   ),
//             //                 );
//             //               },
//             //             ),
//             //           ),
//             //         ],
//             //       ),
//             //     ),
//             //   ),

// // ── Suggestions d'adresses ──────────────────────────────────────
// if (showSuggestions)
//   Positioned(
//     top: 140,
//     left: 0,
//     right: 0,
  
//     child: Container(
//        height: MediaQuery.of(context).size.height * 0.6,
//       decoration: BoxDecoration(
//         color: Get.isDarkMode
//             ? Theme.of(context).canvasColor
//             : Theme.of(context).cardColor,
//         borderRadius: const BorderRadius.vertical(
//           top: Radius.circular(Dimensions.paddingSizeDefault),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//             child: Row(
//               children: [
//                 Text(
//                   'Indiquer votre itinéraire',
//                   style: textBold.copyWith(
//                     fontSize: Dimensions.fontSizeLarge,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   onPressed: () {
//                     loc.setSearchResultShowHide(show: false);
//                   },
//                   icon: const Icon(Icons.close),
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ),
//           ),
//           // ✅ Utiliser Expanded pour que la liste prenne tout l'espace disponible
//           Expanded(
//             child: ListView.builder(
//               itemCount: loc.predictionList!.data!.suggestions!.length,
//               padding: EdgeInsets.zero,
//               physics: const AlwaysScrollableScrollPhysics(), // ✅ Toujours scrollable
//               itemBuilder: (context, index) {
//                 final suggestion = loc.predictionList!.data!.suggestions![index];
//                 final prediction = suggestion.placePrediction;

//                 if (prediction == null) return const SizedBox.shrink();

//                 return InkWell(
//                   onTap: () {
//                     // ✅ Sélectionner la suggestion
//                     _selectSuggestion(
//                       loc,
//                       prediction,
//                       loc.locationType,
//                     );
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: Dimensions.paddingSizeDefault,
//                       horizontal: Dimensions.paddingSizeDefault,
//                     ),
//                     decoration: BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(
//                           color: Colors.grey.withOpacity(0.1),
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           margin: const EdgeInsets.only(top: 2),
//                           child: Icon(
//                             Icons.location_on,
//                             color: Theme.of(context).primaryColor,
//                             size: 20,
//                           ),
//                         ),
//                         const SizedBox(width: Dimensions.paddingSizeSmall),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 prediction.structuredFormat?.mainText?.text ??
//                                     prediction.text?.text ??
//                                     '',
//                                 style: textBold.copyWith(
//                                   fontSize: Dimensions.fontSizeDefault,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               if (prediction.structuredFormat?.secondaryText?.text != null)
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 2),
//                                   child: Text(
//                                     prediction.structuredFormat!.secondaryText!.text!,
//                                     style: textBold.copyWith(
//                                       fontSize: Dimensions.fontSizeSmall,
//                                       color: Colors.grey[700],
//                                     ),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               if (suggestion.distanceText != null || suggestion.durationText != null)
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 5),
//                                   child: Row(
//                                     children: [
//                                       if (suggestion.distanceText != null)
//                                         _InfoChip(
//                                           icon: Icons.straighten,
//                                           label: suggestion.distanceText!,
//                                         ),
//                                       if (suggestion.distanceText != null && suggestion.durationText != null)
//                                         const SizedBox(width: 6),
//                                       if (suggestion.durationText != null)
//                                         _InfoChip(
//                                           icon: Icons.access_time,
//                                           label: suggestion.durationText!,
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     ),
//   ),

// // ── Suggestions d'adresses ──────────────────────────────────────



//           ],
//         );
//       });
//     });
//   }

//   // ── Sélection d'une suggestion ──────────────────────────────────────────
//   void _selectSuggestion(
//     LocationController loc,
//     dynamic prediction,
//     LocationType type,
//   ) {
//     loc.setLocation(
//       fromSearch: true,
//       prediction.placeId ?? '',
//       prediction.text?.text ?? '',
//       null,
//       type: type,
//     ).then((_) {
//       // Fermer les suggestions
//       loc.setSearchResultShowHide(show: false);
//       FocusScope.of(context).unfocus();

//       // Vérifier si l'adresse a bien été définie
//       final hasAddr = switch (type) {
//         LocationType.extraOne => loc.extraRouteAddress != null,
//         LocationType.extraTwo => loc.extraRouteTwoAddress != null,
//         LocationType.extraThree => loc.extraRouteThreeAddress != null,
//         LocationType.to => loc.toAddress != null,
//         _ => false,
//       };

//       if (hasAddr) {
//         _triggerRouteUpdate();
//       }
//     });
//   }

//   // ── Destination seule ───────────────────────────────────────────────────
//   Widget _buildDestinationOnly(LocationController loc, RideController ride) {
//     return Row(children: [
//       Expanded(
//         child: _field(
//           type: LocationType.to,
//           hint: 'destination'.tr,
//           ctrl: loc.destinationLocationController,
//           addr: loc.toAddress,
//           focus: _destinationFocus,
//           ride: ride,
//         ),
//       ),
//       const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//       _buildAddStopButton(loc),
//     ]);
//   }

//   // ── Arrêts + destination réordonnables ──────────────────────────────────
//   Widget _buildReorderable(
//     List<Map<String, dynamic>> items,
//     LocationController loc,
//     RideController ride,
//   ) {
//     return ReorderableListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       proxyDecorator: (child, idx, anim) => Material(
//         elevation: 4,
//         borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//         child: child,
//       ),
//       onReorder: (o, n) => _onReorder(items, o, n, loc),
//       itemCount: items.length,
//       itemBuilder: (ctx, idx) {
//         final item = items[idx];
//         final isDest = item['isDest'] as bool;
//         final type = item['type'] as LocationType;

//         return Container(
//           key: ValueKey('ts_$type'),
//           margin: const EdgeInsets.only(bottom: 2),
//           child: Column(children: [
//             Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
//               if (!isDest)
//                 ReorderableDragStartListener(
//                   index: idx,
//                   child: const SizedBox.shrink(),
//                 )
//               else
//                 const SizedBox(width: 32),

//               Expanded(
//                 child: _field(
//                   type: type,
//                   hint: item['hint'] as String,
//                   ctrl: item['ctrl'] as TextEditingController,
//                   addr: item['addr'] as Address?,
//                   focus: item['focus'] as FocusNode,
//                   ride: ride,
//                 ),
//               ),

//               if (!isDest)
//                 IconButton(
//                   onPressed: () => _confirmRemoveStop(type),
//                   icon: const Icon(Icons.delete_outline,
//                       color: Colors.redAccent, size: 18),
//                   padding: EdgeInsets.zero,
//                   constraints:
//                       const BoxConstraints(minWidth: 32, minHeight: 32),
//                 )
//               else ...[
//                 const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//                 _buildAddStopButton(loc),
//               ],
//             ]),

//             if (idx < items.length - 1)
//               Padding(
//                 padding: const EdgeInsets.only(
//                     left: 32, right: Dimensions.paddingSizeDefault),
//                 child: Divider(
//                   height: 1,
//                   color: Theme.of(context).hintColor.withValues(alpha: 0.2),
//                 ),
//               ),
//           ]),
//         );
//       },
//     );
//   }

//   // ── Champ générique ─────────────────────────────────────────────────────
//   Widget _field({
//     required LocationType type,
//     required String hint,
//     required TextEditingController ctrl,
//     required Address? addr,
//     required FocusNode focus,
//     required RideController ride,
//   }) {
//     return PickLocationWidget(
//       locationType: type,
//       textFieldHint: hint,
//       rideDetails: ride.rideDetails,
//       focusNode: focus,
//       textEditingController: ctrl,
//       isShowCrossButton: false,
//       locationIconTap: () {
//         // Cacher les suggestions avant d'ouvrir la carte
//         Get.find<LocationController>().setSearchResultShowHide(show: false);
//         FocusScope.of(context).unfocus();

//         // Utiliser Get.to avec navigation
//         Get.to(() => PickMapScreen(type: type, address: addr))?.then((result) {
//           // Le résultat peut être l'adresse sélectionnée
//           if (result != null && result is Address) {
//             _updateAddressFromMap(type, result);
//           }
//           // Sinon, vérifier si l'adresse a été mise à jour par le contrôleur
//           final loc = Get.find<LocationController>();
//           final hasAddr = switch (type) {
//             LocationType.extraOne => loc.extraRouteAddress != null,
//             LocationType.extraTwo => loc.extraRouteTwoAddress != null,
//             LocationType.extraThree => loc.extraRouteThreeAddress != null,
//             LocationType.to => loc.toAddress != null,
//             _ => false,
//           };
//           if (hasAddr) {
//             _triggerRouteUpdate();
//           }
//         });
//       },
//       textFieldTap: () {
//         // Afficher les suggestions quand on tape sur le champ
//         final loc = Get.find<LocationController>();
//         loc.setSearchResultShowHide(show: true);
//         loc.locationType = type;
//         setState(() {});
//       },
//       onSuggestionSelected: () {
//         FocusScope.of(context).unfocus();
//         final loc = Get.find<LocationController>();
//         loc.setSearchResultShowHide(show: false);

//         final hasAddr = switch (type) {
//           LocationType.extraOne => loc.extraRouteAddress != null,
//           LocationType.extraTwo => loc.extraRouteTwoAddress != null,
//           LocationType.extraThree => loc.extraRouteThreeAddress != null,
//           LocationType.to => loc.toAddress != null,
//           _ => false,
//         };
//         if (hasAddr) {
//           _triggerRouteUpdate();
//         }
//       },
//     );
//   }

//   // ── Mise à jour depuis la carte ────────────────────────────────────────
//   void _updateAddressFromMap(LocationType type, Address address) {
//     final loc = Get.find<LocationController>();
//     switch (type) {
//       case LocationType.extraOne:
//         loc.extraRouteAddress = address;
//         loc.extraRouteOneController.text = address.address ?? '';
//         break;
//       case LocationType.extraTwo:
//         loc.extraRouteTwoAddress = address;
//         loc.extraRouteTwoController.text = address.address ?? '';
//         break;
//       case LocationType.extraThree:
//         loc.extraRouteThreeAddress = address;
//         loc.extraRouteThreeController.text = address.address ?? '';
//         break;
//       case LocationType.to:
//         loc.toAddress = address;
//         loc.destinationLocationController.text = address.address ?? '';
//         break;
//       default:
//         break;
//     }
//     loc.update();
//     setState(() {});
//   }

//   @override
//   void dispose() {
//     _debounceSearchTimer?.cancel();
//     _autoCalcTimer?.cancel();
//     _extraOneFocus.dispose();
//     _extraTwoFocus.dispose();
//     _extraThreeFocus.dispose();
//     _destinationFocus.dispose();
//     _pickupFocus.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
// }

// // ════════════════════════════════════════════════════════════════════════════
// // Badge affiché quand le tarif a changé
// // ════════════════════════════════════════════════════════════════════════════

// class _FareUpdateBadge extends StatelessWidget {
//   final double newFare;
//   final double originalFare;

//   const _FareUpdateBadge({required this.newFare, required this.originalFare});

//   @override
//   Widget build(BuildContext context) {
//     if ((newFare - originalFare).abs() < 1) return const SizedBox.shrink();

//     final isMore = newFare > originalFare;
//     final color = isMore ? Colors.orange : Colors.green;
//     final icon = isMore ? Icons.arrow_upward : Icons.arrow_downward;
//     final diff = (newFare - originalFare).abs().toStringAsFixed(0);

//     return Container(
//       margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
//       padding: const EdgeInsets.symmetric(
//           horizontal: Dimensions.paddingSizeSmall, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
//         border: Border.all(color: color.withValues(alpha: 0.3)),
//       ),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Icon(icon, size: 13, color: color),
//         const SizedBox(width: 4),
//         Text(
//           isMore
//               ? '${'fare_increased_by'.tr} $diff'
//               : '${'fare_decreased_by'.tr} $diff',
//           style:
//               textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: color),
//         ),
//         const SizedBox(width: 6),
//         Text(
//           '→ ${newFare.toStringAsFixed(0)}',
//           style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: color),
//         ),
//       ]),
//     );
//   }
// }

// // ════════════════════════════════════════════════════════════════════════════
// // Colonne icônes
// // ════════════════════════════════════════════════════════════════════════════

// class _RouteIconsColumn extends StatelessWidget {
//   final int stopsCount;
//   const _RouteIconsColumn({required this.stopsCount});

//   @override
//   Widget build(BuildContext context) {
//     final double lineH = ((1 + stopsCount) * 52.0 - 24).clamp(20.0, 400.0);

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(
//           Dimensions.paddingSizeSmall, Dimensions.paddingSizeDefault, 0, 0),
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         SizedBox(
//           width: Dimensions.iconSizeLarge,
//           child: Image.asset(Images.currentLocation,
//               color: Theme.of(context).textTheme.bodyMedium!.color),
//         ),
//         SizedBox(
//           height: lineH,
//           width: 10,
//           child: CustomDivider(
//             height: 4,
//             dashWidth: 0.8,
//             axis: Axis.vertical,
//             color: Theme.of(context)
//                 .textTheme
//                 .bodyMedium!
//                 .color!
//                 .withValues(alpha: 0.5),
//           ),
//         ),
//         SizedBox(
//           width: Dimensions.iconSizeMedium,
//           child: Transform(
//             alignment: Alignment.center,
//             transform: Get.find<LocalizationController>().isLtr
//                 ? Matrix4.rotationY(0)
//                 : Matrix4.rotationY(math.pi),
//             child: Image.asset(Images.activityDirection,
//                 color: Theme.of(context).textTheme.bodyMedium!.color),
//           ),
//         ),
//       ]),
//     );
//   }
// }

// // ════════════════════════════════════════════════════════════════════════════
// // Séparateur
// // ════════════════════════════════════════════════════════════════════════════

// class _FieldDivider extends StatelessWidget {
//   const _FieldDivider();
//   @override
//   Widget build(BuildContext context) => Padding(
//         padding: const EdgeInsets.symmetric(
//             vertical: Dimensions.paddingSizeExtraSmall),
//         child: Divider(
//           height: 1,
//           color: Theme.of(context).hintColor.withValues(alpha: 0.25),
//         ),
//       );
// }


// // ════════════════════════════════════════════════════════════════════════════
// // Chip distance / durée affiché dans la liste de suggestions
// // ════════════════════════════════════════════════════════════════════════════

// class _InfoChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   const _InfoChip({required this.icon, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: Theme.of(context).primaryColor.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(
//           color: Theme.of(context).primaryColor.withOpacity(0.2),
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 11, color: Theme.of(context).primaryColor),
//           const SizedBox(width: 3),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               color: Theme.of(context).primaryColor,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/widget/pick_location_widget.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

/// Widget de trajet éditable utilisé dans les bottom sheets de course
class EditableRouteInTripWidget extends StatefulWidget {
  final String firstRoute;
  final String secondRoute;
  final String thirdRoute;
  final VoidCallback? onRouteChanged;

  const EditableRouteInTripWidget({
    super.key,
    this.firstRoute = '',
    this.secondRoute = '',
    this.thirdRoute = '',
    this.onRouteChanged,
  });

  @override
  State<EditableRouteInTripWidget> createState() =>
      _EditableRouteInTripWidgetState();
}

class _EditableRouteInTripWidgetState extends State<EditableRouteInTripWidget> {
  // ── Focus nodes ─────────────────────────────────────────────────────────
  late FocusNode _extraOneFocus;
  late FocusNode _extraTwoFocus;
  late FocusNode _extraThreeFocus;
  late FocusNode _destinationFocus;
  late FocusNode _pickupFocus; // Pour le champ départ (lecture seule)

  final ScrollController _scrollController = ScrollController();

  Timer? _debounceSearchTimer;
  Timer? _autoCalcTimer;
  bool _isCalculating = false;
  bool _prefilled = false;

  // Suivi de l'état « en cours de mise à jour » pour l'UI
  bool _isUpdatingRoute = false;
  String? _updateError;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _extraOneFocus = FocusNode();
    _extraTwoFocus = FocusNode();
    _extraThreeFocus = FocusNode();
    _destinationFocus = FocusNode();
    _pickupFocus = FocusNode();

    _setupFocusListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillControllers();
      _setupTextListeners();
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRÉ-REMPLISSAGE
  // ══════════════════════════════════════════════════════════════════════════

  void _prefillControllers() {
    if (_prefilled) return;
    _prefilled = true;

    final loc = Get.find<LocationController>();
    final ride = Get.find<RideController>();
    final trip = ride.tripDetails;

    if (loc.fromAddress == null && trip?.pickupCoordinates != null) {
      loc.fromAddress = Address(
        address: trip?.pickupAddress ?? '',
        latitude: trip?.pickupCoordinates?.coordinates?[1],
        longitude: trip?.pickupCoordinates?.coordinates?[0],
      );
    }

    if (loc.toAddress == null && trip?.destinationCoordinates != null) {
      loc.toAddress = Address(
        address: trip?.destinationAddress ?? '',
        latitude: trip?.destinationCoordinates?.coordinates?[1],
        longitude: trip?.destinationCoordinates?.coordinates?[0],
      );
    }

    // Départ (controller)
    if (loc.pickupLocationController.text.isEmpty) {
      final pickup = trip?.pickupAddress ?? '';
      if (pickup.isNotEmpty) loc.pickupLocationController.text = pickup;
    }

    // Destination (controller)
    if (loc.destinationLocationController.text.isEmpty) {
      final dest = trip?.destinationAddress ?? '';
      if (dest.isNotEmpty) loc.destinationLocationController.text = dest;
    }

    // Arrêts intermédiaires transmis par le parent
    bool changed = false;

    if (widget.firstRoute.isNotEmpty && !loc.extraOneRoute) {
      loc.extraOneRoute = true;
      loc.extraRouteOneController.text = widget.firstRoute;
      changed = true;
    }
    if (widget.secondRoute.isNotEmpty && !loc.extraTwoRoute) {
      loc.extraTwoRoute = true;
      loc.extraRouteTwoController.text = widget.secondRoute;
      changed = true;
    }
    if (widget.thirdRoute.isNotEmpty && !loc.extraThreeRoute) {
      loc.extraThreeRoute = true;
      loc.extraRouteThreeController.text = widget.thirdRoute;
      changed = true;
    }

    if (changed) {
      loc.update();
      if (mounted) setState(() {});
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FOCUS LISTENERS
  // ══════════════════════════════════════════════════════════════════════════

  void _setupFocusListeners() {
    
    void onFocus(FocusNode fn, LocationType type, double scroll) {
      fn.addListener(() {
        if (fn.hasFocus) {
        //  _clearIfPrefilled(type);
          _scrollTo(scroll);
          Get.find<LocationController>().locationType = type;
          // Afficher les suggestions si le champ a du texte
          final loc = Get.find<LocationController>();
          final ctrl = _getControllerForType(type);
          if (ctrl != null && ctrl.text.length > 2) {
            loc.setSearchResultShowHide(show: true);
          }
        } else {
          // Ne pas cacher immédiatement pour permettre la sélection
         Future.delayed(const Duration(milliseconds: 600), () {
            if (!mounted) return; // ✅ Vérification mounted
            final loc = Get.find<LocationController>();
            if (!_extraOneFocus.hasFocus &&
                !_extraTwoFocus.hasFocus &&
                !_extraThreeFocus.hasFocus &&
                !_destinationFocus.hasFocus) {
              loc.setSearchResultShowHide(show: false);
            }
          });
        }
      });
    }

    onFocus(_extraOneFocus, LocationType.extraOne, 300);
    onFocus(_extraTwoFocus, LocationType.extraTwo, 340);
    onFocus(_extraThreeFocus, LocationType.extraThree, 380);
    onFocus(_destinationFocus, LocationType.to, 420);
  }

  TextEditingController? _getControllerForType(LocationType type) {
    final loc = Get.find<LocationController>();
    switch (type) {
      case LocationType.extraOne:
        return loc.extraRouteOneController;
      case LocationType.extraTwo:
        return loc.extraRouteTwoController;
      case LocationType.extraThree:
        return loc.extraRouteThreeController;
      case LocationType.to:
        return loc.destinationLocationController;
      default:
        return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TEXT LISTENERS (autocomplete)
  // ══════════════════════════════════════════════════════════════════════════

  void _setupTextListeners() {
    final loc = Get.find<LocationController>();

    void listen(TextEditingController ctrl, FocusNode fn, LocationType type) {
      ctrl.addListener(() {
        if (!fn.hasFocus) return;
        final text = ctrl.text;
        if (text.length > 2) {
          _debounceSearch(text, type);
        } else {
          loc.setSearchResultShowHide(show: false);
        }
      });
    }

    listen(loc.extraRouteOneController, _extraOneFocus, LocationType.extraOne);
    listen(loc.extraRouteTwoController, _extraTwoFocus, LocationType.extraTwo);
    listen(loc.extraRouteThreeController, _extraThreeFocus,
        LocationType.extraThree);
    listen(loc.destinationLocationController, _destinationFocus,
        LocationType.to);
  }

  void _debounceSearch(String query, LocationType type) {
    _debounceSearchTimer?.cancel();
    final loc = Get.find<LocationController>();
    loc.locationType = type;
    loc.setSearchResultShowHide(show: true);
    _debounceSearchTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        loc.searchLocation(context, query, type: type, fromMap: false);
      } else {
        loc.setSearchResultShowHide(show: false);
      }
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RECALCUL TARIF + PERSISTANCE EN BASE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _triggerRouteUpdate() async {
  final loc = Get.find<LocationController>();
  final ride = Get.find<RideController>();

  if (loc.toAddress == null) return;
  if (_isCalculating) return;

  _autoCalcTimer?.cancel();
  _autoCalcTimer = Timer(const Duration(milliseconds: 700), () async {
    if (!mounted) return; // ✅ Vérification mounted au début du timer
    _isCalculating = true;

    setState(() {
      _isUpdatingRoute = true;
      _updateError = null;
    });

    try {
      final fareResponse = await ride.getEstimatedFare(false);
      if (!mounted) return; // ✅ Après chaque await

      if (fareResponse.statusCode != 200) {
        _setError('fare_calculation_failed'.tr);
        return;
      }

      if (ride.tripDetails?.id != null) {
        final updateResponse = await ride.updateTripRoute(
          tripId: ride.tripDetails!.id!,
          newFare: ride.estimatedFare,
          encodedPoly: ride.encodedPolyLine,
        );
        if (!mounted) return; // ✅ Après chaque await

        if (updateResponse.statusCode == 200) {
          await ride.getRideDetails(ride.tripDetails!.id!);
          if (!mounted) return; // ✅ Après chaque await
          ride.update();
          loc.update();
        } else {
          _setError('route_update_failed'.tr);
          return;
        }
      }

      await _refreshMap();
      if (!mounted) return; // ✅ Après chaque await

      ride.update();
      loc.update();
      setState(() {});
      widget.onRouteChanged?.call();
    } catch (e) {
      if (!mounted) return; // ✅
      _setError('an_error_occurred'.tr);
      debugPrint('EditableRouteInTripWidget._triggerRouteUpdate error: $e');
    } finally {
      _isCalculating = false;
      if (mounted) { // ✅
        setState(() {
          _isUpdatingRoute = false;
        });
      }
    }
  });
}

 void _setError(String msg) {
  if (!mounted) return; // ✅ Vérification mounted
  setState(() {
    _updateError = msg;
    _isUpdatingRoute = false;
  });
  showCustomSnackBar(msg, isError: true);
}

  Future<void> _refreshMap() async {
    final mapCtrl = Get.find<MapController>();
    final loc = Get.find<LocationController>();
    final points = <LatLng>[];

    void add(Address? a) {
      if (a?.latitude != null && a?.longitude != null) {
        points.add(LatLng(a!.latitude!, a.longitude!));
      }
    }

    add(loc.fromAddress);
    add(loc.extraRouteAddress);
    add(loc.extraRouteTwoAddress);
    add(loc.extraRouteThreeAddress);
    add(loc.toAddress);

    if (points.length >= 2) await mapCtrl.showMultipleMarkersOnMap(points);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  void _scrollTo(double position) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _clearIfPrefilled(LocationType type) {
    final loc = Get.find<LocationController>();
    switch (type) {
      case LocationType.extraOne:
        if (loc.extraRouteOneController.text.isNotEmpty) {
          loc.extraRouteOneController.clear();
          loc.extraRouteAddress = null;
        }
        break;
      case LocationType.extraTwo:
        if (loc.extraRouteTwoController.text.isNotEmpty) {
          loc.extraRouteTwoController.clear();
          loc.extraRouteTwoAddress = null;
        }
        break;
      case LocationType.extraThree:
        if (loc.extraRouteThreeController.text.isNotEmpty) {
          loc.extraRouteThreeController.clear();
          loc.extraRouteThreeAddress = null;
        }
        break;
      case LocationType.to:
        if (loc.destinationLocationController.text.isNotEmpty) {
          loc.destinationLocationController.clear();
          loc.toAddress = null;
        }
        break;
      default:
        break;
    }
    loc.update();
  }

  int _stopsCount(LocationController loc) =>
      (loc.extraOneRoute ? 1 : 0) +
      (loc.extraTwoRoute ? 1 : 0) +
      (loc.extraThreeRoute ? 1 : 0);

  void _removeStop(LocationType type) {
    final loc = Get.find<LocationController>();
    switch (type) {
      case LocationType.extraOne:
        loc.extraOneRoute = false;
        loc.extraRouteOneController.clear();
        loc.extraRouteAddress = null;
        break;
      case LocationType.extraTwo:
        loc.extraTwoRoute = false;
        loc.extraRouteTwoController.clear();
        loc.extraRouteTwoAddress = null;
        break;
      case LocationType.extraThree:
        loc.extraThreeRoute = false;
        loc.extraRouteThreeController.clear();
        loc.extraRouteThreeAddress = null;
        break;
      default:
        return;
    }
    loc.update();
    Get.find<RideController>().update();
    setState(() {});
    _triggerRouteUpdate();
  }

  void _confirmRemoveStop(LocationType type) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('supprimer_arret'.tr),
        content: Text('voulez_vous_supprimer_cet_arret'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('annuler'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              _removeStop(type);
            },
            child: Text('supprimer'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BOUTON « + Ajouter un arrêt »
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAddStopButton(LocationController locationController) {
    return InkWell(
      onTap: _canAddMoreStops(locationController)
          ? () => _addNewRoute(locationController)
          : null,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: _canAddMoreStops(locationController)
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
    );
  }

  bool _canAddMoreStops(LocationController locationController) {
    return true;
  }

  void _addNewRoute(LocationController locationController) {
    if (!locationController.extraOneRoute) {
      locationController.extraOneRoute = true;
    } else if (!locationController.extraTwoRoute) {
      locationController.extraTwoRoute = true;
    } else if (!locationController.extraThreeRoute) {
      locationController.extraThreeRoute = true;
    }
    locationController.update();
    setState(() {});
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ITEMS RÉORDONNABLES
  // ══════════════════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> _buildItems(LocationController loc) {
    return [
      if (loc.extraOneRoute)
        {
          'type': LocationType.extraOne,
          'hint': 'extra_route_one'.tr,
          'ctrl': loc.extraRouteOneController,
          'addr': loc.extraRouteAddress,
          'focus': _extraOneFocus,
          'isDest': false,
        },
      if (loc.extraTwoRoute)
        {
          'type': LocationType.extraTwo,
          'hint': 'extra_route_two'.tr,
          'ctrl': loc.extraRouteTwoController,
          'addr': loc.extraRouteTwoAddress,
          'focus': _extraTwoFocus,
          'isDest': false,
        },
      if (loc.extraThreeRoute)
        {
          'type': LocationType.extraThree,
          'hint': 'extra_route_three'.tr,
          'ctrl': loc.extraRouteThreeController,
          'addr': loc.extraRouteThreeAddress,
          'focus': _extraThreeFocus,
          'isDest': false,
        },
      {
        'type': LocationType.to,
        'hint': 'destination'.tr,
        'ctrl': loc.destinationLocationController,
        'addr': loc.toAddress,
        'focus': _destinationFocus,
        'isDest': true,
      },
    ];
  }

  void _onReorder(List<Map<String, dynamic>> items, int old, int next,
      LocationController loc) {
    if (next > old) next -= 1;
    final destIdx = items.indexWhere((i) => i['isDest'] == true);
    if (old == destIdx || next >= destIdx) return;
    final item = items.removeAt(old);
    items.insert(next, item);
    _applyOrder(items, loc);
  }

  void _applyOrder(List<Map<String, dynamic>> items, LocationController loc) {
    final stops = items.where((i) => i['isDest'] == false).toList();
    final sText =
        stops.map((r) => (r['ctrl'] as TextEditingController).text).toList();
    final sAddr = stops.map((r) => r['addr'] as Address?).toList();
    final dest = items.firstWhere((i) => i['isDest'] == true);

    loc
      ..extraOneRoute = false
      ..extraTwoRoute = false
      ..extraThreeRoute = false;
    loc.extraRouteOneController.clear();
    loc.extraRouteTwoController.clear();
    loc.extraRouteThreeController.clear();
    loc.extraRouteAddress = null;
    loc.extraRouteTwoAddress = null;
    loc.extraRouteThreeAddress = null;

    for (int i = 0; i < stops.length; i++) {
      if (i == 0) {
        loc.extraOneRoute = true;
        loc.extraRouteOneController.text = sText[i];
        loc.extraRouteAddress = sAddr[i];
      }
      if (i == 1) {
        loc.extraTwoRoute = true;
        loc.extraRouteTwoController.text = sText[i];
        loc.extraRouteTwoAddress = sAddr[i];
      }
      if (i == 2) {
        loc.extraThreeRoute = true;
        loc.extraRouteThreeController.text = sText[i];
        loc.extraRouteThreeAddress = sAddr[i];
      }
    }

    loc.destinationLocationController.text =
        (dest['ctrl'] as TextEditingController).text;
    loc.toAddress = dest['addr'] as Address?;

    loc.update();
    Get.find<RideController>().update();
    setState(() {});
    _triggerRouteUpdate();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
//   Widget build(BuildContext context) {
//     return GetBuilder<LocationController>(builder: (loc) {
//       return GetBuilder<RideController>(builder: (ride) {
//         final items = _buildItems(loc);

//         // Vérifier si les suggestions doivent être affichées
//         final bool showSuggestions = loc.resultShow &&
//             loc.predictionList?.data?.suggestions != null &&
//             loc.predictionList!.data!.suggestions!.isNotEmpty &&
//             (_extraOneFocus.hasFocus ||
//                 _extraTwoFocus.hasFocus ||
//                 _extraThreeFocus.hasFocus ||
//                 _destinationFocus.hasFocus);

//         return Stack(
//           clipBehavior: Clip.none,
//           children: [
//             // ── Contenu principal ──────────────────────────────────────────
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Indicateur de mise à jour
//                 if (_isUpdatingRoute)
//                   Padding(
//                     padding:
//                         const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
//                     child: Row(children: [
//                       SizedBox(
//                         width: 14,
//                         height: 14,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'updating_route'.tr,
//                         style: textRegular.copyWith(
//                           fontSize: Dimensions.fontSizeSmall,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                       ),
//                     ]),
//                   ),

//                 // Bloc principal
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).hintColor.withValues(alpha: 0.07),
//                     borderRadius:
//                         BorderRadius.circular(Dimensions.paddingSizeSmall),
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Colonne icônes
//                       _RouteIconsColumn(stopsCount: _stopsCount(loc)),

//                       // Colonne champs
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(
//                             top: Dimensions.paddingSizeDefault,
//                             right: Dimensions.paddingSizeDefault,
//                             bottom: Dimensions.paddingSizeDefault,
//                           ),
//                           child: SingleChildScrollView(
//                             controller: _scrollController,
//                             physics: const NeverScrollableScrollPhysics(),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Départ (lecture seule)
//                                 PickLocationWidget(
//                                   locationType: LocationType.from,
//                                   textFieldHint: 'pick_location'.tr,
//                                   rideDetails: ride.rideDetails,
//                                   focusNode: _pickupFocus,
//                                   textEditingController:
//                                       loc.pickupLocationController,
//                                   isShowCrossButton: false,
//                                   locationIconTap: () {},
//                                   textFieldTap: () {},
//                                   onSuggestionSelected: () {},
//                                 ),

//                                 const _FieldDivider(),

//                                 // Arrêts + destination
//                                 if (items.length > 1)
//                                   _buildReorderable(items, loc, ride)
//                                 else
//                                   _buildDestinationOnly(loc, ride),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Nouveau tarif estimé après modification
//                 if (!_isUpdatingRoute &&
//                     ride.estimatedFare > 0 &&
//                     ride.tripDetails != null)
//                   _FareUpdateBadge(
//                     newFare: ride.estimatedFare,
//                     originalFare:
//                         (ride.tripDetails!.estimatedFare ?? 0).toDouble(),
//                   ),
//               ],
//             ),

//             // ── Suggestions d'adresses ──────────────────────────────────────
//             if (showSuggestions)
//               Positioned(
//                 top: 200,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   height: MediaQuery.of(context).size.height * 0.5,
//                   decoration: BoxDecoration(
//                     color: Get.isDarkMode
//                         ? Theme.of(context).canvasColor
//                         : Theme.of(context).cardColor,
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(Dimensions.paddingSizeDefault),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.2),
//                         blurRadius: 10,
//                         offset: const Offset(0, -2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding:
//                             const EdgeInsets.all(Dimensions.paddingSizeDefault),
//                         child: Row(
//                           children: [
//                             Text(
//                               'Indiquer votre itinéraire',
//                               style: textBold.copyWith(
//                                 fontSize: Dimensions.fontSizeLarge,
//                               ),
//                             ),
//                             const Spacer(),
//                             IconButton(
//                               onPressed: () {
//                                 loc.setSearchResultShowHide(show: false);
//                               },
//                               icon: const Icon(Icons.close),
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: ListView.builder(
//                           physics: const ClampingScrollPhysics(),
//                           itemCount: loc
//                               .predictionList!.data!.suggestions!.length,
//                           padding: EdgeInsets.zero,
//                           itemBuilder: (context, index) {
//                             final suggestion = loc
//                                 .predictionList!.data!.suggestions![index];
//                             final prediction = suggestion.placePrediction;

//                             if (prediction == null)
//                               return const SizedBox.shrink();

//                             return GestureDetector(
//                               behavior: HitTestBehavior.opaque,
//                               onTap: () {
//                                 loc.setSearchResultShowHide(show: false);
//                                 FocusScope.of(context).unfocus();
//                                 _selectSuggestion(
//                                   loc,
//                                   prediction,
//                                   loc.locationType,
//                                 );
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: Dimensions.paddingSizeDefault,
//                                   horizontal: Dimensions.paddingSizeDefault,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   border: Border(
//                                     bottom: BorderSide(
//                                       color: Colors.grey.withOpacity(0.1),
//                                       width: 1,
//                                     ),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                       margin: const EdgeInsets.only(top: 2),
//                                       child: Icon(
//                                         Icons.location_on,
//                                         color: Theme.of(context).primaryColor,
//                                         size: 20,
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                         width: Dimensions.paddingSizeSmall),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           // Ligne principale : nom du lieu
//                                           // (ex: "Route du Zoo")
//                                           Text(
//                                             prediction.structuredFormat
//                                                     ?.mainText?.text ??
//                                                 prediction.text?.text ??
//                                                 '',
//                                             style: textBold.copyWith(
//                                               fontSize:
//                                                   Dimensions.fontSizeDefault,
//                                             ),
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                           // Ligne secondaire : localisation
//                                           // (ex: "Abidjan, Côte d'Ivoire")
//                                           if (prediction.structuredFormat
//                                                   ?.secondaryText?.text !=
//                                               null)
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.only(top: 2),
//                                               child: Text(
//                                                 prediction.structuredFormat!
//                                                     .secondaryText!.text!,
//                                                 style: textBold.copyWith(
//                                                   fontSize:
//                                                       Dimensions.fontSizeSmall,
//                                                   color: Colors.grey[700],
//                                                 ),
//                                                 maxLines: 2,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ),
//                                           // Chips distance / durée
//                                           if (suggestion.distanceText != null || suggestion.durationText != null)
//                                             Padding(
//                                               padding: const EdgeInsets.only(top: 5),
//                                               child: Row(
//                                                 children: [
//                                                   if (suggestion.distanceText != null)
//                                                     _InfoChip(
//                                                       icon: Icons.straighten,
//                                                       label: suggestion.distanceText!,
//                                                     ),
//                                                   if (suggestion.distanceText != null && suggestion.durationText != null)
//                                                     const SizedBox(width: 6),
//                                                   if (suggestion.durationText != null)
//                                                     _InfoChip(
//                                                       icon: Icons.access_time,
//                                                       label: suggestion.durationText!,
//                                                     ),
//                                                 ],
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

// // ── Suggestions d'adresses ──────────────────────────────────────



//           ],
//         );
//       });
//     });
//   }


@override
Widget build(BuildContext context) {
  return GetBuilder<LocationController>(builder: (loc) {
    return GetBuilder<RideController>(builder: (ride) {
      final items = _buildItems(loc);

      final bool showSuggestions = loc.resultShow &&
          loc.predictionList?.data?.suggestions != null &&
          loc.predictionList!.data!.suggestions!.isNotEmpty &&
          (_extraOneFocus.hasFocus ||
              _extraTwoFocus.hasFocus ||
              _extraThreeFocus.hasFocus ||
              _destinationFocus.hasFocus);

      // ✅ Column au lieu de Stack — même structure que SetDestinationScreen
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Indicateur de mise à jour ──────────────────────────────
          if (_isUpdatingRoute)
            Padding(
              padding: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeExtraSmall),
              child: Row(children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'updating_route'.tr,
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ]),
            ),

          // ── Bloc principal ─────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withValues(alpha: 0.07),
              borderRadius:
                  BorderRadius.circular(Dimensions.paddingSizeSmall),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RouteIconsColumn(stopsCount: _stopsCount(loc)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
                      bottom: Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PickLocationWidget(
                          locationType: LocationType.from,
                          textFieldHint: 'pick_location'.tr,
                          rideDetails: ride.rideDetails,
                          focusNode: _pickupFocus,
                          textEditingController:
                              loc.pickupLocationController,
                          isShowCrossButton: false,
                          locationIconTap: () {},
                          textFieldTap: () {},
                          onSuggestionSelected: () {},
                        ),
                        const _FieldDivider(),
                        if (items.length > 1)
                          _buildReorderable(items, loc, ride)
                        else
                          _buildDestinationOnly(loc, ride),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Badge tarif ────────────────────────────────────────────
          if (!_isUpdatingRoute &&
              ride.estimatedFare > 0 &&
              ride.tripDetails != null)
            _FareUpdateBadge(
              newFare: ride.estimatedFare,
              originalFare:
                  (ride.tripDetails!.estimatedFare ?? 0).toDouble(),
            ),

          // ── Suggestions — APRÈS le bloc, comme SetDestinationScreen ─
          // ✅ Hauteur fixe + placée en dehors du scroll principal
          if (showSuggestions)
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              margin: const EdgeInsets.only(
                  top: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? Theme.of(context).canvasColor
                    : Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.paddingSizeDefault),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Padding(
                    padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault),
                    child: Row(
                      children: [
                        Text(
                          'Indiquer votre itinéraire',
                          style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge),
                        ),
                        const Spacer(),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              loc.setSearchResultShowHide(show: false),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.close, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✅ Expanded fonctionne car le Container a une height fixe
                  Expanded(
                    child: ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: loc
                          .predictionList!.data!.suggestions!.length,
                      itemBuilder: (context, index) {
                        final suggestion = loc
                            .predictionList!.data!.suggestions![index];
                        final prediction = suggestion.placePrediction;
                        if (prediction == null)
                          return const SizedBox.shrink();

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _selectSuggestion(
                                loc, prediction, loc.locationType);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeDefault,
                              horizontal: Dimensions.paddingSizeDefault,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(Icons.location_on,
                                      color:
                                          Theme.of(context).primaryColor,
                                      size: 20),
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeSmall),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prediction.structuredFormat
                                                ?.mainText?.text ??
                                            prediction.text?.text ??
                                            '',
                                        style: textBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (prediction.structuredFormat
                                              ?.secondaryText?.text !=
                                          null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 2),
                                          child: Text(
                                            prediction.structuredFormat!
                                                .secondaryText!.text!,
                                            style: textBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Colors.grey[700],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      if (suggestion.distanceText != null ||
                                          suggestion.durationText != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5),
                                          child: Row(children: [
                                            if (suggestion.distanceText !=
                                                null)
                                              _InfoChip(
                                                  icon: Icons.straighten,
                                                  label: suggestion
                                                      .distanceText!),
                                            if (suggestion.distanceText !=
                                                    null &&
                                                suggestion.durationText !=
                                                    null)
                                              const SizedBox(width: 6),
                                            if (suggestion.durationText !=
                                                null)
                                              _InfoChip(
                                                  icon: Icons.access_time,
                                                  label: suggestion
                                                      .durationText!),
                                          ]),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  });
}




  // ── Sélection d'une suggestion ──────────────────────────────────────────
  // void _selectSuggestion(
  //   LocationController loc,
  //   dynamic prediction,
  //   LocationType type,
  // ) {
  //   loc.setLocation(
  //     fromSearch: true,
  //     prediction.placeId ?? '',
  //     prediction.text?.text ?? '',
  //     null,
  //     type: type,
  //   ).then((_) {
  //     // Fermer les suggestions
  //     loc.setSearchResultShowHide(show: false);
  //     FocusScope.of(context).unfocus();

  //     // Vérifier si l'adresse a bien été définie
  //     final hasAddr = switch (type) {
  //       LocationType.extraOne => loc.extraRouteAddress != null,
  //       LocationType.extraTwo => loc.extraRouteTwoAddress != null,
  //       LocationType.extraThree => loc.extraRouteThreeAddress != null,
  //       LocationType.to => loc.toAddress != null,
  //       _ => false,
  //     };

  //     if (hasAddr) {
  //       _triggerRouteUpdate();
  //     }
  //   });
  // }

  void _selectSuggestion(
  LocationController loc,
  dynamic prediction,
  LocationType type,
) {
  // ✅ Ne pas cacher ici — laisser setLocation finir d'abord
  loc.setLocation(
    fromSearch: true,
    prediction.placeId ?? '',
    prediction.text?.text ?? '',
    null,
    type: type,
  ).then((_) {
      if (!mounted) return; 
    loc.setSearchResultShowHide(show: false);
    FocusScope.of(context).unfocus();

    final hasAddr = switch (type) {
      LocationType.extraOne => loc.extraRouteAddress != null,
      LocationType.extraTwo => loc.extraRouteTwoAddress != null,
      LocationType.extraThree => loc.extraRouteThreeAddress != null,
      LocationType.to => loc.toAddress != null,
      _ => false,
    };

    if (hasAddr) {
      _triggerRouteUpdate();
    }
  });
}

  // ── Destination seule ───────────────────────────────────────────────────
  Widget _buildDestinationOnly(LocationController loc, RideController ride) {
    return Row(children: [
      Expanded(
        child: _field(
          type: LocationType.to,
          hint: 'destination'.tr,
          ctrl: loc.destinationLocationController,
          addr: loc.toAddress,
          focus: _destinationFocus,
          ride: ride,
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
      _buildAddStopButton(loc),
    ]);
  }

  // ── Arrêts + destination réordonnables ──────────────────────────────────
  Widget _buildReorderable(
    List<Map<String, dynamic>> items,
    LocationController loc,
    RideController ride,
  ) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      proxyDecorator: (child, idx, anim) => Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        child: child,
      ),
      onReorder: (o, n) => _onReorder(items, o, n, loc),
      itemCount: items.length,
      itemBuilder: (ctx, idx) {
        final item = items[idx];
        final isDest = item['isDest'] as bool;
        final type = item['type'] as LocationType;

        return Container(
          key: ValueKey('ts_$type'),
          margin: const EdgeInsets.only(bottom: 2),
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              if (!isDest)
                ReorderableDragStartListener(
                  index: idx,
                  child: const SizedBox.shrink(),
                )
              else
                const SizedBox(width: 32),

              Expanded(
                child: _field(
                  type: type,
                  hint: item['hint'] as String,
                  ctrl: item['ctrl'] as TextEditingController,
                  addr: item['addr'] as Address?,
                  focus: item['focus'] as FocusNode,
                  ride: ride,
                ),
              ),

              if (!isDest)
                IconButton(
                  onPressed: () => _confirmRemoveStop(type),
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 18),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                )
              else ...[
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                _buildAddStopButton(loc),
              ],
            ]),

            if (idx < items.length - 1)
              Padding(
                padding: const EdgeInsets.only(
                    left: 32, right: Dimensions.paddingSizeDefault),
                child: Divider(
                  height: 1,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                ),
              ),
          ]),
        );
      },
    );
  }

  // ── Champ générique ─────────────────────────────────────────────────────
  Widget _field({
    required LocationType type,
    required String hint,
    required TextEditingController ctrl,
    required Address? addr,
    required FocusNode focus,
    required RideController ride,
  }) {
    return PickLocationWidget(
      locationType: type,
      textFieldHint: hint,
      rideDetails: ride.rideDetails,
      focusNode: focus,
      textEditingController: ctrl,
      isShowCrossButton: false,
      locationIconTap: () {
        // Cacher les suggestions avant d'ouvrir la carte
        Get.find<LocationController>().setSearchResultShowHide(show: false);
        FocusScope.of(context).unfocus();

        // Utiliser Get.to avec navigation
        Get.to(() => PickMapScreen(type: type, address: addr))?.then((result) {
          // Le résultat peut être l'adresse sélectionnée
          if (result != null && result is Address) {
            _updateAddressFromMap(type, result);
          }
          // Sinon, vérifier si l'adresse a été mise à jour par le contrôleur
          final loc = Get.find<LocationController>();
          final hasAddr = switch (type) {
            LocationType.extraOne => loc.extraRouteAddress != null,
            LocationType.extraTwo => loc.extraRouteTwoAddress != null,
            LocationType.extraThree => loc.extraRouteThreeAddress != null,
            LocationType.to => loc.toAddress != null,
            _ => false,
          };
          if (hasAddr) {
            _triggerRouteUpdate();
          }
        });
      },
      textFieldTap: () {
        // Afficher les suggestions quand on tape sur le champ
        final loc = Get.find<LocationController>();
        loc.setSearchResultShowHide(show: true);
        loc.locationType = type;
        setState(() {});
      },
      onSuggestionSelected: () {
        FocusScope.of(context).unfocus();
        final loc = Get.find<LocationController>();
        loc.setSearchResultShowHide(show: false);

        final hasAddr = switch (type) {
          LocationType.extraOne => loc.extraRouteAddress != null,
          LocationType.extraTwo => loc.extraRouteTwoAddress != null,
          LocationType.extraThree => loc.extraRouteThreeAddress != null,
          LocationType.to => loc.toAddress != null,
          _ => false,
        };
        if (hasAddr) {
          _triggerRouteUpdate();
        }
      },
    );
  }

  // ── Mise à jour depuis la carte ────────────────────────────────────────
  void _updateAddressFromMap(LocationType type, Address address) {
    final loc = Get.find<LocationController>();
    switch (type) {
      case LocationType.extraOne:
        loc.extraRouteAddress = address;
        loc.extraRouteOneController.text = address.address ?? '';
        break;
      case LocationType.extraTwo:
        loc.extraRouteTwoAddress = address;
        loc.extraRouteTwoController.text = address.address ?? '';
        break;
      case LocationType.extraThree:
        loc.extraRouteThreeAddress = address;
        loc.extraRouteThreeController.text = address.address ?? '';
        break;
      case LocationType.to:
        loc.toAddress = address;
        loc.destinationLocationController.text = address.address ?? '';
        break;
      default:
        break;
    }
    loc.update();
    setState(() {});
  }

  @override
  void dispose() {
    _debounceSearchTimer?.cancel();
    _autoCalcTimer?.cancel();
    _extraOneFocus.dispose();
    _extraTwoFocus.dispose();
    _extraThreeFocus.dispose();
    _destinationFocus.dispose();
    _pickupFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Badge affiché quand le tarif a changé
// ════════════════════════════════════════════════════════════════════════════

class _FareUpdateBadge extends StatelessWidget {
  final double newFare;
  final double originalFare;

  const _FareUpdateBadge({required this.newFare, required this.originalFare});

  @override
  Widget build(BuildContext context) {
    if ((newFare - originalFare).abs() < 1) return const SizedBox.shrink();

    final isMore = newFare > originalFare;
    final color = isMore ? Colors.orange : Colors.green;
    final icon = isMore ? Icons.arrow_upward : Icons.arrow_downward;
    final diff = (newFare - originalFare).abs().toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          isMore
              ? '${'fare_increased_by'.tr} $diff'
              : '${'fare_decreased_by'.tr} $diff',
          style:
              textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          '→ ${newFare.toStringAsFixed(0)}',
          style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: color),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Colonne icônes
// ════════════════════════════════════════════════════════════════════════════

class _RouteIconsColumn extends StatelessWidget {
  final int stopsCount;
  const _RouteIconsColumn({required this.stopsCount});

  @override
  Widget build(BuildContext context) {
    final double lineH = ((1 + stopsCount) * 52.0 - 24).clamp(20.0, 400.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeSmall, Dimensions.paddingSizeDefault, 0, 0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: Dimensions.iconSizeLarge,
          child: Image.asset(Images.currentLocation,
              color: Theme.of(context).textTheme.bodyMedium!.color),
        ),
        SizedBox(
          height: lineH,
          width: 10,
          child: CustomDivider(
            height: 4,
            dashWidth: 0.8,
            axis: Axis.vertical,
            color: Theme.of(context)
                .textTheme
                .bodyMedium!
                .color!
                .withValues(alpha: 0.5),
          ),
        ),
        SizedBox(
          width: Dimensions.iconSizeMedium,
          child: Transform(
            alignment: Alignment.center,
            transform: Get.find<LocalizationController>().isLtr
                ? Matrix4.rotationY(0)
                : Matrix4.rotationY(math.pi),
            child: Image.asset(Images.activityDirection,
                color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Séparateur
// ════════════════════════════════════════════════════════════════════════════

class _FieldDivider extends StatelessWidget {
  const _FieldDivider();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeExtraSmall),
        child: Divider(
          height: 1,
          color: Theme.of(context).hintColor.withValues(alpha: 0.25),
        ),
      );
}


// ════════════════════════════════════════════════════════════════════════════
// Chip distance / durée affiché dans la liste de suggestions
// ════════════════════════════════════════════════════════════════════════════

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Theme.of(context).primaryColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}