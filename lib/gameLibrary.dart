import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'bottomBar.dart';
import 'topBar.dart';
import 'game.dart';

class GameLibraryPage extends StatefulWidget {
  const GameLibraryPage({Key? key}) : super(key: key);

  @override
  _GameLibraryPageState createState() => _GameLibraryPageState();
}

class _GameLibraryPageState extends State<GameLibraryPage> {
  final TextEditingController _libraryNameController = TextEditingController();
  List<String> libraries = [];
  Map<String, Map<String, dynamic>> libraryGames = {};
  final List<String> availableGames = ['Valorant', 'CSGO 2', 'Rainbow Six Siege', 'Apex Legends', 'Fortnite', 'Warzone'];
  String? selectedGame;
  String? _selectedSkillLevel;
  String? _selectedPlayStyle;
  final List<String> _skillLevels = ['Beginner', 'Proficient', 'Expert'];
  final List<String> _playStyles = ['Casual', 'Competitive', 'Mixed'];

  @override
  void initState() {
    super.initState();
    _fetchLibraries();
  }

  void _showAddGameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Game to Add'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableGames.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(availableGames[index]),
                  onTap: () {
                    Navigator.of(context).pop();
                    selectedGame = availableGames[index];
                    _showSelectLibraryDialog();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSelectLibraryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add "$selectedGame" to which library?'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...libraries.map((library) => ListTile(
                  title: Text(libraryGames[library]!['name']),
                  onTap: () {
                    _addGameToLibrary(library);
                    Navigator.of(context).pop();
                  },
                )).toList(),
                ListTile(
                  title: Text('Create New Library'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showCreateLibraryDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateLibraryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Create New Library"),
          content: TextField(
            controller: _libraryNameController,
            decoration: const InputDecoration(hintText: "Enter library name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Create"),
              onPressed: () {
                _addLibraryAndGame();
                selectedGame = null;
              },
            ),
          ],
        );
      },
    );
  }

  void _addLibraryAndGame() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final newLibraryName = _libraryNameController.text.trim();
    if (userId != null && newLibraryName.isNotEmpty) {
      final libraryRef = FirebaseDatabase.instance.ref('libraries/$userId').push();

      // Check if a game is selected, if not initialize an empty array
      final gamesToAdd = selectedGame != null ? [selectedGame] : [];

      libraryRef.set({
        'name': newLibraryName,
        'games': gamesToAdd
      }).then((_) {
        _libraryNameController.clear();
        selectedGame = null; // Clear the selected game after adding it to the library
        Navigator.of(context).pop();
        print("New library created and game added");
      }).catchError((error) {
        print("Error adding library and game: $error");
      });
    }
  }

  void _addGameToLibrary(String libraryId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final DatabaseReference libraryRef = FirebaseDatabase.instance.ref('libraries/$userId/$libraryId/games');

    if (userId != null && selectedGame != null) {
      // Get the current games list from the library
      libraryRef.get().then((DataSnapshot snapshot) {
        if (snapshot.exists) {
          var currentGames;
          if (snapshot.value is List) {
            currentGames = snapshot.value as List;
          } else if (snapshot.value is Map) {
            // Handle the case where games are not stored in an array format
            currentGames = (snapshot.value as Map).values.toList();
          } else {
            currentGames = [];
          }

          if (!currentGames.contains(selectedGame)) {
            // Add the game if it doesn't exist
            libraryRef.push().set(selectedGame).then((_) {
              selectedGame = null;
              print("Game added successfully");
            }).catchError((error) {
              print("Failed to add game: $error");
            });
          } else {
            selectedGame = null;
            _showGameAlreadyExistsDialog();
          }
        } else {
          // If there are no games, just add the selected game
          libraryRef.push().set(selectedGame).then((_) {
            print("Game added successfully");
          }).catchError((error) {
            print("Failed to add game: $error");
          });
        }
      }).catchError((error) {
        print("Failed to get games from library: $error");
      });
    }
  }

  void _showGameAlreadyExistsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Duplicate Game'),
          content: const Text('This game is already in the library.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _viewLibrary(String libraryId) {
    if (libraryGames.containsKey(libraryId)) {
      Map<String, dynamic> libraryData = libraryGames[libraryId] ?? {'name': 'Unnamed Library', 'games': []};
      List<String> gamesList = List<String>.from(libraryData['games'] as List? ?? []);

      // Navigate to the LibraryGamesPage with the library data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LibraryGamesPage(libraryName: libraryData['name'], games: gamesList),
        ),
      );
    } else {
      print("Library ID $libraryId not found in libraryGames");
    }
  }

  void _fetchLibraries() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print("Fetching libraries for user ID: $userId");

    if (userId == null) {
      print("User ID is null, which means the user is not logged in properly.");
      return;
    }

    final librariesRef = FirebaseDatabase.instance.ref('libraries/$userId');
    librariesRef.onValue.listen((event) {
      print("Data snapshot received: ${event.snapshot.value}");
      final value = event.snapshot.value;
      if (value is Map<dynamic, dynamic>) {
        final newLibraryGames = <String, Map<String, dynamic>>{};
        value.forEach((key, value) {
          if (key is String && value is Map<dynamic, dynamic>) {
            final name = value['name'] as String?;
            // Updated logic for handling 'games'
            List<String> games;
            final gamesDynamic = value['games'];
            if (gamesDynamic is List<dynamic>) {
              games = List<String>.from(gamesDynamic);
            } else if (gamesDynamic is Map<dynamic, dynamic>) {
              games = gamesDynamic.values.cast<String>().toList();
            } else {
              games = [];
            }
            // End of update
            newLibraryGames[key] = {'name': name ?? 'Unnamed Library', 'games': games};
            print("Processing library: $key with name $name and games $games");
          }
        });

        if (newLibraryGames.isNotEmpty) {
          print("New library games state to be set: $newLibraryGames");
        } else {
          print("No libraries found or libraries are empty.");
        }

        setState(() {
          libraryGames = newLibraryGames;
          libraries = newLibraryGames.keys.toList();
        });
      } else {
        print("Data fetched from Firebase is not in expected Map<dynamic, dynamic> format or is null.");
      }
    }, onError: (error) {
      print("Error fetching libraries: $error");
    });
  }

  void _deleteLibrary(String libraryId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final libraryRef = FirebaseDatabase.instance.ref('libraries/$userId/$libraryId');

      libraryRef.remove().then((_) {
        print("Library $libraryId deleted successfully");
        setState(() {
          libraries.remove(libraryId);
          libraryGames.remove(libraryId);
          if (libraries.isEmpty) {
            // Manually trigger a UI update if the last library is removed
            _fetchLibraries();
          }
        });
      }).catchError((error) {
        print("Error deleting library: $error");
      });
    }
  }

  void _showDeleteLibraryDialog(String libraryId, String libraryName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Library'),
          content: Text('Are you sure you want to delete "$libraryName"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteLibrary(libraryId);
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: "Game Library",
          onNotificationsPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsPage()),
            );
          },
          onSignOutPressed: () {
            handleSignOut(context); // Call the sign-out handler
          },
        ),
        body: Column(
          children: <Widget>[
        Expanded(
        child: ListView.builder(
          itemCount: libraries.length,
          itemBuilder: (context, index) {
            String libraryId = libraries[index];
            String libraryName = libraryGames[libraryId]?['name'] ?? 'Unnamed Library';
            return GestureDetector(
              onTap: () => _viewLibrary(libraryId),
              child: Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white, // Set the fill color to white or any other color
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black), // Set the border color to black
                ),
                child: ListTile(
                  title: Text(
                    libraryName,
                    style: TextStyle(fontSize: 20),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Call your method to handle deletion
                      _showDeleteLibraryDialog(libraryId, libraryName);
                    },
                  ),
                ),
              ),
            );
          },
        ),
    ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showAddGameDialog,
                      child: Text('Add Game to Library'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showCreateLibraryDialog,
                      child: Text('Create New Library'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      bottomNavigationBar: CustomBottomAppBar(
        items: [
          BottomAppBarItem(title: 'Find Players', routeName: '/find_players', icon: Icons.search),
          BottomAppBarItem(title: 'You', routeName: '/mainMenu', icon: Icons.person),
          BottomAppBarItem(title: 'Game Library', routeName: '/game_library', icon: Icons.book),
          BottomAppBarItem(title: 'Settings', routeName: '/settings', icon: Icons.settings),
        ],
        currentRouteName: '/game_library',
      ),
    );
  }
}

class LibraryGamesPage extends StatelessWidget {
  final String libraryName;
  final List<String> games;

  const LibraryGamesPage({Key? key, required this.libraryName, required this.games}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(libraryName, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(games[index]));
        },
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
        currentRouteName: '/game_library',
      ),
    );
  }
}