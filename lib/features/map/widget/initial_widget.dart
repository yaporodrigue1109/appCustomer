
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/fare_input_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/route_widget.dart';
import 'package:ride_sharing_user_app/features/payment/controllers/payment_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/ride_category.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_fare_summery.dart';
import 'package:ride_sharing_user_app/features/set_destination/widget/schedule_date_time_picker_widget.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/ride_controller_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/set_destination/widget/pick_location_widget.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';

class InitialWidget extends StatefulWidget {
  final GlobalKey<ExpandableBottomSheetState> expandableKey;
      final VoidCallback? onRouteChanged;
  const InitialWidget({super.key, required this.expandableKey,  this.onRouteChanged,});

  @override
  State<InitialWidget> createState() => _InitialWidgetState();

}

class _InitialWidgetState extends State<InitialWidget> with WidgetsBindingObserver {
  double dialogTopPosition = 0;
  double bottomWhiteSpace = 0;
  final GlobalKey _key = GlobalKey();
  Timer? _debounceTimer;
  Timer? _searchDebounceTimer;
  bool _isCalculating = false;


  Timer? _debounceSearchTimer;
  Timer? _autoCalcTimer;

  bool _prefilled = false;

  // Suivi de l'état « en cours de mise à jour » pour l'UI
  bool _isUpdatingRoute = false;
  String? _updateError;

  // ──────────────────────────

  // Focus nodes pour les arrêts
  late FocusNode pickupFocus;
  late FocusNode extraOneFocus;
  late FocusNode extraTwoFocus;
  late FocusNode extraThreeFocus;
  late FocusNode destinationFocus;
  
  // ScrollController pour faire défiler vers le champ
  final ScrollController _scrollController = ScrollController();
  
  // Clés pour obtenir la position des champs
  final GlobalKey _pickupKey = GlobalKey();
  final GlobalKey _extraOneKey = GlobalKey();
  final GlobalKey _extraTwoKey = GlobalKey();
  final GlobalKey _extraThreeKey = GlobalKey();
  final GlobalKey _destinationKey = GlobalKey();




  @override
  void initState() {
    var rideController = Get.find<RideController>();
    if(Get.find<PaymentController>().paymentType == 'wallet' &&
        (rideController.discountAmount.toDouble() > 0 ? rideController.discountFare : rideController.estimatedFare) >
            Get.find<ProfileController>().profileModel!.data!.wallet!.walletBalance!
    ){
      Get.find<PaymentController>().setPaymentType(0);
    }
    
    WidgetsBinding.instance.addObserver(this);

    // Initialiser les focus nodes
    pickupFocus = FocusNode();
    extraOneFocus = FocusNode();
    extraTwoFocus = FocusNode();
    extraThreeFocus = FocusNode();
    destinationFocus = FocusNode();
    
    _setupFocusListeners();
    _setupTextListeners();
    
    super.initState();
  }

  void _setupFocusListeners() {
    pickupFocus.addListener(() {
      if (pickupFocus.hasFocus) {
        Get.find<LocationController>().locationType = LocationType.from;
      }
    });

    extraOneFocus.addListener(() {
      if (extraOneFocus.hasFocus) {
        _clearFieldIfPrefilled(LocationType.extraOne);
        _scrollToPosition(320);
        Get.find<LocationController>().locationType = LocationType.extraOne;
      }
    });
    
    extraTwoFocus.addListener(() {
      if (extraTwoFocus.hasFocus) {
        _clearFieldIfPrefilled(LocationType.extraTwo);
        _scrollToPosition(360);
        Get.find<LocationController>().locationType = LocationType.extraTwo;
      }
    });
    
    extraThreeFocus.addListener(() {
      if (extraThreeFocus.hasFocus) {
        _clearFieldIfPrefilled(LocationType.extraThree);
        _scrollToPosition(400);
        Get.find<LocationController>().locationType = LocationType.extraThree;
      }
    });
    
    destinationFocus.addListener(() {
      if (destinationFocus.hasFocus) {
        _clearFieldIfPrefilled(LocationType.to);
        _scrollToPosition(440);
        Get.find<LocationController>().locationType = LocationType.to;
      }
    });
  }

  void _setupTextListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationController = Get.find<LocationController>();

      // Autocomplete sur le champ "départ"
      locationController.pickupLocationController.addListener(() {
        final text = locationController.pickupLocationController.text;
        if (pickupFocus.hasFocus && text.length > 2) {
          _debounceSearch(text, LocationType.from);
        } else if (pickupFocus.hasFocus && text.length <= 2) {
          locationController.setSearchResultShowHide(show: false);
        }
      });
      
      locationController.extraRouteOneController.addListener(() {
        final text = locationController.extraRouteOneController.text;
        if (extraOneFocus.hasFocus && text.length > 2) {
          _debounceSearch(text, LocationType.extraOne);
        } else if (extraOneFocus.hasFocus && text.length <= 2) {
          locationController.setSearchResultShowHide(show: false);
        }
      });
      
      locationController.extraRouteTwoController.addListener(() {
        final text = locationController.extraRouteTwoController.text;
        if (extraTwoFocus.hasFocus && text.length > 2) {
          _debounceSearch(text, LocationType.extraTwo);
        } else if (extraTwoFocus.hasFocus && text.length <= 2) {
          locationController.setSearchResultShowHide(show: false);
        }
      });
      
      locationController.extraRouteThreeController.addListener(() {
        final text = locationController.extraRouteThreeController.text;
        if (extraThreeFocus.hasFocus && text.length > 2) {
          _debounceSearch(text, LocationType.extraThree);
        } else if (extraThreeFocus.hasFocus && text.length <= 2) {
          locationController.setSearchResultShowHide(show: false);
        }
      });
      
      locationController.destinationLocationController.addListener(() {
        final text = locationController.destinationLocationController.text;
        if (destinationFocus.hasFocus && text.length > 2) {
          _debounceSearch(text, LocationType.to);
        } else if (destinationFocus.hasFocus && text.length <= 2) {
          locationController.setSearchResultShowHide(show: false);
        }
      });
    });
  }

  void _debounceSearch(String query, LocationType type) {
    _searchDebounceTimer?.cancel();

    final locationController = Get.find<LocationController>();

    // Afficher l'autocomplete pendant la saisie
    locationController.locationType = type;
    locationController.setSearchResultShowHide(show: true);

    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        locationController.searchLocation(
          context,
          query,
          type: type,
          fromMap: false,
        );
      } else {
        locationController.setSearchResultShowHide(show: false);
      }
    });
  }

  void _scrollToPosition(double position) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _clearFieldIfPrefilled(LocationType type) {
    final locationController = Get.find<LocationController>();
    switch (type) {
      case LocationType.extraOne:
        if (locationController.extraRouteOneController.text.isNotEmpty) {
          locationController.extraRouteOneController.clear();
          locationController.extraRouteAddress = null;
          locationController.update();
        }
        break;
      case LocationType.extraTwo:
        if (locationController.extraRouteTwoController.text.isNotEmpty) {
          locationController.extraRouteTwoController.clear();
          locationController.extraRouteTwoAddress = null;
          locationController.update();
        }
        break;
      case LocationType.extraThree:
        if (locationController.extraRouteThreeController.text.isNotEmpty) {
          locationController.extraRouteThreeController.clear();
          locationController.extraRouteThreeAddress = null;
          locationController.update();
        }
        break;
      case LocationType.to:
        if (locationController.destinationLocationController.text.isNotEmpty) {
          locationController.destinationLocationController.clear();
          locationController.toAddress = null;
          locationController.update();
        }
        break;
      default:
        break;
    }
  }

  /// Sauvegarde toutes les adresses du trajet si elles n'existent pas déjà
Future<void> _saveRouteAddresses() async {
  final loc = Get.find<LocationController>();
  final addressCtrl = Get.find<AddressController>();

  final addressesToSave = <Address?>[
    loc.fromAddress,
    if (loc.extraOneRoute) loc.extraRouteAddress,
    if (loc.extraTwoRoute) loc.extraRouteTwoAddress,
    if (loc.extraThreeRoute) loc.extraRouteThreeAddress,
    loc.toAddress,
  ];

  for (final addr in addressesToSave) {
    if (addr != null) {
      await addressCtrl.saveAddressIfNotExists(addr);
    }
  }
}

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchDebounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    pickupFocus.dispose();
    extraOneFocus.dispose();
    extraTwoFocus.dispose();
    extraThreeFocus.dispose();
    destinationFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Méthode pour déclencher le calcul automatique
  Future<void> _triggerAutoCalculate() async {
    final locationController = Get.find<LocationController>();
    final rideController = Get.find<RideController>();
    
    if (locationController.fromAddress == null || locationController.toAddress == null) {
      return;
    }
    
    if (_isCalculating) return;
    
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (rideController.loading) return;
      
      _isCalculating = true;
      
      print("🔄 Calcul automatique déclenché avec ${_getCurrentStopsCount(locationController)} arrêts");
      
      try {
        var response = await rideController.getEstimatedFare(false);
        
        if (response.statusCode == 200) {
          print("✅ Tarif recalculé avec succès");
          
          await _updateMapWithStops();
          
          rideController.update();
          locationController.update();
          
          if (mounted) {
            setState(() {});
          }
        }
      } catch (e) {
        print("❌ Erreur lors du calcul: $e");
      } finally {
        _isCalculating = false;
      }
    });
  }

  // Méthode pour mettre à jour la map
  Future<void> _updateMapWithStops() async {
    final mapController = Get.find<MapController>();
    final locationController = Get.find<LocationController>();
    
    List<LatLng> allPoints = [];
    
    if (locationController.fromAddress?.latitude != null && 
        locationController.fromAddress?.longitude != null) {
      allPoints.add(LatLng(
        locationController.fromAddress!.latitude!,
        locationController.fromAddress!.longitude!,
      ));
    }
    
    if (locationController.extraRouteAddress?.latitude != null && 
        locationController.extraRouteAddress?.longitude != null) {
      allPoints.add(LatLng(
        locationController.extraRouteAddress!.latitude!,
        locationController.extraRouteAddress!.longitude!,
      ));
    }
    
    if (locationController.extraRouteTwoAddress?.latitude != null && 
        locationController.extraRouteTwoAddress?.longitude != null) {
      allPoints.add(LatLng(
        locationController.extraRouteTwoAddress!.latitude!,
        locationController.extraRouteTwoAddress!.longitude!,
      ));
    }
    
    if (locationController.extraRouteThreeAddress?.latitude != null && 
        locationController.extraRouteThreeAddress?.longitude != null) {
      allPoints.add(LatLng(
        locationController.extraRouteThreeAddress!.latitude!,
        locationController.extraRouteThreeAddress!.longitude!,
      ));
    }
    
    if (locationController.toAddress?.latitude != null && 
        locationController.toAddress?.longitude != null) {
      allPoints.add(LatLng(
        locationController.toAddress!.latitude!,
        locationController.toAddress!.longitude!,
      ));
    }
    
    if (allPoints.length >= 2) {
      await mapController.showMultipleMarkersOnMap(allPoints);
      print("🗺️ Carte mise à jour avec ${allPoints.length} points");
    }
  }

  // Nouvelle méthode pour obtenir tous les éléments déplaçables
  List<Map<String, dynamic>> _getReorderableItems(LocationController locationController) {
    final List<Map<String, dynamic>> items = [];

    if (locationController.extraOneRoute) {
      items.add({
        'type': LocationType.extraOne,
        'hint': 'extra_route_one'.tr,
        'controller': locationController.extraRouteOneController,
        'address': locationController.extraRouteAddress,
        'focusNode': extraOneFocus,
        'key': _extraOneKey,
        'isDestination': false,
      });
    }
    if (locationController.extraTwoRoute) {
      items.add({
        'type': LocationType.extraTwo,
        'hint': 'extra_route_two'.tr,
        'controller': locationController.extraRouteTwoController,
        'address': locationController.extraRouteTwoAddress,
        'focusNode': extraTwoFocus,
        'key': _extraTwoKey,
        'isDestination': false,
      });
    }
    if (locationController.extraThreeRoute) {
      items.add({
        'type': LocationType.extraThree,
        'hint': 'extra_route_three'.tr,
        'controller': locationController.extraRouteThreeController,
        'address': locationController.extraRouteThreeAddress,
        'focusNode': extraThreeFocus,
        'key': _extraThreeKey,
        'isDestination': false,
      });
    }

    items.add({
      'type': LocationType.to,
      'hint': 'destination'.tr,
      'controller': locationController.destinationLocationController,
      'address': locationController.toAddress,
      'focusNode': destinationFocus,
      'key': _destinationKey,
      'isDestination': true,
    });

    return items;
  }

  // Nouvelle méthode pour construire la section avec glisser-déposer
  Widget _buildDraggableStopsAndDestinationSection(
      LocationController locationController, RideController rideController) {
    final items = _getReorderableItems(locationController);
    
    if (items.length <= 1) {
      return _buildDestinationOnly(locationController, rideController);
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      proxyDecorator: (child, index, animation) {
        return Material(
          elevation: 4,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
          child: child,
        );
      },
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final type = item['type'] as LocationType;
        final hint = item['hint'] as String;
        final controller = item['controller'] as TextEditingController;
        final address = item['address'] as Address?;
        final focusNode = item['focusNode'] as FocusNode;
        final key = item['key'] as GlobalKey;
        final isDestination = item['isDestination'] as bool;

        return Container(
          key: key,
          child: _DraggableStopItem(
            key: ValueKey('reorderable_${type.toString()}_$index'),
            type: type,
            hint: hint,
            controller: controller,
            address: address,
            focusNode: focusNode,
            rideController: rideController,
            isDestination: isDestination,
            onDelete: isDestination ? null : () => _showDeleteDialog(type, locationController),
            onMapTap: () {
              // Cacher l'autocomplete avant de naviguer
              locationController.setSearchResultShowHide(show: false);
              FocusScope.of(context).unfocus();
              
              RouteHelper.goPageAndHideTextField(
                context,
                PickMapScreen(type: type, address: address),
              );
            },
            onFieldTap: () {
              setScrollAndDialogPosition(type, locationController);
            },
            onSuggestionSelected: () {
              FocusScope.of(context).unfocus();
              locationController.setSearchResultShowHide(show: false);
              _triggerAutoCalculate();
            },
            addStopButton: isDestination ? _buildAddStopButton(locationController) : null,
          ),
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        
        final currentItems = _getReorderableItems(locationController);
        final item = currentItems.removeAt(oldIndex);
        currentItems.insert(newIndex, item);
        
        _updateItemsWithNewOrder(currentItems, locationController);
        _triggerAutoCalculate();
      },
    );
  }

  // Méthode pour afficher uniquement la destination
  Widget _buildDestinationOnly(
      LocationController locationController, RideController rideController) {
    return Container(
      key: _destinationKey,
      child: Row(
        children: [
          Expanded(
            child: PickLocationWidget(
              locationType: LocationType.to,
              textFieldHint: 'destination'.tr,
              rideDetails: rideController.rideDetails,
              focusNode: destinationFocus,
              textEditingController: locationController.destinationLocationController,
              isShowCrossButton: false,
              locationIconTap: () {
                // Cacher l'autocomplete avant de naviguer
                locationController.setSearchResultShowHide(show: false);
                FocusScope.of(context).unfocus();
                
                RouteHelper.goPageAndHideTextField(
                  context,
                  PickMapScreen(
                    type: LocationType.to,
                    address: locationController.toAddress,
                  ),
                );
                _triggerAutoCalculate();
              },
              textFieldTap: () {
                setScrollAndDialogPosition(LocationType.to, locationController);
              },
              onSuggestionSelected: () {
                FocusScope.of(context).unfocus();
                locationController.setSearchResultShowHide(show: false);
                _triggerAutoCalculate();
              },
            ),
          ),
          SizedBox(width: Dimensions.paddingSizeSmall),
          _buildAddStopButton(locationController),
        ],
      ),
    );
  }

  // Méthode pour mettre à jour l'ordre des éléments
  void _updateItemsWithNewOrder(
      List<Map<String, dynamic>> items,
      LocationController locationController) {

    final stops = items.where((i) => i['isDestination'] == false).toList();
    final destinationItems = items.where((i) => i['isDestination'] == true).toList();

    final List<String> stopTexts = stops.map((r) => 
      (r['controller'] as TextEditingController).text
    ).toList();
    final List<Address?> stopAddresses = stops.map((r) => 
      r['address'] as Address?
    ).toList();

    final String destText = destinationItems.isNotEmpty
        ? (destinationItems[0]['controller'] as TextEditingController).text
        : '';
    final Address? destAddress = destinationItems.isNotEmpty
        ? destinationItems[0]['address'] as Address?
        : null;

    locationController.extraOneRoute = false;
    locationController.extraTwoRoute = false;
    locationController.extraThreeRoute = false;
    locationController.extraRouteOneController.clear();
    locationController.extraRouteTwoController.clear();
    locationController.extraRouteThreeController.clear();
    locationController.extraRouteAddress = null;
    locationController.extraRouteTwoAddress = null;
    locationController.extraRouteThreeAddress = null;

    for (int i = 0; i < stops.length; i++) {
      if (i == 0) {
        locationController.extraOneRoute = true;
        locationController.extraRouteOneController.text = stopTexts[i];
        locationController.extraRouteAddress = stopAddresses[i];
      } else if (i == 1) {
        locationController.extraTwoRoute = true;
        locationController.extraRouteTwoController.text = stopTexts[i];
        locationController.extraRouteTwoAddress = stopAddresses[i];
      } else if (i == 2) {
        locationController.extraThreeRoute = true;
        locationController.extraRouteThreeController.text = stopTexts[i];
        locationController.extraRouteThreeAddress = stopAddresses[i];
      }
    }

    locationController.destinationLocationController.text = destText;
    locationController.toAddress = destAddress;

    locationController.update();
    Get.find<RideController>().update();
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController){
      return GetBuilder<LocationController>(builder: (locationController){
        return Column(mainAxisSize: MainAxisSize.min, children: [
          RideCategoryWidget(onTap:(value) async {
            if(rideController.isCouponApplicable){
              await Future.delayed(const Duration(milliseconds: 500));
              widget.expandableKey.currentState?.expand(duration: 1000);
            }else{
              widget.expandableKey.currentState?.contract(duration: 500);
              widget.expandableKey.currentState?.expand(duration: 1000);
            }
          }),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)
            ),
            padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
            child: Row(spacing: Dimensions.paddingSizeSmall, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              InkWell(
                onTap: (){
                  if(Get.find<ConfigController>().config?.scheduleTripStatus ?? false){
                    Get.bottomSheet(const ScheduleDateTimePickerWidget(),enableDrag: false, isScrollControlled: true);
                  }
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  child: Row(spacing: Dimensions.paddingSizeExtraSmall, mainAxisSize: MainAxisSize.min, children: [
                    Image.asset(
                      rideController.rideType == RideType.scheduleRide ?
                        Images.scheduleCalenderIcon : Images.clockIcon,
                        height: 14,width: 14,
                    ),
                Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          rideController.rideType == RideType.scheduleRide ?
                          '${'schedule'.tr}: ${
                              DateFormat('d MMM y').format(RideControllerHelper.dateFormatToShow(rideController.scheduleTripDate))}, '
                              '${DateFormat('hh:mm a').format(RideControllerHelper.timeFormatToShow(rideController.scheduleTripTime))}' :
                          'save_for_later'.tr,
                          style: textBold.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                    if(rideController.rideType == RideType.regularRide)
                      Icon(Icons.keyboard_arrow_down_outlined) 
                  ]),
                ),
              )
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Formulaire de localisation
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LocationFromToWidget(),
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
                              // Point de départ
                              Container(
                                key: _pickupKey,
                                child: PickLocationWidget(
                                  locationType: LocationType.from,
                                  rideDetails: rideController.rideDetails,
                                  focusNode: pickupFocus,
                                  textEditingController: locationController.pickupLocationController,
                                  isShowCrossButton: false,
                                  textFieldHint: 'pick_location'.tr, 
                                  locationIconTap: () {
                                    // Cacher l'autocomplete avant de naviguer
                                    locationController.setSearchResultShowHide(show: false);
                                    FocusScope.of(context).unfocus();
                                    
                                    RouteHelper.goPageAndHideTextField(
                                      context,
                                      PickMapScreen(
                                        type: LocationType.from,
                                        address: locationController.fromAddress,
                                      ),
                                    );
                                    _triggerAutoCalculate();
                                  },
                                  textFieldTap: () {
                                    setScrollAndDialogPosition(LocationType.from, locationController);
                                  },
                                  onSuggestionSelected: () {
                                    FocusScope.of(context).unfocus();
                                    locationController.setSearchResultShowHide(show: false);
                                    _triggerAutoCalculate();
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text('to'.tr,
                                    style: textRegular.copyWith(
                                        color: Theme.of(context).textTheme.bodyMedium?.color)),
                              ),

                              // Section des arrêts et destination avec glisser-déposer
                              _buildDraggableStopsAndDestinationSection(locationController, rideController),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeExtraLarge,
                      0,
                      Dimensions.paddingSizeExtraLarge,
                      Dimensions.paddingSizeSmall,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'you_can_add_multiple_route_to'.tr,
                            style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

      
                 if (locationController.resultShow &&
              locationController.predictionList?.data?.suggestions != null &&
              locationController.predictionList!.data!.suggestions!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? Theme.of(context).canvasColor
                    : Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.paddingSizeDefault),
                  bottom: Radius.circular(Dimensions.paddingSizeDefault),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── En-tête ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Row(
                      children: [
                        Text(
                          'Indiquer votre itinéraire',
                          style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                        ),
                        const Spacer(),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => locationController.setSearchResultShowHide(show: false),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.close, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Liste scrollable ──────────────────────────────────────
                  Expanded(
                    child: ListView.builder(
                      // ClampingScrollPhysics : défile indépendamment du sheet
                      physics: const ClampingScrollPhysics(),
                      itemCount:
                          locationController.predictionList!.data!.suggestions!.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final suggestion = locationController
                            .predictionList!.data!.suggestions![index];
                        final prediction = suggestion.placePrediction;
                        if (prediction == null) return const SizedBox.shrink();
 
                        // GestureDetector garantit la sélection dans un bottom sheet
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            locationController.setSearchResultShowHide(show: false);
                            FocusScope.of(context).unfocus();
                            locationController.setLocation(
                              fromSearch: true,
                              prediction.placeId ?? '',
                              prediction.text?.text ?? '',
                              null,
                              type: locationController.locationType,
                            ).then((_) => _triggerAutoCalculate());
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
                                  child: Icon(
                                    Icons.location_on,
                                    color: Theme.of(context).primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Nom du lieu en gras (ex: "Route du Zoo")
                                      Text(
                                        prediction.structuredFormat?.mainText?.text ??
                                            prediction.text?.text ??
                                            '',
                                        style: textBold.copyWith(
                                            fontSize: Dimensions.fontSizeDefault),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      // Localisation (ex: "Abidjan, Côte d'Ivoire")
                                      if (prediction.structuredFormat?.secondaryText?.text != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            prediction.structuredFormat!.secondaryText!.text!,
                                            style: textBold.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: Colors.grey[700],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      // Chips distance / durée
                                      if (suggestion.distanceText != null ||
                                          suggestion.durationText != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: Row(
                                            children: [
                                              if (suggestion.distanceText != null)
                                                _SuggestionChip(
                                                  icon: Icons.straighten,
                                                  label: suggestion.distanceText!,
                                                ),
                                              if (suggestion.distanceText != null &&
                                                  suggestion.durationText != null)
                                                const SizedBox(width: 6),
                                              if (suggestion.durationText != null)
                                                _SuggestionChip(
                                                  icon: Icons.access_time,
                                                  label: suggestion.durationText!,
                                                ),
                                            ],
                                          ),
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

          const SizedBox(height: Dimensions.paddingSizeDefault),

          if(rideController.fareList.isNotEmpty && 
             rideController.fareList[rideController.rideCategoryIndex].extraFareReason != '') ...[
            Text('${'fares_are_a_bit_higher'.tr}${rideController.fareList[rideController.rideCategoryIndex].extraFareReason}', 
                 style: textRegular.copyWith(color: Theme.of(context).colorScheme.inverseSurface,fontSize: 11), 
                 textAlign: TextAlign.center),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          ],

          const SizedBox(height: Dimensions.paddingSizeSmall),

          TripFareSummery(
            tripFare: rideController.estimatedFare,  
            fromParcel: false,
            discountFare: rideController.discountFare, 
            discountAmount: rideController.discountAmount,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault), 

          if(rideController.isCouponApplicable)...[
            Align(alignment: Alignment.centerRight,
              child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  ),
                  child: Text('coupon_applied'.tr,style: textBold.copyWith(color: Theme.of(context).primaryColor))
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],

          rideController.isLoading || rideController.isSubmit ?
          Center(child: SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0)) :
          (Get.find<ConfigController>().config!.bidOnFare! && rideController.rideType != RideType.scheduleRide) ?
          FareInputWidget(
            expandableKey: widget.expandableKey,
            fromRide: true,
            fare: rideController.discountAmount.toDouble() > 0 ?
            rideController.discountFare.toString() :
            rideController.estimatedFare.toString(),
          ) :
          ButtonWidget(
            buttonText: rideController.rideType == RideType.regularRide ? "order".tr : "to_reserve".tr, 
            onPressed: () {
              if(rideController.rideType == RideType.regularRide) {
                _sendFindRiderRequest(rideController);
              }else{
                rideController.submitRideRequest(rideController.noteController.text, false).then((value){
                  if(value.statusCode == 200){
                    Get.find<MapController>().initializeData();
                    showCustomSnackBar(
                        '${'your_trip'.tr} #${rideController.tripDetails?.refId} ${'has_been_successfully_scheduled'.tr}',
                        subMessage: 'you_will_be_notified_when_a_driver_start_for_your'.tr,
                        isError: false
                    );
                    Get.offAll(() => TripDetailsScreen(tripId: rideController.tripDetails?.id ?? ''));
                  }
                });
              }
            },
          ),
        ]);
      });
    });
  }

void _selectSuggestion(
    LocationController loc,
    dynamic prediction,
    LocationType type,
  ) {
    loc.setLocation(
      fromSearch: true,
      prediction.placeId ?? '',
      prediction.text?.text ?? '',
      null,
      type: type,
    ).then((_) {
      // Fermer les suggestions
      loc.setSearchResultShowHide(show: false);
      FocusScope.of(context).unfocus();

      // Vérifier si l'adresse a bien été définie
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

 Future<void> _triggerRouteUpdate() async {
    final loc = Get.find<LocationController>();
    final ride = Get.find<RideController>();

    if (loc.toAddress == null) return;
    if (_isCalculating) return;

    _autoCalcTimer?.cancel();
    _autoCalcTimer = Timer(const Duration(milliseconds: 700), () async {
      _isCalculating = true;

      if (mounted) setState(() {
        _isUpdatingRoute = true;
        _updateError = null;
      });

      try {
        // ── 1. Recalcul du tarif ────────────────────────────────────────
        final fareResponse = await ride.getEstimatedFare(false);
        if (fareResponse.statusCode != 200) {
          _setError('fare_calculation_failed'.tr);
          return;
        }

        // ── 2. Persistance en base ──────────────────────────────────────
        if (ride.tripDetails?.id != null) {
          final updateResponse = await ride.updateTripRoute(
            tripId: ride.tripDetails!.id!,
            newFare: ride.estimatedFare,
            encodedPoly: ride.encodedPolyLine,
          );

          if (updateResponse.statusCode == 200) {
            // ── Recharger tripDetails depuis le serveur plutôt que de
            //    parser la réponse du PUT. La forme de la réponse de
            //    l'endpoint de mise à jour peut différer de celle attendue
            //    par TripDetailsModel.fromJson, ce qui provoquait l'erreur
            //    "Null check operator used on a null value" et empêchait
            //    le tarif/la distance affichés de se mettre à jour.
            await ride.getRideDetails(ride.tripDetails!.id!);
            await _saveRouteAddresses();
          } else {
            _setError('route_update_failed'.tr);
            return;
          }
        }

        // ── 3. Rafraîchissement carte ────────────────────────────────────
        await _refreshMap();

        ride.update();
        loc.update();
        if (mounted) setState(() {});
        widget.onRouteChanged?.call();
      } catch (e) {
        _setError('an_error_occurred'.tr);
        debugPrint('EditableRouteInTripWidget._triggerRouteUpdate error: $e');
      } finally {
        _isCalculating = false;
        if (mounted) setState(() {
          _isUpdatingRoute = false;
        });
      }
    });
  }

  void _setError(String msg) {
    if (mounted) setState(() {
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

  bool _canAddMoreStops(LocationController locationController) {
    // return Get.find<ConfigController>().config!.addIntermediatePoint! &&
    //     !locationController.extraThreeRoute;
    return true;
  }

  bool _hasStops(LocationController locationController) {
    return locationController.extraOneRoute ||
        locationController.extraTwoRoute ||
        locationController.extraThreeRoute;
  }

  int _getCurrentStopsCount(LocationController locationController) {
    int count = 0;
    if (locationController.extraOneRoute) count++;
    if (locationController.extraTwoRoute) count++;
    if (locationController.extraThreeRoute) count++;
    return count;
  }

  Widget _buildAddStopButton(LocationController locationController) {
    final currentStops = _getCurrentStopsCount(locationController);
    final canAddMore = _canAddMoreStops(locationController);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 70,
          height: 3,
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(1.5),
          ),
          child: Row(
            children: [
              for (int i = 0; i < 3; i++)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0.5),
                    decoration: BoxDecoration(
                      color: i < currentStops ? Theme.of(context).primaryColor : Colors.grey[300],
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
        ),
        InkWell(
          onTap: canAddMore ? () {
            _addNewStopAndFocus(locationController);
          } : null,
          child: Tooltip(
            message: 'Ajouter un arrêt intermédiaire ($currentStops/3)',
            child: Container(
              height: 30,
              width: 70,
              decoration: BoxDecoration(
                color: canAddMore ? Theme.of(context).primaryColor : Colors.grey[400],
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add,
                      color: canAddMore ? Colors.white : Colors.grey[200],
                      size: 14
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Arrêt',
                    style: TextStyle(
                      color: canAddMore ? Colors.white : Colors.grey[200],
                      fontSize: 10,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$currentStops/3',
                      style: TextStyle(
                        color: canAddMore ? Colors.white : Colors.grey[200],
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addNewStopAndFocus(LocationController locationController) {
    LocationType nextStopType = _getNextStopType(locationController);
    
    switch (nextStopType) {
      case LocationType.extraOne:
        locationController.extraOneRoute = true;
        break;
      case LocationType.extraTwo:
        locationController.extraTwoRoute = true;
        break;
      case LocationType.extraThree:
        locationController.extraThreeRoute = true;
        break;
      default:
        return;
    }
    
    locationController.update();
    setState(() {});
    
    Future.delayed(const Duration(milliseconds: 100), () {
      // Afficher l'autocomplete dès que le focus est posé
      Get.find<LocationController>().setSearchResultShowHide(show: true);
      switch (nextStopType) {
        case LocationType.extraOne:
          extraOneFocus.requestFocus();
          break;
        case LocationType.extraTwo:
          extraTwoFocus.requestFocus();
          break;
        case LocationType.extraThree:
          extraThreeFocus.requestFocus();
          break;
        default:
          break;
      }
    });
  }

  LocationType _getNextStopType(LocationController locationController) {
    if (!locationController.extraOneRoute) {
      return LocationType.extraOne;
    } else if (!locationController.extraTwoRoute) {
      return LocationType.extraTwo;
    } else {
      return LocationType.extraThree;
    }
  }

  void _showDeleteDialog(LocationType type, LocationController locationController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('supprimer_l_arrêt'.tr),
          content: Text('voulez_vous_supprimer_cet_arrêt'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('annuler'.tr),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _removeStop(type, locationController);
                _triggerAutoCalculate();
              },
              child: Text('supprimer'.tr, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _removeStop(LocationType type, LocationController locationController) {
    switch (type) {
      case LocationType.extraOne:
        locationController.extraOneRoute = false;
        locationController.extraRouteOneController.clear();
        locationController.extraRouteAddress = null;
        break;
      case LocationType.extraTwo:
        locationController.extraTwoRoute = false;
        locationController.extraRouteTwoController.clear();
        locationController.extraRouteTwoAddress = null;
        break;
      case LocationType.extraThree:
        locationController.extraThreeRoute = false;
        locationController.extraRouteThreeController.clear();
        locationController.extraRouteThreeAddress = null;
        break;
      default:
        return;
    }

    locationController.update();
    Get.find<RideController>().update();
    setState(() {});
  }

  void setScrollAndDialogPosition(LocationType locationType, LocationController locationController) {
    locationController.setSearchResultShowHide(show: true);
    setState(() {});
  }

  void _sendFindRiderRequest(RideController rideController){
    rideController.submitRideRequest(rideController.noteController.text, false).then((value) {
      if (value.statusCode == 200) {
        Get.find<AuthController>().saveFindingRideCreatedTime();
        rideController.updateRideCurrentState(RideState.findingRider);
        Get.find<MapController>().initializeData();
        Get.find<MapController>().setOwnCurrentLocation(
            LatLng(
                Get.find<LocationController>().fromAddress?.latitude ?? 0,
                Get.find<LocationController>().fromAddress?.longitude ?? 0
            )
        );
        Get.find<MapController>().notifyMapController();
      }
    });
  }
}

// Widget pour un élément déplaçable (arrêt ou destination)
class _DraggableStopItem extends StatelessWidget {
  final LocationType type;
  final String hint;
  final TextEditingController controller;
  final Address? address;
  final FocusNode focusNode;
  final RideController rideController;
  final bool isDestination;
  final VoidCallback? onDelete;
  final VoidCallback onMapTap;
  final VoidCallback onFieldTap;
  final VoidCallback onSuggestionSelected;
  final Widget? addStopButton;

  const _DraggableStopItem({
    required Key key,
    required this.type,
    required this.hint,
    required this.controller,
    required this.address,
    required this.focusNode,
    required this.rideController,
    required this.isDestination,
    required this.onDelete,
    required this.onMapTap,
    required this.onFieldTap,
    required this.onSuggestionSelected,
    this.addStopButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Poignée de drag
          ReorderableDragStartListener(
            index: _getIndexForType(),
              child: const SizedBox.shrink(),
            // child: Container(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 6,
            //     vertical: 12,
            //   ),
            //   child: Icon(
            //     Icons.drag_handle,
            //     color: Colors.grey[400],
            //     size: 22,
            //   ),
            // ),
          ),

          // Champ de localisation
          Expanded(
            child: PickLocationWidget(
              locationType: type,
              textFieldHint: hint,
              rideDetails: rideController.rideDetails,
              focusNode: focusNode,
              textEditingController: controller,
              isShowCrossButton: false,
              locationIconTap: onMapTap,
              textFieldTap: onFieldTap,
              onSuggestionSelected: onSuggestionSelected,
            ),
          ),

          // Bouton d'ajout (pour destination) ou supprimer (pour arrêts)
          if (isDestination && addStopButton != null) ...[
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            addStopButton!,
          ] else if (!isDestination && onDelete != null) ...[
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              tooltip: 'Supprimer cet arrêt',
            ),
          ],
        ],
      ),
    );
  }

  int _getIndexForType() {
    switch (type) {
      case LocationType.extraOne:
        return 0;
      case LocationType.extraTwo:
        return 1;
      case LocationType.extraThree:
        return 2;
      case LocationType.to:
        return 3;
      default:
        return 0;
    }
  }
}




class _LocationFromToWidget extends StatelessWidget {
  const _LocationFromToWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeDefault,
        0,
        0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: Dimensions.iconSizeLarge,
            child: Image.asset(
              Images.currentLocation,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
          Container(
            height: 40,
            width: 10,
            child: CustomDivider(
              height: 4,
              dashWidth: 0.8,
              axis: Axis.vertical,
              color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(
            width: Dimensions.iconSizeMedium,
            child: Transform(
              alignment: Alignment.center,
              transform: Get.find<LocalizationController>().isLtr
                  ? Matrix4.rotationY(0)
                  : Matrix4.rotationY(math.pi),
              child: Image.asset(
                Images.activityDirection,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _SuggestionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SuggestionChip({required this.icon, required this.label});
 
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
 