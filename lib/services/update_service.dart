import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  // ── À CONFIGURER ────────────────────────────────────────────────────
  // Bundle ID iOS (ex: "com.monapp.ridesharing")
  static const String _iosBundleId = 'com.soutralyvtc.appclient';
  // Lien direct vers votre app sur le Play Store
  static const String _androidPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.soutralyvtc.appclient';
  // Lien App Store
  // ⚠️ Remplacez VOTRE_APP_ID par l'ID numérique trouvé dans App Store Connect
  static const String _iosAppStoreUrl =
      'https://apps.apple.com/app/6760858066';
  // ────────────────────────────────────────────────────────────────────

  /// Point d'entrée : appeler dans [initState] de HomeScreen
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        await _checkAndroidUpdate(context);
      } else if (Platform.isIOS) {
        await _checkIosUpdate(context);
      }
    } catch (e) {
      debugPrint('UpdateService error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // ANDROID — in_app_update (mise à jour flexible ou immédiate)
  // ══════════════════════════════════════════════════════════════════════
  static Future<void> _checkAndroidUpdate(BuildContext context) async {
    final AppUpdateInfo info = await InAppUpdate.checkForUpdate();

    if (info.updateAvailability == UpdateAvailability.updateAvailable) {
      if (info.immediateUpdateAllowed) {
        // Mise à jour obligatoire (configurée dans la console Play)
        await InAppUpdate.performImmediateUpdate();
      } else if (info.flexibleUpdateAllowed) {
        // Mise à jour flexible : téléchargement en arrière-plan
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      } else {
        // Fallback : dialog personnalisé → ouvre le Play Store
        if (context.mounted) {
          _showUpdateDialog(
            context,
            isForced: false,
            storeUrl: _androidPlayStoreUrl,
          );
        }
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // iOS — comparaison de version via l'API iTunes
  // ══════════════════════════════════════════════════════════════════════
  static Future<void> _checkIosUpdate(BuildContext context) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    final String currentVersion = info.version; // ex: "1.2.3"

    final Uri url = Uri.parse(
        'https://itunes.apple.com/lookup?bundleId=$_iosBundleId');
    final http.Response response =
        await http.get(url).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) return;

    final Map<String, dynamic> json = jsonDecode(response.body);
    final List results = json['results'] ?? [];
    if (results.isEmpty) return;

    final String storeVersion = results[0]['version'] ?? '';

    if (_isNewer(storeVersion, currentVersion)) {
      if (context.mounted) {
        _showUpdateDialog(
          context,
          isForced: false,
          storeUrl: _iosAppStoreUrl,
          currentVersion: currentVersion,
          newVersion: storeVersion,
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // DIALOG de mise à jour (iOS + fallback Android)
  // ══════════════════════════════════════════════════════════════════════
  static void _showUpdateDialog(
    BuildContext context, {
    required bool isForced,
    required String storeUrl,
    String? currentVersion,
    String? newVersion,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isForced,
      builder: (ctx) => WillPopScope(
        onWillPop: () async => !isForced,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Titre
                Text(
                  'Mise à jour disponible',
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // Versions
                if (currentVersion != null && newVersion != null)
                  Text(
                    'Version actuelle : $currentVersion → Nouvelle : $newVersion',
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // Message
                Text(
                  'Une nouvelle version de l\'application est disponible. '
                  'Mettez à jour pour profiter des dernières améliorations '
                  'et corrections.',
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Bouton Mettre à jour
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final Uri uri = Uri.parse(storeUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.paddingSizeSmall),
                      ),
                    ),
                    child: Text(
                      'Mettre à jour',
                      style: textBold.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
                ),

                // Bouton Plus tard (sauf si forcé)
                if (!isForced) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Plus tard',
                      style: textRegular.copyWith(
                        color: Colors.grey[600],
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // HELPER : compare "1.2.3" > "1.2.2"
  // ══════════════════════════════════════════════════════════════════════
  static bool _isNewer(String storeVersion, String currentVersion) {
    try {
      final List<int> store = storeVersion
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final List<int> current = currentVersion
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      for (int i = 0; i < store.length; i++) {
        final int s = i < store.length ? store[i] : 0;
        final int c = i < current.length ? current[i] : 0;
        if (s > c) return true;
        if (s < c) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}