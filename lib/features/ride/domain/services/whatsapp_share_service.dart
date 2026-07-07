import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';


class WhatsAppShareService {
  /// Génère et envoie automatiquement le message WhatsApp au bénéficiaire.
  /// Retourne true si WhatsApp a été ouvert, false sinon.
  static Future<bool> sendRideInfoToBeneficiary({
    required String phoneNumber,
    required String beneficiaryName,
    required String driverName,
    required String driverPhone,
    required String vehicleModel,
    required String licensePlate,
    required String tripId,
    required String pickupAddress,
    required String destinationAddress,
    required String estimatedFare,
    required String estimatedDuration,
  }) async {
    final String cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    final String message = _buildMessage(
      beneficiaryName: beneficiaryName,
      driverName: driverName,
      driverPhone: driverPhone,
      vehicleModel: vehicleModel,
      licensePlate: licensePlate,
      tripId: tripId,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      estimatedFare: estimatedFare,
      estimatedDuration: estimatedDuration,
    );

    final String encoded = Uri.encodeComponent(message);
    final Uri uri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encoded');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (_) {}
    return false;
  }

  static String _buildMessage({
    required String beneficiaryName,
    required String driverName,
    required String driverPhone,
    required String vehicleModel,
    required String licensePlate,
    required String tripId,
    required String pickupAddress,
    required String destinationAddress,
    required String estimatedFare,
    required String estimatedDuration,
  }) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return '''
🚖 *Course commandée pour vous !*

Bonjour ${beneficiaryName.isNotEmpty ? beneficiaryName : 'vous'},
Un trajet vient d'être réservé en votre nom depuis l'application SOUTRALY. Voici les informations :

━━━━━━━━━━━━━━━━━━━━
👨‍✈️ *VOTRE CHAUFFEUR*
━━━━━━━━━━━━━━━━━━━━
👤 Nom : $driverName
📞 Téléphone : $driverPhone
🚗 Véhicule : $vehicleModel
🔢 Immatriculation : $licensePlate

━━━━━━━━━━━━━━━━━━━━
📋 *DÉTAILS DU TRAJET*
━━━━━━━━━━━━━━━━━━━━
🆔 Référence : $tripId
📍 Départ : $pickupAddress
🏁 Destination : $destinationAddress
⏱️ Durée estimée : $estimatedDuration
💰 Tarif estimé : $estimatedFare
⏰ Heure de commande : $time

━━━━━━━━━━━━━━━━━━━━
🔒 *Bon voyage !*
━━━━━━━━━━━━━━━━━━━━
''';
  }
}