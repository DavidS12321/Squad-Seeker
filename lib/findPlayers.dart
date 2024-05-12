import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'SearchResultsPage.dart';
import 'bottomBar.dart';
import 'topBar.dart';
import 'themes.dart';

class FindPlayersPage extends StatefulWidget {
  const FindPlayersPage({super.key});

  @override
  _FindPlayersPageState createState() => _FindPlayersPageState();
}

class _FindPlayersPageState extends State<FindPlayersPage> {
  final Map<String, String?> _selectedOptions = {
    'Game': null,
    'Game Mode': null,
    //'Skill Level': null,
    'Language': null,
    'Region': null,
    //'Play Style': null,
  };
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Find Players',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black), // Add black border
                  borderRadius: BorderRadius.circular(5.0), // Add border radius for rounded corners
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by username',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none, // Remove default TextField border
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                ),
              ),
            ),
            _buildFilters(), // Call method to build filter dropdowns
            const SizedBox(height: 20.0),
            _buildButtons(), // Call method to build search and reset buttons
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        items: [
          //BottomAppBarItem(title: 'Messages', routeName: '/messages', icon: Icons.message),
          BottomAppBarItem(title: 'Find Players', routeName: '/find_players', icon: Icons.search),
          BottomAppBarItem(title: 'You', routeName: '/mainMenu', icon: Icons.person),
          BottomAppBarItem(title: 'Game Library', routeName: '/game_library', icon: Icons.book),
          BottomAppBarItem(title: 'Settings', routeName: '/settings', icon: Icons.settings),
        ],
        currentRouteName: '/find_players',
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        _buildFilter('Game', ['Valorant', 'CSGO 2', 'Rainbow Six Siege', 'Apex Legends', 'Fortnite', 'Warzone']),
        //_buildFilter('Skill Level', ['Beginner', 'Proficient', 'Expert']),
        _buildFilter('Language', ['English', 'Spanish', 'French', 'German', 'Chinese', 'Italian', 'Portuguese', 'Japanese', 'Korean']),
        _buildFilter('Region', ['North America', 'Europe', 'Asia', 'South America', 'Africa', 'Australia']),
        //_buildFilter('Play Style', ['Casual', 'Competitive', 'Mixed']),
      ],
    );
  }

  Widget _buildFilter(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          DropdownButtonFormField<String>(
            value: _selectedOptions[label],
            onChanged: (newValue) {
              setState(() {
                _selectedOptions[label] = newValue;
              });
            },
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select $label',
            ),
          ),
          Container(
            height: 1,
            color: Colors.black, // Horizontal line color
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _searchPlayers,
            style: ElevatedButton.styleFrom(
              backgroundColor: myTheme.colorScheme.primary,
            ),
            child: const Text(
              'Search',
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: _resetFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: myTheme.colorScheme.primary,
            ),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _searchPlayers() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
    Query query = usersRef;  // Start with a reference to the users

    // Apply language filter if specified
    if (_selectedOptions['Language'] != null && _selectedOptions['Language']!.isNotEmpty) {
      query = query.orderByChild('language').equalTo(_selectedOptions['Language']);
    }

    // Apply region filter if specified
    if (_selectedOptions['Region'] != null && _selectedOptions['Region']!.isNotEmpty) {
      query = query.orderByChild('region').equalTo(_selectedOptions['Region']);
    }

    DataSnapshot snapshot = await query.get();
    List<Map<String, dynamic>> filteredUsers = [];

    if (snapshot.exists) {
      Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;
      List<Future<void>> gameCheckTasks = [];

      users.forEach((userId, userValue) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(userValue);

        if (_selectedOptions['Game'] != null && _selectedOptions['Game']!.isNotEmpty) {
          // Only fetch libraries if a game filter is specified
          DatabaseReference libraryRef = FirebaseDatabase.instance.ref('libraries/$userId/games');
          var task = libraryRef.get().then((librarySnapshot) {
            if (librarySnapshot.exists) {
              Map<dynamic, dynamic> games = librarySnapshot.value as Map<dynamic, dynamic>;
              bool gameFound = games.values.any((game) => game['name'] == _selectedOptions['Game']);
              if (gameFound) {
                filteredUsers.add(userData);
              }
            }
          });
          gameCheckTasks.add(task);
        } else {
          // If no game filter, add directly
          filteredUsers.add(userData);
        }
      });

      // Wait for all game checks to complete if game filter is applied
      if (gameCheckTasks.isNotEmpty) {
        await Future.wait(gameCheckTasks);
      }
    }

    // Navigate to the search results page with filtered users
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(searchResults: filteredUsers),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedOptions.forEach((key, value) {
        _selectedOptions[key] = null;
      });
    });
  }
}