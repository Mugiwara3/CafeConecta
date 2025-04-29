import 'package:cloud_firestore/cloud_firestore.dart';

class FarmPlot {
  final String name;
  final double hectares;
  final double altitude;
  final String variety;
  final int plants;

  FarmPlot({
    required this.name,
    required this.hectares,
    required this.altitude,
    required this.variety,
    required this.plants,
  });

  factory FarmPlot.fromMap(Map<String, dynamic> map) {
    return FarmPlot(
      name: map['name'] ?? map['nombre'] ?? '',
      hectares: (map['hectares'] ?? map['matas'] ?? 0).toDouble(),
      altitude: (map['altitude'] ?? map['altura'] ?? 0).toDouble(),
      variety: map['variety'] ?? map['variedad'] ?? '',
      plants: map['plants'] ?? map['matas'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hectares': hectares,
      'altitude': altitude,
      'variety': variety,
      'plants': plants,
    };
  }
}

class Farm {
  final String id;
  final String name;
  final double hectares;
  final double altitude;
  final List<FarmPlot> plots;
  final String ownerId;
  final DateTime createdAt;
  final String department;
  final String municipality;
  final String village;

  Farm({
    required this.id,
    required this.name,
    required this.hectares,
    required this.altitude,
    required this.plots,
    required this.ownerId,
    required this.createdAt,
    required this.department,
    required this.municipality,
    this.village = '',
  });

  factory Farm.fromMap(Map<String, dynamic> map) {
    return Farm(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      hectares: (map['hectares'] ?? 0).toDouble(),
      altitude: (map['altitude'] ?? 0).toDouble(),
      plots: (map['plots'] as List<dynamic>? ?? [])
          .map((plot) => FarmPlot.fromMap((plot as Map).cast<String, dynamic>()))
          .toList(),
      ownerId: map['ownerId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      department: map['department'] ?? '',
      municipality: map['municipality'] ?? '',
      village: map['village'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hectares': hectares,
      'altitude': altitude,
      'plots': plots.map((plot) => plot.toMap()).toList(),
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'department': department,
      'municipality': municipality,
      'village': village,
    };
  }
}