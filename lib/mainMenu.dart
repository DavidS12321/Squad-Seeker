import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'User.dart' as CustomUser;
import 'auth_provider.dart';
import 'themes.dart';
import 'bottomBar.dart';
import 'topBar.dart';

class MainMenuPage extends StatefulWidget {
  @override
  _MainMenuPageState createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  void initState() {
    super.initState();
    updateUserProfile();  // Method to load user profile
    Future.microtask(() =>
        Provider.of<AuthProvider>(context, listen: false).getCurrentUser()
    );
  }

  void updateUserProfile() async {
    await Provider.of<AuthProvider>(context, listen: false).getCurrentUser();
    setState(() {});  // Forces a rebuild with updated data
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        String username = '';
        int numReviews = 0;
        double averageRating = 0.0;

        CustomUser.User? currentUser = authProvider.currentUser;
        String profilePictureUrl = currentUser?.profilePictureUrl ?? '';

        print('Profile Picture URL: $profilePictureUrl');

        if (authProvider.isLoggedIn && currentUser != null) {
          username = currentUser.username ?? 'No username';
          print('Current username: $username'); // Correct place for debug print

          numReviews = currentUser.reviews?.length ?? 0;
          List<double>? ratings = currentUser.ratings;

          if (ratings != null && ratings.isNotEmpty) {
            double totalRating = ratings.reduce((value, element) => value + element);
            averageRating = totalRating / ratings.length;
          }
        }

        // Return the main UI components
        return Theme(
          data: myTheme,
          child: Scaffold(
            appBar: CustomAppBar(
              title: 'Profile',
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
            Expanded(
            child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                SizedBox(height: 20.0),
                  ProfilePicture(
                    imageUrl: profilePictureUrl, // Pass the user's profile picture URL
                    radius: 50.0,
                  ),
            SizedBox(height: 20.0),
            Text(
              'Welcome, $username',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          'Number of Reviews: $numReviews',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Average Rating: ${averageRating.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      height: 200.0,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Center(
                        child: Text('Reviews'),
                      ),
                    ),
                  ),
                ),
              ],
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
          ),
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
    var finalImageUrl = imageUrl;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Append timestamp to the imageUrl to avoid cache issues
      finalImageUrl = "$imageUrl?alt=media&token=${DateTime.now().millisecondsSinceEpoch}";
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey,
      backgroundImage: finalImageUrl != null ? NetworkImage(finalImageUrl) : null,
      child: finalImageUrl == null ? Icon(Icons.person, size: radius, color: Colors.white) : null,
    );
  }
}
