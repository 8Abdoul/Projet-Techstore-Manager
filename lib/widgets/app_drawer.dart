import 'package:flutter/material.dart';

import '../screens/admin_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/home_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Widget _buildItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop(); // ferme le drawer
        Navigator.of(context).pushReplacementNamed(route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const ListTile(
              title: Text(
                'Navigation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            _buildItem(
              context: context,
              icon: Icons.store,
              title: 'Accueil',
              route: HomeScreen.routeName,
            ),
            _buildItem(
              context: context,
              icon: Icons.shopping_cart,
              title: 'Panier',
              route: CartScreen.routeName,
            ),
            _buildItem(
              context: context,
              icon: Icons.admin_panel_settings,
              title: 'Administration',
              route: AdminScreen.routeName,
            ),
          ],
        ),
      ),
    );
  }
}
