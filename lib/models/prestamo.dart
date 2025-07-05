class Prestamo {
  final int? id;
  final int contactoId;
  final double monto;           // Saldo actual
  final double montoOriginal;   // Monto original al crear el préstamo
  final bool pagado;
  final String? nota;

  Prestamo({
    this.id,
    required this.contactoId,
    required this.monto,
    required this.montoOriginal,
    required this.pagado,
    this.nota,
  });

  Prestamo copyWith({
    int? id,
    int? contactoId,
    double? monto,
    double? montoOriginal,
    bool? pagado,
    String? nota,
  }) {
    return Prestamo(
      id: id ?? this.id,
      contactoId: contactoId ?? this.contactoId,
      monto: monto ?? this.monto,
      montoOriginal: montoOriginal ?? this.montoOriginal,
      pagado: pagado ?? this.pagado,
      nota: nota ?? this.nota,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactoId': contactoId,
      'monto': monto,
      'montoOriginal': montoOriginal,
      'pagado': pagado ? 1 : 0,
      'nota': nota,
    };
  }

  factory Prestamo.fromMap(Map<String, dynamic> map) {
    return Prestamo(
      id: map['id'],
      contactoId: map['contactoId'],
      monto: map['monto'] is int
          ? (map['monto'] as int).toDouble()
          : map['monto'],
      montoOriginal: map['montoOriginal'] is int
          ? (map['montoOriginal'] as int).toDouble()
          : map['montoOriginal'],
      pagado: map['pagado'] == 1,
      nota: map['nota'],
    );
  }
}