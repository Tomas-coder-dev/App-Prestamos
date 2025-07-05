import 'package:flutter/cupertino.dart';
import '../models/prestamo.dart';
import '../models/contacto.dart';
import '../db/database_helper.dart';
import 'prestamo_detalle.dart';

class PrestamosListScreen extends StatefulWidget {
  const PrestamosListScreen({super.key});

  @override
  State<PrestamosListScreen> createState() => _PrestamosListScreenState();
}

class _PrestamosListScreenState extends State<PrestamosListScreen> {
  List<Prestamo> _prestamos = [];
  Map<int, Contacto> _contactos = {};
  final Set<int> _selectedPrestamos = {};
  bool _mostrarPagados = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prestamos = await DatabaseHelper.instance.getPrestamos();
    final contactos = await DatabaseHelper.instance.getContactos();
    if (!mounted) return;
    setState(() {
      _prestamos = prestamos;
      _contactos = {for (var c in contactos) c.id!: c};
      _selectedPrestamos.clear(); // Limpia selección al recargar
    });
  }

  void _toggleSeleccion(int id) {
    setState(() {
      if (_selectedPrestamos.contains(id)) {
        _selectedPrestamos.remove(id);
      } else {
        _selectedPrestamos.add(id);
      }
    });
  }

  void _toggleMostrarPagados(bool value) {
    setState(() {
      _mostrarPagados = value;
      _selectedPrestamos.clear();
    });
  }

  Future<void> _navigateToPrestamoDetalle({Prestamo? prestamo}) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PrestamoDetalleScreen(prestamo: prestamo),
      ),
    );
    _loadData();
  }

  Future<void> _deletePrestamo(int id) async {
    await DatabaseHelper.instance.deletePrestamo(id);
    _loadData();
  }

  Future<void> _abonarPrestamo(Prestamo prestamo) async {
    final controller = TextEditingController();
    final result = await showCupertinoDialog<double>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Abonar al préstamo'),
        content: CupertinoTextField(
          controller: controller,
          placeholder: 'Monto a abonar',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, null),
          ),
          CupertinoDialogAction(
            child: const Text('Abonar'),
            onPressed: () {
              final value = double.tryParse(controller.text) ?? 0.0;
              Navigator.pop(context, value);
            },
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      final nuevoMonto = (prestamo.monto - result)
          .clamp(0, double.infinity)
          .toDouble();
      final pagado = nuevoMonto == 0;
      await DatabaseHelper.instance.updatePrestamo(
        prestamo.copyWith(monto: nuevoMonto, pagado: pagado),
      );
      _loadData();
    }
  }

  Future<void> _marcarPagado(Prestamo prestamo) async {
    await DatabaseHelper.instance.updatePrestamo(
      prestamo.copyWith(monto: 0, pagado: true),
    );
    _loadData();
  }

  double get totalSeleccionadoSaldoActual {
    return _prestamos
        .where((p) =>
            _selectedPrestamos.contains(p.id) &&
            (p.pagado == _mostrarPagados))
        .fold(0.0, (sum, p) => sum + p.monto);
  }

  double get totalSeleccionadoOriginal {
    return _prestamos
        .where((p) =>
            _selectedPrestamos.contains(p.id) &&
            (p.pagado == _mostrarPagados))
        .fold(0.0, (sum, p) => sum + p.montoOriginal);
  }

  @override
  Widget build(BuildContext context) {
    final prestamosFiltrados =
        _prestamos.where((p) => p.pagado == _mostrarPagados).toList();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Préstamos')),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _mostrarPagados ? 'Préstamos Pagados' : 'Préstamos Activos',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      CupertinoSlidingSegmentedControl<bool>(
                        groupValue: _mostrarPagados,
                        children: const {
                          false: Text('Activos'),
                          true: Text('Pagados'),
                        },
                        onValueChanged: (value) {
                          if (value != null) _toggleMostrarPagados(value);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: prestamosFiltrados.isEmpty
                      ? const Center(child: Text('No hay préstamos'))
                      : CupertinoScrollbar(
                          child: ListView.builder(
                            itemCount: prestamosFiltrados.length,
                            itemBuilder: (context, index) {
                              final prestamo = prestamosFiltrados[index];
                              final contacto = _contactos[prestamo.contactoId];
                              final seleccionado =
                                  _selectedPrestamos.contains(prestamo.id);
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _mostrarPagados
                                      ? CupertinoColors.activeGreen
                                          .withAlpha((0.08 * 255).round())
                                      : CupertinoColors.activeBlue
                                          .withAlpha((0.08 * 255).round()),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: CupertinoColors.black
                                          .withAlpha((0.06 * 255).round()),
                                      blurRadius: 2,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CupertinoCheckbox(
                                      value: seleccionado,
                                      onChanged: (_) =>
                                          _toggleSeleccion(prestamo.id!),
                                      activeColor: CupertinoColors.activeBlue,
                                    ),
                                    Expanded(
                                      child: CupertinoListTile(
                                        leading: Icon(
                                          prestamo.pagado
                                              ? CupertinoIcons
                                                  .check_mark_circled_solid
                                              : CupertinoIcons.money_dollar,
                                          color: prestamo.pagado
                                              ? CupertinoColors.activeGreen
                                              : CupertinoColors.activeBlue,
                                        ),
                                        title: Row(
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
                                            const SizedBox(width: 7),
                                            Text(
                                              '/ \$${prestamo.montoOriginal.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: CupertinoColors.systemGrey,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Text(
                                          contacto != null
                                              ? contacto.nombre
                                              : 'Contacto eliminado',
                                          style: const TextStyle(
                                            color: CupertinoColors.systemGrey2,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (!prestamo.pagado) ...[
                                              CupertinoButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () =>
                                                    _abonarPrestamo(prestamo),
                                                child: const Icon(
                                                  CupertinoIcons.add_circled,
                                                  color: CupertinoColors.systemYellow,
                                                ),
                                              ),
                                              CupertinoButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () =>
                                                    _marcarPagado(prestamo),
                                                child: const Icon(
                                                  CupertinoIcons.check_mark_circled,
                                                  color: CupertinoColors.systemGreen,
                                                ),
                                              ),
                                            ],
                                            CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () =>
                                                  _deletePrestamo(prestamo.id!),
                                              child: const Icon(
                                                CupertinoIcons.delete,
                                                color: CupertinoColors.systemRed,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () => _navigateToPrestamoDetalle(
                                            prestamo: prestamo),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
                if (_selectedPrestamos.isNotEmpty)
                  Container(
                    color: CupertinoColors.darkBackgroundGray.withAlpha((0.85 * 255).round()),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Original: \$${totalSeleccionadoOriginal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: CupertinoColors.activeBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (!_mostrarPagados)
                          Text(
                            'Total Saldo Actual: \$${totalSeleccionadoSaldoActual.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: CupertinoColors.systemYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: CupertinoButton.filled(
                onPressed: () => _navigateToPrestamoDetalle(),
                child: const Icon(CupertinoIcons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CupertinoCheckbox puro estilo iOS actualizado
class CupertinoCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  const CupertinoCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      onPressed: () => onChanged(!value),
      child: Icon(
        value
            ? CupertinoIcons.check_mark_circled_solid
            : CupertinoIcons.circle,
        color: value
            ? (activeColor ?? CupertinoColors.activeBlue)
            : CupertinoColors.systemGrey3,
        size: 28,
      ),
    );
  }
}

class CupertinoListTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;

  const CupertinoListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            if (leading != null)
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: leading!,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                    child: title,
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: DefaultTextStyle(
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .copyWith(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey2,
                            ),
                        child: subtitle!,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}