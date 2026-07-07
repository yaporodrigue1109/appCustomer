
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/home/screens/home_screen.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/domain/models/navigation_model.dart';
import 'package:ride_sharing_user_app/features/notification/screens/notification_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_screen.dart';
import 'package:ride_sharing_user_app/features/address/screens/my_address.dart';
import 'package:ride_sharing_user_app/features/message/screens/message_list.dart';
import 'package:ride_sharing_user_app/features/my_offer/screens/my_offer_screen.dart';
import 'package:ride_sharing_user_app/features/wallet/screens/wallet_screen.dart';
import 'package:ride_sharing_user_app/features/safety_setup/screens/safety_setup_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/features/profile/screens/edit_profile_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/my_level/screens/my_level_screen.dart';
import 'package:ride_sharing_user_app/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:ride_sharing_user_app/features/settings/screens/setting_screen.dart';
import 'package:ride_sharing_user_app/features/ride/screens/scheduled_rides_screen.dart';


class ExpandableMenu extends StatefulWidget {
  const ExpandableMenu({super.key});

  @override
  State<ExpandableMenu> createState() => _ExpandableMenuState();
}

class _ExpandableMenuState extends State<ExpandableMenu>
    with SingleTickerProviderStateMixin {
  bool _isDrawerOpen = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  late List<NavigationModel> _menuItems;

  @override
  void initState() {
    super.initState();
    _initializeMenuItems();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _initializeMenuItems() {
    _menuItems = [
      NavigationModel(
        name: 'Accueil',
        activeIcon: Images.homeActive,
        inactiveIcon: Images.homeOutline,
        screen: const HomeScreen(),
      ),
      NavigationModel(
        name: 'Activité',
        activeIcon: Images.activityActive,
        inactiveIcon: Images.activityOutline,
        screen: const TripScreen(fromProfile: false),
      ),
      NavigationModel(
        name: 'Notifications',
        activeIcon: Images.notificationActive,
        inactiveIcon: Images.notificationOutline,
        screen: const NotificationScreen(),
      ),
      NavigationModel(
        name: 'Profil',
        activeIcon: Images.profileActive,
        inactiveIcon: Images.profileOutline,
        screen: const ProfileScreen(),
      ),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _toggleDrawer() async {
    if (_isDrawerOpen) {
      await _animationController.reverse();
      _removeOverlay();
    } else {
      _showDrawer();
      _animationController.forward();
    }

    if (mounted) {
      setState(() {
        _isDrawerOpen = !_isDrawerOpen;
      });
    }
  }

  void _showDrawer() {
    _overlayEntry = OverlayEntry(
      builder: (context) => GetBuilder<ProfileController>(
        builder: (profileController) {
          return Stack(
            children: [
              // Overlay semi-transparent
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleDrawer,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        color: Colors.black
                            .withOpacity(0.5 * _animationController.value),
                      );
                    },
                  ),
                ),
              ),

              // Drawer
              Positioned(
                top: 120,
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Material(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,
                      color: Colors.white,
                      child: SafeArea(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                SizedBox(
                                  height: 185,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        height: 175,
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusExtraLarge),
                                          color: Get.isDarkMode
                                              ? Theme.of(context)
                                                  .scaffoldBackgroundColor
                                              : Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.1),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeSmall),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      child: ImageWidget(
                                                        height: 70,
                                                        width: 70,
                                                        image: profileController
                                                                    .profileModel
                                                                    ?.data
                                                                    ?.profileImage !=
                                                                null
                                                            ? '${Get.find<ConfigController>().config!.imageBaseUrl!.profileImage}/'
                                                                '${profileController.profileModel?.data?.profileImage ?? ''}'
                                                            : '',
                                                        placeholder:
                                                            Images.personPlaceholder,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeSmall),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          profileController
                                                              .customerName(),
                                                          style: textBold
                                                              .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeExtraLarge,
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .color!
                                                                .withValues(
                                                                    alpha: 0.9),
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: Dimensions
                                                                .paddingSizeExtraSmall),
                                                        if ((Get.find<ConfigController>()
                                                                    .config
                                                                    ?.levelStatus ??
                                                                false) &&
                                                            profileController
                                                                    .profileModel
                                                                    ?.data
                                                                    ?.level !=
                                                                null)
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "${'level'.tr} : ${profileController.profileModel?.data?.level?.name ?? ''}",
                                                                style: textBold
                                                                    .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .color!
                                                                      .withValues(
                                                                          alpha:
                                                                              0.8),
                                                                  fontSize: Dimensions
                                                                      .fontSizeSmall,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 5),
                                                              SizedBox(
                                                                width: 15,
                                                                height: 15,
                                                                child:
                                                                    ImageWidget(
                                                                  image:
                                                                      "${AppConstants.baseUrl}/storage/app/public/customer/level/"
                                                                      "${profileController.profileModel?.data?.level?.image ?? ''}",
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              '${"your_rating".tr} :',
                                                              style: textBold
                                                                  .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium!
                                                                    .color!
                                                                    .withValues(
                                                                        alpha:
                                                                            0.8),
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 3),
                                                            Text(
                                                              profileController
                                                                      .profileModel!
                                                                      .data!
                                                                      .userRating ??
                                                                  "0",
                                                              style: textBold
                                                                  .copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium!
                                                                    .color!
                                                                    .withValues(
                                                                        alpha:
                                                                            0.8),
                                                              ),
                                                            ),
                                                            const Icon(
                                                                Icons.star,
                                                                size: 12,
                                                                color: Colors
                                                                    .amber),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                _buildColumnItem(
                                                  'total_ride',
                                                  '${profileController.profileModel?.data?.totalRideCount ?? 0}',
                                                  context,
                                                ),
                                                Container(
                                                  width: 1,
                                                  height: 40,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                _buildColumnItem(
                                                  'total_point',
                                                  '${profileController.profileModel?.data?.loyaltyPoints ?? 0}',
                                                  context,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: InkWell(
                                              onTap: () async {
                                                await _animationController
                                                    .reverse();
                                                _removeOverlay();
                                                if (mounted) {
                                                  setState(() {
                                                    _isDrawerOpen = false;
                                                  });
                                                }
                                                Get.to(() =>
                                                    const EditProfileScreen());
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                    Dimensions
                                                        .paddingSizeDefault),
                                                child: SizedBox(
                                                  width: 20,
                                                  child: Image.asset(
                                                      Images.editIcon),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                    width: Dimensions.paddingSizeSmall),

                                // Menu items
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        _buildProfileMenuItem(
                                          title: 'profile',
                                          icon: Images.profileProfile,
                                          onTap: () => _navigateToScreen(
                                              const EditProfileScreen()),
                                        ),

                                        // ── Bouton Devenir Chauffeur mis en avant ──
                                        _buildDriverAppMenuItem(context),

                                        _buildProfileMenuItem(
                                          title: 'my_address',
                                          icon: Images.location,
                                          onTap: () => _navigateToScreen(
                                              const MyAddressScreen()),
                                        ),
                                        _buildProfileMenuItem(
                                          title: 'message',
                                          icon: Images.profileMessage,
                                          onTap: () => _navigateToScreen(
                                              const MessageListScreen()),
                                        ),
                                        // _buildProfileMenuItem(
                                        //   title: 'my_wallet',
                                        //   icon: Images.profileMyWallet,
                                        //   onTap: () => _navigateToScreen(
                                        //       const WalletScreen()),
                                        // ),
                                        _buildProfileMenuItem(
                                          title: 'my_offer',
                                          icon: Images.paymentAndVoucher,
                                          onTap: () => _navigateToScreen(
                                              const MyOfferScreen()),
                                        ),
                                        _buildProfileMenuItem(
                                          title: 'order_history',
                                          icon: Images.profileMyTrip,
                                          onTap: () => _navigateToScreen(
                                              const TripScreen(
                                                  fromProfile: true)),
                                        ),
                                        _buildProfileMenuItem(
                                          title: 'safety',
                                          icon: Images.privacyPolicy,
                                          onTap: () => _navigateToScreen(
                                              const SafetySetupScreen()),
                                        ),

                                        if ((Get.find<ConfigController>()
                                                    .config
                                                    ?.referralEarningStatus ??
                                                false) ||
                                            ((Get.find<ProfileController>()
                                                        .profileModel
                                                        ?.data
                                                        ?.wallet
                                                        ?.referralEarn ??
                                                    0) >
                                                0))
                                          _buildProfileMenuItem(
                                            title: 'refer_and_earn',
                                            icon: Images.referralIcon1,
                                            onTap: () => _navigateToScreen(
                                                const ReferAndEarnScreen()),
                                          ),

                                        if (Get.find<ConfigController>()
                                                .config
                                                ?.levelStatus ??
                                            false)
                                          _buildProfileMenuItem(
                                            title: 'my_level',
                                            icon: Images.myLevelIcon,
                                            onTap: () => _navigateToScreen(
                                                const MyLevelScreen()),
                                          ),

                                        _buildProfileMenuItem(
                                          title: 'settings',
                                          icon: Images.profileSetting,
                                          onTap: () => _navigateToScreen(
                                              const SettingScreen()),
                                        ),

                                        _buildProfileMenuItem(
                                          title: 'schedule_trip',
                                          icon: Images.trafficOnlineIcon,
                                          onTap: () => _navigateToScreen(
                                              const ScheduledRidesScreen()),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // ── Bouton Devenir Chauffeur mis en avant ──────────────────────────────────
  Widget _buildDriverAppMenuItem(BuildContext context) {
    const String playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.soutralyvtc.appchaufeur'; 
    const String appPackage = 'com.soutralyvtc.appchaufeur';

    Future<void> handleTap() async {
      // Ferme le drawer proprement
      await _animationController.reverse();
      _removeOverlay();
      if (mounted) setState(() => _isDrawerOpen = false);

      // Tente d'ouvrir l'app si installée, sinon redirige vers le Play Store
      final Uri appUri = Uri.parse('android-app://$appPackage');
      final Uri storeUri = Uri.parse(playStoreUrl);

      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
      } else {
        await launchUrl(storeUri, mode: LaunchMode.externalApplication);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: handleTap,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.75),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        Images.profileProfile,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'works_driver'.tr,
                          style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColor,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Menu item standard ─────────────────────────────────────────────────────
  Widget _buildProfileMenuItem({
    required String title,
    required String icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    icon,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Text(
                  title.tr,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildColumnItem(String title, String value, BuildContext context) {
    return Column(children: [
      Text(
        value,
        style: textBold.copyWith(
          color: Theme.of(context).primaryColor,
          fontSize: Dimensions.fontSizeExtraLarge,
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
      Text(
        title.tr,
        style: textMedium.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context)
              .textTheme
              .bodyMedium!
              .color!
              .withValues(alpha: 0.8),
        ),
      ),
    ]);
  }

  void _navigateToScreen(Widget screen) async {
    await _animationController.reverse();
    _removeOverlay();
    if (mounted) {
      setState(() {
        _isDrawerOpen = false;
      });
    }
    Get.to(() => screen);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (profileController) {
        return Container(
          key: _buttonKey,
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: AnimatedCrossFade(
              firstChild:
                  const Icon(Icons.menu, color: Colors.white, size: 26),
              secondChild:
                  const Icon(Icons.close, color: Colors.white, size: 26),
              crossFadeState: _isDrawerOpen
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            onPressed: _toggleDrawer,
          ),
        );
      },
    );
  }
}
