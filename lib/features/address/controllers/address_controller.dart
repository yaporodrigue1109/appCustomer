import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/address/domain/services/address_service_interface.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';


class AddressController extends GetxController implements GetxService {
  final AddressServiceInterface addressServiceInterface;
  AddressController({required this.addressServiceInterface});

  List<Address>? addressList;

  bool isLoading = false;
  int? _currentIndex = 0;
  int? get currentIndex => _currentIndex;

  List<AddressTypeModel> addressTypeList = [
    AddressTypeModel('home', Images.homeIcon),
    AddressTypeModel('office', Images.workIcon),
    AddressTypeModel('others', Images.otherIcon),
    ];

  int _selectAddressIndex = 0;

  int get selectAddressIndex => _selectAddressIndex;
  String  selectAddress = 'home';

  void updateAddressIndex(int index, bool notify) {
    _selectAddressIndex = index;
    selectAddress = addressTypeList[_selectAddressIndex].title;
    if(notify) {
      update();
    }
  }

  Future<void> addNewAddress(Address address, {bool updateAddress = false}) async {
    isLoading = true;
    update();
    Response response;
    if(updateAddress){
      response = await addressServiceInterface.update(address);
    }else{
      response = await addressServiceInterface.add(address);
    }
    if(response.statusCode == 200) {
      getAddressList(1);
      Get.back();
      isLoading = false;
      Get.find<LocationController>().clearAddAddress();
      showCustomSnackBar(updateAddress ?'address_updated_successfully'.tr : 'address_added_successfully'.tr, isError: false);
    }else{
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();

  }

  Future<void> getAddressList(int offset) async {
    isLoading = true;

    Response? response = await addressServiceInterface.getList(offset : offset);
    if(response!.statusCode == 200 && response.body['data'] != null){
      addressList = [];
      isLoading = false;
      addressList!.addAll(AddressModel.fromJson(response.body).data!);
    }else{
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();

  }

  Future<void> deleteAddress(String addressId) async {
    isLoading = true;
    update();
    Response? response = await addressServiceInterface.delete(addressId);
    if(response!.statusCode == 200){
      Get.back();
      isLoading = false;
      getAddressList(1);
      showCustomSnackBar('address_deleted_successfully'.tr, isError: false);
    }else{
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();

  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  Timer? _timer;
  void updateLastLocation(){
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async{
      var location = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.high)
      );
      await addressServiceInterface.updateLastLocation(location.latitude.toString(), location.longitude.toString(), Get.find<LocationController>().zoneID ?? '');
    });
  }




/// Sauvegarde une adresse si elle n'existe pas déjà (comparaison par coordonnées)
Future<void> saveAddressIfNotExists(Address address) async {
  if (address.address == null || address.latitude == null || address.longitude == null) return;

  // Charger la liste si elle n'est pas encore chargée
  if (addressList == null) {
    await getAddressList(1);
  }

  // Vérifier si une adresse avec des coordonnées proches existe déjà
  final alreadyExists = addressList?.any((existing) {
    if (existing.latitude == null || existing.longitude == null) return false;
    final latDiff = (existing.latitude! - address.latitude!).abs();
    final lngDiff = (existing.longitude! - address.longitude!).abs();
    return latDiff < 0.0001 && lngDiff < 0.0001; // ~10 mètres de tolérance
  }) ?? false;

  if (alreadyExists) return; // Déjà enregistrée, on skip

  // Construire l'adresse à sauvegarder
  final toSave = Address(
    address: address.address,
    latitude: address.latitude,
    longitude: address.longitude,
    addressLabel: 'others', // label par défaut
    contactPersonName: Get.find<ProfileController>().profileModel?.data?.firstName ?? '',
    contactPersonPhone: Get.find<ProfileController>().profileModel?.data?.phone ?? '',
  );

  final response = await addressServiceInterface.add(toSave);
  if (response.statusCode == 200) {
    await getAddressList(1); // Rafraîchir la liste
  }
}
}





class AddressTypeModel{
  final String title;
  final String icon;

  AddressTypeModel(this.title, this.icon);
}