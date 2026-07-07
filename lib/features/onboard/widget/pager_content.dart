
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class PagerContent extends StatelessWidget {
  const PagerContent({
    super.key, 
    required this.image, 
    required this.text1, 
    required this.text2, 
    required this.text3, 
    required this.text4, 
    required this.index
  });
  
  final String image;
  final String text1;
  final String text2;
  final String text3;
  final String text4;
  final int index;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    if(index != 3) {
      return Stack(
        children: [
          // Image en fond d'écran
          Positioned.fill(
            child: Image.asset(
              image,
              fit: BoxFit.contain, // L'image couvre tout l'espace
              width: Get.width ,
              height: size.height,
            ),
          ),
          
       
        ],
      );
    }

    // Dernière page avec image en fond
    return Stack(
      children: [
        // Image en fond d'écran
        Positioned.fill(
          child: Image.asset(
            image,
            fit: BoxFit.cover,
            width: Get.width,
            height: size.height,
          ),
        ),
        
      
      ],
    );
  }
}