import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_shimmer.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/features/set_destination/widget/schedule_date_time_picker_widget.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart'; 

class ScheduledRidesScreen extends StatefulWidget {
  const ScheduledRidesScreen({super.key});

  @override
  State<ScheduledRidesScreen> createState() => _ScheduledRidesScreenState();
}

class _ScheduledRidesScreenState extends State<ScheduledRidesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RideController>().getScheduledRideList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: BodyWidget(
          appBar: AppBarWidget(
            title: 'Mes trajets programmés'.tr,
            showBackButton: true,
            centerTitle: true,
          ),
          body: const ScheduledRidesManager(),
        ),
        floatingActionButton: LayoutBuilder(
          builder: (context, constraints) {
            // Adaptation du FAB selon la largeur de l'écran
            if (constraints.maxWidth < 360) {
              // Petits écrans : FAB circulaire simple
              return FloatingActionButton(
                onPressed: () {
                  Get.to(() => const SetDestinationScreen(rideType: RideType.scheduleRide));
                },
                child: const Icon(Icons.add),
                backgroundColor: Theme.of(context).primaryColor,
              );
            } else {
              // Écrans plus grands : FAB étendu avec texte
              return FloatingActionButton.extended(
                onPressed: () {
                  Get.to(() => const SetDestinationScreen(rideType: RideType.scheduleRide));
                },
                icon: const Icon(Icons.add),
                label: Text('Nouveau trajet'.tr),
                backgroundColor: Theme.of(context).primaryColor,
              );
            }
          },
        ),
        floatingActionButtonLocation: MediaQuery.of(context).size.width < 360
            ? FloatingActionButtonLocation.endFloat
            : FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

// Nouveau widget pour les boutons d'édition/annulation
class _ShowScheduleTripEditCancelButton extends StatelessWidget {
  final String tripId;
  final String? currentStatus;
  const _ShowScheduleTripEditCancelButton({required this.tripId, this.currentStatus});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController){
      return Column(
        children: [
          // Bouton d'édition (uniquement si le statut est 'pending')
          if(currentStatus?.toLowerCase() == 'pending')
            ButtonWidget(
              buttonText: 'edit_schedule'.tr,
              onPressed: () => Get.bottomSheet(
                ScheduleDateTimePickerWidget(
                  fromSetDestinationScreen: true, 
                  tripId: tripId
                ),
                enableDrag: false, 
                isScrollControlled: true,
              ),
            ),

          // Bouton d'annulation (uniquement si le trajet n'est pas déjà annulé)
          if(currentStatus?.toLowerCase() != 'cancelled')
            GetBuilder<RideController>(builder: (rideController){
              return rideController.isLoading ?
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
                ),
              ) :
              ButtonWidget(
                backgroundColor: Theme.of(context).cardColor,
                textColor: Theme.of(context).colorScheme.error,
                buttonText: 'cancel_trip'.tr,
                onPressed: () {
                  _showCancelConfirmationDialog(context, tripId, rideController);
                },
              );
            })
        ],
      );
    });
  }

  void _showCancelConfirmationDialog(BuildContext context, String tripId, RideController rideController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Annuler le trajet'.tr,
            style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          content: Text(
            'Voulez-vous vraiment annuler ce trajet programmé ?'.tr,
            style: textRegular,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Non'.tr,
                style: textMedium.copyWith(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                rideController.tripStatusUpdate(
                  tripId, 
                  'cancelled', 
                  'ride_request_cancelled_successfully',
                  ''
                ).then((value){
                  if(value.statusCode == 200){
                    Get.offAll(const DashboardScreen()); 
                  }
                });
              },
              child: Text(
                'Oui, annuler'.tr,
                style: textMedium.copyWith(color: Colors.red),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
          ),
        );
      },
    );
  }
}

class ScheduledRidesManager extends StatelessWidget {
  const ScheduledRidesManager({super.key});

  String _formatDate(String? dateTime) {
    if (dateTime == null) return 'Date non spécifiée'.tr;
    try {
      DateTime date = DateTime.parse(dateTime);
      // Format plus compact pour les petits écrans
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GetBuilder<RideController>(
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.all(
            screenWidth < 360 
              ? Dimensions.paddingSizeSmall 
              : Dimensions.paddingSizeDefault
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec statistiques ou info
              Container(
                width: Get.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Adaptation selon la largeur disponible
                    if (constraints.maxWidth < 300) {
                      // Très petit écran
                      return Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vos trajets'.tr,
                                    style: textSemiBold.copyWith(fontSize: 14),
                                  ),
                                  Text(
                                    controller.scheduledRides.isEmpty
                                        ? 'Aucun trajet'.tr
                                        : '${controller.scheduledRides.length} trajet(s)'.tr,
                                    style: textRegular.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Écran normal
                      return Column(
                        spacing: Dimensions.paddingSizeSmall,
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          
                          Image.asset(
                            Images.calenderIcon,
                            height: screenWidth < 400 ? 60 : 80,
                            width: screenWidth < 400 ? 60 : 80,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.schedule,
                              size: screenWidth < 400 ? 60 : 80,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          
                          Text(
                            'Vos trajets programmés'.tr,
                            style: textSemiBold.copyWith(
                              fontSize: screenWidth < 400 ? 14 : 16,
                            ),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: Dimensions.paddingSizeSmall,
                              left: Dimensions.paddingSizeSmall,
                              right: Dimensions.paddingSizeSmall,
                            ),
                            child: Text(
                              controller.scheduledRides.isEmpty
                                  ? 'Vous n\'avez aucun trajet programmé pour le moment'.tr
                                  : 'Vous avez ${controller.scheduledRides.length} trajet(s) programmé(s)'.tr,
                              style: textRegular.copyWith(
                                fontSize: screenWidth < 400 ? 10 : 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Titre de la liste
              if (controller.scheduledRides.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  child: Text(
                    'Liste des trajets'.tr,
                    style: textSemiBold.copyWith(
                      fontSize: screenWidth < 400 ? 14 : 16,
                    ),
                  ),
                ),

              // Liste des trajets ou état vide
              Expanded(
                child: controller.isLoading
                  ? const BannerShimmer()
                  : controller.scheduledRides.isEmpty
                      ? _buildEmptyState(screenWidth)
                      : RefreshIndicator(
                          onRefresh: () => controller.getScheduledRideList(),
                          child: ListView.separated(
                            padding: EdgeInsets.only(
                              bottom: screenWidth < 400 ? 60 : 80, // Espace pour le FAB
                            ),
                            itemCount: controller.scheduledRides.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final ride = controller.scheduledRides[index];
                              return _buildRideCard(ride, context, controller, screenWidth);
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(height: Dimensions.paddingSizeSmall);
                            },
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(double screenWidth) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth < 400 ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_send_outlined,
              size: screenWidth < 400 ? 60 : 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              'Aucun trajet programmé'.tr,
              style: textBold.copyWith(
                fontSize: screenWidth < 400 
                  ? Dimensions.fontSizeLarge 
                  : Dimensions.fontSizeOverLarge,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'Vous n\'avez pas encore de trajets programmés.\nAppuyez sur le bouton + pour en créer un.'.tr,
              style: textRegular.copyWith(
                fontSize: screenWidth < 400 
                  ? Dimensions.fontSizeSmall 
                  : Dimensions.fontSizeDefault,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard(dynamic ride, BuildContext context, RideController controller, double screenWidth) {
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
      ),
      child: ExpansionTile(
        collapsedIconColor: Theme.of(context).textTheme.bodyMedium!.color,
        iconColor: Theme.of(context).textTheme.bodyMedium!.color,
        leading: Container(
          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
          ),
          child: Icon(
            Icons.calendar_today,
            color: Theme.of(context).primaryColor,
            size: isSmallScreen ? 14 : 16,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(ride.scheduledAt),
              style: textSemiBold.copyWith(
                fontSize: isSmallScreen 
                  ? Dimensions.fontSizeSmall 
                  : Dimensions.fontSizeDefault,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    ride.pickupAddress?.address ?? 'Adresse de départ non spécifiée'.tr,
                    style: textRegular.copyWith(
                      fontSize: isSmallScreen 
                        ? Dimensions.fontSizeExtraSmall 
                        : Dimensions.fontSizeSmall,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                _buildStatusBadge(ride.status, isSmallScreen),
              ],
            ),
          ],
        ),
        shape: Border(),
        expandedAlignment: Alignment.centerLeft,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
              horizontal: isSmallScreen 
                ? Dimensions.paddingSizeDefault 
                : Dimensions.paddingSizeExtraLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations détaillées
                _buildDetailRow(
                  icon: Icons.location_on,
                  label: 'Départ:'.tr,
                  value: ride.pickupAddress?.address ?? 'Adresse de départ non spécifiée'.tr,
                  isSmallScreen: isSmallScreen,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                _buildDetailRow(
                  icon: Icons.location_on,
                  label: 'Destination:'.tr,
                  value: ride.destinationAddress?.address ?? 'Non spécifiée'.tr,
                  isSmallScreen: isSmallScreen,
                ),
                
                const SizedBox(height: Dimensions.paddingSizeSmall),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        icon: Icons.attach_money,
                        label: 'Prix:'.tr,
                        value: '${ride.estimatedFare?.toStringAsFixed(0) ?? '0'} F',
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                    if (!isSmallScreen) const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: _buildDetailRow(
                        icon: Icons.speed,
                        label: 'Distance:'.tr,
                        value: '${ride.estimatedDistance ?? '0'} km',
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: Dimensions.paddingSizeSmall),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        icon: Icons.timer,
                        label: 'Durée:'.tr,
                        value: '${ride.estimatedDuration ?? '0'} min',
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                    if (!isSmallScreen) const SizedBox(width: Dimensions.paddingSizeSmall),
                    if (ride.vehicleCategoryName != null)
                      Expanded(
                        child: _buildDetailRow(
                          icon: Icons.directions_car,
                          label: 'Véhicule:'.tr,
                          value: ride.vehicleCategoryName!,
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: Dimensions.paddingSizeDefault),
                
                // Nouveaux boutons d'action avec _ShowScheduleTripEditCancelButton
                _ShowScheduleTripEditCancelButton(
                  tripId: ride.id!,
                  currentStatus: ride.status,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isSmallScreen,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon, 
          size: isSmallScreen ? 14 : 16, 
          color: Colors.grey[600]
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: textRegular.copyWith(
                fontSize: isSmallScreen 
                  ? Dimensions.fontSizeExtraSmall 
                  : Dimensions.fontSizeSmall,
                color: Colors.grey[600],
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: textMedium.copyWith(
                    fontSize: isSmallScreen 
                      ? Dimensions.fontSizeExtraSmall 
                      : Dimensions.fontSizeSmall,
                    color: Colors.grey[800],
                  ),
                ),
                TextSpan(
                  text: value,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String? status, bool isSmallScreen) {
    Color color;
    String label;
    
    switch (status?.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'En attente'.tr;
        break;
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmé'.tr;
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Annulé'.tr;
        break;
      case 'completed':
        color = Colors.blue;
        label = 'Terminé'.tr;
        break;
      default:
        color = Colors.grey;
        label = status ?? 'Inconnu'.tr;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : Dimensions.paddingSizeSmall,
        vertical: isSmallScreen ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: textMedium.copyWith(
          fontSize: isSmallScreen 
            ? Dimensions.fontSizeExtraSmall * 0.9 
            : Dimensions.fontSizeExtraSmall,
          color: color,
        ),
      ),
    );
  }
}