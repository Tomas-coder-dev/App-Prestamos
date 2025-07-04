class Prestamo {
  final int? id;
  final int contactoId;
  final double monto;
  final bool pagado;
  final String? nota;

  Prestamo({
    this.id,
    required this.contactoId,
    required this.monto,
    required this.pagado,
    this.nota,
  });

  Prestamo copyWith({
    int? id,
    int? contactoId,
    double? monto,
    bool? pagado,
    String? nota,
  }) {
    return Prestamo(
      id: id ?? this.id,
      contactoId: contactoId ?? this.contactoId,
      monto: monto ?? this.monto,
      pagado: pagado ?? this.pagado,
      nota: nota ?? this.nota,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactoId': contactoId,
      'monto': monto,
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
      pagado: map['pagado'] == 1,
      nota: map['nota'],
    );
  }
}
