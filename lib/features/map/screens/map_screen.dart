
                    import 'dart:async';
                    import 'package:flutter/material.dart';
                    import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
                    import 'package:get/get.dart';
                    import 'package:google_maps_flutter/google_maps_flutter.dart';
                    import 'package:just_the_tooltip/just_the_tooltip.dart';
                    import 'package:permission_handler/permission_handler.dart' as perm;
                    import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dart';
                    import 'package:ride_sharing_user_app/features/map/widget/custom_icon_card.dart';
                    import 'package:ride_sharing_user_app/features/map/widget/discount_coupon_bottomsheet.dart';
                    import 'package:ride_sharing_user_app/features/safety_setup/controllers/safety_alert_controller.dart';
                    import 'package:ride_sharing_user_app/features/safety_setup/widgets/safety_alert_bottomsheet_widget.dart';
                    import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
                    import 'package:ride_sharing_user_app/features/parcel/widgets/parcel_expendable_bottom_sheet.dart';
                    import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
                    import 'package:ride_sharing_user_app/features/ride/widgets/ride_expendable_bottom_sheet.dart';
                    import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
                    import 'package:ride_sharing_user_app/theme/theme_controller.dart';
                    import 'package:ride_sharing_user_app/util/app_constants.dart';
                    import 'package:ride_sharing_user_app/util/dimensions.dart';
                    import 'package:ride_sharing_user_app/util/images.dart';
                    import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
                    import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
                    import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
                    import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
                    import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
                    import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
                    import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
                    import 'package:ride_sharing_user_app/util/styles.dart'; 
                    import 'package:ride_sharing_user_app/features/payment/screens/review_screen.dart';

                    enum MapScreenType { ride, splash, parcel, location }

                    class MapScreen extends StatefulWidget {
                      final MapScreenType fromScreen;
                      final bool isShowCurrentPosition;
                      final bool showRideForOtherPrompt;

                      const MapScreen({
                        super.key,
                        required this.fromScreen,
                        this.isShowCurrentPosition = true,
                        this.showRideForOtherPrompt = false,
                      });

                      @override
                      State<MapScreen> createState() => _MapScreenState();
                    }

                    class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
                      GoogleMapController? _mapController;
                      GlobalKey<ExpandableBottomSheetState> key =
                          GlobalKey<ExpandableBottomSheetState>();
                      final Completer<GoogleMapController> _controller = Completer();

                      // ── Bénéficiaire ──────────────────────────────────────────────
                      final TextEditingController _editNameController = TextEditingController();
                      final TextEditingController _editPhoneController = TextEditingController();
                      List<contacts.Contact> _cachedContacts = [];
                      bool _hasLoadedContacts = false;
                      bool _isLoadingContacts = false;
                     // ✅ Ajouter ces variables
                    bool _isFollowingLocation = true;
                    bool _isUserInteracting = false;
                    Timer? _recenterTimer;

                        
                      // ──────────────────────────────────────────────────────────────

                      @override
                      void initState() {
                        super.initState();
                        WidgetsBinding.instance.addObserver(this);
                        Get.find<MapController>().setContainerHeight(
                            (widget.fromScreen == MapScreenType.parcel) ? 200 : 260, false);

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Future.delayed(const Duration(milliseconds: 1000), () {
                            Get.find<MapController>().initializeMapOnStart();
                          });
                        });
                      }

                      @override
                      void didChangeAppLifecycleState(AppLifecycleState state) {
                        super.didChangeAppLifecycleState(state);
                        if (state == AppLifecycleState.resumed) {
                          _setMapCurrentRoutes();
                        }
                      }

                      @override
                      void dispose() {
                        _mapController?.dispose();
                        _editNameController.dispose();
                        _editPhoneController.dispose();
                        _recenterTimer?.cancel();
                        WidgetsBinding.instance.removeObserver(this);
                        Get.find<MapController>().mapController?.dispose();
                        super.dispose();
                      }

                      // ══════════════════════════════════════════════════════════════
                      //  BÉNÉFICIAIRE – carte d'affichage
                      // ══════════════════════════════════════════════════════════════

                      /// Carte affichée en haut de la carte lorsque la course est pour quelqu'un d'autre.
                      Widget _buildBeneficiaryInfoCard(LocationController locationController,
                          RideController rideController) {
                        if (!locationController.isRideForOther ||
                            rideController.currentRideState != RideState.initial) {
                          return const SizedBox.shrink();
                        }



                        final String name =
                            locationController.beneficiaryName?.isNotEmpty == true
                                ? locationController.beneficiaryName!
                                : 'Nom non renseigné';
                        final String phone =
                            locationController.beneficiaryPhone.isNotEmpty
                                ? locationController.beneficiaryPhone
                                : 'Numéro non renseigné';

                        return Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Icône bénéficiaire
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Nom + Numéro
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                              children: [
                                                Text(
                                                  'Course pour ',
                                                  style: textRegular.copyWith(
                                                    fontSize: Dimensions.fontSizeSmall,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    name,
                                                    style: textSemiBold.copyWith(
                                                      fontSize: Dimensions.fontSizeSmall,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(Icons.phone, size: 12, color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Text(
                                              phone,
                                              style: textRegular.copyWith(
                                                fontSize: Dimensions.fontSizeSmall,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Bouton Modifier
                                  InkWell(
                                    onTap: () => _showEditBeneficiarySheet(locationController),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 14,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Modifier',
                                            style: textMedium.copyWith(
                                              fontSize: 11,
                                              color: Theme.of(context).primaryColor,
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
                      }

                      // ══════════════════════════════════════════════════════════════
                      //  BÉNÉFICIAIRE – bottom sheet d'édition
                      // ══════════════════════════════════════════════════════════════

                      void _showEditBeneficiarySheet(LocationController locationController) {
                        // Pré-remplir avec les valeurs actuelles
                        _editNameController.text = locationController.beneficiaryName ?? '';
                        _editPhoneController.text = locationController.beneficiaryPhone;

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) {
                            return StatefulBuilder(
                              builder: (ctx, setSheetState) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius:
                                        const BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  padding: EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    top: 20,
                                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Barre de titre
                                      Row(
                                        children: [
                                          Icon(Icons.person_pin,
                                              color: Theme.of(context).primaryColor),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Modifier le bénéficiaire',
                                              style: textSemiBold.copyWith(
                                                  fontSize: Dimensions.fontSizeLarge),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            icon: const Icon(Icons.close),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Vous pouvez modifier le nom et le numéro ou choisir un autre contact.',
                                        style: textRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Champ Nom
                                      Text('Nom du bénéficiaire',
                                          style: textMedium.copyWith(
                                              fontSize: Dimensions.fontSizeSmall)),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _editNameController,
                                        decoration: InputDecoration(
                                          hintText: 'Ex: John Doe',
                                          prefixIcon: Icon(Icons.person,
                                              color: Theme.of(context).primaryColor, size: 18),
                                          filled: true,
                                          fillColor:
                                              Theme.of(context).hintColor.withOpacity(0.05),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.paddingSizeSmall),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: Dimensions.paddingSizeDefault,
                                              vertical: Dimensions.paddingSizeSmall),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Champ Numéro + bouton contacts
                                      Text('Numéro du bénéficiaire',
                                          style: textMedium.copyWith(
                                              fontSize: Dimensions.fontSizeSmall)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _editPhoneController,
                                              keyboardType: TextInputType.phone,
                                              decoration: InputDecoration(
                                                hintText: 'Ex: +225 xx xx xx xx xx',
                                                prefixIcon: Icon(Icons.phone,
                                                    color: Theme.of(context).primaryColor,
                                                    size: 18),
                                                filled: true,
                                                fillColor: Theme.of(context)
                                                    .hintColor
                                                    .withOpacity(0.05),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(
                                                      Dimensions.paddingSizeSmall),
                                                  borderSide: BorderSide.none,
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: Dimensions.paddingSizeDefault,
                                                    vertical: Dimensions.paddingSizeSmall),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          // Bouton sélectionner depuis les contacts
                                          InkWell(
                                            onTap: () async {
                                              setSheetState(() => _isLoadingContacts = true);
                                              final picked = await _pickContactFromSheet(ctx);
                                              setSheetState(() => _isLoadingContacts = false);
                                              if (picked != null) {
                                                _editNameController.text =
                                                    picked['name'] ?? '';
                                                _editPhoneController.text =
                                                    picked['phone'] ?? '';
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(
                                                    Dimensions.paddingSizeSmall),
                                              ),
                                              child: _isLoadingContacts
                                                  ? SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Theme.of(context).primaryColor,
                                                      ),
                                                    )
                                                  : Icon(Icons.contacts,
                                                      color: Theme.of(context).primaryColor,
                                                      size: 20),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),

                                      // Bouton Confirmer
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            final newName = _editNameController.text.trim();
                                            final newPhone = _editPhoneController.text.trim();

                                            if (newPhone.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text('Veuillez saisir un numéro de téléphone'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            locationController.setBeneficiaryName(newName);
                                            locationController.setBeneficiaryPhone(newPhone);
                                            locationController.update();

                                            Navigator.pop(ctx);

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Bénéficiaire mis à jour : $newName ($newPhone)'),
                                                backgroundColor: Colors.green,
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );

                                            // Rafraîchir l'affichage de la carte
                                            setState(() {});
                                          },
                                          icon: const Icon(Icons.check, color: Colors.white),
                                          label: Text(
                                            'Confirmer',
                                            style: textSemiBold.copyWith(color: Colors.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).primaryColor,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }

                      // ══════════════════════════════════════════════════════════════
                      //  CONTACTS – sélection depuis la liste du téléphone
                      // ══════════════════════════════════════════════════════════════

                      /// Ouvre un sélecteur de contact et retourne {name, phone} ou null.
                      Future<Map<String, String>?> _pickContactFromSheet(
                          BuildContext sheetCtx) async {
                        try {
                          final status = await perm.Permission.contacts.request();
                          if (status != perm.PermissionStatus.granted) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Permission contacts refusée'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return null;
                          }

                          // Charger les contacts si pas encore en cache
                          if (!_hasLoadedContacts) {
                            final list = await contacts.FlutterContacts.getAll(
                              properties: {
                                contacts.ContactProperty.phone,
                                contacts.ContactProperty.name,
                              },
                            );
                            _cachedContacts =
                                list.where((c) => c.phones.isNotEmpty).toList();
                            _hasLoadedContacts = true;
                          }

                          if (_cachedContacts.isEmpty) return null;

                          // Afficher la liste de contacts dans un dialog
                          final result = await showDialog<Map<String, String>>(
                            context: context,
                            builder: (dialogCtx) {
                              List<contacts.Contact> filtered = List.from(_cachedContacts);
                              final searchCtrl = TextEditingController();

                              return StatefulBuilder(
                                builder: (dialogCtx, setDialogState) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          // Titre
                                          Row(
                                            children: [
                                              Icon(Icons.contacts,
                                                  color: Theme.of(context).primaryColor),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Choisir un contact',
                                                  style: textSemiBold.copyWith(
                                                      fontSize: Dimensions.fontSizeLarge),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () => Navigator.pop(dialogCtx),
                                                icon: const Icon(Icons.close),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Recherche
                                          TextField(
                                            controller: searchCtrl,
                                            onChanged: (q) {
                                              final query = q.toLowerCase();
                                              setDialogState(() {
                                                filtered = query.isEmpty
                                                    ? List.from(_cachedContacts)
                                                    : _cachedContacts.where((c) {
                                                        final nameMatch = c.displayName
                                                                ?.toLowerCase()
                                                                .contains(query) ==
                                                            true;
                                                        final phoneMatch = c.phones.any((p) =>
                                                            p.number.toLowerCase().contains(query));
                                                        return nameMatch || phoneMatch;
                                                      }).toList();
                                              });
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Rechercher un contact',
                                              prefixIcon: const Icon(Icons.search),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(Dimensions.paddingSizeDefault),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey[100],
                                              contentPadding: const EdgeInsets.symmetric(
                                                  vertical: Dimensions.paddingSizeSmall),
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Liste
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: filtered.length,
                                              itemBuilder: (_, index) {
                                                final contact = filtered[index];
                                                final name = contact.displayName ?? 'Sans nom';
                                                final phone = contact.phones.first.number;

                                                return ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.1),
                                                    child: Text(
                                                      name.isNotEmpty
                                                          ? name[0].toUpperCase()
                                                          : '?',
                                                      style: TextStyle(
                                                        color: Theme.of(context).primaryColor,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(name, style: textMedium),
                                                  subtitle: Text(phone,
                                                      style: textRegular.copyWith(
                                                          fontSize: Dimensions.fontSizeSmall,
                                                          color: Colors.grey[600])),
                                                  trailing: Icon(Icons.chevron_right,
                                                      color: Colors.grey[400]),
                                                  onTap: () => Navigator.pop(
                                                      dialogCtx, {'name': name, 'phone': phone}),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );

                          return result;
                        } catch (e) {
                          debugPrint('Erreur contacts: $e');
                          return null;
                        }
                      }

                      // ══════════════════════════════════════════════════════════════
                      //  BUILD
                      // ══════════════════════════════════════════════════════════════

                      @override
                      Widget build(BuildContext context) {
                      
                        return SafeArea(
                          
                          top: false,
                          child: PopScope(
                            canPop: Navigator.canPop(context),
                            onPopInvokedWithResult: (didPop, value) {
                              if (didPop) {
                                Future.delayed(const Duration(milliseconds: 500)).then((onValue) {
                                  if (Get.find<RideController>().currentRideState.name ==
                                          AppConstants.findingRider ||
                                      Get.find<ParcelController>().currentParcelState.name ==
                                          AppConstants.findingRider) {
                                    Get.offAll(() => const DashboardScreen());
                                  }
                                });
                              } else {
                                Get.offAll(() => const DashboardScreen());
                              }
                            },
                            child: Scaffold(
                              resizeToAvoidBottomInset: false,
                              body: GetBuilder<RideController>(
                                builder: (rideController) {
                                  return Stack(
                                    children: [
                                      BodyWidget(
                                        topMargin: 0,
                                        appBar: AppBarWidget(
                                          title: widget.fromScreen == MapScreenType.parcel
                                              ? 'your_parcel'.tr
                                              : _getAppbarTitle(rideController),
                                          subTitle: widget.fromScreen == MapScreenType.parcel
                                              ? null
                                              : rideController.isLoading
                                                  ? 'refreshing_date'.tr
                                                  : _getAppbarSubTitle(rideController),
                                          centerTitle: true,
                                          onBackPressed: () {
                                            if (Navigator.canPop(context)) {
                                              if (Get.find<RideController>()
                                                          .currentRideState
                                                          .name ==
                                                      AppConstants.findingRider ||
                                                  Get.find<ParcelController>()
                                                          .currentParcelState
                                                          .name ==
                                                      AppConstants.findingRider) {
                                                Get.offAll(() => const DashboardScreen());
                                              } else {
                                                Get.back();
                                              }
                                            } else {
                                              Get.offAll(() => const DashboardScreen());
                                            }
                                          },
                                        ),
                                        body: GetBuilder<MapController>(
                                          builder: (mapController) {
                                            return ExpandableBottomSheet(
                                              key: key,
                                              background: GetBuilder<RideController>(
                                                builder: (rideController) {
                                                  return Stack(
                                                    children: [
                                                    
Padding(
  padding: EdgeInsets.only(bottom: mapController.sheetHeight - 20),
  child: GetBuilder<LocationController>(
    builder: (locationController) {
      // ✅ Utiliser la position réelle de l'utilisateur si disponible
      final bool hasValidPosition = locationController.position.latitude != 0;
      final LatLng initialTarget = hasValidPosition
          ? LatLng(
              locationController.position.latitude,
              locationController.position.longitude,
            )
          : Get.find<MapController>().defaultPosition;
      
      return GoogleMap(
        style: Get.isDarkMode
            ? Get.find<ThemeController>().darkMap
            : Get.find<ThemeController>().lightMap,
        initialCameraPosition: CameraPosition(
          target: initialTarget,
          zoom: hasValidPosition ? 15 : 12,
        ),
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);
          mapController.mapController = controller;
          _mapController = controller;

          // ✅ Attendre un peu puis centrer sur la position
          await Future.delayed(const Duration(milliseconds: 300));
          await mapController.centerMapOnMyLocation();

          if (rideController.currentRideState.name == AppConstants.findingRider ||
              rideController.currentRideState.name == AppConstants.riseFare) {
            mapController.initializeData();
            if (rideController.tripDetails?.pickupCoordinates != null) {
              mapController.setOwnCurrentLocation(LatLng(
                rideController.tripDetails!.pickupCoordinates!.coordinates![1],
                rideController.tripDetails!.pickupCoordinates!.coordinates![0],
              ));
            }
          } else if (rideController.currentRideState.name == AppConstants.initial) {
            mapController.getPolyline();
          } else if (rideController.currentRideState.name == AppConstants.completeRide) {
            mapController.initializeData();
          } else {
            mapController.initializeData();
            mapController.setMarkersInitialPosition();
            rideController.startLocationRecord();
          }
        },
        minMaxZoomPreference: const MinMaxZoomPreference(0, AppConstants.mapZoom),
        markers: Set<Marker>.of(mapController.markers),
        polylines: Set<Polyline>.of(mapController.polylines.values),
        zoomControlsEnabled: false,
        compassEnabled: false,
        trafficEnabled: mapController.isTrafficEnable,
        indoorViewEnabled: true,
        mapToolbarEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
      );
    },
  ),
),

                                                      // Boutons de contrôle (côté droit)
                                                      // Positioned(
                                                      //   bottom: Get.height * 0.34,
                                                      //   right: 0,
                                                      //   child: Align(
                                                      //     alignment: Alignment.bottomRight,
                                                      //     child: Column(
                                                      //       children: [
                                                      //         Tooltip(
                                                      //           message:
                                                      //               'Centrer sur la Côte d\'Ivoire',
                                                      //           child: CustomIconCard(
                                                      //             icon: Images.mapLocationIcon,
                                                      //             iconColor: Colors.orange,
                                                      //             onTap: () async {
                                                      //               await mapController
                                                      //                   .centerMapOnIvoryCoast();
                                                      //             },
                                                      //           ),
                                                      //         ),
                                                      //         const SizedBox(
                                                      //             height:
                                                      //                 Dimensions.paddingSizeSmall),
                                                      //         GetBuilder<LocationController>(
                                                      //           builder: (locationController) {
                                                      //             return Tooltip(
                                                      //               message:
                                                      //                   'Centrer sur ma position',
                                                      //               child: CustomIconCard(
                                                      //                 icon:
                                                      //                     Images.currentLocation,
                                                      //                 iconColor: Theme.of(context)
                                                      //                     .primaryColor,
                                                      //                 onTap: () async {
                                                      //                   await mapController
                                                      //                       .centerMapOnMyLocation();
                                                      //                 },
                                                      //               ),
                                                      //             );
                                                      //           },
                                                      //         ),
                                                      //       ],
                                                      //     ),
                                                      //   ),
                                                      // ),

                                                      // Trafic
                                                      // Positioned(
                                                      //   bottom: Get.height * 0.40,
                                                      //   right: 0,
                                                      //   child: Align(
                                                      //     alignment: Alignment.bottomRight,
                                                      //     child: Tooltip(
                                                      //       message: mapController.isTrafficEnable
                                                      //           ? 'Désactiver le trafic'
                                                      //           : 'Activer le trafic',
                                                      //       child: CustomIconCard(
                                                      //         icon: mapController.isTrafficEnable
                                                      //             ? Images.trafficOnlineIcon
                                                      //             : Images.trafficOfflineIcon,
                                                      //         iconColor:
                                                      //             mapController.isTrafficEnable
                                                      //                 ? Theme.of(context)
                                                      //                     .colorScheme
                                                      //                     .secondaryContainer
                                                      //                 : Theme.of(context).hintColor,
                                                      //         onTap: () =>
                                                      //             mapController.toggleTrafficView(),
                                                      //       ),
                                                      //     ),
                                                      //   ),
                                                      // ),

                                                      // Coupon
                                                      // if (_isShowCouponButton(rideController))
                                                      //   Positioned(
                                                      //     bottom: Get.height * 0.46,
                                                      //     right: 0,
                                                      //     child: Align(
                                                      //       alignment: Alignment.bottomRight,
                                                      //       child: Tooltip(
                                                      //         message: 'Voir les offres',
                                                      //         child: CustomIconCard(
                                                      //           icon: Images.offerMapIcon,
                                                      //           iconColor: Theme.of(context)
                                                      //               .colorScheme
                                                      //               .inverseSurface,
                                                      //           onTap: () {
                                                      //             Get.bottomSheet(
                                                      //               const DiscountAndCouponBottomSheet(),
                                                      //               backgroundColor:
                                                      //                   Theme.of(context).cardColor,
                                                      //               isDismissible: false,
                                                      //             );
                                                      //           },
                                                      //         ),
                                                      //       ),
                                                      //     ),
                                                      //   ),

                                                      // Alerte sécurité
                                                      // if (_isSafetyFeatureActive())
                                                      //   Positioned(
                                                      //     bottom: Get.height * 0.52,
                                                      //     right: 0,
                                                      //     child: Align(
                                                      //       alignment: Alignment.bottomRight,
                                                      //       child: JustTheTooltip(
                                                      //         backgroundColor: Get.isDarkMode
                                                      //             ? Theme.of(context).primaryColor
                                                      //             : Theme.of(context)
                                                      //                 .textTheme
                                                      //                 .bodyMedium!
                                                      //                 .color,
                                                      //         controller: rideController
                                                      //             .justTheController,
                                                      //         preferredDirection:
                                                      //             AxisDirection.right,
                                                      //         tailLength: 10,
                                                      //         tailBaseWidth: 20,
                                                      //         content: Container(
                                                      //           width: 130,
                                                      //           padding: const EdgeInsets.all(
                                                      //               Dimensions.paddingSizeSmall),
                                                      //           child: Text(
                                                      //             'safety_alert_sent'.tr,
                                                      //             style: textRegular.copyWith(
                                                      //               color: Colors.white,
                                                      //               fontSize:
                                                      //                   Dimensions.fontSizeSmall,
                                                      //             ),
                                                      //           ),
                                                      //         ),
                                                      //         child: Tooltip(
                                                      //           message: 'Alerte de sécurité',
                                                      //           child: GetBuilder<
                                                      //               SafetyAlertController>(
                                                      //             builder:
                                                      //                 (safetyAlertController) {
                                                      //               return CustomIconCard(
                                                      //                 icon: safetyAlertController
                                                      //                             .currentState ==
                                                      //                         SafetyAlertState
                                                      //                             .afterSendAlert
                                                      //                     ? Images.shieldCheckIcon
                                                      //                     : Images
                                                      //                         .safelyShieldIcon2,
                                                      //                 iconColor: safetyAlertController
                                                      //                             .currentState ==
                                                      //                         SafetyAlertState
                                                      //                             .afterSendAlert
                                                      //                     ? Colors.white
                                                      //                     : Theme.of(context)
                                                      //                         .primaryColor,
                                                      //                 backgroundColor: safetyAlertController
                                                      //                             .currentState ==
                                                      //                         SafetyAlertState
                                                      //                             .afterSendAlert
                                                      //                     ? Colors.red
                                                      //                     : null,
                                                      //                 onTap: () {
                                                      //                   Get.bottomSheet(
                                                      //                     isScrollControlled: true,
                                                      //                     const SafetyAlertBottomSheetWidget(),
                                                      //                     backgroundColor:
                                                      //                         Theme.of(context)
                                                      //                             .cardColor,
                                                      //                     isDismissible: false,
                                                      //                   );
                                                      //                 },
                                                      //               );
                                                      //             },
                                                      //           ),
                                                      //         ),
                                                      //       ),
                                                      //     ),
                                                      //   ),


                                                      // ✅ UN SEUL Positioned pour tous les boutons
Positioned(
  bottom: mapController.sheetHeight + 12,
  right: 0,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [

      // Sécurité (en haut si actif)
      if (_isSafetyFeatureActive())
        GetBuilder<SafetyAlertController>(
          builder: (safetyAlertController) {
            return Column(
              children: [
                JustTheTooltip(
                  backgroundColor: Get.isDarkMode
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyMedium!.color,
                  controller: rideController.justTheController,
                  preferredDirection: AxisDirection.right,
                  tailLength: 10,
                  tailBaseWidth: 20,
                  content: Container(
                    width: 130,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Text(
                      'safety_alert_sent'.tr,
                      style: textRegular.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                  child: CustomIconCard(
                    icon: safetyAlertController.currentState == SafetyAlertState.afterSendAlert
                        ? Images.shieldCheckIcon
                        : Images.safelyShieldIcon2,
                    iconColor: safetyAlertController.currentState == SafetyAlertState.afterSendAlert
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    backgroundColor: safetyAlertController.currentState == SafetyAlertState.afterSendAlert
                        ? Colors.red
                        : null,
                    onTap: () {
                      Get.bottomSheet(
                        isScrollControlled: true,
                        const SafetyAlertBottomSheetWidget(),
                        backgroundColor: Theme.of(context).cardColor,
                        isDismissible: false,
                      );
                    },
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],
            );
          },
        ),

      // Coupon (si visible)
      if (_isShowCouponButton(rideController))
        Column(
          children: [
            CustomIconCard(
              icon: Images.offerMapIcon,
              iconColor: Theme.of(context).colorScheme.inverseSurface,
              onTap: () {
                Get.bottomSheet(
                  const DiscountAndCouponBottomSheet(),
                  backgroundColor: Theme.of(context).cardColor,
                  isDismissible: false,
                );
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],
        ),

      // Trafic
      CustomIconCard(
        icon: mapController.isTrafficEnable
            ? Images.trafficOnlineIcon
            : Images.trafficOfflineIcon,
        iconColor: mapController.isTrafficEnable
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).hintColor,
        onTap: () => mapController.toggleTrafficView(),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      // Centrer Côte d'Ivoire
      CustomIconCard(
        icon: Images.mapLocationIcon,
        iconColor: Colors.orange,
        onTap: () async => await mapController.centerMapOnIvoryCoast(),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      // Centrer ma position
      CustomIconCard(
        icon: Images.currentLocation,
        iconColor: Theme.of(context).primaryColor,
        onTap: () async => await mapController.centerMapOnMyLocation(),
      ),

    ],
  ),
),

                                                      // ── PROMPT "commander pour quelqu'un d'autre" (question initiale) ──
                                                      if (widget.showRideForOtherPrompt &&
                                                          !Get.find<LocationController>()
                                                              .isRideForOther &&
                                                          rideController.currentRideState ==
                                                              RideState.initial)
                                                        Positioned(
                                                          top: 20,
                                                          left: 10,
                                                          right: 10,
                                                          child: _buildRideForOtherPrompt(),
                                                        ),

                                                      // ── CARTE BÉNÉFICIAIRE (affiché quand un contact est sélectionné) ──
                                                      GetBuilder<LocationController>(
                                                        builder: (locationController) {
                                                          return _buildBeneficiaryInfoCard(
                                                              locationController, rideController);
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                              persistentContentHeight: mapController.sheetHeight,
                                              expandableContent: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  widget.fromScreen == MapScreenType.parcel
                                                      ? GetBuilder<RideController>(
                                                          builder: (parcelController) {
                                                            return ParcelExpendableBottomSheet(
                                                                expandableKey: key);
                                                          },
                                                        )
                                                      : (widget.fromScreen ==
                                                                  MapScreenType.ride ||
                                                              widget.fromScreen ==
                                                                  MapScreenType.splash)
                                                          ? GetBuilder<RideController>(
                                                              builder: (rideController) {
                                                                return RideExpendableBottomSheet(
                                                                    expandableKey: key);
                                                              },
                                                            )
                                                          : const SizedBox(),
                                                  SizedBox(
                                                      height:
                                                          MediaQuery.of(context).viewInsets.bottom),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      widget.fromScreen == MapScreenType.location
                                          ? Positioned(
                                              child: Align(
                                                alignment: Alignment.bottomCenter,
                                                child: SizedBox(
                                                  height: 70,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(
                                                        Dimensions.paddingSizeDefault),
                                                    child: ButtonWidget(
                                                      buttonText: 'set_location'.tr,
                                                      onPressed: () => Get.back(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }

                      // ══════════════════════════════════════════════════════════════
                      //  PROMPT "Cette course est pour vous ?" (déjà existant)
                      // ══════════════════════════════════════════════════════════════

                      Widget _buildRideForOtherPrompt() {
                        final locationController = Get.find<LocationController>();

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.help_outline,
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Cette course est pour vous ?',
                                      style: textSemiBold.copyWith(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Vous avez modifié le point de départ. Souhaitez-vous commander pour quelqu\'un d\'autre ?',
                                style: textRegular.copyWith(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        locationController.hasShownRideForOtherPrompt = true;
                                        setState(() {});
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Course pour vous-même'),
                                            duration: Duration(seconds: 1),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Pour moi',
                                            style:
                                                textMedium.copyWith(color: Colors.grey[700]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        locationController.setRideForOther(true);
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Pour quelqu\'un d\'autre',
                                            style: textMedium.copyWith(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      locationController.setDontAskAgain(true);
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Vous ne serez plus averti'),
                                          duration: Duration(seconds: 2),
                                          backgroundColor: Colors.grey,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Ne plus me demander',
                                      style: textRegular.copyWith(
                                          fontSize: 12, color: Colors.grey[500]),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  TextButton(
                                    onPressed: () {
                                      locationController.hasShownRideForOtherPrompt = true;
                                      setState(() {});
                                    },
                                    child: Text(
                                      'Fermer',
                                      style: textRegular.copyWith(
                                          fontSize: 12, color: Colors.grey[500]),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }

                      // ══════════════════════════════════════════════════════════════
                      //  HELPERS
                      // ══════════════════════════════════════════════════════════════

                      bool _isSafetyFeatureActive() {
                        return ((Get.find<ConfigController>().config?.safetyFeatureStatus ??
                                false) &&
                            (Get.find<RideController>().currentRideState.name ==
                                AppConstants.ongoingRide) &&
                            Get.find<RideController>().tripDetails?.type != AppConstants.parcel);
                      }

                      String _getAppbarTitle(RideController rideController) {
                        if (rideController.currentRideState == RideState.initial) {
                          return 'chose_a_vehicle'.tr;
                        } else if (rideController.currentRideState == RideState.outForPickup ||
                            rideController.currentRideState == RideState.otpSent) {
                          return 'oth_the_way_to_pickup'.tr;
                        } else if (rideController.currentRideState == RideState.ongoingRide) {
                          return 'ongoing'.tr;
                        }else if (rideController.currentRideState == RideState.arrived) {
                          return 'arrived'.tr;
                        }
                        // else if (rideController.currentRideState == RideState.accepted) {
                        //   return 'accepted'.tr;
                        // }
                        
                         else if (rideController.currentRideState == RideState.riseFare) {
                          return 'rise_fare'.tr;
                        } else if (rideController.currentRideState == RideState.findingRider) {
                          return 'finding_drider'.tr;
                        } else {
                          return 'your_trip'.tr;
                        }
                      }

                      // String? _getAppbarSubTitle(RideController rideController) {
                      //   if (rideController.currentRideState == RideState.ongoingRide ||
                      //       rideController.currentRideState == RideState.outForPickup ||
                      //       rideController.currentRideState == RideState.otpSent) {
                      //     return '${rideController.tripDetails?.type == AppConstants.parcel ? 'parcel'.tr : 'trip'.tr} #${rideController.tripDetails?.refId}';
                      //   } else {
                      //     return null;
                      //   }
                      // }

                      String? _getAppbarSubTitle(RideController rideController) {
                        if (rideController.currentRideState == RideState.ongoingRide ||
                            rideController.currentRideState == RideState.outForPickup ||
                            rideController.currentRideState == RideState.otpSent) {
                          final refId = rideController.tripDetails?.refId;
                          // ✅ Ne pas afficher si refId est null
                          if (refId == null) return null;
                          return '${rideController.tripDetails?.type == AppConstants.parcel ? 'parcel'.tr : 'trip'.tr} #$refId';
                        }
                        return null;
                      }

                    }

                    bool _isShowCouponButton(RideController rideController) {
                      if ((rideController.tripDetails?.type == AppConstants.parcel) &&
                          Get.find<ParcelController>().currentParcelState ==
                              ParcelDeliveryState.initial) {
                        return true;
                      } else if ((rideController.tripDetails?.type != AppConstants.parcel) &&
                          rideController.currentRideState == RideState.initial) {
                        return true;
                      } else {
                        return false;
                      }
                    }

                    void _setMapCurrentRoutes() {
                      RideController rideController = Get.find<RideController>();
                      MapController mapController = Get.find<MapController>();
                      if (rideController.currentTripDetails?.id == null) return;
                      rideController
                          .getRideDetails(rideController.currentTripDetails!.id!)
                          .then((value) {
                        if (value.statusCode == 200) {
                          if (rideController.currentTripDetails!.type == AppConstants.parcel) {
                            if (rideController.currentTripDetails!.currentStatus ==
                                AppConstants.pending) {
                              Get.find<ParcelController>()
                                  .updateParcelState(ParcelDeliveryState.findingRider);
                              mapController.getPolyline();
                            } else if (rideController.currentTripDetails!.currentStatus ==
                                AppConstants.accepted) {
                              Get.find<ParcelController>()
                                  .updateParcelState(ParcelDeliveryState.otpSent);
                              mapController.getPolyline();
                              rideController.startLocationRecord();
                               mapController.notifyMapController();
                            } else if (rideController.currentTripDetails!.currentStatus ==
                                AppConstants.ongoing) {
                              Get.find<ParcelController>()
                                  .updateParcelState(ParcelDeliveryState.parcelOngoing);
                              mapController.getPolyline();
                              rideController.startLocationRecord();
                              mapController.notifyMapController();
                              if (rideController.currentTripDetails!.parcelInformation?.payer ==
                                      AppConstants.sender &&
                                  rideController.currentTripDetails!.paymentStatus == 'unpaid') {
                                Get.off(() => const PaymentScreen(fromParcel: true));
                               
                              }
                            } else {
                              Get.offAll(() => const DashboardScreen());
                            }
                          } else {
                            if (rideController.currentTripDetails!.currentStatus ==
                                AppConstants.pending) {
                              rideController.updateRideCurrentState(RideState.findingRider);
                              mapController.getPolyline();
                            } else if (rideController.currentTripDetails!.currentStatus ==
                                AppConstants.outForPickup) {
                              rideController.updateRideCurrentState(RideState.outForPickup);
                              mapController.getPolyline();
                              rideController.startLocationRecord();
                              mapController.notifyMapController();
                            } else if (rideController.currentTripDetails!.currentStatus ==
                                AppConstants.ongoing) {
                              rideController.updateRideCurrentState(RideState.ongoingRide);
                              mapController.getPolyline();
                              rideController.startLocationRecord();
                              mapController.notifyMapController();
                              }
                          else if (rideController.currentTripDetails!.currentStatus ==
                                AppConstants.accepted) {
                              rideController.updateRideCurrentState(RideState.outForPickup);
                              mapController.getPolyline();
                              rideController.startLocationRecord();
                              mapController.notifyMapController();
                            

                            }else if (rideController.currentTripDetails!.currentStatus ==
                                AppConstants.arrived) {
                              rideController.updateRideCurrentState(RideState.arrived);
                              mapController.getPolyline();
                              rideController.startLocationRecord();
                              mapController.notifyMapController();
                            } 
                            else if ((rideController.currentTripDetails!.currentStatus ==
                                        AppConstants.completed &&
                                    rideController.currentTripDetails!.paymentStatus ==
                                        AppConstants.unPaid) ||
                                (rideController.currentTripDetails!.currentStatus ==
                                        AppConstants.cancelled &&
                                    rideController.currentTripDetails!.paymentStatus ==
                                        AppConstants.unPaid &&
                                    rideController.currentTripDetails!.paidFare! > 0)) {
                              Get.off(() => const PaymentScreen(fromParcel: false));
                               //final String tripId = rideController.currentTripDetails?.id ?? '';
                              //   Get.offAll(() => ReviewScreen(tripId: tripId));
                            } else {
                              Get.offAll(() => const DashboardScreen());
                            }
                          }
                        }
                      });
                    }


