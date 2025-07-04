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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Préstamos')),
      child: SafeArea(
        child: Stack(
          children: [
            _prestamos.isEmpty
                ? const Center(child: Text('No hay préstamos'))
                : CupertinoScrollbar(
                    child: ListView.builder(
                      itemCount: _prestamos.length,
                      itemBuilder: (context, index) {
                        final prestamo = _prestamos[index];
                        final contacto = _contactos[prestamo.contactoId];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: prestamo.pagado
                                ? CupertinoColors.activeGreen.withAlpha(22)
                                : CupertinoColors.activeBlue.withAlpha(22),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: CupertinoListTile(
                            leading: Icon(
                              prestamo.pagado
                                  ? CupertinoIcons.check_mark_circled_solid
                                  : CupertinoIcons.money_dollar,
                              color: prestamo.pagado
                                  ? CupertinoColors.activeGreen
                                  : CupertinoColors.activeBlue,
                            ),
                            title: Text(
                              '\$${prestamo.monto.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: prestamo.pagado
                                    ? CupertinoColors.activeGreen
                                    : CupertinoColors.activeBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
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
                                    onPressed: () => _abonarPrestamo(prestamo),
                                    child: const Icon(
                                      CupertinoIcons.add_circled,
                                      color: CupertinoColors.systemYellow,
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _marcarPagado(prestamo),
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
                            onTap: () =>
                                _navigateToPrestamoDetalle(prestamo: prestamo),
                          ),
                        );
                      },
                    ),
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

/// CupertinoListTile con leading para préstamos
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            if (leading != null)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
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
                        style: CupertinoTheme.of(context).textTheme.textStyle
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
