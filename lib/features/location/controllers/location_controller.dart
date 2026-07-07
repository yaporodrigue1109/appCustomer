
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/location/domain/models/place_details_model.dart';
import 'package:ride_sharing_user_app/features/location/domain/models/prediction_model.dart';
import 'package:ride_sharing_user_app/features/location/domain/models/zone_response.dart';
import 'package:ride_sharing_user_app/features/location/domain/services/location_service_interface.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_dialog_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LocationType{from, to, extraOne, extraTwo, extraThree, location, accessLocation, senderLocation, receiverLocation}

class LocationController extends GetxController implements GetxService {
  final LocationServiceInterface locationServiceInterface;
  LocationController({required this.locationServiceInterface});

  // Constantes
  static const double MODIFICATION_THRESHOLD_KM = 0.1; // 100 mètres
  static const String DONT_ASK_KEY = 'dont_ask_ride_for_other';
  static const Duration LOCATION_UPDATE_INTERVAL = Duration(seconds: 30);
  static const Duration USER_INACTIVITY_TIMEOUT = Duration(minutes: 5);

  Position _position = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1);
  Position _pickPosition = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1);
  Address? fromAddress;
  Address? toAddress;
  Address? extraRouteAddress;
  Address? extraRouteTwoAddress;
  Address? extraRouteThreeAddress;
  Address? parcelSenderAddress;
  Address? parcelReceiverAddress;
  bool _loading = false;
  String _address = '';
  String _pickAddress = '';
  List<AddressModel>? _addressList;
  bool _isLoading = false;
  bool _inZone = false;
  String? _zoneID;
  bool _buttonDisabled = true;
  bool _changeAddress = true;
  GoogleMapController? mapController;
  PredictionModel? _predictionList;
  bool _updateAddAddressData = true;
  LatLng _initialPosition = const LatLng(5.3694041, -3.9286325);
  bool addEntrance = false;
  int currentExtraRoute = 0;
  bool extraOneRoute = false;
  bool extraTwoRoute = false;
  bool extraThreeRoute = false;
  bool resultShow = false;
  bool picking = false;
  LocationType locationType = LocationType.from;
  Address? addAddress;
  
  // ✅ NOUVEAU : Propriétés séparées pour les suggestions d'adresses (expéditeur/destinataire)
  PredictionModel? _senderPredictionList;
  PredictionModel? _receiverPredictionList;
  bool _showSenderSuggestions = false;
  bool _showReceiverSuggestions = false;

  // GETTERS existants
  PredictionModel? get predictionList => _predictionList;
  bool get isLoading => _isLoading;
  bool get loading => _loading;
  Position get position => _position;
  Position get pickPosition => _pickPosition;
  String get address => _address;
  String get pickAddress => _pickAddress;
  List<AddressModel>? get addressList => _addressList;
  bool get inZone => _inZone;
  String? get zoneID => _zoneID;
  bool get buttonDisabled => _buttonDisabled;
  LatLng get initialPosition => _initialPosition;
  
  // ✅ NOUVEAUX GETTERS
  PredictionModel? get senderPredictionList => _senderPredictionList;
  PredictionModel? get receiverPredictionList => _receiverPredictionList;
  bool get showSenderSuggestions => _showSenderSuggestions;
  bool get showReceiverSuggestions => _showReceiverSuggestions;

  final TextEditingController locationController = TextEditingController();
  final TextEditingController entranceController = TextEditingController();
  final TextEditingController pickupLocationController = TextEditingController();
  final TextEditingController destinationLocationController = TextEditingController();
  final TextEditingController extraRouteOneController = TextEditingController();
  final TextEditingController extraRouteTwoController = TextEditingController();
  final TextEditingController extraRouteThreeController = TextEditingController();

  final FocusNode entranceNode = FocusNode();
  List<Address> _recentAddresses = [];

  List<Address> get recentAddresses => _recentAddresses;

  // VARIABLES POUR "COMMANDER POUR UN AUTRE"
  bool _isRideForOther = false;
  String _beneficiaryPhone = '';
  String _beneficiaryName = '';
  Address? _originalPickupAddress;
  bool _hasShownRideForOtherPrompt = false; // Pour éviter d'afficher plusieurs fois

  // VARIABLES POUR L'ACTUALISATION AUTOMATIQUE
  Timer? _locationUpdateTimer;
  bool _isAutoUpdating = false;
  Position? _lastKnownPosition;
  StreamSubscription? _locationSubscription;
  bool _userModifiedManually = false;
  
  // Timer pour l'inactivité utilisateur
  Timer? _userInactivityTimer;
  
  // SharedPreferences
  late SharedPreferences _prefs;

  // GETTERS POUR LES NOUVELLES VARIABLES
  bool get isRideForOther => _isRideForOther;
  String get beneficiaryPhone => _beneficiaryPhone;
  String get beneficiaryName => _beneficiaryName;
  Address? get originalPickupAddress => _originalPickupAddress;
  bool get isAutoUpdating => _isAutoUpdating;
  Position? get lastKnownPosition => _lastKnownPosition;
  bool get userModifiedManually => _userModifiedManually;
  bool get dontAskAgain => _prefs.getBool(DONT_ASK_KEY) ?? false;
  bool get hasShownRideForOtherPrompt => _hasShownRideForOtherPrompt;

  set hasShownRideForOtherPrompt(bool value) {
    _hasShownRideForOtherPrompt = value;
    update();
  }

  // ✅ MÉTHODE getPredictions (pour corriger l'erreur)
  PredictionModel? getPredictions(LocationType type) {
    switch(type) {
      case LocationType.senderLocation:
        return _senderPredictionList;
      case LocationType.receiverLocation:
        return _receiverPredictionList;
      default:
        return _predictionList;
    }
  }

  // ✅ MÉTHODE areSuggestionsVisible
  bool areSuggestionsVisible(LocationType type) {
    switch(type) {
      case LocationType.senderLocation:
        return _showSenderSuggestions;
      case LocationType.receiverLocation:
        return _showReceiverSuggestions;
      default:
        return resultShow;
    }
  }

  // ✅ MÉTHODE clearPredictions
  void clearPredictions({LocationType? type}) {
    if (type == null) {
      _senderPredictionList = null;
      _receiverPredictionList = null;
      _predictionList = null;
      _showSenderSuggestions = false;
      _showReceiverSuggestions = false;
      resultShow = false;
    } else {
      switch(type) {
        case LocationType.senderLocation:
          _senderPredictionList = null;
          _showSenderSuggestions = false;
          break;
        case LocationType.receiverLocation:
          _receiverPredictionList = null;
          _showReceiverSuggestions = false;
          break;
        default:
          _predictionList = null;
          resultShow = false;
      }
    }
    update();
  }

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    getCurrentLocation();
  }

  @override
  void onClose() {
    stopAutoLocationUpdate();
    _locationSubscription?.cancel();
    _userInactivityTimer?.cancel();
    super.onClose();
  }

  // Méthode pour enregistrer l'interaction utilisateur
  void onUserInteraction() {
    _resetUserInactivityTimer();
  }

  void _resetUserInactivityTimer() {
    _userInactivityTimer?.cancel();
    _userInactivityTimer = Timer(USER_INACTIVITY_TIMEOUT, () {
      // Après 5 minutes d'inactivité, réactiver le suivi automatique si approprié
      if (_userModifiedManually && !_isRideForOther) {
        print('📍 Inactivité détectée - Réactivation du suivi automatique');
        resetToCurrentLocation();
      }
    });
  }

  // Méthode pour définir la préférence "Ne plus me demander"
  void setDontAskAgain(bool value) {
    _prefs.setBool(DONT_ASK_KEY, value);
    // Réinitialiser le flag pour pouvoir réafficher plus tard si l'utilisateur change d'avis
    if (!value) {
      _hasShownRideForOtherPrompt = false;
    }
    update();
  }

  // Méthode pour réinitialiser le flag du prompt
  void resetRideForOtherPromptFlag() {
    _hasShownRideForOtherPrompt = true;
    update();
  }

  void initAddLocationData() {
    addEntrance = false;
    extraTwoRoute = false;
    extraOneRoute = false;
    extraThreeRoute = false;
    resultShow = false;
    currentExtraRoute = 0;
    _isLoading = false;
    _loading = false;
    _pickPosition = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1);
    _hasShownRideForOtherPrompt = false; // Réinitialiser à chaque nouvelle session
  }

  void initTextControllers() {
    locationController.clear();
    _pickAddress = '';
    pickupLocationController.text = '';
    destinationLocationController.text = '';
    extraRouteOneController.text = '';
    extraRouteTwoController.text = '';
    extraRouteThreeController.text = '';
    entranceController.text = '';
  }

  void initParcelData() {
    parcelSenderAddress = null;
    parcelReceiverAddress = null;
  }

  void setAddEntrance() {
    addEntrance = !addEntrance;
    update();
  }

  void setPickUp(Address? address) {
    pickupLocationController.text = address?.address ?? '';
    fromAddress = address;
    
    // Si c'est la première fois qu'on définit l'adresse (position actuelle)
    if (_originalPickupAddress == null && address != null) {
      setOriginalPickupAddress(address);
    }
    
    // Si l'adresse est modifiée manuellement et que ce n'est pas pour un autre
    if (!_isRideForOther && address != null) {
      _userModifiedManually = true;
      _logLocationState('Point de départ modifié manuellement');
      onUserInteraction();
    }
    
    update();
  }

  void setDestination(Address? address) {
    destinationLocationController.text = address?.address ?? '';
    toAddress = address;
    onUserInteraction();
  }

  void setExtraRoute({bool remove = false}) {
    if(remove){
      currentExtraRoute = currentExtraRoute - 1;
      if(currentExtraRoute == 1){
        extraTwoRoute = false;
        extraThreeRoute = false;
      }else{
        extraOneRoute = false;
      }
    }else{
      if(currentExtraRoute < 2){
        currentExtraRoute = currentExtraRoute + 1;

        if(currentExtraRoute == 1){
          extraOneRoute = true;
        }if(currentExtraRoute == 2){
          extraTwoRoute = true;
        }
        if(currentExtraRoute == 3){
          extraThreeRoute = true;
        }
      }
    }

    if (kDebugMode) {
      print('=======extra===>$currentExtraRoute');
    }
    onUserInteraction();
    update();
  }

  

Future<Address?> getCurrentLocation({bool isAnimate = true, GoogleMapController? mapController, LocationType type = LocationType.from}) async {
  bool isSuccess = await checkPermission(() {});
  Address? addressModel;
  if(isSuccess) {
    try {
      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }

      Position newLocalData = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        timeLimit: const Duration(seconds: 10),
      );
      
      print("📍 Position réelle obtenue: ${newLocalData.latitude}, ${newLocalData.longitude}");
      
      _position = newLocalData;
      _lastKnownPosition = newLocalData;
      _initialPosition = LatLng(_position.latitude, _position.longitude);

      // ✅ Mettre à jour la position par défaut dans MapController
      if (Get.isRegistered<MapController>()) {
        Get.find<MapController>().updateDefaultPosition(
          _position.latitude,
          _position.longitude,
        );
      }
      
      if(isAnimate && mapController != null) {
        await mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _initialPosition, zoom: 15)
          )
        );
      }
      
      if(type == LocationType.from){
        _pickPosition = Position(
            latitude: position.latitude, longitude: position.longitude, timestamp: DateTime.now(),
            heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1, altitudeAccuracy: 1, headingAccuracy: 1);
        ZoneResponseModel responseModel = await getZone(_position.latitude.toString(), _position.longitude.toString());
        String address = await initAddressAddressFromGeocode(_initialPosition);

        if(responseModel.isSuccess && responseModel.zoneId != null) {
          addressModel = Address(
            latitude: newLocalData.latitude, longitude: newLocalData.longitude,
            address: address, zoneId: responseModel.zoneId,
          );
          
          _originalPickupAddress = addressModel;
          _userModifiedManually = false;
          _hasShownRideForOtherPrompt = false;
        }
      }

      _locationSubscription = Geolocator.getPositionStream().listen((newLocalData) {
        if (mapController != null) {
          Get.find<MapController>().updateMarkerAndCircle(latLng: LatLng(newLocalData.latitude, newLocalData.longitude));
        }
      });
      
    } catch(e) {
      if (kDebugMode) {
        print("❌ Erreur de localisation: $e");
      }
      // Position de secours (Abidjan)
      _position = Position(
        latitude: 5.345317, 
        longitude: -4.024432, 
        timestamp: DateTime.now(),
        accuracy: 1, altitude: 1, heading: 1, speed: 1, 
        speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1
      );
      _initialPosition = LatLng(_position.latitude, _position.longitude);
      
      if (Get.isRegistered<MapController>()) {
        Get.find<MapController>().updateDefaultPosition(
          _position.latitude,
          _position.longitude,
        );
      }
    }

    update();
  }
  return addressModel;
}


  Future<LatLng?> getCurrentPosition({GoogleMapController? mapController}) async {
    bool isSuccess = await checkPermission(() {});
    LatLng? latLng;
    if(isSuccess) {
      try {
        Position newLocalData = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
        latLng = LatLng(newLocalData.latitude, newLocalData.longitude);
        _lastKnownPosition = newLocalData;
      }catch(e){
        if (kDebugMode) {
          print(e);
        }
      }

      if (mapController != null && latLng != null) {
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(latLng.latitude, latLng.longitude), zoom: 16),
        ));
      }

      update();
    }
    return latLng;
  }

  bool selectLocation = false;
  Future<ZoneResponseModel> getZone(String lat, String long) async {
    _isLoading = true;
    update();
    ZoneResponseModel responseModel;
    Response response = await locationServiceInterface.getZone(lat, long);
    if(response.statusCode == 200 && response.body['data'] != null && response.body['data']['id'] != null) {
      _zoneID = response.body['data']['id'].toString();
      _inZone = true;
      responseModel = ZoneResponseModel(true, '', _zoneID);
    }else {
      _inZone = false;
      responseModel = ZoneResponseModel(false, response.statusText, null);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future <void> saveUserAddress(Address? address) async {
    locationServiceInterface.saveUserAddress(address);
  }

  Address? getUserAddress() {
    Address? address;
    if(locationServiceInterface.getUserAddress() != null) {
      address = Address.fromJson(jsonDecode(locationServiceInterface.getUserAddress()!));
    }
    return address;
  }

  Future<String> initAddressAddressFromGeocode(LatLng latLng) async {
    Response response = await locationServiceInterface.getAddressFromGeocode(latLng);
    if(response.statusCode == 200) {
      _address = response.body['data']['results'][0]['formatted_address'].toString();
      pickupLocationController.text = _address;
      fromAddress = Address(latitude: latLng.latitude, longitude: latLng.longitude, address: _address);
      
      // Sauvegarder l'adresse originale lors de l'initialisation
      _originalPickupAddress = fromAddress;
      _userModifiedManually = false;
      _hasShownRideForOtherPrompt = false;
    }else {
      showCustomSnackBar(response.body['errors'][0]['message'] ?? response.bodyString);
    }
    update();
    return _address;
  }

  Future<String> getAddressFromGeocode(LatLng latLng) async {
    Response response = await locationServiceInterface.getAddressFromGeocode(latLng);
    if(response.statusCode == 200) {
      _address = response.body['data']['results'][0]['formatted_address'].toString();
    }else {
      showCustomSnackBar(response.body['errors'][0]['message'] ?? response.bodyString);
    }
    update();
    return _address;
  }

  // ✅ MODIFIER la méthode searchLocation
  Future<List<Suggestions>?> searchLocation(BuildContext context, String text, {LocationType type = LocationType.from, bool fromMap = false}) async {
    locationType = type;
    if(!fromMap) {
      update();
    }

    if(text.isNotEmpty) {
      if(!fromMap) {
        setSearchResultShowHide(show: true, type: type);
      }

      // Utiliser la position actuelle de l'utilisateur (Abidjan)
      String currentLat = _position.latitude.toString();
      String currentLng = _position.longitude.toString();
      
      // Si la position n'est pas disponible, utiliser Abidjan par défaut
      if (_position.latitude == 0 || _position.longitude == 0) {
        currentLat = '5.3556';
        currentLng = '-3.8731';
      }
      
      print('📍 Recherche autour de: $currentLat, $currentLng');
      
      Response response = await locationServiceInterface.searchLocation(
        text, 
        countryCode: 'CI',
        location: '$currentLat,$currentLng',
        radius: '50000',
      );
      
      if (response.statusCode == 200) {
        PredictionModel predictions = PredictionModel.fromJson(response.body);
        
           // Ajouter la distance calculée pour chaque suggestion
  
        // Stocker dans la liste appropriée selon le type
        switch(type) {
          case LocationType.senderLocation:
            _senderPredictionList = predictions;
            _showSenderSuggestions = true;
            break;
          case LocationType.receiverLocation:
            _receiverPredictionList = predictions;
            _showReceiverSuggestions = true;
            break;
          default:
            _predictionList = predictions;
            resultShow = true;
        }
        
        int resultCount = predictions.data?.suggestions?.length ?? 0;
        print('✅ $resultCount résultats trouvés en Côte d\'Ivoire');
        update();
      } else {
        print('❌ Erreur recherche: ${response.statusCode}');
      }
    } else {
      if(!fromMap) {
        setSearchResultShowHide(show: false, type: type);
      }
    }
    onUserInteraction();
    
    // Retourner les suggestions selon le type
    switch(type) {
      case LocationType.senderLocation:
        return _senderPredictionList?.data?.suggestions;
      case LocationType.receiverLocation:
        return _receiverPredictionList?.data?.suggestions;
      default:
        return _predictionList?.data?.suggestions;
    }
  }
 
  void updatePosition(LatLng? positionLatLng, bool fromAddressScreen, LocationType? type) async {
    if(_updateAddAddressData && positionLatLng != null) {
      _loading = true;
      update();
      try {
        if (fromAddressScreen) {
          type == LocationType.from ? fromAddress :
          type == LocationType.to ? toAddress :
          type == LocationType.extraOne ? extraRouteOneController.text :
          type == LocationType.extraTwo ? extraRouteTwoController.text :
          type == LocationType.extraThree ? extraRouteThreeController.text :
          _position = Position(
              latitude: positionLatLng.latitude, longitude: positionLatLng.longitude, timestamp: DateTime.now(),
              heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1,altitudeAccuracy: 1, headingAccuracy: 1
          );
        } else {
          _pickPosition = Position(
              latitude: positionLatLng.latitude, longitude: positionLatLng.longitude, timestamp: DateTime.now(),
              heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1,altitudeAccuracy: 1, headingAccuracy: 1
          );
        }
        ZoneResponseModel responseModel = await getZone(positionLatLng.latitude.toString(), positionLatLng.longitude.toString());
        if(responseModel.isSuccess) {
          _buttonDisabled = false;
        }
        if (_changeAddress) {
          String addressFromGeocode = await getAddressFromGeocode(LatLng(positionLatLng.latitude, positionLatLng.longitude));
          fromAddressScreen ? _address = addressFromGeocode : _pickAddress = addressFromGeocode;
        } else {
          _changeAddress = true;
        }
      } catch (e) {}
    }else {
      _updateAddAddressData = true;
    }
    _loading = false;
    update();
  }

  Future<void> saveAddressAndNavigate(Address address, LocationType type) async {
    picking = true;
    update();

    setSearchResultShowHide(show: false, type: type);
    if(type == LocationType.accessLocation) {
      await saveUserAddress(address);
      Get.find<CategoryController>().getCategoryList();
      Get.find<BottomMenuController>().navigateToDashboard();
    }else {
      Get.back();
      if(type == LocationType.from) {
        pickupLocationController.text = address.address!;
        fromAddress = address;
        _userModifiedManually = true;
        onUserInteraction();
      }else if(type == LocationType.to) {
        destinationLocationController.text = address.address!;
        toAddress = address;
        onUserInteraction();
      }else if(type == LocationType.extraOne) {
        extraRouteOneController.text = address.address!;
        extraRouteAddress = address;
        onUserInteraction();
      }else if(type == LocationType.extraTwo) {
        extraRouteTwoController.text = address.address!;
        extraRouteTwoAddress = address;
        onUserInteraction();
      }else if(type == LocationType.extraThree) {
        extraRouteThreeController.text = address.address!;
        extraRouteThreeAddress = address;
        onUserInteraction();
      }
      else if(type == LocationType.senderLocation) {
        Get.find<ParcelController>().senderAddressController.text = address.address!;
        parcelSenderAddress = address;
      }else if(type == LocationType.receiverLocation) {
        Get.find<ParcelController>().receiverAddressController.text = address.address!;
        parcelReceiverAddress = address;
      }else{
        addAddress = address;
        _pickAddress = address.address!;
        _pickPosition = Position(
            latitude: address.latitude!, longitude: address.longitude!,
            timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,altitudeAccuracy: 1, headingAccuracy: 1
        );
      }
    }
    picking = false;
    update();
  }

  void setSenderAddress(Address? address) {
    Get.find<ParcelController>().senderAddressController.text = address?.address ?? '';
    parcelSenderAddress = address;
    update();
  }

  void setReceiverAddress(Address? address) {
    Get.find<ParcelController>().receiverAddressController.text = address?.address ?? '';
    parcelReceiverAddress = address;
    update();
  }

  // ✅ MODIFIER setSearchResultShowHide
  void setSearchResultShowHide({bool show = false, LocationType? type}) {
    if (type == null) {
      // Comportement par défaut pour la rétrocompatibilité
      resultShow = show;
      _showSenderSuggestions = show;
      _showReceiverSuggestions = show;
    } else {
      switch(type) {
        case LocationType.senderLocation:
          _showSenderSuggestions = show;
          break;
        case LocationType.receiverLocation:
          _showReceiverSuggestions = show;
          break;
        default:
          resultShow = show;
      }
    }
    update();
  }

  bool selecting = false;
  
  // ✅ MODIFIER setLocation
  Future<Address?> setLocation(String placeID, String address, GoogleMapController? mapController, {LocationType type = LocationType.from, bool fromSearch = false}) async {
    _loading = true;
    
    // Cacher les suggestions selon le type
    setSearchResultShowHide(show: false, type: type);
    
    selecting = true;
    update();
    LatLng latLng = const LatLng(0, 0);
    Address? selectedAddress;
    Response response = await locationServiceInterface.getPlaceDetails(placeID);
    if(response.statusCode == 200) {
      PlaceDetailsModel placeDetails = PlaceDetailsModel.fromJson(response.body);
      latLng = LatLng(placeDetails.data?.location?.latitude ?? 0, placeDetails.data?.location?.longitude ?? 0);

      ZoneResponseModel zoneResponse = await getZone(latLng.latitude.toString(), latLng.longitude.toString());
      if(zoneResponse.zoneId != null) {
        // Effacer les prédictions selon le type
        if(type == LocationType.senderLocation) {
          _senderPredictionList = null;
        } else if(type == LocationType.receiverLocation) {
          _receiverPredictionList = null;
        } else {
          _predictionList = null;
        }
        
        if(fromSearch){
          switch(type) {
            case LocationType.from:
              fromAddress = Address(latitude: latLng.latitude, longitude: latLng.longitude, address: address);
              pickupLocationController.text = address;
              _userModifiedManually = true;
              onUserInteraction();
              break;
            case LocationType.to:
              toAddress = Address(latitude: latLng.latitude, longitude: latLng.longitude, address: address);
              destinationLocationController.text = address;
              onUserInteraction();
              break;
            case LocationType.extraOne:
              extraRouteAddress = Address(latitude: latLng.latitude, longitude: latLng.longitude, address: address);
              extraRouteOneController.text = address;
              onUserInteraction();
              break;
            case LocationType.extraTwo:
              extraRouteTwoAddress = Address(latitude: latLng.latitude, longitude: latLng.longitude, address: address);
              extraRouteTwoController.text = address;
              onUserInteraction();
              break;
            case LocationType.extraThree:
              extraRouteThreeAddress = Address(latitude: latLng.latitude, longitude: latLng.longitude, address: address);
              extraRouteThreeController.text = address;
              onUserInteraction();
              break;
            case LocationType.senderLocation:
              parcelSenderAddress = Address(latitude: latLng.latitude, longitude: latLng.longitude, address: address);
              Get.find<ParcelController>().senderAddressController.text = address;
              break;
            case LocationType.receiverLocation:
              parcelReceiverAddress = Address(latitude: latLng.latitude, longitude: latLng.longitude, address: address);
              Get.find<ParcelController>().receiverAddressController.text = address;
              break;
            default:
              break;
          }
        }

        _pickPosition = Position(
            latitude: latLng.latitude, longitude: latLng.longitude,
            timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1);
        _pickAddress = address;

        _changeAddress = false;
        if(mapController != null) {
          mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 16)));
        }
        selecting = false;
        _loading = false;
        update();
        selectedAddress = Address(
          latitude: pickPosition.latitude,
          longitude: pickPosition.longitude,
          addressLabel: 'others', address: pickAddress,
        );
      }else {
        selecting = false;
        showCustomSnackBar('service_not_available_in_this_area'.tr);
      }
    }
    selecting = false;
    return selectedAddress;
  }

  void disableButton() {
    _buttonDisabled = true;
    _inZone = true;
    update();
  }

  Future<bool> checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(ConfirmationDialogWidget(description: 'you_denied_location_permission'.tr, onYesPressed: () async {
        Get.back();
        await Geolocator.openAppSettings();
      }, icon: Images.logo), barrierDismissible: false);
    }else {
      onTap();
      return true;
    }
    return false;
  }

  void clearAddAddress(){
    addAddress = null;
  }

  // Méthode utilitaire pour calculer la distance
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Rayon de la Terre en kilomètres
    
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    
    double a = 
      math.sin(dLat/2) * math.sin(dLat/2) +
      math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) * 
      math.sin(dLon/2) * math.sin(dLon/2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
    double distance = earthRadius * c;
    
    return distance;
  }

  double _deg2rad(double deg) {
    return deg * (math.pi / 180);
  }

  // Méthode pour tester la recherche en Côte d'Ivoire
  Future<void> testSearchCoteDIvoire(String query) async {
    print('🧪 TEST RECHERCHE COTE D\'IVOIRE: "$query"');
    
    String location = '${_position.latitude},${_position.longitude}';
    if (_position.latitude == 0) {
      location = '5.3556,-3.8731';
    }
    
    Response response = await locationServiceInterface.searchLocation(
      query,
      countryCode: 'CI',
      location: location,
      radius: '50000',
    );
    
    if (response.statusCode == 200) {
      print('✅ TEST RÉUSSI!');
      var data = response.body['data'];
      if (data != null && data['suggestions'] != null) {
        List suggestions = data['suggestions'];
        print('📊 Nombre de résultats: ${suggestions.length}');
        
        for (int i = 0; i < suggestions.length && i < 5; i++) {
          var place = suggestions[i]['placePrediction'];
          if (place != null) {
            print('   ${i+1}. ${place['text']?['text']}');
          }
        }
      }
    } else {
      print('❌ TEST ÉCHOUÉ: ${response.statusCode}');
      print('📦 Réponse: ${response.body}');
    }
  }

  // MÉTHODE POUR DÉMARRER L'ACTUALISATION AUTOMATIQUE
  void startAutoLocationUpdate() {
    if (_isAutoUpdating) return;
    
    _isAutoUpdating = true;
    _updateCurrentLocationPeriodically();
    
    _locationUpdateTimer = Timer.periodic(LOCATION_UPDATE_INTERVAL, (timer) {
      _updateCurrentLocationPeriodically();
    });
    
    print("📍 Actualisation automatique démarrée");
    update();
  }

  // MÉTHODE POUR ARRÊTER L'ACTUALISATION AUTOMATIQUE
  void stopAutoLocationUpdate() {
    _isAutoUpdating = false;
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    print("📍 Actualisation automatique arrêtée");
    update();
  }

  // MÉTHODE POUR METTRE À JOUR LA POSITION PÉRIODIQUEMENT
  Future<void> _updateCurrentLocationPeriodically() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("📍 Service de localisation désactivé");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        print("📍 Permission refusée");
        return;
      }

      Position newPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      _lastKnownPosition = newPosition;
      _position = newPosition;
      _initialPosition = LatLng(newPosition.latitude, newPosition.longitude);
      
      await _updatePickupFromCurrentPosition(newPosition);
      
      print("📍 Position mise à jour: ${newPosition.latitude}, ${newPosition.longitude}");
      update();
      
    } catch (e) {
      print("📍 Erreur de mise à jour position: $e");
    }
  }

  // MÉTHODE POUR METTRE À JOUR LE POINT DE DÉPART
  Future<void> _updatePickupFromCurrentPosition(Position position) async {
    try {
      String address = await getAddressFromGeocode(
        LatLng(position.latitude, position.longitude)
      );
      
      bool hasUserModifiedManually = false;
      
      if (fromAddress != null && _originalPickupAddress != null) {
        double? currentLat = fromAddress!.latitude;
        double? currentLng = fromAddress!.longitude;
        double? originalLat = _originalPickupAddress!.latitude;
        double? originalLng = _originalPickupAddress!.longitude;
        
        if (currentLat != null && currentLng != null && 
            originalLat != null && originalLng != null) {
          
          double distanceFromOriginal = _calculateDistance(
            currentLat, currentLng, originalLat, originalLng
          );
          
          // Si l'utilisateur s'est éloigné de plus du seuil de l'original
          if (distanceFromOriginal > MODIFICATION_THRESHOLD_KM) {
            hasUserModifiedManually = true;
            print("📍 L'utilisateur a modifié manuellement (distance: ${distanceFromOriginal.toStringAsFixed(3)} km)");
          }
        }
      }
      
      if (!_isRideForOther && fromAddress != null && !hasUserModifiedManually && !_userModifiedManually) {
        Address newPickupAddress = Address(
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
        );
        
        setPickUp(newPickupAddress);
        print("📍 Point de départ mis à jour automatiquement: $address");
      } else if (hasUserModifiedManually || _userModifiedManually) {
        print("📍 Position automatique ignorée (modification manuelle détectée)");
      }
      
    } catch (e) {
      print("📍 Erreur de mise à jour point de départ: $e");
    }
  }

  Future<void> resetToCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("📍 Service de localisation désactivé");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        print("📍 Permission refusée");
        return;
      }

      Position currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      String address = await getAddressFromGeocode(
        LatLng(currentPosition.latitude, currentPosition.longitude)
      );
      
      Address newPickupAddress = Address(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        address: address,
      );
      
      // Mettre à jour l'adresse originale
      setOriginalPickupAddress(newPickupAddress);
      
      setPickUp(newPickupAddress);
      
      _userModifiedManually = false;
      _hasShownRideForOtherPrompt = false;
      
      print("📍 Position réinitialisée à la position actuelle: $address");
      _logLocationState('Après réinitialisation');
      update();
      
    } catch (e) {
      print("📍 Erreur de réinitialisation: $e");
    }
  }

  bool isPickupModifiedFromInitial() {
    print("🔍 isPickupModifiedFromInitial - Début");
    print("   fromAddress: ${fromAddress?.address}");
    print("   _originalPickupAddress: ${_originalPickupAddress?.address}");
    
    if (fromAddress == null || _originalPickupAddress == null) {
      print("   ➡ fromAddress ou originalPickupAddress null → false");
      return false;
    }
    
    // Si c'est pour un autre, on ne considère pas comme "modifié" pour le prompt
    if (_isRideForOther) {
      print("   ➡ isRideForOther true → false");
      return false;
    }
    
    double? currentLat = fromAddress!.latitude;
    double? currentLng = fromAddress!.longitude;
    double? originalLat = _originalPickupAddress!.latitude;
    double? originalLng = _originalPickupAddress!.longitude;
    
    print("   current: ($currentLat, $currentLng)");
    print("   original: ($originalLat, $originalLng)");
    
    if (currentLat != null && currentLng != null && 
        originalLat != null && originalLng != null) {
      
      double distance = _calculateDistance(
        currentLat, currentLng, originalLat, originalLng
      );
      
      bool isModified = distance > MODIFICATION_THRESHOLD_KM;
      print("   distance: ${distance.toStringAsFixed(3)} km");
      print("   seuil: $MODIFICATION_THRESHOLD_KM km");
      print("   ➡ modifié: $isModified");
      
      return isModified;
    }
    
    bool isModified = fromAddress!.address != _originalPickupAddress!.address;
    print("   ➡ comparaison par adresse: $isModified");
    return isModified;
  }

  void resetPromptState() {
    _hasShownRideForOtherPrompt = false;
    update();
  }

  // Ajoutez cette méthode pour définir l'adresse originale
  void setOriginalPickupAddress(Address address) {
    _originalPickupAddress = Address(
      latitude: address.latitude,
      longitude: address.longitude,
      address: address.address,
    );
    print("📝 OriginalPickupAddress défini: ${_originalPickupAddress?.address}");
  }

  // Méthode pour logger l'état de la localisation
  void _logLocationState(String context) {
    print('📍 État de la localisation [$context]:');
    print('   - Position actuelle: ${_position.latitude}, ${_position.longitude}');
    print('   - Adresse départ: ${fromAddress?.address}');
    print('   - Adresse originale: ${_originalPickupAddress?.address}');
    print('   - Modifié manuellement: $_userModifiedManually');
    print('   - Pour un autre: $_isRideForOther');
    print('   - Bénéficiaire: $_beneficiaryName ($_beneficiaryPhone)');
  }

  // Réinitialiser le flag de modification
  void resetModificationFlag() {
    _userModifiedManually = false;
    update();
  }

  // MÉTHODE POUR DÉFINIR SI C'EST POUR UN AUTRE
  void setRideForOther(bool value, {String phone = '', String name = ''}) {
    print('🔄 setRideForOther: $value, phone: $phone, name: $name');
    
    if (value && !_isRideForOther) {
      // Activation : sauvegarder l'adresse originale
      _originalPickupAddress = fromAddress != null 
          ? Address(
              latitude: fromAddress!.latitude,
              longitude: fromAddress!.longitude,
              address: fromAddress!.address,
            )
          : null;
      
      print('📝 Sauvegarde adresse originale: ${_originalPickupAddress?.address}');
      
      // ARRÊTER l'actualisation automatique
      stopAutoLocationUpdate();
      
    } else if (!value && _isRideForOther) {
      // Désactivation : restaurer l'adresse originale si disponible
      if (_originalPickupAddress != null) {
        setPickUp(_originalPickupAddress);
        print('🔄 Restauration adresse originale: ${_originalPickupAddress?.address}');
      }
      _beneficiaryPhone = '';
      _beneficiaryName = '';
      _originalPickupAddress = null;
      
      // REDÉMARRER l'actualisation automatique
      startAutoLocationUpdate();
      _userModifiedManually = false;
      
      // IMPORTANT: Réinitialiser le flag du prompt pour qu'il puisse se réafficher
      // si l'utilisateur modifie à nouveau le point de départ
      _hasShownRideForOtherPrompt = false;
    }
    
    _isRideForOther = value;
    if (value) {
      if (phone.isNotEmpty) _beneficiaryPhone = phone;
      if (name.isNotEmpty) _beneficiaryName = name;
    }
    
    _logLocationState('setRideForOther');
    update();
  }

  // MÉTHODE POUR DÉFINIR LE NUMÉRO DE TÉLÉPHONE
  void setBeneficiaryPhone(String phone) {
    print('📞 setBeneficiaryPhone: $phone');
    _beneficiaryPhone = phone;
    update();
  }

  // MÉTHODE POUR DÉFINIR LE NOM DU BÉNÉFICIAIRE
  void setBeneficiaryName(String name) {
    print('👤 setBeneficiaryName: $name');
    _beneficiaryName = name;
    update();
  }

  // MÉTHODE POUR VÉRIFIER SI LE POINT DE DÉPART EST DIFFÉRENT
  bool isPickupDifferentFromUser() {
    if (!_isRideForOther) return false;
    
    if (_originalPickupAddress == null) return false;
    if (fromAddress == null) return true;
    
    double? currentLat = fromAddress!.latitude;
    double? currentLng = fromAddress!.longitude;
    double? originalLat = _originalPickupAddress!.latitude;
    double? originalLng = _originalPickupAddress!.longitude;
    
    if (currentLat != null && currentLng != null && 
        originalLat != null && originalLng != null) {
      
      double distance = _calculateDistance(
        currentLat, currentLng, originalLat, originalLng
      );
      
      bool isDifferent = distance > MODIFICATION_THRESHOLD_KM;
      print('🔍 isPickupDifferentFromUser: $isDifferent (distance: ${distance.toStringAsFixed(3)} km)');
      print('   Original: ${_originalPickupAddress?.address}');
      print('   Current: ${fromAddress?.address}');
      
      return isDifferent;
    }
    
    bool isDifferent = fromAddress!.address != _originalPickupAddress!.address;
    print('🔍 isPickupDifferentFromUser (par adresse): $isDifferent');
    return isDifferent;
  }

  // MÉTHODE POUR RÉINITIALISER
  void resetRideForOther() {
    print('🔄 resetRideForOther');
    _isRideForOther = false;
    _beneficiaryPhone = '';
    _beneficiaryName = '';
    _originalPickupAddress = null;
    _userModifiedManually = false;
    _hasShownRideForOtherPrompt = false;
    update();
  }

  // Méthode pour valider le numéro ivoirien
  bool isValidIvorianPhone(String phone) {
    // Formats: +225 07 89 45 12 34, 07 89 45 12 34, 0789451234
    final RegExp phoneRegex = RegExp(
      r'^(\+225|00225)?[ ]?[0-9]{2}[ ]?[0-9]{2}[ ]?[0-9]{2}[ ]?[0-9]{2}[ ]?[0-9]{2}$'
    );
    return phoneRegex.hasMatch(phone.replaceAll(' ', ''));
  }

  // Méthode pour formater le numéro
  String formatIvorianPhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.startsWith('+225')) {
      return cleaned;
    } else if (cleaned.startsWith('00225')) {
      return '+225' + cleaned.substring(5);
    } else if (cleaned.length == 10) {
      return '+225' + cleaned;
    } else if (cleaned.length == 8) {
      return '+225' + cleaned;
    }
    return phone;
  }

  // Ajoutez cette méthode dans LocationController
  bool shouldShowRideForOtherPrompt() {
    // Ne pas afficher si déjà en mode "pour quelqu'un d'autre"
    if (_isRideForOther) return false;
    
    // Ne pas afficher si l'utilisateur a choisi "Ne plus me demander"
    if (dontAskAgain) return false;
    
    // Ne pas afficher si déjà affiché dans cette session
    if (_hasShownRideForOtherPrompt) return false;
    
    // Vérifier si le point de départ a été modifié par rapport à la position initiale
    bool isModified = isPickupModifiedFromInitial();
    
    print('🔍 shouldShowRideForOtherPrompt: $isModified');
    print('   - isRideForOther: $_isRideForOther');
    print('   - dontAskAgain: ${dontAskAgain}');
    print('   - hasShown: $_hasShownRideForOtherPrompt');
    
    return isModified;
  }

  Future<void> setLocationFromAddress(Address address, {required LocationType type}) async {
    if (type == LocationType.from) {
      setPickUp(address);
      pickupLocationController.text = address.address ?? '';
    } else if (type == LocationType.to) {
      setDestination(address);
      destinationLocationController.text = address.address ?? '';
    }
    update();
  }
}