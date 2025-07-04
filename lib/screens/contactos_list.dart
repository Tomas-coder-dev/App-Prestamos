import 'package:flutter/cupertino.dart';
import '../models/contacto.dart';
import '../db/database_helper.dart';
import 'contacto_detalle.dart';

class ContactosListScreen extends StatefulWidget {
  const ContactosListScreen({super.key});

  @override
  State<ContactosListScreen> createState() => _ContactosListScreenState();
}

class _ContactosListScreenState extends State<ContactosListScreen> {
  List<Contacto> _contactos = [];
  List<Contacto> _filteredContactos = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContactos();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContactos = _contactos
          .where((c) => c.nombre.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _loadContactos() async {
    final contactos = await DatabaseHelper.instance.getContactos();
    if (!mounted) return;
    setState(() {
      _contactos = contactos;
      _filteredContactos = contactos;
    });
  }

  Future<void> _navigateToDetalle({required Contacto contacto}) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ContactoDetalleScreen(contacto: contacto),
      ),
    );
    _loadContactos();
  }

  Future<void> _navigateToNuevoContacto() async {
    // Quitamos los underscores para cumplir con el lint.
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Nuevo Contacto'),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CupertinoTextFormFieldRow(
                    controller: nombreController,
                    placeholder: 'Nombre',
                    prefix: const Icon(
                      CupertinoIcons.person,
                      color: CupertinoColors.systemBlue,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Campo requerido'
                        : null,
                  ),
                  CupertinoTextFormFieldRow(
                    controller: telefonoController,
                    placeholder: 'Teléfono',
                    prefix: const Icon(
                      CupertinoIcons.phone,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                  CupertinoTextFormFieldRow(
                    controller: emailController,
                    placeholder: 'Email',
                    prefix: const Icon(
                      CupertinoIcons.mail,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CupertinoButton.filled(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await DatabaseHelper.instance.insertContacto(
                          Contacto(
                            nombre: nombreController.text,
                            telefono: telefonoController.text,
                            email: emailController.text,
                          ),
                        );
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                  CupertinoButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    _loadContactos();
  }

  Future<void> _deleteContacto(int id) async {
    await DatabaseHelper.instance.deleteContacto(id);
    _loadContactos();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Contactos')),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoSearchTextField(
                    controller: _searchController,
                    placeholder: 'Buscar contacto por nombre',
                  ),
                ),
                Expanded(
                  child: _filteredContactos.isEmpty
                      ? const Center(child: Text('No hay contactos'))
                      : CupertinoScrollbar(
                          child: ListView.builder(
                            itemCount: _filteredContactos.length,
                            itemBuilder: (context, index) {
                              final contacto = _filteredContactos[index];
                              return CupertinoListTile(
                                title: Text(
                                  contacto.nombre,
                                  style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                  ),
                                ),
                                subtitle: Text(
                                  contacto.telefono ?? '',
                                  style: const TextStyle(
                                    color: CupertinoColors.systemGrey2,
                                  ),
                                ),
                                trailing: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () =>
                                      _deleteContacto(contacto.id!),
                                  child: const Icon(
                                    CupertinoIcons.delete,
                                    color: CupertinoColors.systemRed,
                                  ),
                                ),
                                onTap: () =>
                                    _navigateToDetalle(contacto: contacto),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: CupertinoButton.filled(
                onPressed: _navigateToNuevoContacto,
                child: const Icon(CupertinoIcons.person_add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CupertinoListTile
class CupertinoListTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CupertinoListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
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
