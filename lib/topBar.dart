import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'bottomBar.dart';
import 'login.dart';

void handleSignOut(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Sign Out"),
        content: Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              // Get the AuthProvider instance using Provider.of
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              // Call the signOut method from AuthProvider
              authProvider.signOut();
              // Navigate to the LoginPage
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => LoginPage(),
              ));
            },
            child: Text("Sign Out"),
          ),
        ],
      );
    },
  );
}

// Define the Notifications Page widget
class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Text('Notifications Page'),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        // Implement the custom bottom app bar
        items: [
          //BottomAppBarItem(title: 'Messages', routeName: '/messages', icon: Icons.message),
          BottomAppBarItem(title: 'Find Players', routeName: '/find_players', icon: Icons.search),
          BottomAppBarItem(title: 'You', routeName: '/mainMenu', icon: Icons.person),
          BottomAppBarItem(title: 'Game Library', routeName: '/game_library', icon: Icons.book),
          BottomAppBarItem(title: 'Settings', routeName: '/settings', icon: Icons.settings),
        ],
        currentRouteName: '/mainMenu',
      ),
    );
  }
}

// Define the CustomAppBar widget
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onSignOutPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.onNotificationsPressed,
    required this.onSignOutPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: onNotificationsPressed,
          icon: const Icon(Icons.notifications), // Notifications icon
        ),
        IconButton(
          onPressed: () => handleSignOut(context), // Call the sign-out handler
          icon: const Icon(Icons.logout), // Logout icon
        ),
      ],
    );
  }
}