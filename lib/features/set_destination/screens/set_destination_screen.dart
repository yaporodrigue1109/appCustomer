
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/ride_category.dart';
import 'package:ride_sharing_user_app/features/set_destination/widget/pick_location_widget.dart';
import 'package:ride_sharing_user_app/features/set_destination/widget/pickup_time_date_widget.dart';
import 'package:ride_sharing_user_app/features/set_destination/widget/process_button_widget.dart';
import 'package:ride_sharing_user_app/features/set_destination/widget/reservation_note_widget.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/categoty_model.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_my_address.dart';


class SetDestinationScreen extends StatefulWidget {
  final Address? address;
  final String? searchText;
  final RideType rideType;

  const SetDestinationScreen({
    super.key,
    this.address,
    this.searchText,
    this.rideType = RideType.regularRide,
  });

  @override
  State<SetDestinationScreen> createState() => _SetDestinationScreenState();
}

class _SetDestinationScreenState extends State<SetDestinationScreen> {
  late FocusNode pickLocationFocus;
  late FocusNode destinationLocationFocus;
  late FocusNode extraOneFocus;
  late FocusNode extraTwoFocus;
  late FocusNode extraThreeFocus;

  ScrollController scrollController = ScrollController();
  double dialogTopPosition = 0;
  double bottomWhiteSpace = 0;
  var keyboardVisibilityController = KeyboardVisibilityController();
  late StreamSubscription<bool> keyboardSubscription;
  final GlobalKey _key = GlobalKey();
  bool _isInitialized = false;

  Timer? _debounceTimer;

  bool _isSearchTriggered = false;

  bool _pickupSelected = false;
  bool _destinationSelected = false;
  
  bool _shouldShowRideForOtherPrompt = false;
  bool _isAutoSearchEnabled = true;

  LocationType? _lastActiveFocus;


  @override
  void initState() {
    super.initState();

    pickLocationFocus = FocusNode();
    destinationLocationFocus = FocusNode();
    extraOneFocus = FocusNode();
    extraTwoFocus = FocusNode();
    extraThreeFocus = FocusNode();

    _setupAllFocusListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LocationController>().resetPromptState();
      _initializeScreen();
      Get.find<LocationController>().resetRideForOther();
      Get.find<RideController>().clearBeneficiaryInfo();
      Get.find<LocationController>().startAutoLocationUpdate();
      _setInitialPickupLocation();
      _setupAddressListeners();
      
    });

    Get.find<RideController>().setRideType(widget.rideType);
    Get.find<LocationController>().initAddLocationData();
    Get.find<LocationController>().initTextControllers();
    Get.find<RideController>().clearExtraRoute();
    Get.find<MapController>().initializeData();
    Get.find<RideController>().initData();
    Get.find<ParcelController>().updatePaymentPerson(false, notify: false);

    if (widget.address != null) {
      Get.find<LocationController>().setDestination(widget.address);
    }
    if (widget.searchText != null) {
      Get.find<LocationController>()
          .setDestination(Address(address: widget.searchText));
      Future.delayed(const Duration(seconds: 1)).then((_) {
        Get.find<LocationController>().searchLocation(
          Get.context!,
          widget.searchText ?? '',
          type: LocationType.to,
        );
      });
    }

    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        bottomWhiteSpace = 0;
      }
    });
    
    _isAutoSearchEnabled = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
  Get.find<LocationController>().setSearchResultShowHide(show: false);
});
  }

  void _setupAllFocusListeners() {
    pickLocationFocus.addListener(() {
      if (pickLocationFocus.hasFocus) {
         _lastActiveFocus = LocationType.from;
        _clearFieldIfPrefilled(LocationType.from);
      }
    });
    destinationLocationFocus.addListener(() {
      if (destinationLocationFocus.hasFocus) {
        _lastActiveFocus = LocationType.to;
        _clearFieldIfPrefilled(LocationType.to);
      }
    });
    extraOneFocus.addListener(() {
      if (extraOneFocus.hasFocus) {
         _lastActiveFocus = LocationType.extraOne;
        _clearFieldIfPrefilled(LocationType.extraOne);
      }
    });
    extraTwoFocus.addListener(() {
      if (extraTwoFocus.hasFocus) {
          _lastActiveFocus = LocationType.extraTwo;
        _clearFieldIfPrefilled(LocationType.extraTwo);
      }
    });
    extraThreeFocus.addListener(() {
      if (extraThreeFocus.hasFocus) {
        _lastActiveFocus = LocationType.extraThree;
        _clearFieldIfPrefilled(LocationType.extraThree);
      }
    });
  }

  void _clearFieldIfPrefilled(LocationType type) {
    final locationController = Get.find<LocationController>();
    switch (type) {
      case LocationType.from:
        if (locationController.pickupLocationController.text.isNotEmpty) {
          locationController.pickupLocationController.clear();
          locationController.fromAddress = null;
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
      default:
        break;
    }
  }
 
  void _setupAddressListeners() {
    final locationController = Get.find<LocationController>();

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      bool hasValidPickup = locationController.fromAddress != null &&
          locationController.fromAddress!.address != null &&
          locationController.fromAddress!.address!.isNotEmpty;

      bool hasValidDestination = locationController.toAddress != null &&
          locationController.toAddress!.address != null &&
          locationController.toAddress!.address!.isNotEmpty;

      if (hasValidPickup && hasValidDestination) {
        timer.cancel();
      }
    });
  }

  void _checkAndTriggerSearch() {
    final lc = Get.find<LocationController>();
    
    bool hasValidPickup = lc.fromAddress != null &&
        lc.fromAddress!.address != null &&
        lc.fromAddress!.address!.isNotEmpty;
    
    bool hasValidDestination = lc.toAddress != null &&
        lc.toAddress!.address != null &&
        lc.toAddress!.address!.isNotEmpty;
    
    bool allStopsFilled = _areAllActiveStopsFilled(lc);
    
    if (!hasValidPickup || !hasValidDestination || !allStopsFilled ||
        !_pickupSelected || !_destinationSelected) {
      _isSearchTriggered = false;
      _shouldShowRideForOtherPrompt = false;
      _isAutoSearchEnabled = true;
      return;
    }
    
    _checkAndUpdateRideForOtherPrompt(lc);
    
    bool isPickupModified = lc.isPickupModifiedFromInitial();
    
    if (!isPickupModified && !lc.isRideForOther && !_shouldShowRideForOtherPrompt && _isAutoSearchEnabled) {
      _autoSearchRide();
    }
  }

  bool _areAllActiveStopsFilled(LocationController lc) {
    if (lc.extraOneRoute) {
      if (lc.extraRouteAddress == null ||
          lc.extraRouteOneController.text.trim().isEmpty) return false;
    }
    if (lc.extraTwoRoute) {
      if (lc.extraRouteTwoAddress == null ||
          lc.extraRouteTwoController.text.trim().isEmpty) return false;
    }
    if (lc.extraThreeRoute) {
      if (lc.extraRouteThreeAddress == null ||
          lc.extraRouteThreeController.text.trim().isEmpty) return false;
    }
    return true;
  }

  void _checkAndUpdateRideForOtherPrompt(LocationController lc) {
    if (lc.isRideForOther) {
      _shouldShowRideForOtherPrompt = false;
      _isAutoSearchEnabled = false;
      setState(() {});
      return;
    }
    
    if (lc.dontAskAgain) {
      _shouldShowRideForOtherPrompt = false;
      setState(() {});
      return;
    }
    
    if (lc.hasShownRideForOtherPrompt) {
      _shouldShowRideForOtherPrompt = false;
      setState(() {});
      return;
    }
    
    bool isPickupModified = lc.isPickupModifiedFromInitial();
    
    if (isPickupModified) {
      _shouldShowRideForOtherPrompt = true;
      _isAutoSearchEnabled = false;
      FocusScope.of(context).unfocus();
      setState(() {});
    } else {
      _shouldShowRideForOtherPrompt = false;
      setState(() {});
    }
  }

  Future<void> _autoSearchRide() async {
    if (_isSearchTriggered) return;
    if (!_isAutoSearchEnabled) return;
    
    final locationController = Get.find<LocationController>();
    final rideController = Get.find<RideController>();
    final configController = Get.find<ConfigController>();
    
    bool hasValidPickup = locationController.fromAddress != null &&
        locationController.fromAddress!.address != null &&
        locationController.fromAddress!.address!.isNotEmpty;
    
    bool hasValidDestination = locationController.toAddress != null &&
        locationController.toAddress!.address != null &&
        locationController.toAddress!.address!.isNotEmpty;
    
    bool isPickupModified = locationController.isPickupModifiedFromInitial();
    
    if (isPickupModified || locationController.isRideForOther || _shouldShowRideForOtherPrompt) {
      return;
    }
    
    if (!hasValidPickup || !hasValidDestination) return;
    
    if (configController.config!.maintenanceMode != null &&
        configController.config!.maintenanceMode!.maintenanceStatus == 1 &&
        configController.config!.maintenanceMode!.selectedMaintenanceSystem!
            .userApp == 1) {
      showCustomSnackBar('maintenance_mode_on_for_ride'.tr, isError: true);
      return;
    }
    
    if (rideController.loading) return;
    
    _isSearchTriggered = true;
    
    var response = await rideController.getEstimatedFare(false);
    
    if (response.statusCode == 200) {
         await _saveRouteAddresses();
      await Get.to(() => MapScreen(
            fromScreen: MapScreenType.ride,
            isShowCurrentPosition: false,
            showRideForOtherPrompt: false,
          ));
      
      _isSearchTriggered = false;
      rideController.updateRideCurrentState(RideState.initial);
    } else {
      _isSearchTriggered = false;
    }
  }

  Future<void> _searchRideManually() async {
    if (_isSearchTriggered) return;
    
    final locationController = Get.find<LocationController>();
    final rideController = Get.find<RideController>();
    final configController = Get.find<ConfigController>();
    
    if (configController.config!.maintenanceMode != null &&
        configController.config!.maintenanceMode!.maintenanceStatus == 1 &&
        configController.config!.maintenanceMode!.selectedMaintenanceSystem!
            .userApp == 1) {
      showCustomSnackBar('maintenance_mode_on_for_ride'.tr, isError: true);
      return;
    }
    
    if (rideController.loading) return;
    
    _isSearchTriggered = true;
    
    var response = await rideController.getEstimatedFare(false);
    
    if (response.statusCode == 200) {
          await _saveRouteAddresses();
      bool shouldShowPrompt = _shouldShowRideForOtherPrompt;
      
      await Get.to(() => MapScreen(
            fromScreen: MapScreenType.ride,
            isShowCurrentPosition: false,
            showRideForOtherPrompt: shouldShowPrompt,
          ));
      
      _isSearchTriggered = false;
      
      rideController.updateRideCurrentState(RideState.initial);
    } else {
      _isSearchTriggered = false;
    }
  }

  Future<void> _setInitialPickupLocation() async {
    try {
      final locationController = Get.find<LocationController>();

      if (locationController.position.latitude != 0 &&
          locationController.position.longitude != 0) {
        String address = await locationController.getAddressFromGeocode(LatLng(
          locationController.position.latitude,
          locationController.position.longitude,
        ));

        Address currentAddress = Address(
          latitude: locationController.position.latitude,
          longitude: locationController.position.longitude,
          address: address,
        );

        locationController.setOriginalPickupAddress(currentAddress);
        locationController.setPickUp(currentAddress);
        locationController.hasShownRideForOtherPrompt = false;
        locationController.update();
        _pickupSelected = true;
      }
    } catch (e) {
      print("❌ Erreur: $e");
    }
  }

  void _initializeScreen() {
    if (_isInitialized) return;

    try {
      final rideController = Get.find<RideController>();
      final categoryController = Get.find<CategoryController>();

      if (widget.rideType == RideType.regularRide) {
        if (categoryController.categoryList != null &&
            categoryController.categoryList!.isNotEmpty) {
          if (rideController.rideCategoryIndex >=
              categoryController.categoryList!.length) {
            rideController.setRideCategoryIndex(0);
          }
        }
      }

      _isInitialized = true;
      rideController.update();
    } catch (e) {
      print("❌ Erreur: $e");
      Future.delayed(const Duration(milliseconds: 500), () {
        _initializeScreen();
      });
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
    pickLocationFocus.dispose();
    destinationLocationFocus.dispose();
    extraOneFocus.dispose();
    extraTwoFocus.dispose();
    extraThreeFocus.dispose();
    _debounceTimer?.cancel();
    Get.find<LocationController>().stopAutoLocationUpdate();
    keyboardSubscription.cancel();
    super.dispose();
  }

  Widget _buildEnhancedLocationIndicator(
      LocationController locationController) {
    bool isAutoTracking = !locationController.userModifiedManually;

    return Container(
      margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isAutoTracking
            ? Colors.blue.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAutoTracking) ...[
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Auto',
              style: textRegular.copyWith(fontSize: 8, color: Colors.blue),
            ),
          ] else ...[
            Icon(Icons.edit_location, color: Colors.orange, size: 10),
            const SizedBox(width: 4),
            Text(
              'Manuel',
              style: textRegular.copyWith(fontSize: 8, color: Colors.orange),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoTrackingButton(LocationController locationController) {
    if (!locationController.userModifiedManually ||
        locationController.isRideForOther) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              await locationController.resetToCurrentLocation();
              _pickupSelected = true;
              _shouldShowRideForOtherPrompt = false;
              _isAutoSearchEnabled = true;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Position réinitialisée à votre position actuelle'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeExtraSmall,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(Dimensions.paddingSizeSmall),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.my_location, color: Colors.blue, size: 16),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    'Utiliser ma position actuelle',
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideForOtherPrompt(LocationController locationController) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(Dimensions.paddingSizeSmall),
                ),
                child: Icon(
                  Icons.help_outline,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Text(
                  'Cette course est pour vous ?',
                  style: textSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            'Vous avez modifié le point de départ à plus de 100 mètres de votre position actuelle. Souhaitez-vous commander pour quelqu\'un d\'autre ?',
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    locationController.hasShownRideForOtherPrompt = true;
                    _shouldShowRideForOtherPrompt = false;
                    _isAutoSearchEnabled = true;
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Course pour vous-même'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          BorderRadius.circular(Dimensions.paddingSizeSmall),
                    ),
                    child: Center(
                      child: Text(
                        'Pour moi',
                        style: textMedium.copyWith(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: InkWell(
                  onTap: () {
                    locationController.setRideForOther(true);
                    _shouldShowRideForOtherPrompt = false;
                    _isAutoSearchEnabled = false;
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.paddingSizeSmall),
                    ),
                    child: Center(
                      child: Text(
                        'Pour quelqu\'un d\'autre',
                        style: textMedium.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  locationController.setDontAskAgain(true);
                  _shouldShowRideForOtherPrompt = false;
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Vous ne serez plus averti'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.grey,
                    ),
                  );
                },
                child: Text(
                  'Ne plus me demander',
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              TextButton(
                onPressed: () {
                  locationController.hasShownRideForOtherPrompt = true;
                  _shouldShowRideForOtherPrompt = false;
                  setState(() {});
                },
                child: Text(
                  'Fermer',
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleContactSelected(contacts.Contact contact) {
  final locationController = Get.find<LocationController>();
  
  if (contact.phones.isNotEmpty) {
    String phone = contact.phones.first.number;
    locationController.setBeneficiaryPhone(phone);
  }
  
  if (contact.displayName != null && contact.displayName!.isNotEmpty) {
    locationController.setBeneficiaryName(contact.displayName!);
  } else {
    locationController.setBeneficiaryName('');
  }
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact sélectionné: ${contact.displayName ?? 'Sans nom'}'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }
}

  void _onSuggestionSelected(LocationType type) {
    if (type == LocationType.from) {
      _pickupSelected = true;
      _shouldShowRideForOtherPrompt = false;
      _isAutoSearchEnabled = true;
    } else if (type == LocationType.to) {
      _destinationSelected = true;
    }
    _checkAndTriggerSearch();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GetBuilder<RideController>(builder: (rideController) {
          return BodyWidget(
            appBar: AppBarWidget(
              title: rideController.rideType == RideType.scheduleRide
                  ? 'schedule_trip_setup'.tr
                  : 'trip_setup'.tr,
              centerTitle: true,
              onBackPressed: () {
                if (Navigator.canPop(context)) {
                  Get.back();
                } else {
                  Get.offAll(() => const DashboardScreen());
                }
              },
            ),
            body: GetBuilder<LocationController>(builder: (locationController) {
              bool hasValidRoute = locationController.fromAddress != null &&
                  locationController.toAddress != null;
              
              bool showRideForOtherPrompt = hasValidRoute &&
                  _shouldShowRideForOtherPrompt &&
                  !locationController.isRideForOther &&
                  !locationController.dontAskAgain &&
                  !locationController.hasShownRideForOtherPrompt;

              return Stack(clipBehavior: Clip.none, children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeDefault,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            if (showRideForOtherPrompt)
                              _buildRideForOtherPrompt(locationController),

                            if (showRideForOtherPrompt)
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                            if (locationController.isRideForOther)
                              _RideForOtherWidget(
                                onContactSelected: (contact) {
                                  _handleContactSelected(contact);
                                },
                              ),

                            if (locationController.isRideForOther)
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                            const SizedBox(height: Dimensions.paddingSizeSmall),

                          //  _buildAutoTrackingButton(locationController),  // c'est ca qui etait Utiliser ma position actuelle

                          Row(
                              children: [
                                Text('set_your_location'.tr, style: textSemiBold),
                                _buildEnhancedLocationIndicator(locationController),
                                const Spacer(),
                                // ✅ Bouton icône remplace le bloc séparé
                                if (locationController.userModifiedManually && !locationController.isRideForOther)
                                  InkWell(
                                    onTap: () async {
                                      await locationController.resetToCurrentLocation();
                                      _pickupSelected = true;
                                      _shouldShowRideForOtherPrompt = false;
                                      _isAutoSearchEnabled = true;
                                      setState(() {});
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                      ),
                                      child: const Icon(
                                        Icons.my_location,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .hintColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeSmall),
                              ),
                              child: Column(children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _LocationFromToWidget(),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: Dimensions.paddingSizeDefault,
                                          right: Dimensions.paddingSizeDefault,
                                          bottom: Dimensions.paddingSizeDefault,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            PickLocationWidget(
                                              locationType: LocationType.from,
                                              rideDetails:
                                                  rideController.rideDetails,
                                              focusNode: pickLocationFocus,
                                              textEditingController:
                                                  locationController
                                                      .pickupLocationController,
                                              isShowCrossButton: false,
                                              textFieldHint: 'pick_location'.tr,
                                              locationIconTap: () {
                                                RouteHelper
                                                    .goPageAndHideTextField(
                                                  context,
                                                  PickMapScreen(
                                                    type: LocationType.from,
                                                    address: locationController
                                                        .fromAddress,
                                                  ),
                                                );
                                              },
                                              textFieldTap: () {
                                                setScrollAndDialogPosition(
                                                    LocationType.from,
                                                    locationController);
                                              },
                                              onSuggestionSelected: () {
                                                _onSuggestionSelected(LocationType.from);
                                              },
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 2.0),
                                              child: Text(
                                                'to'.tr,
                                                style: textRegular.copyWith(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                ),
                                              ),
                                            ),

                                            _buildDraggableStopsAndDestinationSection(
                                                locationController,
                                                rideController),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'you_can_add_multiple_route_to'.tr,
                                          style: textRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color!
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),

                      const SizedBox(height: Dimensions.paddingSizeDefault),
                       // const HomeMyAddress(addressPage: AddressPage.home),
                  HomeMyAddress(
  onAddressSelected: (address) {
    final loc = Get.find<LocationController>();

    // ✅ Utiliser le dernier focus mémorisé (le focus est déjà perdu au moment du tap)
    switch (_lastActiveFocus) {
      case LocationType.from:
        loc.setPickUp(address);
        loc.pickupLocationController.text = address.address ?? '';
        _pickupSelected = true;
        _shouldShowRideForOtherPrompt = false;
        _isAutoSearchEnabled = true;
        break;
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
      default:
        loc.setDestination(address);
        loc.destinationLocationController.text = address.address ?? '';
        _destinationSelected = true;
        break;
    }

    loc.setSearchResultShowHide(show: false);
    loc.update();
    FocusScope.of(context).unfocus();
    setState(() {});
    _checkAndTriggerSearch();
  },
),

                            if (rideController.rideType == RideType.scheduleRide)
                              ReservationNoteWidget(globalKey: _key),
                          ],
                        ),
                      ),
                    ),

                    // if (locationController.resultShow && 
                    //     locationController.predictionList?.data?.suggestions != null &&
                    //     locationController.predictionList!.data!.suggestions!.isNotEmpty)
                    if (locationController.resultShow && 
                        locationController.predictionList?.data?.suggestions != null &&
                        locationController.predictionList!.data!.suggestions!.isNotEmpty &&
                        (pickLocationFocus.hasFocus || 
                        destinationLocationFocus.hasFocus || 
                        extraOneFocus.hasFocus || 
                        extraTwoFocus.hasFocus || 
                        extraThreeFocus.hasFocus))
                      Container(
                        height: MediaQuery.of(context).size.height * 0.6,
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
                            Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                              child: Row(
                                children: [
                                  Text(
                                    'Indiquer votre itinéraire',
                                    style: textBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      locationController.setSearchResultShowHide(show: false);
                                    },
                                    icon: const Icon(Icons.close),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: locationController
                                    .predictionList!.data!.suggestions!.length,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  final suggestion = locationController
                                      .predictionList!.data!.suggestions![index];
                                  final prediction = suggestion.placePrediction;
                                  
                                  if (prediction == null) return const SizedBox.shrink();

                                  return InkWell(
                                    onTap: () {
                                      Get.find<LocationController>().setLocation(
                                        fromSearch: true,
                                        prediction.placeId ?? '',
                                        prediction.text?.text ?? '',
                                        null,
                                        type: locationController.locationType,
                                      ).then((_) {
                                        if (locationController.locationType ==
                                            LocationType.from) {
                                          _onSuggestionSelected(LocationType.from);
                                        } else if (locationController.locationType ==
                                            LocationType.to) {
                                          _onSuggestionSelected(LocationType.to);
                                        }
                                      });
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
                                          Container(
                                            margin: const EdgeInsets.only(top: 2),
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
                                                // Ligne principale : nom du lieu
                                                // (ex: "Route du Zoo")
                                                Text(
                                                  prediction.structuredFormat
                                                          ?.mainText?.text ??
                                                      prediction.text?.text ??
                                                      '',
                                                  style: textBold.copyWith(
                                                    fontSize: Dimensions.fontSizeDefault,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                // Ligne secondaire : localisation
                                                // (ex: "Abidjan, Côte d'Ivoire")
                                                if (prediction.structuredFormat
                                                        ?.secondaryText?.text !=
                                                    null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                      top: 2,
                                                    ),
                                                    child: Text(
                                                      prediction.structuredFormat!
                                                          .secondaryText!.text!,
                                                      style: textBold.copyWith(
                                                        fontSize: Dimensions.fontSizeSmall,
                                                        color: Colors.grey[700],
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                // Chips distance / durée
                                                if (suggestion.distanceText != null || suggestion.durationText != null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 5),
                                                    child: Row(
                                                      children: [
                                                        if (suggestion.distanceText != null)
                                                          _InfoChip(
                                                            icon: Icons.straighten,
                                                            label: suggestion.distanceText!,
                                                          ),
                                                        if (suggestion.distanceText != null && suggestion.durationText != null)
                                                          const SizedBox(width: 6),
                                                        if (suggestion.durationText != null)
                                                          _InfoChip(
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
                  ],
                ),
              ]);
            }),
          );
        }),
        bottomNavigationBar: ProcessButtonWidget(
          pickLocationFocus: pickLocationFocus,
          destinationLocationFocus: destinationLocationFocus,
          onSearchPressed: _shouldShowRideForOtherPrompt || 
                           (Get.find<LocationController>().isRideForOther)
              ? () async {
                  await _searchRideManually();
                }
              : null,
        ),
      ),
    );
  }
  

  Widget _buildDraggableStopsAndDestinationSection(
      LocationController locationController, RideController rideController) {
    final items = _getReorderableItems(locationController);

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
        final isDestination = item['isDestination'] as bool;

        FocusNode? focusNode;
        switch (type) {
          case LocationType.extraOne:
            focusNode = extraOneFocus;
            break;
          case LocationType.extraTwo:
            focusNode = extraTwoFocus;
            break;
          case LocationType.extraThree:
            focusNode = extraThreeFocus;
            break;
          case LocationType.to:
            focusNode = destinationLocationFocus;
            break;
          default:
            focusNode = null;
        }

        return _DraggableStopItem(
          key: ValueKey('reorderable_${type.toString()}'),
          type: type,
          hint: hint,
          controller: controller,
          address: address,
          focusNode: focusNode,
          rideController: rideController,
          isDestination: isDestination,
          onDelete: isDestination
              ? null
              : () => _showDeleteDialog(type, locationController),
          onMapTap: () {
            RouteHelper.goPageAndHideTextField(
              context,
              PickMapScreen(type: type, address: address),
            );
          },
          onFieldTap: () =>
              setScrollAndDialogPosition(type, locationController),
          onSuggestionSelected: () {
            if (type == LocationType.to) {
              _onSuggestionSelected(LocationType.to);
            } else {
              _checkAndTriggerSearch();
            }
          },
          addStopButton: isDestination
              ? _buildAddStopButton(locationController)
              : null,
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;

        final currentItems = _getReorderableItems(locationController);
        final item = currentItems.removeAt(oldIndex);
        currentItems.insert(newIndex, item);

        _updateItemsWithNewOrder(currentItems, locationController);
      },
    );
  }

  List<Map<String, dynamic>> _getReorderableItems(
      LocationController locationController) {
    final List<Map<String, dynamic>> items = [];

    if (locationController.extraOneRoute) {
      items.add({
        'type': LocationType.extraOne,
        'hint': 'extra_route_one'.tr,
        'controller': locationController.extraRouteOneController,
        'address': locationController.extraRouteAddress,
        'isDestination': false,
      });
    }
    if (locationController.extraTwoRoute) {
      items.add({
        'type': LocationType.extraTwo,
        'hint': 'extra_route_two'.tr,
        'controller': locationController.extraRouteTwoController,
        'address': locationController.extraRouteTwoAddress,
        'isDestination': false,
      });
    }
    if (locationController.extraThreeRoute) {
      items.add({
        'type': LocationType.extraThree,
        'hint': 'extra_route_three'.tr,
        'controller': locationController.extraRouteThreeController,
        'address': locationController.extraRouteThreeAddress,
        'isDestination': false,
      });
    }

    items.add({
      'type': LocationType.to,
      'hint': 'destination'.tr,
      'controller': locationController.destinationLocationController,
      'address': locationController.toAddress,
      'isDestination': true,
    });

    return items;
  }

  bool _canAddMoreStops(LocationController locationController) {
    // return Get.find<ConfigController>().config!.addIntermediatePoint! &&
    //     !locationController.extraThreeRoute;
     return true;
  }

  int _getCurrentStopsCount(LocationController locationController) {
    int count = 0;
    if (locationController.extraOneRoute) count++;
    if (locationController.extraTwoRoute) count++;
    if (locationController.extraThreeRoute) count++;
    return count;
  }

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

  void _showDeleteDialog(
      LocationType type, LocationController locationController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('supprimer_arret'.tr),
          content: Text('voulez_vous_supprimer_cet_arret'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('annuler'.tr),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _removeStop(type, locationController);
              },
              child:
                  Text('supprimer'.tr, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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

  void _updateItemsWithNewOrder(
      List<Map<String, dynamic>> items,
      LocationController locationController) {

    final stops = items.where((i) => i['isDestination'] == false).toList();
    final destinationItems = items.where((i) => i['isDestination'] == true).toList();

    final List<String> stopTexts =
        stops.map((r) => (r['controller'] as TextEditingController).text).toList();
    final List<Address?> stopAddresses =
        stops.map((r) => r['address'] as Address?).toList();

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
    
    _checkAndTriggerSearch();
    setState(() {});
  }

  void setScrollAndDialogPosition(
      LocationType locationType, LocationController locationController) {
    scrollController
        .jumpTo(MediaQuery.of(context).size.height + Get.height * 0.3);

    bottomWhiteSpace =
        Get.find<RideController>().rideType == RideType.scheduleRide
            ? (Get.height * 0.4 -
                (_key.currentContext?.size?.height ?? 0))
            : Get.height * 0.4;

    setState(() {});
  }
}

class _DraggableStopItem extends StatelessWidget {
  final LocationType type;
  final String hint;
  final TextEditingController controller;
  final Address? address;
  final FocusNode? focusNode;
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
          ReorderableDragStartListener(
            index: _indexForType(type),
             child: const SizedBox.shrink(),
          ),

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

  int _indexForType(LocationType type) {
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



class _RideForOtherWidget extends StatefulWidget {
  final Function(contacts.Contact)? onContactSelected;
  
  const _RideForOtherWidget({this.onContactSelected});

  @override
  State<_RideForOtherWidget> createState() => _RideForOtherWidgetState();
}

class _RideForOtherWidgetState extends State<_RideForOtherWidget> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  bool _saveContact = false;
  bool _isLoadingContacts = false;
  
  // Cache pour les contacts
  List<contacts.Contact> _cachedContacts = [];
  bool _hasLoadedContacts = false;

  @override
  void initState() {
    super.initState();
    final locationController = Get.find<LocationController>();
    if (locationController.isRideForOther) {
      _phoneController.text = locationController.beneficiaryPhone;
      _nameController.text = locationController.beneficiaryName ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(
      builder: (locationController) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius:
                BorderRadius.circular(Dimensions.paddingSizeDefault),
            border: Border.all(
              color: locationController.isRideForOther
                  ? Theme.of(context).primaryColor.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: locationController.isRideForOther
                            ? Theme.of(context)
                                .primaryColor
                                .withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            Dimensions.paddingSizeSmall),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: locationController.isRideForOther
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cette course est pour vous ou pour quelqu\'un d\'autre ?',
                            style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall, 
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            locationController.isRideForOther
                                ? 'Pour quelqu\'un d\'autre'
                                : 'Pour moi-même',
                            style: textSemiBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: locationController.isRideForOther
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: locationController.isRideForOther,
                      onChanged: (value) {
                        _toggleRideForOther(locationController,
                            value: value);
                      },
                      activeColor: Theme.of(context).primaryColor,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              if (locationController.isRideForOther) ...[
                Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault),
                ),
                Padding(
                  padding:
                      const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nom du destinataire',
                        style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall),
                      ),
                      const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall),
                      TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Ex: Jean Dupont',
                          prefixIcon: Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                            size: 18,
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .hintColor
                              .withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                Dimensions.paddingSizeSmall),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal:
                                Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                        ),
                        onChanged: (value) {
                          locationController
                              .setBeneficiaryName(value);
                        },
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        'Numéro du destinataire',
                        style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall),
                      ),
                      const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              focusNode: _phoneFocusNode,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Ex: xx xx xx xx xx',
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: Theme.of(context).primaryColor,
                                  size: 18,
                                ),
                                filled: true,
                                fillColor: Theme.of(context)
                                    .hintColor
                                    .withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.paddingSizeSmall),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal:
                                      Dimensions.paddingSizeDefault,
                                  vertical: Dimensions.paddingSizeSmall,
                                ),
                              ),
                              onChanged: (value) {
                                locationController
                                    .setBeneficiaryPhone(value);
                              },
                            ),
                          ),
                          const SizedBox(
                              width: Dimensions.paddingSizeSmall),
                          InkWell(
                            onTap: () async {
                              await _requestPermissionAndShowContacts();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeSmall),
                              ),
                              child: _isLoadingContacts
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  : Icon(
                                      Icons.contacts,
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: Dimensions.paddingSizeDefault,
                    right: Dimensions.paddingSizeDefault,
                    bottom: Dimensions.paddingSizeDefault,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _saveContact,
                          onChanged: (value) {
                            setState(() {
                              _saveContact = value ?? false;
                            });
                          },
                          activeColor: Theme.of(context).primaryColor,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(
                          width: Dimensions.paddingSizeExtraSmall),
                      Expanded(
                        child: Text(
                          'Sauvegarder ce contact',
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _requestPermissionAndShowContacts() async {
    setState(() {
      _isLoadingContacts = true;
    });
    
    try {
      final status = await perm.Permission.contacts.request();
      
      if (status == perm.PermissionStatus.granted) {
        await _showContactsDialog();
      } else {
        setState(() {
          _isLoadingContacts = false;
        });
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      setState(() {
        _isLoadingContacts = false;
      });
      print('Erreur lors de la demande de permission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la demande de permission'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission requise'),
          content: const Text(
            'Pour accéder à vos contacts, veuillez autoriser l\'application dans les paramètres de votre téléphone.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                perm.openAppSettings(); 
              },
              child: const Text('Ouvrir les paramètres'),
            ),
          ],
        );
      },
    );
  }

  // Version optimisée avec getAll()
  Future<void> _showContactsDialog() async {
    try {
      // Vérifier si les contacts sont déjà en cache
      if (!_hasLoadedContacts) {
        // Chargement rapide avec getAll()
     final contactsList = await contacts.FlutterContacts.getAll(
          properties: {
            contacts.ContactProperty.phone, // Charger les numéros
            contacts.ContactProperty.name, // Charger les noms
           
          },
          
        );
        
        // Filtrer les contacts qui ont au moins un numéro
        _cachedContacts = contactsList
            .where((contact) => contact.phones.isNotEmpty)
            .toList();
        
        _hasLoadedContacts = true;
      }
      
      setState(() {
        _isLoadingContacts = false;
      });
      
      if (_cachedContacts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aucun contact avec numéro trouvé'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      if (!mounted) return;
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              String searchQuery = '';
              List<contacts.Contact> filteredContacts = _cachedContacts;
              
              return Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Row(
                      children: [
                        Text(
                          'Choisir un contact',
                          style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge),
                        ),
                        const Spacer(),
                        Text(
                          '${_cachedContacts.length} contacts',
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    TextField(
                      autofocus: false,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                          if (searchQuery.isEmpty) {
                            filteredContacts = _cachedContacts;
                          } else {
                            filteredContacts = _cachedContacts.where((contact) {
                              bool nameMatches = contact.displayName != null &&
                                  contact.displayName!.toLowerCase().contains(searchQuery);
                              bool phoneMatches = contact.phones.any((phone) =>
                                  phone.number.toLowerCase().contains(searchQuery));
                              return nameMatches || phoneMatches;
                            }).toList();
                          }
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Rechercher un contact',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredContacts.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final contact = filteredContacts[index];
                          String phone = contact.phones.first.number;
                          String name = contact.displayName ?? 'Sans nom';
                          
                          return InkWell(
                            onTap: () {
                              _phoneController.text = phone;
                              _nameController.text = name;
                              
                              final locationController = Get.find<LocationController>();
                              locationController.setBeneficiaryPhone(phone);
                              locationController.setBeneficiaryName(name);
                              
                              if (widget.onContactSelected != null) {
                                widget.onContactSelected!(contact);
                              }
                              
                              Navigator.pop(context);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Contact sélectionné: $name'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeDefault,
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
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeDefault),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: textMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          phone,
                                          style: textRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey[400], 
                                    size: 20,
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
              );
            },
          );
        },
      );
    } catch (e) {
      setState(() {
        _isLoadingContacts = false;
      });
      print('Erreur lors de la récupération des contacts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la récupération des contacts'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleRideForOther(LocationController locationController,
      {required bool value}) {
    if (value) {
      locationController.setRideForOther(true);
      setState(() {});
    } else {
      _showConfirmationDialog(context, locationController);
    }
  }

  void _showConfirmationDialog(
      BuildContext context, LocationController locationController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
              'Voulez-vous vraiment commander pour vous-même ? Les informations du destinataire seront effacées.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                locationController.setRideForOther(false);
                _phoneController.clear();
                _nameController.clear();
                Navigator.pop(context);
              },
              child: const Text('Oui',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _phoneFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }
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