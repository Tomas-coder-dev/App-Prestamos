class Contacto {
  int? id;
  String nombre;
  String? telefono;
  String? email;

  Contacto({this.id, required this.nombre, this.telefono, this.email});

  factory Contacto.fromMap(Map<String, dynamic> json) => Contacto(
    id: json['id'],
    nombre: json['nombre'],
    telefono: json['telefono'],
    email: json['email'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'telefono': telefono,
    'email': email,
  };
}
