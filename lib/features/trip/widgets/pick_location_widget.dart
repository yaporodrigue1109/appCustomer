import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

enum LocationType {
  from,
  to,
  extraOne,
  extraTwo,
  extraThree
}

class PickLocationWidget extends StatelessWidget {
  final LocationType locationType;
  final dynamic rideDetails;
  final FocusNode? focusNode;
  final TextEditingController textEditingController;
  final bool isShowCrossButton;
  final String textFieldHint;
  final Function() locationIconTap;
  final Function() textFieldTap;
  final Function(String)? onChanged;  // AJOUTER CE PARAMÈTRE
  final Function()? onClear;           // AJOUTER CE PARAMÈTRE

  const PickLocationWidget({
    Key? key,
    required this.locationType,
    this.rideDetails,
    this.focusNode,
    required this.textEditingController,
    required this.isShowCrossButton,
    required this.textFieldHint,
    required this.locationIconTap,
    required this.textFieldTap,
    this.onChanged,    // AJOUTER ICI
    this.onClear,      // AJOUTER ICI
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      focusNode: focusNode,
      onTap: textFieldTap,
      onChanged: onChanged,  // UTILISER LE PARAMÈTRE
      decoration: InputDecoration(
        hintText: textFieldHint,
        hintStyle: TextStyle(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).hintColor,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeSmall,
          horizontal: Dimensions.paddingSizeSmall,
        ),
        suffixIcon: isShowCrossButton && textEditingController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, size: 18),
          onPressed: () {
            textEditingController.clear();
            if (onClear != null) onClear!();  // UTILISER LE PARAMÈTRE
          },
        )
            : null,
      ),
    );
  }
}