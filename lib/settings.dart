import 'package:flutter/material.dart';
import 'themes.dart';
import 'bottomBar.dart';
import 'topBar.dart';
import 'settingsPages.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildSettingTile(String title, IconData icon, VoidCallback onTap) {
      return Column(
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(title),
            trailing: const Icon(Icons.arrow_forward),
            onTap: onTap,
          ), // Add SizedBox for vertical spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 1,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12.0),
        ],
      );
    }
    return Theme(
      data: myTheme, // Use your theme data
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Settings',
          onNotificationsPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsPage()),
            );
          },
          onSignOutPressed: () {
            handleSignOut(context);
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  buildSettingTile('Account', Icons.account_circle, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage()));
                  }),
                  buildSettingTile('Notifications', Icons.notifications, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage()));
                  }),
                  buildSettingTile('Appearance', Icons.palette, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AppearancePage()));
                  }),
                  buildSettingTile('Privacy and Security', Icons.security_outlined, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacySecurityPage()));
                  }),
                  buildSettingTile('Help and Support', Icons.help, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSupportPage()));
                  }),
                  buildSettingTile('About', Icons.info, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
                  }),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomAppBar(
          items: [
            //BottomAppBarItem(title: 'Messages', routeName: '/messages', icon: Icons.message),
            BottomAppBarItem(title: 'Find Players', routeName: '/find_players', icon: Icons.search),
            BottomAppBarItem(title: 'You', routeName: '/mainMenu', icon: Icons.person),
            BottomAppBarItem(title: 'Game Library', routeName: '/game_library', icon: Icons.book),
            BottomAppBarItem(title: 'Settings', routeName: '/settings', icon: Icons.settings),
          ],
          currentRouteName: ModalRoute.of(context)?.settings.name ?? '/settings',
        ),
      ),
    );
  }
}