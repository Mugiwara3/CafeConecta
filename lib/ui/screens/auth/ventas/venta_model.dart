class Venta {
  final String id;
  final String vendedor;
  final String fecha;
  final List<Map<String, dynamic>> cafes;
  final double total;

  Venta({
    required this.id,
    required this.vendedor,
    required this.fecha,
    required this.cafes,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendedor': vendedor,
      'fecha': fecha,
      'cafes': cafes,
      'total': total,
    };
  }

  factory Venta.fromMap(Map<String, dynamic> map) {
    return Venta(
      id: map['id'],
      vendedor: map['vendedor'],
      fecha: map['fecha'],
      cafes: List<Map<String, dynamic>>.from(map['cafes']),
      total: map['total'].toDouble(),
    );
  }
}
