# PrestamosApp

Aplicación Flutter estilo **Cupertino (iOS)** para la gestión de préstamos entre contactos.

## Características

- **Modo oscuro** permanente y diseño nativo iOS.
- **Gestión de contactos:**  
  - Crea, visualiza, edita teléfono/email y elimina contactos.
  - El nombre del contacto NO es editable tras su creación.
- **Gestión de préstamos:**  
  - Crea préstamos seleccionando el contacto.
  - Visualiza todos los préstamos activos y pagados.
  - Puedes abonar parcial o totalmente un préstamo.
  - Marca préstamos como pagados con un solo toque.
  - Lista de préstamos en la ficha de cada contacto.
- **Buscador:**  
  - Busca contactos por nombre.
- **Interfaz amigable:**  
  - Iconografía y colores modernos Cupertino.
  - Botones flotantes para crear nuevos contactos y préstamos.

## Estructura del Proyecto

```
lib/
│
├── main.dart
├── db/
│   └── database_helper.dart
├── models/
│   ├── contacto.dart
│   └── prestamo.dart
└── screens/
    ├── contactos_list.dart
    ├── contacto_detalle.dart
    ├── prestamos_list.dart
    └── prestamo_detalle.dart
```

- `db/database_helper.dart`: Acceso y gestión de la base de datos SQLite.
- `models/`: Definición de modelos de datos (`Contacto`, `Prestamo`).
- `screens/`: Pantallas principales de la app.

## Uso

- **Agregar Contacto:**  
  Pulsa el botón "+" en la pantalla de contactos, completa los datos y guarda.
- **Editar Contacto:**  
  Pulsa sobre un contacto. Solo podrás editar teléfono y email.
- **Eliminar Contacto:**  
  Pulsa el ícono de papelera junto al contacto.
- **Agregar Préstamo:**  
  Ve a la pestaña "Préstamos", pulsa "+", selecciona un contacto y completa los datos.
- **Abonar o Pagar Préstamo:**  
  Desde la pestaña "Préstamos", usa los botones de abono o marcado como pagado junto a cada préstamo.

## Notas Técnicas

- App desarrollada con **Flutter 3.x** y widgets Cupertino.
- La base de datos es **local (SQLite)**, sin conexión a Internet ni sincronización en la nube.
- Los colores, iconos y tipografías siguen las guías de diseño iOS.

**Desarrollado por [Tomas-Coder-Dev]**
