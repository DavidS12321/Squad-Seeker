import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:squad_seeker/settings.dart';
import 'auth_provider.dart';
import 'findPlayers.dart';
import 'firebase_options.dart';
import 'gameLibrary.dart';
import 'login.dart';
import 'mainMenu.dart';
import 'messaging.dart';
import 'themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Squad Seeker',
      theme: myTheme,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoggedIn) {
            return MainMenuPage();
          } else {
            return LoginPage();
          }
        },
      ),
      routes: {
        '/mainMenu': (context) => MainMenuPage(),
        //'/messages': (context) => messagesPage(),
        '/find_players': (context) => const FindPlayersPage(),
        '/game_library': (context) => const GameLibraryPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}