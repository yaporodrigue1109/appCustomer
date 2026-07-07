
// import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';

// class ScheduledRideModel {
//   int? id;
//   String? scheduledAt;
//   String? status;
//   Address? pickupAddress;
//   Address? destinationAddress;
//   List<Address>? intermediateStops;

//   double? estimatedFare;
//   String? vehicleCategoryName;
//   String? estimatedDistance;
//   String? estimatedDuration;
//   String? createdAt;
//   String? updatedAt;

//   ScheduledRideModel({
//     this.id,
//     this.scheduledAt,
//     this.status,
//     this.pickupAddress,
//     this.destinationAddress,
//     this.intermediateStops,
   
//     this.estimatedFare,
//     this.vehicleCategoryName,
//     this.estimatedDistance,
//     this.estimatedDuration,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory ScheduledRideModel.fromJson(Map<String, dynamic> json) {
//     return ScheduledRideModel(
//       id: json['id'],
//       scheduledAt: json['scheduled_at'],
//       status: json['status'],
//       pickupAddress: json['pickup_address'] != null 
//           ? Address.fromJson(json['pickup_address']) 
//           : null,
//       destinationAddress: json['destination_address'] != null 
//           ? Address.fromJson(json['destination_address']) 
//           : null,
//       intermediateStops: json['intermediate_stops'] != null
//           ? List<Address>.from(
//               json['intermediate_stops'].map((x) => Address.fromJson(x))
//             )
//           : null,
      
//       estimatedFare: json['estimated_fare']?.toDouble(),
//       vehicleCategoryName: json['vehicle_category_name'],
//       estimatedDistance: json['estimated_distance'],
//       estimatedDuration: json['estimated_duration'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'scheduled_at': scheduledAt,
//       'status': status,
//       'pickup_address': pickupAddress?.toJson(),
//       'destination_address': destinationAddress?.toJson(),
//       'intermediate_stops': intermediateStops?.map((x) => x.toJson()).toList(),
      
//       'estimated_fare': estimatedFare,
//       'vehicle_category_name': vehicleCategoryName,
//       'estimated_distance': estimatedDistance,
//       'estimated_duration': estimatedDuration,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//     };
//   }
// }



import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';

class ScheduledRideModel {
  String? id;  // Changé de int? à String?
  String? scheduledAt;
  String? status;
  Address? pickupAddress;
  Address? destinationAddress;
  List<Address>? intermediateStops;
  double? estimatedFare;
  String? vehicleCategoryName;
  String? estimatedDistance;
  String? estimatedDuration;
  String? createdAt;
  String? updatedAt;

  ScheduledRideModel({
    this.id,
    this.scheduledAt,
    this.status,
    this.pickupAddress,
    this.destinationAddress,
    this.intermediateStops,
    this.estimatedFare,
    this.vehicleCategoryName,
    this.estimatedDistance,
    this.estimatedDuration,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduledRideModel.fromJson(Map<String, dynamic> json) {
    return ScheduledRideModel(
      id: json['id']?.toString(), // Conversion explicite en String
      scheduledAt: json['scheduled_at'],
      status: json['status'],
      pickupAddress: json['pickup_address'] != null 
          ? Address.fromJson(json['pickup_address']) 
          : null,
      destinationAddress: json['destination_address'] != null 
          ? Address.fromJson(json['destination_address']) 
          : null,
      intermediateStops: json['intermediate_stops'] != null
          ? List<Address>.from(
              json['intermediate_stops'].map((x) => Address.fromJson(x))
            )
          : null,
      estimatedFare: json['estimated_fare']?.toDouble(),
      vehicleCategoryName: json['vehicle_category_name'],
      estimatedDistance: json['estimated_distance']?.toString(), // Conversion en String
      estimatedDuration: json['estimated_duration']?.toString(), // Conversion en String
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduled_at': scheduledAt,
      'status': status,
      'pickup_address': pickupAddress?.toJson(),
      'destination_address': destinationAddress?.toJson(),
      'intermediate_stops': intermediateStops?.map((x) => x.toJson()).toList(),
      'estimated_fare': estimatedFare,
      'vehicle_category_name': vehicleCategoryName,
      'estimated_distance': estimatedDistance,
      'estimated_duration': estimatedDuration,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}