

import 'dart:async';
import 'dart:convert';  
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/domain/models/parcel_estimated_fare_model.dart';
import 'package:ride_sharing_user_app/features/refund_request/controllers/refund_request_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/bidding_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/estimated_fare_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/final_fare_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/nearest_driver_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/remaining_distance_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/ride_list_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/services/ride_service_interface.dart';
import 'package:ride_sharing_user_app/features/safety_setup/controllers/safety_alert_controller.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/helper/ride_controller_helper.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/payment/controllers/payment_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/scheduled_ride_model.dart'; 
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/features/ride/domain/services/whatsapp_share_service.dart';


enum RideState{initial, riseFare, findingRider, outForPickup,arrived,accepted, afterAcceptRider, otpSent, ongoingRide, completeRide}
enum RideType{regularRide, scheduleRide}


class RideController extends GetxController implements GetxService {
  final RideServiceInterface rideServiceInterface;
  RideController({required this.rideServiceInterface});

  RideState currentRideState = RideState.initial;
  TripDetails? tripDetails;
  TripDetails? rideDetails;
  double currentFarePrice = 0;
  int rideCategoryIndex = 0;
  bool isLoading = false;
  String estimatedDistance = '0';
  String estimatedDuration = '0';
  double estimatedFare = 0;
  double actualFare = 0;
  List<FareModel> fareList = [];
  ParcelEstimatedFare? parcelEstimatedFare;
  String parcelFare = '0';
  String encodedPolyLine = '';
  bool loading = false;
  bool isEstimate = false;
  bool isSubmit = false;
  List<Nearest> nearestDriverList = [];
  FinalFare? finalFare;
  List<Bidding> biddingList = [];
  List<RemainingDistanceModel> remainingDistanceModel = [];
  bool isCouponApplicable = false;
  double discountFare = 0;
  double discountAmount = 0;
  List<String>? _thumbnailPaths;
  List<String>? get thumbnailPaths => _thumbnailPaths;
  JustTheController justTheController = JustTheController();
  RideType _rideType = RideType.regularRide;

  RideType get rideType => _rideType;
  String? scheduleTripDate;
  DateTime? scheduleTripTime;
  RideListModel? runningRideList;
  String? _lastKnownTripId;
String? get lastKnownTripId => _lastKnownTripId;

  // VARIABLES POUR "COMMANDER POUR UN AUTRE"
  bool orderForOther = false;
  String? otherPhoneNumber;
  Address? otherPickupAddress;

  TripDetails? get currentTripDetails => tripDetails;

  TextEditingController inputFarePriceController = TextEditingController(text: '0.00');
  TextEditingController noteController = TextEditingController();

  List<ScheduledRideModel> scheduledRides = [];

  // ============================================================================
  // ✨ NOUVEAUX GETTERS POUR PARTAGE DE POSITION ET BLOCAGE ANNULATION
  // ============================================================================

  /// 🎯 Détermine si la course a démarré (conducteur en route ou en trajet)
  bool get isRideStarted {
    if (tripDetails == null) return false;
    
    print('🔍 isRideStarted CHECK:');
    print('   • currentRideState: $currentRideState');
    print('   • tripDetails?.currentStatus: ${tripDetails?.currentStatus}');
    
    bool result = currentRideState == RideState.outForPickup ||
           currentRideState == RideState.ongoingRide ||
           currentRideState == RideState.otpSent ||
           tripDetails?.currentStatus == 'outForPickup' ||
           tripDetails?.currentStatus == 'ongoing' ||
           tripDetails?.currentStatus == 'accepted' ||
           tripDetails?.currentStatus == 'picked_up'||
           tripDetails?.currentStatus == 'arrived'; //New Y2R
    
    print('   ✅ RÉSULTAT et etat de la course: $result\n');
    return result;
  }

  /// 🚫 Détermine si l'annulation est possible
  bool get canCancelRide {
    if (tripDetails == null) return false;
    
    return !isRideStarted && 
           (tripDetails?.currentStatus == 'pending' ||
            tripDetails?.currentStatus == 'accepted');
  }

  /// 📍 Détermine si le partage de position est disponible
  bool get canShareLocation {
    return isRideStarted && tripDetails != null;
  }

  /// 💬 Message d'état pour l'interface
  String get rideStateMessage {
    if (tripDetails == null) return 'Initialisation...'; 
    
    switch (currentRideState) {
      case RideState.initial:
        return 'Avant de commander';
      case RideState.riseFare:
        return 'Augmentation du prix';
      case RideState.findingRider:
        return 'Recherche de conducteur...';
      case RideState.outForPickup:
        return 'Le conducteur arrive...';
        case RideState.arrived:
        return 'Le conducteur est arrivé...';
      case RideState.afterAcceptRider:
        return 'Conducteur accepté';
      case RideState.otpSent:
        return 'OTP envoyé';
      case RideState.ongoingRide:
        return 'Trajet en cours';
      case RideState.completeRide:
        return 'Trajet terminé';
      default:
        return 'État inconnu';
    }
  }

  // ============================================================================
  // FIN DES NOUVEAUX GETTERS
  // ============================================================================

  void initData() {
    currentRideState = RideState.initial;
    tripDetails = null;
    isLoading = false;
    loading = false;
    encodedPolyLine = '';
    scheduleTripDate = null;
    scheduleTripTime = null;
  }

  void updateRideCurrentState(RideState newState) {
    print('📝 MISE À JOUR ÉTAT: $currentRideState → $newState');
    currentRideState = newState;

//Envois whatssap automatiquement au beneficiaire
 if (newState == RideState.outForPickup) {
    final locationCtrl = Get.find<LocationController>();
    
    if (locationCtrl.isRideForOther &&
        locationCtrl.beneficiaryPhone.isNotEmpty) {
      _sendAutoWhatsAppToBeneficiary(locationCtrl);
    }
  }

    update();
  }

//Envois whatssap automatiquement au beneficiaire
Future<void> _sendAutoWhatsAppToBeneficiary(LocationController locationCtrl) async {
  try {
    final driver = tripDetails?.driver;
    final vehicle = tripDetails?.vehicle;

    final String driverName = [driver?.firstName, driver?.lastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');

    final String vehicleModel =
        '${vehicle?.model?.name ?? ''} ${vehicle?.model?.engine ?? ''}'.trim();

    final double fare = (tripDetails?.discountAmount ?? 0) > 0
        ? tripDetails?.discountActualFare ?? 0
        : tripDetails?.actualFare ?? 0;

    await WhatsAppShareService.sendRideInfoToBeneficiary(
      phoneNumber:     normalizePhoneNumber(locationCtrl.beneficiaryPhone) ,
      beneficiaryName:  locationCtrl.beneficiaryName ?? '',
      driverName:       driverName,
      driverPhone:      driver?.phone ?? '',
      vehicleModel:     vehicleModel,
      licensePlate:     vehicle?.licencePlateNumber ?? '',
      tripId:           tripDetails?.refId ?? '',
      pickupAddress:    tripDetails?.pickupAddress ?? '',
      destinationAddress: tripDetails?.destinationAddress ?? '',
      estimatedFare:    PriceConverter.convertPrice(fare),
      estimatedDuration: estimatedDuration ?? '',
    );
  } catch (e) {
    debugPrint('❌ Erreur envoi WhatsApp automatique : $e');
  }
}

/// Normalise un numéro ivoirien vers le format international +2250700000000
String normalizePhoneNumber(String phone) {
  // Supprimer tous les espaces, tirets, parenthèses
  String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');

  // Déjà au bon format
  if (cleaned.startsWith('+225')) return cleaned;

  // Format 2250700000000 → +2250700000000
  if (cleaned.startsWith('225')) return '+$cleaned';

  // Format 0700000000 (10 chiffres commençant par 0) → +2250700000000
  if (cleaned.startsWith('0') && cleaned.length == 10) {
    return '+225${cleaned.substring(1)}';
  }

  // Format 700000000 (9 chiffres, sans le 0) → +2250700000000
  if (!cleaned.startsWith('0') && cleaned.length == 9) {
    return '+225$cleaned';
  }

  // Format inconnu : retourner tel quel pour ne pas corrompre
  return phone;
}


  Future<void> setBidingAmount(String balance) async{
    if(balance.isNotEmpty){
      actualFare = double.parse(balance);
      parcelFare = balance;
    }
    update();
  }

  String categoryName = '';
  String selectedCategoryId = '';
  FareModel? selectedType;
  
  void setRideCategoryIndex(int newIndex){
    rideCategoryIndex = newIndex;
    categoryName = Get.find<CategoryController>().categoryList![rideCategoryIndex].id!;

    Get.find<CategoryController>().setCouponFilterIndex(newIndex + 2);

    if(fareList.isNotEmpty){
      for(int i = 0; i< fareList.length; i++){
        if(fareList[i].vehicleCategoryId == categoryName){
          selectedType =  fareList[i];
          break;
        }
      }

      estimatedDistance = selectedType!.estimatedDistance!;
      estimatedDuration = selectedType!.estimatedDuration!;
      selectedCategoryId = selectedType!.vehicleCategoryId!;
      estimatedFare = (((selectedType?.extraFareFee ?? 0) > 0) || ((selectedType?.surgeMultiplier ?? 0) >0)) ? selectedType?.extraEstimatedFare ?? 0 : selectedType?.estimatedFare ?? 0;
      currentFarePrice = estimatedFare;
      actualFare = estimatedFare;
      isCouponApplicable = selectedType!.couponApplicable!;
      discountFare = (((selectedType?.extraFareFee ?? 0) > 0) || ((selectedType?.surgeMultiplier ?? 0) >0)) ? selectedType?.extraDiscountFare ?? 0 : selectedType?.discountFare ?? 0;
      discountAmount = (((selectedType?.extraFareFee ?? 0) > 0) || ((selectedType?.surgeMultiplier ?? 0) >0)) ? selectedType?.extraDiscountAmount ?? 0 : selectedType?.discountAmount ?? 0;
    }

    update();
  }

  void resetControllerValue(){
    currentRideState = RideState.initial;
    rideCategoryIndex = 0;
    update();
  }

  void clearRideDetails(){
    tripDetails = null;
    rideDetails = null;
    update();
  }

  @override
  onInit(){
    if(tripDetails != null && Get.find<AuthController>().getUserToken() != ''){
      startLocationRecord();
    }else{
      stopLocationRecord();
    }
    super.onInit();
  }

  // ============================================================================
  // COMMANDER POUR UN AUTRE
  // ============================================================================

  void toggleOrderForOther() {
    orderForOther = !orderForOther;
    if (!orderForOther) {
      otherPhoneNumber = null;
    }
    update();
  }

  void setOtherPhone(String number) {
    otherPhoneNumber = number; 
    update();
  }

  void setOtherPickupAddress(Address? address) {
    otherPickupAddress = address;
    update();
  }

  void setBeneficiaryInfo({required String phone, required Address? pickupAddress}) {
    print('📝 setBeneficiaryInfo - phone: $phone');
    orderForOther = true;
    otherPhoneNumber = phone;
    otherPickupAddress = pickupAddress;
    update();
  }

  void clearBeneficiaryInfo() {
    print('🧹 clearBeneficiaryInfo');
    orderForOther = false;
    otherPhoneNumber = null;
    otherPickupAddress = null;
    update();
  }

  // ============================================================================
  // MÉTHODES PRINCIPALES
  // ============================================================================

  Future<Response> getEstimatedFare(bool parcel) async {
   
    loading = true;
    isEstimate = true;
    update();
    parcelEstimatedFare = null;
    LocationController locController = Get.find<LocationController>();
    ParcelController parcelController = Get.find<ParcelController>();
    Address fromPosition = parcel ? locController.parcelSenderAddress! : locController.fromAddress!;
    Address toPosition = parcel ? locController.parcelReceiverAddress! : locController.toAddress!;
    DateTime scheduleDate = RideControllerHelper.dateFormatToShow(scheduleTripDate);
    DateTime scheduleTime = RideControllerHelper.timeFormatToShow(scheduleTripTime);

    DateTime scheduledTime = DateTime(scheduleDate.year,scheduleDate.month,scheduleDate.day,scheduleTime.hour,scheduleTime.minute,scheduleTime.second);

    Response? response = await rideServiceInterface.getEstimatedFare(
      pickupLatLng: LatLng(fromPosition.latitude!, fromPosition.longitude!),
      destinationLatLng: LatLng(toPosition.latitude!, toPosition.longitude!),
      currentLatLng: LatLng(locController.initialPosition.latitude, locController.initialPosition.longitude),
      type: parcel ? 'parcel' : 'ride_request',
      rideRequestType: parcel ? null : _rideType == RideType.regularRide ? 'regular' : 'scheduled',
      pickupAddress : parcel ? parcelController.senderAddressController.text
          : locController.fromAddress!.address.toString(),
      destinationAddress: parcel ? parcelController.receiverAddressController.text
          : locController.toAddress!.address!,
      extraOne: locController.extraOneRoute,
      extraTwo: locController.extraTwoRoute,
      extraThree: locController.extraThreeRoute,
      extraOneLatLng: locController.extraRouteAddress != null ? LatLng(
        locController.extraRouteAddress!.latitude!, locController.extraRouteAddress!.longitude!,
      ) : null,
      extraTwoLatLng: locController.extraRouteTwoAddress != null ? LatLng(
        locController.extraRouteTwoAddress!.latitude!, locController.extraRouteTwoAddress!.longitude!,
      ) : null,
      extraThreeLatLng: locController.extraRouteThreeAddress != null ? LatLng(
        locController.extraRouteThreeAddress!.latitude!, locController.extraRouteThreeAddress!.longitude!,
      ) : null,
      parcelWeight: Get.find<ParcelController>().parcelWeightController.text,
      parcelCategoryId: parcel ? parcelController.parcelCategoryList![parcelController.selectedParcelCategory].id : '',
      scheduledAt: _rideType == RideType.scheduleRide ? scheduledTime.toString() : '',
    );

    if(response!.statusCode == 200) {
      loading = false;
      isEstimate = false;

      if(parcel) {
        parcelEstimatedFare = ParcelEstimatedFare.fromJson(response.body);
        encodedPolyLine = ParcelEstimatedFare.fromJson(response.body).data!.encodedPolyline!;
        parcelFare = ParcelEstimatedFare.fromJson(response.body).data!.estimatedFare!.toString();
      }else{
        fareList = [];
        fareList.addAll(EstimatedFareModel.fromJson(response.body).data!);
        setRideCategoryIndex(rideCategoryIndex != 0 ?  rideCategoryIndex : 0);
        if(fareList[rideCategoryIndex].polyline == null){
          showCustomSnackBar('road_not_found'.tr,isError: true);
        }
        encodedPolyLine = fareList[rideCategoryIndex].polyline!;
      }
    }else{
      
      loading = false;
      isEstimate = false;
      ApiChecker.checkApi(response);
      if(response.statusCode == 403 && !parcel) {
        tripDetails = null;
        rideDetails = null;
      }
    }

    update();
    return response;
  }

  Future<Response> submitRideRequest(String note, bool parcel, {String categoryId = ''}) async {
    initCountingTimeStates();
    isSubmit = true;
    update();

    LocationController locController = Get.find<LocationController>();
    Address pickUpPosition = parcel ? locController.parcelSenderAddress! : tripDetails == null ? locController.fromAddress! : Address();
    Address destinationPosition = parcel ? locController.parcelReceiverAddress! : tripDetails == null ? locController.toAddress! : Address();

    DateTime scheduleDate = RideControllerHelper.dateFormatToShow(scheduleTripDate);
    DateTime scheduleTime = RideControllerHelper.timeFormatToShow(scheduleTripTime);

    DateTime scheduledTime = DateTime(scheduleDate.year,scheduleDate.month,scheduleDate.day,scheduleTime.hour,scheduleTime.minute,scheduleTime.second);

    String pickupCoordinates = jsonEncode([pickUpPosition.longitude, pickUpPosition.latitude]);
    String destinationCoordinates = jsonEncode([destinationPosition.longitude, destinationPosition.latitude]);
    String customerCoordinates = jsonEncode([locController.initialPosition.longitude, locController.initialPosition.latitude]);

    Response response = await rideServiceInterface.submitRideRequest(
      pickupCoordinates: pickupCoordinates,
      destinationCoordinates: destinationCoordinates,
      customerCoordinates: customerCoordinates,
      pickupLat: pickUpPosition.latitude.toString(),
      pickupLng: pickUpPosition.longitude.toString(),
      destinationLat: destinationPosition.latitude.toString(),
      destinationLng: destinationPosition.longitude.toString(),
      customerCurrentLat: locController.initialPosition.latitude.toString(),
      customerCurrentLng: locController.initialPosition.longitude.toString(), 
      type: parcel ? 'parcel' : 'ride_request',
      rideRequestType: parcel ? null : _rideType == RideType.regularRide ? 'regular' : 'scheduled',
      pickupAddress: parcel ? Get.find<ParcelController>().senderAddressController.text
          : tripDetails == null ? locController.fromAddress!.address.toString() : tripDetails!.pickupAddress!,
      destinationAddress: parcel ? Get.find<ParcelController>().receiverAddressController.text
          : locController.toAddress?.address ?? tripDetails!.destinationAddress! ,
      vehicleCategoryId: parcel ? categoryId : selectedCategoryId,
      estimatedDistance: parcel ? parcelEstimatedFare!.data!.estimatedDistance!.toString() : estimatedDistance,
      estimatedTime: parcel ? parcelEstimatedFare!.data!.estimatedDuration!.replaceFirst('min', '') : estimatedDuration,
      estimatedFare: parcel ? parcelFare : estimatedFare.toString(),
      actualFare: parcel ? parcelFare : estimatedFare != actualFare ? actualFare.toString() : estimatedFare.toString(),
      bid:parcel ? false : estimatedFare != actualFare, 
      note: note,
      paymentMethod: Get.find<PaymentController>().paymentTypeList[Get.find<PaymentController>().paymentTypeIndex],
      encodedPolyline: parcel ? encodedPolyLine : encodedPolyLine.isNotEmpty ? encodedPolyLine : fareList.isNotEmpty ? fareList[rideCategoryIndex].polyline! : '',
      middleAddress: [locController.extraRouteAddress?.address ?? '', locController.extraRouteTwoAddress?.address ?? '', locController.extraRouteThreeAddress?.address ?? ''],
      entrance: locController.entranceController.text.toString(),
      extraOne: locController.extraOneRoute,
      extraTwo: locController.extraTwoRoute,
      extraThree: locController.extraThreeRoute,
      extraLatOne: locController.extraRouteAddress != null ? locController.extraRouteAddress!.latitude.toString() : '',
      extraLngOne: locController.extraRouteAddress != null ? locController.extraRouteAddress!.longitude.toString() : '',
      extraLatTwo: locController.extraRouteTwoAddress != null ? locController.extraRouteTwoAddress!.latitude.toString() : '',
      extraLngTwo: locController.extraRouteTwoAddress != null ? locController.extraRouteTwoAddress!.longitude.toString() : '',
      extraLatThree: locController.extraRouteThreeAddress != null ? locController.extraRouteThreeAddress!.latitude.toString() : '',
      extraLngThree: locController.extraRouteThreeAddress != null ? locController.extraRouteThreeAddress!.longitude.toString() : '',
      areaId: parcel ? '' : fareList.isNotEmpty ? fareList[rideCategoryIndex].areaId ?? '' : '',
      senderName: Get.find<ParcelController>().senderNameController.text,
      senderPhone: Get.find<ParcelController>().getSenderContactNumber,
      senderAddress: Get.find<ParcelController>().senderAddressController.text,
      receiverName: Get.find<ParcelController>().receiverNameController.text,
      receiverPhone: Get.find<ParcelController>().getReceiverContactNumber,
      receiverAddress: Get.find<ParcelController>().receiverAddressController.text,
      parcelCategoryId: parcel ? Get.find<ParcelController>().parcelCategoryList![Get.find<ParcelController>().selectedParcelCategory].id : '',
      payer: Get.find<ParcelController>().payReceiver?'receiver':"sender",
      weight: Get.find<ParcelController>().parcelWeightController.text,
      tripRequestId: parcel ? null : tripDetails?.id,
      returnFee: parcel ? parcelEstimatedFare?.data?.returnFee : 0,
      cancellationFee: parcel ? parcelEstimatedFare?.data?.cancellationFee : 0,
      extraEstimatedFare: parcel ? (parcelEstimatedFare?.data?.extraEstimatedFare ?? 0) : (selectedType?.extraEstimatedFare ?? 0),
      extraDiscountFare: parcel ? (parcelEstimatedFare?.data?.extraDiscountFare ?? 0) : (selectedType?.extraDiscountFare ?? 0),
      extraDiscountAmount: parcel ? (parcelEstimatedFare?.data?.extraDiscountAmount ?? 0) : (selectedType?.extraDiscountAmount ?? 0),
      extraReturnFee: parcel ? (parcelEstimatedFare?.data?.extraReturnFee ?? 0) : (selectedType?.extraReturnFee ?? 0),
      extraCancellationFee: parcel ? (parcelEstimatedFare?.data?.extraCancellationFee ?? 0) : (selectedType?.extraCancellationFee ?? 0),
      extraFareAmount: parcel ? (parcelEstimatedFare?.data?.extraFareAmount ?? 0) : (selectedType?.extraFareAmount ?? 0),
      extraFareFee: parcel ? (parcelEstimatedFare?.data?.extraFareFee ?? 0) : (selectedType?.extraFareFee ?? 0),
      zoneId: parcel ? parcelEstimatedFare?.data?.zoneId ?? '' : selectedType?.zoneId ,
      scheduledAt: _rideType == RideType.scheduleRide ? scheduledTime.toString() : '',
      surgeMultiplier: parcel ? parcelEstimatedFare?.data?.surgeMultiplier : selectedType?.surgeMultiplier,

    // ✅ AJOUTER
  isRideForOther: parcel ? false : locController.isRideForOther,
  beneficiaryName: (!parcel && locController.isRideForOther)? (locController.beneficiaryName ?? '') : null,
  beneficiaryPhone: (!parcel && locController.isRideForOther) ? normalizePhoneNumber(locController.beneficiaryPhone): null,
    );

    if(response.statusCode == 200 && response.body['data'] != null) {
      biddingList = [];
      tripDetails = TripDetailsModel.fromJson(response.body).data!;
      tripDetails!.id = response.body['data']['id'];
      encodedPolyLine = tripDetails!.encodedPolyline!;
      
      Get.find<ParcelController>().receiverNameController.clear();
      Get.find<ParcelController>().receiverContactController.clear();
      Get.find<ParcelController>().receiverAddressController.clear();
      Get.find<ParcelController>().onChangeReceiverCountryCode(null);
      Get.find<ParcelController>().onChangeSenderCountryCode(null);
      Get.find<ParcelController>().parcelWeightController.clear();
      
      PusherHelper().pusherDriverStatus(response.body['data']['id']);
      isSubmit = false;
      noteController.clear();
    }else{
      isSubmit = false;
      ApiChecker.checkApi(response);
      if(response.statusCode == 403) {
        tripDetails = null;
        rideDetails = null;
      }
    }
    
    actualFare = 0;
    isLoading = false;
    update();

    return response;
  }

  void clearExtraRoute(){
    Get.find<LocationController>().extraOneRoute = false;
    Get.find<LocationController>().extraTwoRoute = false;
    Get.find<LocationController>().extraThreeRoute = false;
    Get.find<LocationController>().extraRouteAddress = null;
    Get.find<LocationController>().extraRouteTwoAddress = null;
    Get.find<LocationController>().extraRouteThreeAddress = null;
  }

  Future<Response> getRideDetails(String tripId,{bool isUpdate = true}) async {
 _lastKnownTripId = tripId; 

      isLoading = true;
  // ✅ Ne pas effacer tripDetails si isUpdate = false
  if (isUpdate) {
    tripDetails = null;
    _thumbnailPaths = null;
    update();
  }

    Response response = await rideServiceInterface.getRideDetails(tripId);
    if (response.statusCode == 200) {
      Get.find<MapController>().notifyMapController();
      tripDetails = TripDetailsModel.fromJson(response.body).data!;
      update(); 
      estimatedDistance = tripDetails!.estimatedDistance!.toString();
      isLoading = false;

      encodedPolyLine = tripDetails!.encodedPolyline!;
      List<Attachments> attachments = tripDetails?.parcelRefund?.attachments ?? [];
      _thumbnailPaths = List.filled(attachments.length, '');

      if(tripDetails?.parcelRefund?.attachments != null){
        Future.forEach(tripDetails!.parcelRefund!.attachments!, (element) async{
          if(element.file!.contains('.mp4')){
            String? path = await Get.find<RefundRequestController>().generateThumbnail(element.file!);
            _thumbnailPaths?[tripDetails!.parcelRefund!.attachments!.indexOf(element)] =  path ?? '';
            update();
          }
        });
      }
    }
    update();
    return response;
  }

  bool runningTrip = false;

  Future<Response> getCurrentRegularRide() async {
    Response response = await rideServiceInterface.getCurrentRegularRide();
    if (response.statusCode == 200 && response.body['data'] != null) {
      rideDetails = TripDetailsModel.fromJson(response.body).data!;
      estimatedDistance = rideDetails!.estimatedDistance!.toString();
      encodedPolyLine = rideDetails!.encodedPolyline ?? '';
    }else if(response.statusCode == 403){
      rideDetails = null;
    }
    update();
    return response;
  }

  Future<Response> remainingDistance(String requestID,{bool mapBound = false}) async {
    isLoading = true;
    print("je suis ici depuis las $requestID");
    Response response = await rideServiceInterface.remainDistance(requestID);
    if (response.statusCode == 200) {
      Get.find<MapController>().getDriverToPickupOrDestinationPolyline(response.body[0]["encoded_polyline"],mapBound: mapBound);
      remainingDistanceModel = [];
      for(var distance in response.body) {
        remainingDistanceModel.add(RemainingDistanceModel.fromJson(distance));
      }

      if(Get.find<MapController>().isInside && tripDetails != null && currentRideState == RideState.outForPickup) {
        updateRideCurrentState(RideState.otpSent);
      }
      if(Get.find<MapController>().isInside && tripDetails != null && currentRideState == RideState.arrived) {
        updateRideCurrentState(RideState.arrived);
      }
      if(Get.find<MapController>().isInside && Get.find<ParcelController>().currentParcelState == ParcelDeliveryState.acceptRider){
        Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.otpSent);
      }
      isLoading = false;
    }else{
      print("je suis ici depuis la 1 $response");
      isLoading = false;
     // ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<Response> getBiddingList(String tripId, int offset) async {
    isLoading = true;

    Response response = await rideServiceInterface.biddingList(tripId, offset);
    if (response.statusCode == 200) {
      biddingList = [];
      biddingList.addAll(BiddingModel.fromJson(response.body).data!);
      isLoading = false;
    }else{
       print("je suis ici depuis la 2");
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<Response> ignoreBidding(String bidId,String tripId) async {
    isLoading = true;
    update();
    Response response = await rideServiceInterface.ignoreBidding(bidId);
    if (response.statusCode == 200) {
      getBiddingList(tripId, 1).then((value){
        if(biddingList.isEmpty){
          Get.back();
        }
      });
      isLoading = false;
    }else{
      getBiddingList(tripId, 1).then((value){
        if(biddingList.isEmpty){
          Get.back();
          Future.delayed(const Duration(milliseconds: 300)).then((value){
             print("je suis ici depuis la 2");
            ApiChecker.checkApi(response);
          });
        }
      });
      isLoading = false;
    }
    update();
    return response;
  }

  Future<Response> getNearestDriverList(String lat, String lng) async {
    Response response = await rideServiceInterface.nearestDriverList(lat, lng);
    if (response.statusCode == 200) {
      nearestDriverList = [];
      nearestDriverList.addAll(NearestDriverModel.fromJson(response.body).data!);
      Get.find<MapController>().searchDeliveryMen();
    }else{
       print("je suis ici depuis la 3");
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Timer? _timer;
  
  // void startLocationRecord() {
  //   if(Get.find<RideController>().tripDetails != null && Get.find<AuthController>().getUserToken() != ''){
  //     Get.find<RideController>().remainingDistance(Get.find<RideController>().tripDetails!.id!,mapBound: true);
  //   }else{
  //     _timer?.cancel();
  //   }
  //   _timer?.cancel();
  //   _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
  //     if(Get.find<RideController>().tripDetails != null && Get.find<AuthController>().getUserToken() != '' ){
  //       if(Get.find<RideController>().tripDetails?.type == AppConstants.parcel && (Get.find<RideController>().tripDetails?.currentStatus == AppConstants.accepted || Get.find<RideController>().tripDetails?.currentStatus == AppConstants.ongoing)){
  //         Get.find<RideController>().remainingDistance(Get.find<RideController>().tripDetails!.id!);
  //       }else if(Get.find<RideController>().tripDetails?.type == 'ride_request' && (Get.find<RideController>().tripDetails?.currentStatus == AppConstants.outForPickup || Get.find<RideController>().tripDetails?.currentStatus == AppConstants.ongoing)){
  //         Get.find<RideController>().remainingDistance(Get.find<RideController>().tripDetails!.id!);
  //       }
  //     }else{
  //       _timer?.cancel();
  //     }
  //   });
  // }

  void startLocationRecord() {
  if (Get.find<RideController>().tripDetails != null &&
      Get.find<AuthController>().getUserToken() != '') {
    Get.find<RideController>().remainingDistance(
        Get.find<RideController>().tripDetails!.id!,
        mapBound: true);
  } else {
    _timer?.cancel();
  }
  _timer?.cancel();
  _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
    final ride = Get.find<RideController>();
    if (ride.tripDetails != null &&
        Get.find<AuthController>().getUserToken() != '') {

      if (ride.tripDetails?.type == AppConstants.parcel &&
          (ride.tripDetails?.currentStatus == AppConstants.accepted ||
              ride.tripDetails?.currentStatus == AppConstants.ongoing)) {
        ride.remainingDistance(ride.tripDetails!.id!);

      } else if (ride.tripDetails?.type == 'ride_request' &&
          (ride.tripDetails?.currentStatus == AppConstants.outForPickup ||
              ride.tripDetails?.currentStatus == AppConstants.ongoing)) {
        ride.remainingDistance(ride.tripDetails!.id!);

        // ✅ AJOUT : recharger tripDetails pour détecter driverArrivesAt
        // (renseigné quand le chauffeur déclare son arrivée manuellement)
        if (ride.tripDetails?.driverArrivesAt == null ||
            ride.tripDetails!.driverArrivesAt == 'null' ||
            ride.tripDetails!.driverArrivesAt!.isEmpty) {
          ride.getRideDetails(ride.tripDetails!.id!, isUpdate: false);
        }
      }
    } else {
      _timer?.cancel();
    }
  });
}

  void stopLocationRecord() {
    _timer?.cancel();
  }

  /// ✅ MISE À JOUR: Quand un conducteur accepte, on met à jour correctement l'état
  Future<Response> tripAcceptOrRejected(String tripId, String type, String driverId) async {
     print("le chauffeur a excepte la course");
    isLoading = true;
    update();
    Response response = await rideServiceInterface.tripAcceptOrReject(tripId, type, driverId);
    if (response.statusCode == 200) {
      biddingList = [];
          print("je suis ici avec ");
      showCustomSnackBar('trip_is_accepted'.tr, isError: false);
      Get.back();
      getRideDetails(tripId, isUpdate: false).then((value) {
        if(value.statusCode == 200){
          // ✅ CORRECTION: Mettre à jour l'état AVANT la distance
          print("je suis ici ");
          updateRideCurrentState(RideState.outForPickup);  // ← Le conducteur est en route !
          
          remainingDistance(tripDetails!.id!,mapBound: true);
          Get.find<MapController>().notifyMapController();
          Get.offAll(()=> const MapScreen(fromScreen: MapScreenType.ride));
        }
      });
      isLoading = false;
    }else{
      getBiddingList(tripId, 1).then((value){
        if(biddingList.isEmpty){
          Get.back();
          Future.delayed(const Duration(milliseconds: 300)).then((value){
             print("je suis ici depuis la 5");
            ApiChecker.checkApi(response);
          });
        }
      });
      isLoading = false;
    }
    update();
    return response;
  }

  void clearBiddingList(){
    biddingList = [];
    update();
  }

  Future<Response> tripStatusUpdate(String tripId, String status, String message, String cancellationCause, {bool afterAccept = false}) async {
    isLoading = true;
    update();
    Response response = await rideServiceInterface.tripStatusUpdate(tripId, status, cancellationCause);
    if (response.statusCode == 200) {
      Get.find<TripController>().othersCancellationController.clear();
      Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();
      if(status == AppConstants.cancelled && !afterAccept){
        tripDetails = null;
        updateRideCurrentState(RideState.initial);  // ← Réinitialiser l'état
      }
      showCustomSnackBar(message.tr, isError: false);
      isLoading = false;
    }else{
      isLoading = false;
       print("je suis ici depuis la 6");
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<Response> getFinalFare(String tripId) async {
    isLoading = true;
    update();
    Response response = await rideServiceInterface.getFinalFare(tripId);
    if (response.statusCode == 200 ) {
      if(response.body['data'] != null){
        finalFare = FinalFareModel.fromJson(response.body).data!;
      }
    }else{
       print("je suis ici depuis la 7");
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();
    return response;
  }

  double? firstCount = 0;
  double? secondCount = 0;
  double? thirdCount = 0;
  int stateCount = 0;
  Timer? _findingStateAnimation;

  void countingTimeStates() async{
    _findingStateAnimation?.cancel();
    if(stateCount == 0){
      await Future.delayed(const Duration(seconds: 1)).then((value){
        firstCount = null;
        secondCount = 0;
        thirdCount = 0;
        update();
      });

      _findingStateAnimation = Timer.periodic(const Duration(minutes: 1), (time){
        firstCount = 1;
        stateCount = 1;
        countingTimeStates();
      });
    }

    if(stateCount == 1){
      await Future.delayed(const Duration(milliseconds: 100)).then((value){
        firstCount = 1;
        secondCount = null;
        thirdCount = 0;
        update();
      });

      _findingStateAnimation = Timer.periodic(const Duration(minutes: 1), (time){
        secondCount = 1;
        stateCount = 2;
        countingTimeStates();
      });
    }

    if(stateCount == 2){
      await  Future.delayed(const Duration(milliseconds: 100)).then((value){
        firstCount = 1;
        secondCount = 1;
        thirdCount = null;
        update();
      });

      _findingStateAnimation = Timer.periodic(const Duration(minutes: 3), (time){
        thirdCount = 1;
        stateCount = 3;
        update();
        _findingStateAnimation?.cancel();
      });
    }

    if(stateCount == 3){
      update();
    }
  }

  void initCountingTimeStates({bool isRestart = false}){
    if(isRestart){
      if(stateCount == 3){
        firstCount = 0;
        secondCount = 0;
        thirdCount = 0;
        stateCount = 0;
      }
      countingTimeStates();
    }else{
      firstCount = 0;
      secondCount = 0;
      thirdCount = 0;
      stateCount = 0;
    }
  }

  void resumeCountingTimeState(int duration){
    if(duration < 60){
      secondCount = 0;
      thirdCount = 0;
      stateCount = 0;
    }else if(duration > 60 && duration < 120){
      firstCount = 1;
      thirdCount = 0;
      stateCount = 1;
    }else if (duration > 120 && duration < 300){
      firstCount = 1;
      secondCount = 1;
      stateCount = 2;
    }else{
      firstCount = 1;
      secondCount = 1;
      thirdCount = 1;
      stateCount = 3;
    }
    countingTimeStates();
  }

  Future<Response> parcelReturned(String tripId) async {
    isLoading = true;
    update();
    Response response = await rideServiceInterface.parcelReceived(tripId);
    if (response.statusCode == 200) {
      getRideDetails(tripId);
      Get.find<ParcelController>().getRunningParcelList();
    }else {
       print("je suis ici depuis la 10");
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();
    return response;
  }

  void showSafetyAlertTooltip(){
    justTheController.showTooltip();
  }

  void setRideType(RideType rideType, {bool isUpdate = false}){
    _rideType = rideType;
    if(isUpdate){
      update();
    }
  }

  void setScheduleTripDate(String date){
    scheduleTripDate = date;
  }

  void setScheduleTripTime(DateTime time){
    scheduleTripTime = time;
  }

  Future<Response> updateScheduleTripTimeDate(String? tripId) async {
    isLoading = true;
    update();
    DateTime scheduleDate = RideControllerHelper.dateFormatToShow(scheduleTripDate);
    DateTime scheduleTime = RideControllerHelper.timeFormatToShow(scheduleTripTime);

    DateTime scheduledTime = DateTime(scheduleDate.year,scheduleDate.month,scheduleDate.day,scheduleTime.hour,scheduleTime.minute,scheduleTime.second);

    Response response = await rideServiceInterface.updateScheduleTripTimeDate(tripId, '$scheduledTime');
    if (response.statusCode == 200) {
      tripDetails = TripDetailsModel.fromJson(response.body).data!;
      isLoading = false;
    }else{
      isLoading = false;
       print("je suis ici depuis la 11");
     ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<void> getRunningRideList() async{
    isLoading = true;
    Response response = await rideServiceInterface.getRunningRideList();
    if(response.statusCode == 200 ){
      isLoading = false;
      if(response.body['data'] != null){
        runningRideList = RideListModel.fromJson(response.body);
      }
    }else{
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();
  }

  // ============================================================================
  // TRAJETS PROGRAMMÉS
  // ============================================================================

  Future<void> deleteScheduledRide(String rideId) async {
    try {
      isLoading = true;
      update();

      Response response = await rideServiceInterface.deleteScheduledRide(rideId);
      
      if (response.statusCode == 200) {
        await getScheduledRideList();
        showCustomSnackBar(
          'Trajet programmé supprimé avec succès',
          isError: false,
        );
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression: $e');
      showCustomSnackBar(
        'Une erreur est survenue lors de la suppression',
        isError: true,
      );
    } finally {
      print('❌ Je cherche l\'erreur mais impossible');
      showCustomSnackBar(
        'Je cherche l\'erreur',
        isError: true,
      );
      isLoading = false;
      update();
    }
  }

  Future<void> getScheduledRideList() async {
    try {
      isLoading = true;
      update();

      Response response = await rideServiceInterface.getScheduledRides();

      if (response.statusCode == 200) {
        if (response.body is List) {
          scheduledRides = List<ScheduledRideModel>.from(
            response.body.map((x) => ScheduledRideModel.fromJson(x))
          );
        } else if (response.body['data'] != null) {
          scheduledRides = List<ScheduledRideModel>.from(
            response.body['data'].map((x) => ScheduledRideModel.fromJson(x))
          );
        } else {
          scheduledRides = [];
        }
        
        print('📊 Nombre de trajets chargés: ${scheduledRides.length}');
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des trajets programmés: $e');
      scheduledRides = [];
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> deleteAllScheduledRides() async {
    try {
      isLoading = true;
      update();

      Response response = await rideServiceInterface.deleteAllScheduledRides();
      
      if (response.statusCode == 200) {
        scheduledRides = [];
        showCustomSnackBar(
          'Tous les trajets programmés ont été supprimés',
          isError: false,
        );
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression multiple: $e');
      showCustomSnackBar(
        'Une erreur est survenue',
        isError: true,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> cancelScheduledRide(String rideId) async {
    try {
      isLoading = true;
      update();

      Response response = await rideServiceInterface.cancelScheduledRide(rideId);
      
      if (response.statusCode == 200) {
        await getScheduledRideList();
        showCustomSnackBar(
          'Trajet programmé annulé',
          isError: false,
        );
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('❌ Erreur lors de l\'annulation: $e');
      showCustomSnackBar(
        'Une erreur est survenue',
        isError: true,
      );
    } finally {
      isLoading = false;
      update();
    }
  }


// ════════════════════════════════════════════════════════════════════════════
// PATCH — ride_controller.dart
// Ajouter la méthode updateTripRoute après tripStatusUpdate()
// ════════════════════════════════════════════════════════════════════════════
//
// Note : rideServiceInterface est déjà injecté dans le constructeur.
// On suit exactement le même pattern que tripStatusUpdate.

  /// Persiste en base les modifications de route (destination, arrêts)
  /// faites pendant la course, et notifie le chauffeur.
  ///
  /// Séquence appelée par [EditableRouteInTripWidget] :
  ///   1. getEstimatedFare  →  nouveau tarif
  ///   2. updateTripRoute   →  (cette méthode) persistance API
  ///   3. refreshMap        →  nouveau tracé carte
 // Dans RideController.dart

Future<Response> updateTripRoute({
  required String tripId,
  required double newFare,
  required String encodedPoly,
}) async {
  final loc = Get.find<LocationController>();
  
  // Récupérer les coordonnées de destination
  String destLat = loc.toAddress?.latitude?.toString() ?? '0';
  String destLng = loc.toAddress?.longitude?.toString() ?? '0';
  String destAddress = loc.toAddress?.address ?? '';
    final String currentEstimatedDistance = estimatedDistance; // déjà dans RideController
  final String currentEstimatedDuration = estimatedDuration; // idem
  
  // Récupérer les arrêts intermédiaires
  List<Map<String, dynamic>> intermediateCoords = [];
  List<String> intermediateAddresses = [];
  
  if (loc.extraOneRoute && loc.extraRouteAddress != null) {
    intermediateCoords.add({
      'lat': loc.extraRouteAddress!.latitude ?? 0,
      'lng': loc.extraRouteAddress!.longitude ?? 0,
    });
    intermediateAddresses.add(loc.extraRouteAddress!.address ?? '');
  }
  
  if (loc.extraTwoRoute && loc.extraRouteTwoAddress != null) {
    intermediateCoords.add({
      'lat': loc.extraRouteTwoAddress!.latitude ?? 0,
      'lng': loc.extraRouteTwoAddress!.longitude ?? 0,
    });
    intermediateAddresses.add(loc.extraRouteTwoAddress!.address ?? '');
  }
  
  if (loc.extraThreeRoute && loc.extraRouteThreeAddress != null) {
    intermediateCoords.add({
      'lat': loc.extraRouteThreeAddress!.latitude ?? 0,
      'lng': loc.extraRouteThreeAddress!.longitude ?? 0,
    });
    intermediateAddresses.add(loc.extraRouteThreeAddress!.address ?? '');
  }
  
  // Convertir en format JSON
  String intermediateCoordsJson = jsonEncode(intermediateCoords.map((c) => [c['lat'], c['lng']]).toList());
  String intermediateAddressesJson = jsonEncode(intermediateAddresses);
  
  return await rideServiceInterface.updateTripRoute(
    tripId: tripId,
    destinationAddress: destAddress,
    destinationLat: destLat,
    destinationLng: destLng,
    estimatedFare: newFare.toString(),
    encodedPolyline: encodedPoly,
    intermediateCoordinates: intermediateCoordsJson,
    middleAddressJson: intermediateAddressesJson,

        estimatedDistance: currentEstimatedDistance, // ← NOUVEAU
    estimatedDuration: currentEstimatedDuration, // ← NOUVEAU
  );
}}



class ThumbnailPathModel{
  final String? path;
  ThumbnailPathModel(this.path);
}



