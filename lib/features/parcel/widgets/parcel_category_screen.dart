
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/custom_title.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:shimmer/shimmer.dart';

class ParcelCategoryView extends StatelessWidget {
  final bool isDetails;
  const ParcelCategoryView({super.key, this.isDetails = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParcelController>(builder: (parcelController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDetails)
            CustomTitle(
              title: "select_your_parcel_type",
              color: Theme.of(context).primaryColor,
            ),

          SizedBox(
            height: 120,
            child: parcelController.parcelCategoryList != null
                ? parcelController.parcelCategoryList!.isNotEmpty
                    ? ListView.builder(
                        itemCount: parcelController.parcelCategoryList!.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final isSelected = parcelController.selectedParcelCategory == index;
                          return _ParcelCategoryItem(
                            index: index,
                            isSelected: isSelected,
                            parcelController: parcelController,
                          );
                        },
                      )
                    : _EmptyState()
                : const ParcelCategoryShimmer(),
          ),
        ],
      );
    });
  }
}

// ─── Item de catégorie ────────────────────────────────────────────────────────

class _ParcelCategoryItem extends StatelessWidget {
  final int index;
  final bool isSelected;
  final ParcelController parcelController;

  const _ParcelCategoryItem({
    required this.index,
    required this.isSelected,
    required this.parcelController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => parcelController.updateParcelCategoryIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
        width: 88,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Stack(
          children: [
            // ── Contenu ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image avec fond doux
                  Container(
                    height: 59,
                    width: 59,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.12)
                          : Theme.of(context).hintColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        child: ImageWidget(
                          image:
                              '${Get.find<ConfigController>().config!.imageBaseUrl?.parcel}/${parcelController.parcelCategoryList![index].image}',
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  // Nom
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      parcelController.parcelCategoryList![index].name!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: textSemiBold.copyWith(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.8),
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Badge check ──────────────────────────────────────────────────
            if (isSelected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  height: 18,
                  width: 18,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── État vide ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined,
              color: Theme.of(context).hintColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'no_parcel_category_found'.tr,
            style: textSemiBold.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer ──────────────────────────────────────────────────────────────────

class ParcelCategoryShimmer extends StatelessWidget {
  const ParcelCategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[50]!,
          child: Container(
            margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            width: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Container(height: 10, width: 60, color: Colors.white),
                const SizedBox(height: 4),
                Container(height: 10, width: 40, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
