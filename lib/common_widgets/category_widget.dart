
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/categoty_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CategoryWidget extends StatelessWidget {
  final Category category;
  final bool? isSelected;
  final bool fromSelect;
  final int index;
  final double fontSizeText;
  final Function(void)? onTap;
  final String? price;

  const CategoryWidget({
    super.key,
    required this.category,
    this.isSelected,
    this.fromSelect = false,
    required this.index,
    this.fontSizeText = 0,
    this.onTap,
    this.price,
  });

  @override
  Widget build(BuildContext context) {
    final rideController = Get.find<RideController>();
    final locationController = Get.find<LocationController>();

    // Détecter si on est sur SetDestinationScreen
    final bool isOnSetDestination = ModalRoute.of(context)?.settings.name == '/set-destination' ||
        Get.currentRoute.contains('set-destination');

    // Vérifier si on doit afficher les prix
    final bool shouldShowPrice = fromSelect &&
        !isOnSetDestination &&
        _hasDestinationSearched(locationController) &&
        _hasFareCalculated(rideController);

    // Obtenir le prix seulement si on doit l'afficher
    final categoryPrice = shouldShowPrice ? (price ?? _getCategoryPrice(rideController, index)) : null;

    return InkWell(
      onTap: () {
        rideController.setRideCategoryIndex(index);
        if (!fromSelect) {
          Get.to(() => const SetDestinationScreen());
        }
        onTap?.call(null);
      },
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            // Conteneur de l'image
            Container(
              height: isSelected != null ? 80 : 70,
              width: isSelected != null ? 80 : 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: (isSelected != null && isSelected!)
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Theme.of(context).hintColor.withOpacity(0.1),
                border: Border.all(
                  color: (isSelected != null && isSelected!)
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: _buildImage(context),
                  ),
                  if (isSelected ?? false)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          Images.offerIcon,
                          height: 12,
                          width: 12,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              category.name ?? '',
              style: textSemiBold.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                fontSize: fontSizeText == 0 ? Dimensions.fontSizeSmall : fontSizeText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (!isOnSetDestination && fromSelect && categoryPrice != null && categoryPrice.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  _formatPrice(categoryPrice),
                  style: textBold.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeExtraSmall,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final String? imagePath = category.image;
    final String categoryName = category.name?.toLowerCase() ?? '';

    print("🔍 CategoryWidget - Nom: ${category.name}, Image path: $imagePath");

    // CAS 1: Image null ou vide -> placeholder
    if (imagePath == null || imagePath.isEmpty) {
      return Image.asset(Images.carPlaceholder, fit: BoxFit.cover);
    }

    // CAS 2: "Courses" -> asset local
    if (categoryName == "courses" || categoryName == "Courses") {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(Images.carPlaceholder, fit: BoxFit.cover),
      );
    }

    // CAS 3: "Premium" -> URL réseau (même traitement que les autres)
    // Pour Premium, on utilise l'URL du serveur, PAS l'asset
    print("🌐 Chargement URL réseau pour ${category.name}: $imagePath");

    final configController = Get.find<ConfigController>();
    final String baseUrl = configController.config?.imageBaseUrl?.vehicleCategory ?? '';

    // Construire l'URL complète
    String fullImageUrl = imagePath;
    if (!imagePath.startsWith('http') && baseUrl.isNotEmpty) {
      String cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      String cleanImagePath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
      fullImageUrl = '$cleanBaseUrl$cleanImagePath';
    }

    print("🌐 URL complète pour ${category.name}: $fullImageUrl");

    return ImageWidget(
      image: fullImageUrl,
      height: double.infinity,
      width: double.infinity,
      placeholder: Images.carPlaceholder,
      radius: 0,
      fit: BoxFit.cover,
    );
  }

  bool _hasDestinationSearched(LocationController locationController) {
    return locationController.toAddress != null &&
        locationController.toAddress?.address?.isNotEmpty == true;
  }

  bool _hasFareCalculated(RideController rideController) {
    return rideController.fareList.isNotEmpty;
  }

  String _getCategoryPrice(RideController rideController, int index) {
    if (rideController.fareList.isEmpty || index >= rideController.fareList.length) {
      return "0";
    }
    try {
      final fareModel = rideController.fareList[index];
      return fareModel.estimatedFare?.toString() ?? "0";
    } catch (e) {
      return "0";
    }
  }

  String _formatPrice(String price) {
    try {
      final value = double.tryParse(price) ?? 0;
      if (value > 0) {
        final formattedValue = value.toStringAsFixed(0);
        final buffer = StringBuffer();
        for (int i = 0; i < formattedValue.length; i++) {
          if (i > 0 && (formattedValue.length - i) % 3 == 0) {
            buffer.write(' ');
          }
          buffer.write(formattedValue[i]);
        }
        return ''; // Ne pas afficher le prix
      }
      return '';
    } catch (_) {
      return '';
    }
  }
}