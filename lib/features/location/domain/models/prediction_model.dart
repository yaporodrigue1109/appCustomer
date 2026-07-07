// class PredictionModel {
//   String? responseCode;
//   String? message;
//   int? totalSize;
//   int? limit;
//   int? offset;
//   Data? data;
//   List<String>? errors;

//   PredictionModel(
//       {this.responseCode,
//         this.message,
//         this.totalSize,
//         this.limit,
//         this.offset,
//         this.data,
//         this.errors});

//   PredictionModel.fromJson(Map<String, dynamic> json) {
//     responseCode = json['response_code'];
//     message = json['message'];
//     totalSize = json['total_size'];
//     limit = json['limit'];
//     offset = json['offset'];
//     data = json['data'] != null ? Data.fromJson(json['data']) : null;
//     errors = json['errors'].cast<String>();
//   }

// }

// class Data {
//   List<Suggestions>? suggestions;

//   Data({this.suggestions});

//   Data.fromJson(Map<String, dynamic> json) {
//     if (json['suggestions'] != null) {
//       suggestions = <Suggestions>[];
//       json['suggestions'].forEach((v) {
//         suggestions!.add(Suggestions.fromJson(v));
//       });
//     }
//   }

// }

// class Suggestions {
//   PlacePrediction? placePrediction;
//    double? distance; // ✅ Ajouter
//   String? distanceText; // ✅ Ajouter

//   Suggestions({this.placePrediction,this.distance,
//     this.distanceText,});

//   Suggestions.fromJson(Map<String, dynamic> json) {
//     placePrediction = json['placePrediction'] != null
//         ? PlacePrediction.fromJson(json['placePrediction'])
//         : null;
//          // ✅ Récupérer la distance depuis le JSON
//     distance = json['distance']?.toDouble();
//     distanceText = json['distance_text'];
//   }

// }

// class PlacePrediction {
//   String? place;
//   String? placeId;
//   Description? text;
//   StructuredFormat? structuredFormat;
//   List<String>? types;

//   PlacePrediction(
//       {this.place, this.placeId, this.text, this.structuredFormat, this.types});

//   PlacePrediction.fromJson(Map<String, dynamic> json) {
//     place = json['place'];
//     placeId = json['placeId'];
//     text = json['text'] != null ? Description.fromJson(json['text']) : null;
//     structuredFormat = json['structuredFormat'] != null
//         ? StructuredFormat.fromJson(json['structuredFormat'])
//         : null;
//     types = json['types'].cast<String>();
//   }


// }

// class Description {
//   String? text;
//   List<Matches>? matches;

//   Description({this.text, this.matches});

//   Description.fromJson(Map<String, dynamic> json) {
//     text = json['text'];
//     if (json['matches'] != null) {
//       matches = <Matches>[];
//       json['matches'].forEach((v) {
//         matches!.add(Matches.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['text'] = text;
//     if (matches != null) {
//       data['matches'] = matches!.map((v) => v.toJson()).toList();
//     }
  
//     return data;
//   }
// }

// class Matches {
//   int? endOffset;

//   Matches({this.endOffset});

//   Matches.fromJson(Map<String, dynamic> json) {
//     endOffset = json['endOffset'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['endOffset'] = endOffset;
    
//     return data;
//   }
// }

// class StructuredFormat {
//   Description? mainText;
//   SecondaryText? secondaryText;


//   StructuredFormat({this.mainText, this.secondaryText
//   });

//   StructuredFormat.fromJson(Map<String, dynamic> json) {
//     mainText =
//     json['mainText'] != null ? Description.fromJson(json['mainText']) : null;
//     secondaryText = json['secondaryText'] != null
//         ? SecondaryText.fromJson(json['secondaryText'])
//         : null;

    
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (mainText != null) {
//       data['mainText'] = mainText!.toJson();
//     }
//     if (secondaryText != null) {
//       data['secondaryText'] = secondaryText!.toJson();
//     }
    
//     return data;
//   }
// }


// class SecondaryText {
//   String? text;

//   SecondaryText({this.text});

//   SecondaryText.fromJson(Map<String, dynamic> json) {
//     text = json['text'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['text'] = text;
//     return data;
//   }
// }



class PredictionModel {
  String? responseCode;
  String? message;
  int? totalSize;
  int? limit;
  int? offset;
  Data? data;
  List<String>? errors;

  PredictionModel(
      {this.responseCode,
        this.message,
        this.totalSize,
        this.limit,
        this.offset,
        this.data,
        this.errors});

  PredictionModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    errors = json['errors'].cast<String>();
  }
}

class Data {
  List<Suggestions>? suggestions;

  Data({this.suggestions});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['suggestions'] != null) {
      suggestions = <Suggestions>[];
      json['suggestions'].forEach((v) {
        suggestions!.add(Suggestions.fromJson(v));
      });
    }
  }
}

class Suggestions {
  PlacePrediction? placePrediction;

  /// Distance à vol d'oiseau (ancienne version, conservée pour compatibilité)
  double? distance;

  /// Distance routière formatée renvoyée par Distance Matrix
  /// ex : "2,3 km" (null si user_location absent de la requête)
  String? distanceText;

  /// Durée de trajet formatée renvoyée par Distance Matrix
  /// ex : "8 min" (null si user_location absent de la requête)
  String? durationText;

  Suggestions({
    this.placePrediction,
    this.distance,
    this.distanceText,
    this.durationText,
  });

  Suggestions.fromJson(Map<String, dynamic> json) {
    placePrediction = json['placePrediction'] != null
        ? PlacePrediction.fromJson(json['placePrediction'])
        : null;
    distance = json['distance']?.toDouble();
    distanceText = json['distance_text'];
    durationText = json['duration_text'];
  }
}

class PlacePrediction {
  String? place;
  String? placeId;
  Description? text;
  StructuredFormat? structuredFormat;
  List<String>? types;

  PlacePrediction(
      {this.place, this.placeId, this.text, this.structuredFormat, this.types});

  PlacePrediction.fromJson(Map<String, dynamic> json) {
    place = json['place'];
    placeId = json['placeId'];
    text = json['text'] != null ? Description.fromJson(json['text']) : null;
    structuredFormat = json['structuredFormat'] != null
        ? StructuredFormat.fromJson(json['structuredFormat'])
        : null;
    types = json['types'].cast<String>();
  }
}

class Description {
  String? text;
  List<Matches>? matches;

  Description({this.text, this.matches});

  Description.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    if (json['matches'] != null) {
      matches = <Matches>[];
      json['matches'].forEach((v) {
        matches!.add(Matches.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    if (matches != null) {
      data['matches'] = matches!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Matches {
  int? endOffset;

  Matches({this.endOffset});

  Matches.fromJson(Map<String, dynamic> json) {
    endOffset = json['endOffset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['endOffset'] = endOffset;
    return data;
  }
}

class StructuredFormat {
  Description? mainText;
  SecondaryText? secondaryText;

  StructuredFormat({this.mainText, this.secondaryText});

  StructuredFormat.fromJson(Map<String, dynamic> json) {
    mainText =
        json['mainText'] != null ? Description.fromJson(json['mainText']) : null;
    secondaryText = json['secondaryText'] != null
        ? SecondaryText.fromJson(json['secondaryText'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (mainText != null) {
      data['mainText'] = mainText!.toJson();
    }
    if (secondaryText != null) {
      data['secondaryText'] = secondaryText!.toJson();
    }
    return data;
  }
}

class SecondaryText {
  String? text;

  SecondaryText({this.text});

  SecondaryText.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    return data;
  }
}