import 'package:flutter/cupertino.dart';
import '../models/prestamo.dart';
import '../models/contacto.dart';
import '../db/database_helper.dart';

class PrestamoDetalleScreen extends StatefulWidget {
  final Prestamo? prestamo;

  const PrestamoDetalleScreen({super.key, this.prestamo});

  @override
  State<PrestamoDetalleScreen> createState() => _PrestamoDetalleScreenState();
}

class _PrestamoDetalleScreenState extends State<PrestamoDetalleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _montoController;
  late final TextEditingController _notaController;
  bool _pagado = false;
  Contacto? _selectedContacto;

  @override
  void initState() {
    super.initState();
    _montoController = TextEditingController(
      text: widget.prestamo?.monto.toString() ?? '',
    );
    _notaController = TextEditingController(text: widget.prestamo?.nota ?? '');
    _pagado = widget.prestamo?.pagado ?? false;
    if (widget.prestamo != null) {
      _cargarContacto(widget.prestamo!.contactoId);
    }
  }

  Future<void> _cargarContacto(int id) async {
    final contactos = await DatabaseHelper.instance.getContactos();
    setState(() {
      _selectedContacto = contactos.firstWhere(
        (c) => c.id == id,
        orElse: () => Contacto(id: id, nombre: 'Desconocido'),
      );
    });
  }

  @override
  void dispose() {
    _montoController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  Future<void> _savePrestamo() async {
    if (_formKey.currentState!.validate() && _selectedContacto != null) {
      final isNuevo = widget.prestamo == null;
      final montoOriginal = isNuevo
          ? double.tryParse(_montoController.text) ?? 0.0
          : widget.prestamo!.montoOriginal;
      final prestamo = Prestamo(
        id: widget.prestamo?.id,
        contactoId: _selectedContacto!.id!,
        monto: double.tryParse(_montoController.text) ?? 0.0,
        montoOriginal: montoOriginal,
        pagado: _pagado,
        nota: _notaController.text,
      );
      if (isNuevo) {
        await DatabaseHelper.instance.insertPrestamo(prestamo);
      } else {
        await DatabaseHelper.instance.updatePrestamo(prestamo);
      }
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> _seleccionarContacto() async {
    final contactos = await DatabaseHelper.instance.getContactos();
    if (!mounted) return;
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Seleccionar contacto'),
        actions: [
          for (final c in contactos)
            CupertinoActionSheetAction(
              isDefaultAction: c.id == _selectedContacto?.id,
              child: Text(c.nombre),
              onPressed: () {
                setState(() => _selectedContacto = c);
                Navigator.pop(context);
              },
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.prestamo != null;
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.darkBackgroundGray.withAlpha(242),
        middle: Text(
          isEditing ? 'Editar Préstamo' : 'Nuevo Préstamo',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _savePrestamo,
          child: const Icon(
            CupertinoIcons.check_mark_circled,
            color: CupertinoColors.activeBlue,
            size: 28,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          color: CupertinoColors.black,
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: CupertinoColors.darkBackgroundGray.withAlpha(230),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 22,
                    horizontal: 16,
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      CupertinoButton(
                        onPressed: _seleccionarContacto,
                        color: CupertinoColors.systemBlue,
                        child: Text(
                          _selectedContacto == null
                              ? 'Seleccionar Contacto'
                              : _selectedContacto!.nombre,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      CupertinoTextFormFieldRow(
                        controller: _montoController,
                        placeholder: 'Monto',
                        prefix: const Icon(
                          CupertinoIcons.money_dollar,
                          color: CupertinoColors.systemYellow,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Campo requerido'
                            : null,
                        style: theme.textTheme.textStyle.copyWith(fontSize: 18),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        enabled: !isEditing, // Solo editable al crear
                      ),
                      // Visualización del monto original (en edición)
                      if (isEditing)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.doc_text,
                                color: CupertinoColors.systemGrey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Original: \$${widget.prestamo!.montoOriginal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      CupertinoTextFormFieldRow(
                        controller: _notaController,
                        placeholder: 'Nota (opcional)',
                        maxLines: 2,
                        prefix: const Icon(
                          CupertinoIcons.pencil_ellipsis_rectangle,
                          color: CupertinoColors.systemBlue,
                        ),
                        style: theme.textTheme.textStyle.copyWith(fontSize: 18),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          CupertinoSwitch(
                            value: _pagado,
                            onChanged: (value) =>
                                setState(() => _pagado = value),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            '¿Préstamo pagado?',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}