import 'package:flutter/material.dart';
import 'bottomBar.dart';
import 'topBar.dart';
import 'messageDetails.dart';

class messagesPage extends StatefulWidget {
  @override
  messagesPageState createState() => messagesPageState();
}

class messagesPageState extends State<messagesPage> {
  List<Message> messages = [
    Message('Profile 1', 'Username 1', 'Time 1', 'Most recent message 1'),
    Message('Profile 2', 'Username 2', 'Time 2', 'Most recent message 2'),
    Message('Profile 3', 'Username 3', 'Time 3', 'Most recent message 3'),
    // Add more messages as needed
  ];

  TextEditingController searchController = TextEditingController();
  List<Message> filteredMessages = [];

  @override
  void initState() {
    super.initState();
    filteredMessages.addAll(messages);
  }

  void filterMessages(String query) {
    setState(() {
      filteredMessages = messages
          .where((message) => message.username.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar( // Using CustomAppBar from topBar.dart
        title: 'Messages',
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
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black), // Add black border
                borderRadius: BorderRadius.circular(5.0), // Add border radius for rounded corners
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterMessages,
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(), // Add a divider after the search bar
          Expanded(
            child: ListView.builder(
              itemCount: filteredMessages.length,
              itemBuilder: (context, index) {
                final message = filteredMessages[index];
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(message.profileImage),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(message.username),
                          SizedBox(height: 4),
                          Text(message.time),
                        ],
                      ),
                      subtitle: Text(message.recentMessage),
                      onTap: () {
                        // Handle message selection
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageDetailPage(message: message),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 1,
                      color: Colors.black,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(
        items: [
          BottomAppBarItem(title: 'Messages', routeName: '/messages', icon: Icons.message),
          BottomAppBarItem(title: 'Find Players', routeName: '/find_players', icon: Icons.search),
          BottomAppBarItem(title: 'You', routeName: '/mainMenu', icon: Icons.person),
          BottomAppBarItem(title: 'Game Library', routeName: '/game_library', icon: Icons.book),
          BottomAppBarItem(title: 'Settings', routeName: '/settings', icon: Icons.settings),
        ],
        currentRouteName: '/messages',
      ),
    );
  }
}

class Message {
  final String profileImage;
  final String username;
  final String time;
  final String recentMessage;

  Message(this.profileImage, this.username, this.time, this.recentMessage);
}