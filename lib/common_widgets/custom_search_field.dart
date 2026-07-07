// import 'package:flutter/material.dart';
// import 'package:ride_sharing_user_app/util/dimensions.dart';
// import 'package:ride_sharing_user_app/util/styles.dart';


// class CustomSearchField extends StatefulWidget {
//   final TextEditingController controller;
//   final String hint;
//   final bool fillColor;
//   final Function(String) onChanged;
//   final FocusNode? focusNode;
//   final VoidCallback? onTap;
//   const CustomSearchField({super.key,
//     required this.controller,
//     required this.hint,
//     required this.onChanged,
//     this.fillColor = false,
//     this.focusNode,
//     this.onTap
//   });

//   @override
//   State<CustomSearchField> createState() => _CustomSearchFieldState();
// }

// class _CustomSearchFieldState extends State<CustomSearchField> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Expanded(
//         child: TextField(
//           cursorColor: Theme.of(context).primaryColor,
//           controller: widget.controller,
//           focusNode: widget.focusNode,
//           textInputAction: TextInputAction.search,
//           enabled: true,
//           onTap: widget.onTap,
//           style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyMedium!.color),
//           decoration: InputDecoration(
//             hintText: widget.hint,
//             hintStyle: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.5)),
//             filled: widget.fillColor,
//             fillColor: Theme.of(context).cardColor,
//             isDense: true,
//             contentPadding: EdgeInsets.zero,
//             focusedBorder:const OutlineInputBorder(
//               borderSide: BorderSide(color: Colors.transparent, width: 0)),
//             enabledBorder: const OutlineInputBorder(
//               borderSide: BorderSide(color: Colors.transparent, width: 0)),

//           ),
//           onChanged: widget.onChanged,

//         ),
//       ),
//     ],);
//   }
// }




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CustomSearchField extends StatelessWidget {
  final FocusNode? focusNode;
  final TextEditingController controller;
  final String hint;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onSuggestionSelected; // AJOUTER CE PARAMÈTRE
  final bool isBorder;

  const CustomSearchField({
    super.key,
    this.focusNode,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onTap,
    this.onSuggestionSelected, // AJOUTER ICI
    this.isBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).hintColor,
        ),
        border: isBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              )
            : InputBorder.none,
        enabledBorder: isBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                borderSide: BorderSide(color: Theme.of(context).disabledColor),
              )
            : InputBorder.none,
        focusedBorder: isBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              )
            : InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: () {
        // Quand l'utilisateur appuie sur "Entrée" ou termine l'édition
        if (onSuggestionSelected != null) {
          onSuggestionSelected!();
        }
      },
    );
  }
}
