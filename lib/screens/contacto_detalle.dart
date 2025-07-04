import 'package:flutter/cupertino.dart';
import '../models/contacto.dart';
import '../models/prestamo.dart';
import '../db/database_helper.dart';

class ContactoDetalleScreen extends StatefulWidget {
  final Contacto contacto;
  const ContactoDetalleScreen({super.key, required this.contacto});

  @override
  State<ContactoDetalleScreen> createState() => _ContactoDetalleScreenState();
}

class _ContactoDetalleScreenState extends State<ContactoDetalleScreen> {
  late final TextEditingController _telefonoController;
  late final TextEditingController _emailController;
  List<Prestamo> _prestamos = [];

  @override
  void initState() {
    super.initState();
    _telefonoController = TextEditingController(text: widget.contacto.telefono);
    _emailController = TextEditingController(text: widget.contacto.email);
    _loadPrestamos();
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadPrestamos() async {
    final prestamos = await DatabaseHelper.instance.getPrestamos(
      contactoId: widget.contacto.id,
    );
    if (!mounted) return;
    setState(() {
      _prestamos = prestamos;
    });
  }

  Future<void> _saveContacto() async {
    final contacto = Contacto(
      id: widget.contacto.id,
      nombre: widget.contacto.nombre,
      telefono: _telefonoController.text,
      email: _emailController.text,
    );
    await DatabaseHelper.instance.updateContacto(contacto);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final prestamosActivos = _prestamos.where((p) => !p.pagado).toList();
    final prestamosAntiguos = _prestamos.where((p) => p.pagado).toList();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.darkBackgroundGray.withAlpha(242),
        middle: const Text('Detalle del Contacto'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveContacto,
          child: const Icon(
            CupertinoIcons.check_mark_circled,
            color: CupertinoColors.activeBlue,
            size: 28,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: CupertinoColors.darkBackgroundGray.withAlpha(230),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoTextFormFieldRow(
                      controller: TextEditingController(
                        text: widget.contacto.nombre,
                      ),
                      placeholder: 'Nombre',
                      enabled: false,
                      prefix: const Icon(
                        CupertinoIcons.person,
                        color: CupertinoColors.systemBlue,
                      ),
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    CupertinoTextFormFieldRow(
                      controller: _telefonoController,
                      placeholder: 'Teléfono',
                      prefix: const Icon(
                        CupertinoIcons.phone,
                        color: CupertinoColors.systemBlue,
                      ),
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    CupertinoTextFormFieldRow(
                      controller: _emailController,
                      placeholder: 'Email',
                      prefix: const Icon(
                        CupertinoIcons.mail,
                        color: CupertinoColors.systemBlue,
                      ),
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ],
                ),
              ),
              const Text(
                'Préstamos activos',
                style: TextStyle(
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              ...(prestamosActivos.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No hay préstamos activos.',
                          style: TextStyle(color: CupertinoColors.systemGrey2),
                        ),
                      ),
                    ]
                  : prestamosActivos.map(
                      (prestamo) => _PrestamoCupertinoTile(prestamo: prestamo),
                    )),
              const SizedBox(height: 18),
              const Text(
                'Historial de préstamos',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              ...(prestamosAntiguos.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No hay préstamos antiguos.',
                          style: TextStyle(color: CupertinoColors.systemGrey2),
                        ),
                      ),
                    ]
                  : prestamosAntiguos.map(
                      (prestamo) => _PrestamoCupertinoTile(prestamo: prestamo),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrestamoCupertinoTile extends StatelessWidget {
  final Prestamo prestamo;
  const _PrestamoCupertinoTile({required this.prestamo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: prestamo.pagado
            ? CupertinoColors.activeGreen.withAlpha(22)
            : CupertinoColors.activeBlue.withAlpha(22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {}, // Puedes agregar detalles si lo deseas
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                prestamo.pagado
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.money_dollar,
                color: prestamo.pagado
                    ? CupertinoColors.activeGreen
                    : CupertinoColors.activeBlue,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${prestamo.monto.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: prestamo.pagado
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.activeBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    prestamo.pagado ? 'Pagado' : 'Pendiente',
                    style: TextStyle(
                      color: prestamo.pagado
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.activeBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
