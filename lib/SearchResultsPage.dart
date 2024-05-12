import 'package:flutter/material.dart';
import 'bottomBar.dart'; // Ensure this is correctly imported based on your project structure.

class SearchResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;

  const SearchResultsPage({Key? key, required this.searchResults}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search Results",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: searchResults.isNotEmpty
          ? ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(searchResults[index]['username'] ?? 'No username provided'),
            onTap: () => _showProfileDialog(context, searchResults[index]),
          );
        },
      )
          : Center(child: Text("No results found.")),
      bottomNavigationBar: CustomBottomAppBar(
        items: [
          BottomAppBarItem(title: 'Find Players', routeName: '/find_players', icon: Icons.search),
          BottomAppBarItem(title: 'You', routeName: '/mainMenu', icon: Icons.person),
          BottomAppBarItem(title: 'Game Library', routeName: '/game_library', icon: Icons.book),
          BottomAppBarItem(title: 'Settings', routeName: '/settings', icon: Icons.settings),
        ],
        currentRouteName: '/find_players',
      ),
    );
  }

  void _showProfileDialog(BuildContext context, Map<String, dynamic> userInfo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(userInfo['username'] ?? 'Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ProfilePicture(
                  imageUrl: userInfo['profilePictureUrl'],
                  radius: 50.0,
                ),
                SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: 'Region: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${userInfo['region']}',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    text: 'Language: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${userInfo['language']}',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context). pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class ProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final double radius;

  const ProfilePicture({Key? key, this.imageUrl, this.radius = 50.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the image URL is valid
    bool isValidUrl = imageUrl != null && imageUrl!.isNotEmpty;
    final imageProvider = isValidUrl ? NetworkImage(imageUrl! + "?v=${DateTime.now().millisecondsSinceEpoch}") : null;

    print("Profile Picture URL in Widget: $imageUrl");

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey,
      backgroundImage: imageProvider,
      child: imageProvider == null ? Icon(Icons.person, size: radius, color: Colors.white) : null,
    );
  }
}