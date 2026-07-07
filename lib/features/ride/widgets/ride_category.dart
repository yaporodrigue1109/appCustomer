// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';
// import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
// import 'package:ride_sharing_user_app/features/home/domain/models/categoty_model.dart';
// import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
// import 'package:ride_sharing_user_app/common_widgets/category_widget.dart';
// import 'package:ride_sharing_user_app/util/styles.dart';

// class RideCategoryWidget extends StatelessWidget {
//   final Function(void)? onTap;
//   const RideCategoryWidget({super.key, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final defaultPrimaryColor = Theme.of(context).primaryColor;
    
//     return GetBuilder<RideController>(
//       builder: (rideController) {
//         return GetBuilder<CategoryController>(
//           builder: (categoryController) {
//             if (categoryController.categoryList != null) {
//               if (categoryController.categoryList!.isNotEmpty) {
                
//                 // DEBUG
//                 print('=== DEBUG: Mapping catégories ↔ tarifs ===');
                
//                 // 1. Créer un Map pour associer NOM DE CATÉGORIE → Prix
//                 final Map<String, String> categoryNamePriceMap = {};
                
//                 // VÉRIFIEZ la structure exacte de fare
//                 // Regardez si fare a un nom de catégorie ou autre identifiant
//                 for (var fare in rideController.fareList) {
//                   print('Fare item: $fare');
                  
//                   // Option A: Si fare a un nom de catégorie
//                   // if (fare.categoryName != null) {
//                   //   categoryNamePriceMap[fare.categoryName!.toLowerCase()] =
//                   //       fare.estimatedFare?.toString() ?? "0";
//                   // }

//                   // Option B: Si fare a vehicleCategoryName
//                   // if (fare.vehicleCategoryName != null) {
//                   //   categoryNamePriceMap[fare.vehicleCategoryName!.toLowerCase()] =
//                   //       fare.estimatedFare?.toString() ?? "0";
//                   // }
//                 }

//                 // 2. Si le Map est vide, ESSAYONS UNE CORRESPONDANCE MANUELLE
//                 // Basé sur l'ordre logique : Eco < Confort < Premium
//                 if (categoryNamePriceMap.isEmpty && rideController.fareList.isNotEmpty) {
//                   print('=== Tentative de mapping manuel ===');
                  
//                   // Trier les tarifs par prix croissant (Eco devrait être moins cher)
//                   final sortedFares = List.from(rideController.fareList);
//                   sortedFares.sort((a, b) {
//                     final priceA = a.estimatedFare ?? 0;
//                     final priceB = b.estimatedFare ?? 0;
//                     return priceA.compareTo(priceB);
//                   });
                  
//                   print('Tarifs triés par prix croissant:');
//                   for (int i = 0; i < sortedFares.length; i++) {
//                     print('  [$i] Prix: ${sortedFares[i].estimatedFare}');
//                   }
                  
//                   // Mapping manuel: le moins cher = Eco, moyen = Confort, plus cher = Premium
//                   if (sortedFares.length >= 3) {
//                     // Assigner manuellement
//                     categoryNamePriceMap['Gbonhi'] = sortedFares[0].estimatedFare?.toString() ?? "0";
//                     categoryNamePriceMap['Choco'] = sortedFares[1].estimatedFare?.toString() ?? "0";
//                     categoryNamePriceMap['Fariman'] = sortedFares[2].estimatedFare?.toString() ?? "0";
                    
//                     print('Mapping manuel:');
//                     print('  Gbonhi -> ${categoryNamePriceMap['Gbonhi']}');
//                     print('  Choco -> ${categoryNamePriceMap['Choco']}');
//                     print('  Fariman -> ${categoryNamePriceMap['Fariman']}');
//                   }
//                 }
                
//                 // 3. Créer une liste de catégories avec leurs prix
//                 final List<Map<String, dynamic>> categoriesWithPrices = [];
                
//                 for (var category in categoryController.categoryList!) {
//                   final originalName = category.name?.toString() ?? '';
//                   final normalizedName = originalName.toLowerCase();
                  
//                   // Récupérer le prix
//                   String price = "0";
                  
//                   if (categoryNamePriceMap.isNotEmpty) {
//                     // Chercher par nom exact
//                     price = categoryNamePriceMap[normalizedName] ?? "0";
                    
//                     // Si pas trouvé, chercher par variations
//                     if (price == "0") {
//                       if (normalizedName.contains('fariman') || normalizedName.contains('courses')) {
//                         price = categoryNamePriceMap['Fariman'] ?? "0";
//                       } else if (normalizedName.contains('choco')) {
//                         price = categoryNamePriceMap['Choco'] ?? "0";
//                       } else if (normalizedName.contains('gbonhi')) {
//                         price = categoryNamePriceMap['Gbonhi'] ?? "0";
//                       }
//                     }
//                   }
                  
//                   categoriesWithPrices.add({
//                     'category': category,
//                     'price': price,
//                     'order': _getCategoryOrder(normalizedName),
//                     'originalName': originalName,
//                   });
                  
//                   print('Catégorie "${originalName}" -> Prix: $price');
//                 }
                
//                 // 4. Trier par ordre souhaité (Eco → Confort → Premium)
//                 categoriesWithPrices.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
                
//                 // 5. Afficher
//                 return SizedBox(
//                   height: 180, // Augmenté de 150 à 180 pour plus d'espace
//                   width: Get.width,
//                   child: ListView.builder(
//                     itemCount: categoriesWithPrices.length,
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     scrollDirection: Axis.horizontal,
//                     itemBuilder: (context, index) {
//                       final item = categoriesWithPrices[index];
//                       final category = item['category'] as Category;
//                       final price = item['price'] as String;
//                       final originalName = item['originalName'] as String;
                      
//                       // Trouver l'index original pour la sélection
//                       final originalIndex = categoryController.categoryList!.indexOf(category);
                      
//                       // Pour "courses" afficher "Premium"
//                       if (originalName.toLowerCase() == "courses") {
//                         category.name = "Fariman";
//                       }
                      
//                       // Déterminer la couleur
//                       Color? categoryColor;
//                       final displayName = category.name?.toString() ?? '';
                      
//                       if (rideController.rideCategoryIndex == originalIndex) {
//                         if (displayName.toLowerCase() == "fariman") {
//                           categoryColor = Colors.green;
//                         } else if (displayName.toLowerCase() == "choco") {
//                           categoryColor = const Color.fromARGB(103, 78, 50, 50);
//                         } else if (displayName.toLowerCase() == "gbonhi") {
//                           categoryColor = Colors.deepOrange;
//                         }
//                       }
                      
//                       // Formater le prix
//                       final formattedPrice = _formatPrice(price);
                      
//                       // Créer le widget
//                       Widget categoryCard = Container(
//                         width: 100, // Augmenté de 85 à 100 pour plus d'espace
//                         margin: const EdgeInsets.symmetric(horizontal: 6.0), // Augmenté de 4 à 6
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             // Catégorie avec texte plus grand
//                             CategoryWidget(
//                               index: originalIndex,
//                               fromSelect: true,
//                               category: category,
//                               isSelected: rideController.rideCategoryIndex == originalIndex,
//                               fontSizeText: 13, // Augmenté de 10 à 12
//                               onTap: (_) {
//                                 _handleCategoryTap(category, originalName, originalIndex, context);
//                               },
//                             ),
                            
//                             // Afficher le prix SEULEMENT si formattedPrice n'est pas vide
//                             if (formattedPrice.isNotEmpty) ...[
//                               const SizedBox(height: 4), // Augmenté de 2 à 4
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), // Augmenté de (4,2) à (6,4)
//                                 decoration: BoxDecoration(
//                                   color: rideController.rideCategoryIndex == originalIndex
//                                       ? (categoryColor ?? defaultPrimaryColor).withOpacity(0.1)
//                                       : Colors.grey.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(6), // Augmenté de 4 à 6
//                                 ),
//                                 child: Text(
//                                   formattedPrice,
//                                   style: TextStyle(
//                                     fontSize: 14, // Augmenté de 12 à 14
//                                     fontWeight: FontWeight.bold,
//                                     color: rideController.rideCategoryIndex == originalIndex
//                                         ? (categoryColor ?? defaultPrimaryColor)
//                                         : Colors.grey[700],
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       );
                      
//                       // Appliquer le thème de couleur si nécessaire
//                       if (categoryColor != null && rideController.rideCategoryIndex == originalIndex) {
//                         return Theme(
//                           data: Theme.of(context).copyWith(
//                             primaryColor: categoryColor,
//                             colorScheme: Theme.of(context).colorScheme.copyWith(
//                               primary: categoryColor,
//                             ),
//                           ),
//                           child: categoryCard,
//                         );
//                       } else {
//                         return categoryCard;
//                       }
//                     },
//                   ),
//                 );
//               } else {
//                 return Center(child: Text('no_category_found'.tr));
//               }
//             } else {
//               return Center(
//                 child: SpinKitCircle(
//                   color: defaultPrimaryColor,
//                   size: 40.0,
//                 ),
//               );
//             }
//           },
//         );
//       },
//     );
//   }
  
//   int _getCategoryOrder(String name) {
//     if (name == 'courses') name = 'gbonhi';
    
//     switch (name) {
//       case 'gbonhi': return 1;
//       case 'choco': return 2;
//       case 'fariman': return 3;
//       default: return 999;
//     }
//   }
  
//   void _handleCategoryTap(Category category, String originalName, int originalIndex, BuildContext context) {
//     if (originalName.toLowerCase() == "courses") {
//       category.name = originalName;
//     }
    
//     Get.find<RideController>().setRideCategoryIndex(originalIndex);
//     onTap?.call(null);
    
//     Future.delayed(Duration.zero, () {
//       if (originalName.toLowerCase() == "courses") {
//         category.name = "Gbonhi";
//       }
//     });
//   }
  
//   // String _formatPrice(String price) {
//   //   try {
//   //     double fare = double.tryParse(price) ?? 0;
//   //     if (fare == 0) return ''; // Retourne chaîne vide si prix est 0
//   //     return '${fare.toStringAsFixed(0)} FCFA';
//   //   } catch (e) {
//   //     return ''; // Retourne chaîne vide en cas d'erreur
//   //   }
//   // }
// // LEs montant doivent etre des multiple de 5
//   String _formatPrice(String price) {
//   try {
//     double fare = double.tryParse(price) ?? 0;
//     if (fare == 0) return ''; // Retourne chaîne vide si prix est 0
    
//     // Arrondir au multiple de 5 supérieur
//     int roundedFare = _roundToMultipleOf5(fare);
    
//     return '$roundedFare F';
//   } catch (e) {
//     return ''; // Retourne chaîne vide en cas d'erreur
//   }
// }

// // Fonction pour arrondir au multiple de 5 supérieur
// int _roundToMultipleOf5(double value) {
//   int intValue = value.ceil(); // Arrondir à l'entier supérieur
//   int remainder = intValue % 5;
  
//   if (remainder == 0) {
//     return intValue; // Déjà multiple de 5
//   } else {
//     return intValue + (5 - remainder); // Ajouter pour atteindre le prochain multiple de 5
//   }
// }

// }




import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/categoty_model.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/category_widget.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RideCategoryWidget extends StatelessWidget {
  final Function(void)? onTap;
  const RideCategoryWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final defaultPrimaryColor = Theme.of(context).primaryColor;
    
    return GetBuilder<RideController>(
      builder: (rideController) {
        return GetBuilder<CategoryController>(
          builder: (categoryController) {
            if (categoryController.categoryList != null) {
              if (categoryController.categoryList!.isNotEmpty) {
                
                // DEBUG
                print('=== DEBUG: Mapping catégories ↔ tarifs ===');
                
                // 1. Créer un Map pour associer NOM DE CATÉGORIE → Prix
                final Map<String, String> categoryNamePriceMap = {};
                
                // VÉRIFIEZ la structure exacte de fare
                // Regardez si fare a un nom de catégorie ou autre identifiant
                for (var fare in rideController.fareList) {
                  print('Fare item: $fare');
                  
                  // Option A: Si fare a un nom de catégorie
                  // if (fare.categoryName != null) {
                  //   categoryNamePriceMap[fare.categoryName!.toLowerCase()] =
                  //       fare.estimatedFare?.toString() ?? "0";
                  // }

                  // Option B: Si fare a vehicleCategoryName
                  // if (fare.vehicleCategoryName != null) {
                  //   categoryNamePriceMap[fare.vehicleCategoryName!.toLowerCase()] =
                  //       fare.estimatedFare?.toString() ?? "0";
                  // }
                }

                // 2. Si le Map est vide, ESSAYONS UNE CORRESPONDANCE MANUELLE
                // Basé sur l'ordre logique : Eco < Confort < Premium
                if (categoryNamePriceMap.isEmpty && rideController.fareList.isNotEmpty) {
                  print('=== Tentative de mapping manuel ===');
                  
                  // Trier les tarifs par prix croissant (Eco devrait être moins cher)
                  final sortedFares = List.from(rideController.fareList);
                  sortedFares.sort((a, b) {
                    final priceA = a.estimatedFare ?? 0;
                    final priceB = b.estimatedFare ?? 0;
                    return priceA.compareTo(priceB);
                  });
                  
                  print('Tarifs triés par prix croissant:');
                  for (int i = 0; i < sortedFares.length; i++) {
                    print('  [$i] Prix: ${sortedFares[i].estimatedFare}');
                  }
                  
                  // Mapping manuel: le moins cher = Eco, moyen = Confort, plus cher = Premium
                  if (sortedFares.length >= 3) {
                    // Assigner manuellement
                    categoryNamePriceMap['gbonhi'] = sortedFares[0].estimatedFare?.toString() ?? "0";
                    categoryNamePriceMap['choco'] = sortedFares[1].estimatedFare?.toString() ?? "0";
                    categoryNamePriceMap['fariman'] = sortedFares[2].estimatedFare?.toString() ?? "0";
                    
                    print('Mapping manuel:');
                    print('  Gbonhi -> ${categoryNamePriceMap['gbonhi']}');
                    print('  Choco -> ${categoryNamePriceMap['choco']}');
                    print('  Fariman -> ${categoryNamePriceMap['fariman']}');
                  }
                }
                
                // 3. Créer une liste de catégories avec leurs prix
                final List<Map<String, dynamic>> categoriesWithPrices = [];
                
                for (var category in categoryController.categoryList!) {
                  final originalName = category.name?.toString() ?? '';
                  final normalizedName = originalName.toLowerCase();
                  
                  // Récupérer le prix
                  String price = "0";
                  
                  if (categoryNamePriceMap.isNotEmpty) {
                    // Chercher par nom exact
                    price = categoryNamePriceMap[normalizedName] ?? "0";
                    
                    // Si pas trouvé, chercher par variations
                    if (price == "0") {
                      if (normalizedName.contains('fariman') || normalizedName.contains('courses')) {
                        price = categoryNamePriceMap['fariman'] ?? "0";
                      } else if (normalizedName.contains('choco')) {
                        price = categoryNamePriceMap['choco'] ?? "0";
                      } else if (normalizedName.contains('gbonhi')) {
                        price = categoryNamePriceMap['gbonhi'] ?? "0";
                      }
                    }
                  }
                  
                  categoriesWithPrices.add({
                    'category': category,
                    'price': price,
                    'order': _getCategoryOrder(normalizedName),
                    'originalName': originalName,
                  });
                  
                  print('Catégorie "${originalName}" -> Prix: $price');
                }
                
                // 4. Trier par ordre souhaité (Eco → Confort → Premium)
                categoriesWithPrices.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
                
                // 5. Afficher
                return SizedBox(
                  height: 150, // ✅ Réduit de 180 à 150
                  width: Get.width,
                  child: ListView.builder(
                    itemCount: categoriesWithPrices.length,
                    padding: const EdgeInsets.symmetric(horizontal: 4.0), // ✅ Réduit de 8 à 4
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final item = categoriesWithPrices[index];
                      final category = item['category'] as Category;
                      final price = item['price'] as String;
                      final originalName = item['originalName'] as String;
                      
                      // Trouver l'index original pour la sélection
                      final originalIndex = categoryController.categoryList!.indexOf(category);
                      
                      // Pour "courses" afficher "Premium"
                      if (originalName.toLowerCase() == "courses") {
                        category.name = "Fariman";
                      }
                      
                      // Déterminer la couleur
                      Color? categoryColor;
                      final displayName = category.name?.toString() ?? '';
                      
                      if (rideController.rideCategoryIndex == originalIndex) {
                        if (displayName.toLowerCase() == "fariman") {
                          categoryColor = Colors.green;
                        } else if (displayName.toLowerCase() == "choco") {
                          categoryColor = const Color.fromARGB(103, 78, 50, 50);
                        } else if (displayName.toLowerCase() == "gbonhi") {
                          categoryColor = Colors.deepOrange;
                        }
                      }
                      
                      // Formater le prix
                      final formattedPrice = _formatPrice(price);
                      
                      // ✅ CRÉER UN WIDGET PLUS COMPACT
                      Widget categoryCard = Container(
                        width: 110, // ✅ Réduit de 100 à 90
                        margin: const EdgeInsets.symmetric(horizontal: 1.0), // ✅ Réduit de 6 à 4
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center, // ✅ Centrer verticalement
                          children: [
                            // ✅ Catégorie agrandie
                            CategoryWidget(
                              index: originalIndex,
                              fromSelect: true,
                              category: category,
                              isSelected: rideController.rideCategoryIndex == originalIndex,
                              fontSizeText: 15, // ✅ Augmenté de 12 à 14
                              onTap: (_) {
                                _handleCategoryTap(category, originalName, originalIndex, context);
                              },
                            ),
                            
                            // ✅ Afficher le prix avec un espacement réduit
                            if (formattedPrice.isNotEmpty) ...[
                             // const SizedBox(height: 2), // ✅ Réduit de 4 à 2
                              Container(
                              //  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), // ✅ Réduit de (6,4) à (4,2)
                                decoration: BoxDecoration(
                                  color: rideController.rideCategoryIndex == originalIndex
                                      ? (categoryColor ?? defaultPrimaryColor).withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4), // ✅ Réduit de 6 à 4
                                ),
                                child: Text(
                                  formattedPrice,
                                  style: TextStyle(
                                    fontSize: 16, // ✅ Réduit de 14 à 12
                                    fontWeight: FontWeight.bold,
                                    color: rideController.rideCategoryIndex == originalIndex
                                        ? (categoryColor ?? defaultPrimaryColor)
                                        : Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                      
                      // Appliquer le thème de couleur si nécessaire
                      if (categoryColor != null && rideController.rideCategoryIndex == originalIndex) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            primaryColor: categoryColor,
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: categoryColor,
                            ),
                          ),
                          child: categoryCard,
                        );
                      } else {
                        return categoryCard;
                      }
                    },
                  ),
                );
              } else {
                return Center(child: Text('no_category_found'.tr));
              }
            } else {
              return Center(
                child: SpinKitCircle(
                  color: defaultPrimaryColor,
                  size: 40.0,
                ),
              );
            }
          },
        );
      },
    );
  }
  
  int _getCategoryOrder(String name) {
    if (name == 'courses') name = 'gbonhi';
    
    switch (name) {
      case 'gbonhi': return 1;
      case 'choco': return 2;
      case 'fariman': return 3;
      default: return 999;
    }
  }
  
  void _handleCategoryTap(Category category, String originalName, int originalIndex, BuildContext context) {
    if (originalName.toLowerCase() == "courses") {
      category.name = originalName;
    }
    
    Get.find<RideController>().setRideCategoryIndex(originalIndex);
    onTap?.call(null);
    
    Future.delayed(Duration.zero, () {
      if (originalName.toLowerCase() == "courses") {
        category.name = "Gbonhi";
      }
    });
  }
  
  // LEs montant doivent être des multiples de 5
  String _formatPrice(String price) {
    try {
      double fare = double.tryParse(price) ?? 0;
      if (fare == 0) return ''; // Retourne chaîne vide si prix est 0
      
      // Arrondir au multiple de 5 supérieur
      int roundedFare = _roundToMultipleOf5(fare);
      
      return '$roundedFare F';
    } catch (e) {
      return ''; // Retourne chaîne vide en cas d'erreur
    }
  }

  // Fonction pour arrondir au multiple de 5 supérieur
  int _roundToMultipleOf5(double value) {
    int intValue = value.ceil(); // Arrondir à l'entier supérieur
    int remainder = intValue % 5;
    
    if (remainder == 0) {
      return intValue; // Déjà multiple de 5
    } else {
      return intValue + (5 - remainder); // Ajouter pour atteindre le prochain multiple de 5
    }
  }
}