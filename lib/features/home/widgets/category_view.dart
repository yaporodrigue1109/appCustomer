

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/category_widget.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/category_shimmer.dart';
import 'package:ride_sharing_user_app/features/parcel/screens/parcel_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/categoty_model.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (categoryController) {
      return SizedBox(
        height: 130,
        width: Get.width,
        child: Center(
          child: Transform.scale(
            scale: 1.2,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                // Catégories - Affiche COURSES avec son image locale
                if (categoryController.categoryList != null &&
                    categoryController.categoryList!.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: categoryController.categoryList!.length > 0 ? 1 : 0,
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final originalCategory = categoryController.categoryList![index];
 
                      // CRÉER UNE COPIE pour l'affichage seulement
                      final displayCategory = Category(
                        id: originalCategory.id,
                        name: "Courses", // Forcer le nom à "Courses"
                        image: Images.courses, // Forcer l'image locale
                      );

                      print("📋 Affichage: ${displayCategory.name} - Image: ${displayCategory.image}");

                      return Container(
                        width: 100,
                        height: 90,
                        child: Transform.scale(
                          scale: 1.5,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 1.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Container avec bordure orange autour du CategoryWidget
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    // border: Border.all(
                                    //   color: Colors.orange, // Bordure orange
                                    //   width: 3, // Épaisseur de la bordure
                                    // ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8), // Pour que le CategoryWidget s'adapte
                                    child: CategoryWidget(
                                      index: index,
                                      category: displayCategory, // Utiliser la copie modifiée
                                      fontSizeText: 10,
                                      onTap: (_) {
                                        // Sauvegarder l'index de la catégorie ORIGINALE (Premium)
                                        Get.find<RideController>().setRideCategoryIndex(index);
                                        Get.to(() => const SetDestinationScreen(
                                          rideType: RideType.regularRide,
                                        ));
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                const CategoryShimmer(),

                // Parcel
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: InkWell(
                    onTap: () => Get.to(() => const ParcelScreen()),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 103,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).hintColor.withOpacity(0.15),
                          ),
                          margin: const EdgeInsets.only(bottom: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: Image.asset(Images.parcel),
                          ),
                        ),
                        Text(
                          'parcel'.tr,
                          style: textSemiBold.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}