import 'package:flutter/cupertino.dart';
import 'screens/contactos_list.dart';
import 'screens/prestamos_list.dart';

void main() {
  runApp(const PrestamosApp());
}

class PrestamosApp extends StatelessWidget {
  const PrestamosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemBlue, // Más iOS
        scaffoldBackgroundColor: CupertinoColors.black,
        barBackgroundColor: CupertinoColors.darkBackgroundGray,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(color: CupertinoColors.white),
        ),
      ),
      home: HomeCupertinoTabScaffold(),
    );
  }
}

class HomeCupertinoTabScaffold extends StatelessWidget {
  const HomeCupertinoTabScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: CupertinoColors.systemBlue,
        inactiveColor: CupertinoColors.systemGrey2,
        backgroundColor: CupertinoColors.darkBackgroundGray,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_2),
            label: 'Contactos',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar),
            label: 'Préstamos',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => const ContactosListScreen(),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => const PrestamosListScreen(),
            );
          default:
            return CupertinoTabView(
              builder: (context) => const ContactosListScreen(),
            );
        }
      },
    );
  }
}
