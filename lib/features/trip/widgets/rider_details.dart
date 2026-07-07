
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/contact_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';

class ActivityScreenRiderDetails extends StatefulWidget {
  const ActivityScreenRiderDetails({super.key});

  @override
  State<ActivityScreenRiderDetails> createState() =>
      _ActivityScreenRiderDetailsState();
}

class _ActivityScreenRiderDetailsState
    extends State<ActivityScreenRiderDetails> {
  Timer? _waitTimer;

  /// Secondes écoulées depuis l'arrivée du chauffeur
  int _elapsed = 0;
  bool _timerStarted = false;

  /// Temps de grâce : 3 minutes
  static const int _gracePeriod = 180;

  /// Secondes restantes dans le temps de grâce (180 → 0)
  int get _remaining => (_gracePeriod - _elapsed).clamp(0, _gracePeriod);

  /// Secondes de retard après le temps de grâce
  int get _overtime => (_elapsed - _gracePeriod).clamp(0, 99999);

  /// true = encore dans le temps de grâce
  bool get _inGrace => _elapsed < _gracePeriod;

  @override
  void dispose() {
    _waitTimer?.cancel();
    super.dispose();
  }

  /// Démarre le timer en reprenant depuis [driverArrivesAt] si disponible.
  /// Évite la remise à zéro quand on quitte et revient sur l'écran.
  void _startTimerIfNeeded({String? driverArrivesAt}) {
    if (_timerStarted) return;
    _timerStarted = true;
print("heure d'arriver du chauffeur $driverArrivesAt ");
    // Calculer les secondes déjà écoulées depuis l'arrivée du chauffeur
    if (driverArrivesAt != null &&
        driverArrivesAt.isNotEmpty &&
        driverArrivesAt != 'null') {
      try {
        final DateTime arrivedAt = DateTime.parse(driverArrivesAt);
        final int alreadyElapsed =
            DateTime.now().difference(arrivedAt).inSeconds;
        _elapsed = alreadyElapsed.clamp(0, 99999);
      } catch (_) {
        _elapsed = 0;
      }
    } else {
      _elapsed = 0;
    }

    _waitTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
  }

  void _stopTimer() {
    _waitTimer?.cancel();
    _waitTimer = null;
    _timerStarted = false;
    _elapsed = 0;
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      // driverArrivesAt renseigné = chauffeur arrivé sur place.
      // On masque le badge dès que la course démarre (ongoingRide).
      final bool isArrived =
          rideController.tripDetails?.driverArrivesAt != null &&
          rideController.tripDetails!.driverArrivesAt!.isNotEmpty &&
          rideController.tripDetails!.driverArrivesAt != 'null' &&
          rideController.currentRideState != RideState.ongoingRide;

      if (isArrived) {
        _startTimerIfNeeded(
          driverArrivesAt: rideController.tripDetails?.driverArrivesAt,
        );
      } else {
        if (_timerStarted) _stopTimer();
      }

      final String ratting =
          rideController.tripDetails?.driverAvgRating != null
              ? double.parse(rideController.tripDetails!.driverAvgRating!)
                  .toStringAsFixed(1)
              : '0';

      final String? vehicleColor =
          rideController.tripDetails?.vehicle?.vehicleColor;

      return Column(
        children: [
          // ── Badge arrivée + chrono ──────────────────────────────────
          if (isArrived) ...[

            // ── Bloc principal : badge couleur selon phase ─────────────
            Container(
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _inGrace
                      ? [Colors.green.shade600, Colors.green.shade400]
                      : [Colors.red.shade600, Colors.red.shade400],
                ),
                borderRadius:
                    BorderRadius.circular(Dimensions.paddingSizeSmall),
                boxShadow: [
                  BoxShadow(
                    color: (_inGrace ? Colors.green : Colors.red)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icône
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _inGrace
                          ? Icons.where_to_vote_rounded
                          : Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  // Texte selon phase
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chauffeur arrivé !',
                          style: textBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        Text(
                          _inGrace
                              ? 'Vous avez 3 min pour que la course démarre'
                              : 'Les minutes supplémentaires seront facturées',
                          style: textRegular.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chrono
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _inGrace
                              ? Icons.timer_outlined
                              : Icons.timer_off_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          // Compte à rebours pendant grâce, compte en avant après
                          _inGrace
                              ? _formatTime(_remaining)
                              : '+${_formatTime(_overtime)}',
                          style: textBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Carte chauffeur / véhicule ──────────────────────────────
          Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(Dimensions.paddingSizeSmall),
              border: Border.all(
                width: .75,
                color: isArrived
                    ? (_inGrace
                        ? Colors.green.withOpacity(0.5)
                        : Colors.red.withOpacity(0.5))
                    : Theme.of(context).hintColor.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne chauffeur
                Padding(
                  padding:
                      const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault),
                        child: ImageWidget(
                          height: 50,
                          width: 50,
                          image:
                              rideController.tripDetails?.driver != null
                                  ? '${Get.find<ConfigController>().config!.imageBaseUrl!.profileImageDriver}'
                                      '/${rideController.tripDetails!.driver!.profileImage}'
                                  : '',
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (rideController.tripDetails?.driver != null)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${rideController.tripDetails!.driver!.firstName!} '
                                      '${rideController.tripDetails!.driver!.lastName!}',
                                      style: textMedium.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ContactWidget(
                                    driverId: rideController
                                            .tripDetails?.driver?.id ??
                                        '0',
                                  ),
                                ],
                              ),
                            Text.rich(
                              TextSpan(
                                style: textRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withValues(alpha: 0.8),
                                ),
                                children: [
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.star,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      size: 15,
                                    ),
                                    alignment: PlaceholderAlignment.middle,
                                  ),
                                  TextSpan(
                                    text: ratting,
                                    style: textRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  color: Theme.of(context)
                      .hintColor
                      .withValues(alpha: 0.25),
                ),

                // Ligne véhicule
                Padding(
                  padding:
                      const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: rideController.tripDetails?.vehicle != null
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rideController.tripDetails!.vehicle!
                                        .model!.name!,
                                    style: textMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    rideController.tripDetails!.vehicle!
                                        .licencePlateNumber!,
                                    style: textRegular.copyWith(
                                        fontSize:
                                            Dimensions.fontSizeDefault),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (vehicleColor != null &&
                                      vehicleColor.isNotEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _parseColor(
                                                  vehicleColor),
                                              border: Border.all(
                                                color: Colors.grey
                                                    .withValues(alpha: 0.4),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            vehicleColor,
                                            style: textRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color
                                                  ?.withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Photo modèle agrandie
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                color: rideController.tripDetails?.vehicle
                                            ?.model?.image !=
                                        null
                                    ? Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: 0.15)
                                    : null,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      Dimensions.paddingSizeExtraSmall),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                child: ImageWidget(
                                  height: 80,
                                  width: 80,
                                  image: rideController
                                              .tripDetails!.vehicle !=
                                          null
                                      ? '${Get.find<ConfigController>().config!.imageBaseUrl!.vehicleModel!}/${rideController.tripDetails!.vehicle!.model!.image!}'
                                      : '',
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Color _parseColor(String value) {
    final v = value.trim().toLowerCase();
    final hex = v.replaceAll('#', '');
    if (hex.length == 6) {
      final code = int.tryParse('FF$hex', radix: 16);
      if (code != null) return Color(code);
    }
    const Map<String, Color> named = {
      'blanc': Colors.white,
      'white': Colors.white,
      'noir': Colors.black,
      'black': Colors.black,
      'rouge': Colors.red,
      'red': Colors.red,
      'bleu': Colors.blue,
      'blue': Colors.blue,
      'vert': Colors.green,
      'green': Colors.green,
      'jaune': Colors.yellow,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'gris': Colors.grey,
      'grey': Colors.grey,
      'gray': Colors.grey,
      'marron': Colors.brown,
      'brown': Colors.brown,
      'violet': Colors.purple,
      'purple': Colors.purple,
      'rose': Colors.pink,
      'pink': Colors.pink,
      'beige': Color(0xFFF5F5DC),
      'argent': Colors.blueGrey,
      'silver': Colors.blueGrey,
      'or': Color(0xFFFFD700),
      'gold': Color(0xFFFFD700),
    };
    return named[v] ?? Colors.grey;
  }
}