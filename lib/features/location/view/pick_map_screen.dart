
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/location/widget/location_search_dialog.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class PickMapScreen extends StatefulWidget {
  final LocationType type;
  final Address? address;
  final Function(Position position, String address)? onLocationPicked;
  
  const PickMapScreen({
    super.key, 
    this.onLocationPicked, 
    required this.type,
    this.address
  });

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  bool _isCameraMoving = false;
  bool _mapInitialized = false;
  bool _mapError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('🟢 PickMapScreen initState');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  // Future<void> _initializeLocation() async {
  //   final locationController = Get.find<LocationController>();
  //   print('📍 Position initiale: ${locationController.initialPosition}');
    
  //   if (locationController.initialPosition.latitude == 0) {
  //     print('⚠️ Position à 0, récupération...');
  //     await locationController.getCurrentLocation();
  //     setState(() {});
  //   }
  // }

  Future<void> _initializeLocation() async {
  final locationController = Get.find<LocationController>();
  
  if (locationController.position.latitude == 0) {
    await locationController.getCurrentLocation();
  }
  
  // ✅ Centrer la carte sur la vraie position si la carte est déjà créée
  if (_mapController != null && locationController.position.latitude != 0) {
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            locationController.position.latitude,
            locationController.position.longitude,
          ),
          zoom: 16,
        ),
      ),
    );
  }
  
  if (mounted) setState(() {});
}

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

 

  LatLng _getInitialTarget(LocationController locationController) {
  // Si une adresse est passée en paramètre
  if (widget.address != null && 
      widget.address!.latitude != null && 
      widget.address!.latitude != 0) {
    return LatLng(widget.address!.latitude!, widget.address!.longitude!);
  }
  
  // ✅ Position GPS réelle en priorité
  if (locationController.position.latitude != 0) {
    return LatLng(
      locationController.position.latitude,
      locationController.position.longitude,
    );
  }
  
  // Position initiale sauvegardée
  if (locationController.initialPosition.latitude != 0) {
    return locationController.initialPosition;
  }
  
  // Fallback Abidjan
  return const LatLng(5.3599517, -4.0082563);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<LocationController>(builder: (locationController) {
          // Afficher les erreurs
          if (_mapError) {
            return _buildErrorWidget();
          }
          
          // Afficher le chargement
          if (!_mapInitialized && locationController.initialPosition.latitude == 0) {
            return _buildLoadingWidget();
          }

          final initialTarget = _getInitialTarget(locationController);
          
          return Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                
                target:initialTarget, // position actuelle programme
                  zoom: 16,
                ),
                minMaxZoomPreference: const MinMaxZoomPreference(0, 18),
                onMapCreated: (GoogleMapController controller) {
                  print('✅ GoogleMap créée avec succès');
                  setState(() {
                    _mapController = controller;
                    _mapInitialized = true;
                    _mapError = false;
                  });
                  
                  // Mettre à jour la position après la création
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_mapController != null) {
                      locationController.updatePosition(
                        _cameraPosition?.target ?? initialTarget,
                        false,
                        widget.type,
                      );
                    }
                  });
                },
                zoomControlsEnabled: false,
                compassEnabled: true,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                indoorViewEnabled: true,
                trafficEnabled: false,
                buildingsEnabled: true,
                onCameraMove: (CameraPosition position) {
                  _cameraPosition = position;
                },
                onCameraMoveStarted: () {
                  setState(() {
                    _isCameraMoving = true;
                  });
                  locationController.disableButton();
                },
                onCameraIdle: () {
                  setState(() {
                    _isCameraMoving = false;
                  });
                  try {
                    if (_cameraPosition != null) {
                      locationController.updatePosition(
                        _cameraPosition!.target,
                        false,
                        widget.type,
                      );
                    }
                  } catch (e) {
                    print('❌ Erreur onCameraIdle: $e');
                  }
                },
                // SUPPRIMEZ cette ligne qui cause l'erreur :
                // onMapError: (error) { ... }
                
                style: Get.isDarkMode
                    ? Get.find<ThemeController>().darkMap
                    : Get.find<ThemeController>().lightMap,
              ),

              // Marqueur central
              Center(
                child: locationController.loading
                    ? SpinKitCircle(
                        color: Theme.of(context).primaryColor, 
                        size: 40.0,
                      )
                    : Image.asset(
                        _isCameraMoving 
                            ? Images.pickLocationAnimatedIcon 
                            : Images.pickLocationIcon,
                        height: 44, 
                        width: 24,
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ Erreur chargement icône: $error');
                          return Icon(
                            Icons.location_on,
                            size: 44,
                            color: Theme.of(context).primaryColor,
                          );
                        },
                      ),
              ),

              // Barre de recherche
              Positioned(
                top: Dimensions.paddingSizeLarge,
                left: Dimensions.paddingSizeSmall,
                right: Dimensions.paddingSizeSmall,
                child: _buildSearchBar(locationController),
              ),

              // Bouton ma position
              Positioned(
                bottom: 80,
                right: Dimensions.paddingSizeSmall,
                child: FloatingActionButton(
                  hoverColor: Colors.transparent,
                  mini: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: () async {
                    print('📍 Bouton ma position pressé');
                    await locationController.getCurrentLocation();
                    if (_mapController != null && 
                        locationController.initialPosition.latitude != 0) {
                      _mapController!.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: locationController.initialPosition,
                            zoom: 16,
                          ),
                        ),
                      );
                    }
                  },
                  child: Icon(
                    Icons.my_location, 
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),

              // Bouton de validation
              Positioned(
                bottom: 30.0,
                left: Dimensions.paddingSizeSmall,
                right: Dimensions.paddingSizeSmall,
                child: _buildConfirmButton(locationController),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar(LocationController locationController) {
    return InkWell(
      onTap: () {
        if (_mapController != null) {
          Get.dialog(LocationSearchDialog(
            mapController: _mapController!,
            type: widget.type,
          ));
        } else {
          showCustomSnackBar('Carte pas encore initialisée');
        }
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              size: 25,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Expanded(
              child: Text(
                locationController.pickAddress.isNotEmpty
                    ? locationController.pickAddress
                    : 'Rechercher une adresse',
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: locationController.pickAddress.isNotEmpty
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context).disabledColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Icon(
              Icons.search,
              size: 25,
              color: Theme.of(context).disabledColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(LocationController locationController) {
    if (locationController.picking) {
      return Center(
        child: SpinKitCircle(
          color: Theme.of(context).primaryColor,
          size: 40.0,
        ),
      );
    }

    bool isEnabled = !locationController.buttonDisabled && 
                     !locationController.loading && 
                     locationController.inZone &&
                     locationController.pickPosition.latitude != 0;

    return ButtonWidget(
      fontSize: Dimensions.fontSizeDefault,
      buttonText: locationController.inZone
          ? 'pick_location'.tr
          : 'service_not_available_in_this_area'.tr,
      onPressed: isEnabled
          ? () {
              if (locationController.pickPosition.latitude != 0 && 
                  locationController.pickAddress.isNotEmpty) {
                if (widget.onLocationPicked != null) {
                  widget.onLocationPicked!(
                    locationController.pickPosition,
                    locationController.pickAddress,
                  );
                }
                Address address = Address(
                  latitude: locationController.pickPosition.latitude,
                  longitude: locationController.pickPosition.longitude,
                  addressLabel: 'others',
                  address: locationController.pickAddress,
                  zoneId: locationController.zoneID,
                );
                locationController.saveAddressAndNavigate(address, widget.type);
              } else {
                showCustomSnackBar('pick_an_address'.tr);
              }
            }
          : null,
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Initialisation de la carte...',
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              'Erreur de chargement de la carte',
              style: textBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _mapError = false;
                  _mapInitialized = false;
                });
                _initializeLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                  vertical: Dimensions.paddingSizeDefault,
                ),
              ),
              child: Text(
                'Réessayer',
                style: textRegular.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}