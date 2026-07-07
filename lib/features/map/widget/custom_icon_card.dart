
/*

import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class CustomIconCard extends StatelessWidget {
  final String icon;
  final Function()? onTap;
  final Color? iconColor;
  final Color? backGroundColor;
  const CustomIconCard({
    super.key, required this.icon, this.onTap,
    this.iconColor,this.backGroundColor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: .25, color: Theme.of(context).cardColor),
              borderRadius: BorderRadius.circular(100),
              color: backGroundColor ?? Theme.of(context).cardColor
            ),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: SizedBox(
                width: Dimensions.iconSizeLarge,
                child: Image.asset(icon, color: iconColor),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

*/

import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class CustomIconCard extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final Function onTap;
  final Color? backgroundColor; // AJOUTEZ CE PARAMÈTRE (notez le nom en camelCase)

  const CustomIconCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: () => onTap(),
        child: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).cardColor, // UTILISEZ backgroundColor ici
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.2),
                blurRadius: 5,
                spreadRadius: 1,
              )
            ],
          ),
          child: Center(
            child: Image.asset(
              icon,
              height: 20,
              width: 20,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}