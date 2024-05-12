import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'bottomBar.dart';
import 'forgotCredentials.dart';
import 'themes.dart';
import 'package:squad_seeker/auth_provider.dart' as squad_seeker_auth_provider;

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<squad_seeker_auth_provider.AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Account', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: currentUser != null
          ? ListView(
          children: [
            ListTile(
              title: Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(currentUser.username),
            ),
            ListTile(
              title: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(currentUser.email),
            ),
            ListTile(
              title: Text('Region', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(currentUser.region),
            ),
            ListTile(
              title: Text('Language', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(currentUser.language),
            ),
            ListTile(
              title: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(currentUser.phoneNumber),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _changeProfilePicture(context),
              child: Text('Change Profile Picture'),
            ),
            SizedBox(height: 20),
            _buildChangeButton(context, 'Change Password', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
              );
            }),
          ],
      )
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: CustomBottomAppBar(
        // Implement the custom bottom app bar
        items: [
          //BottomAppBarItem(title: 'Messages', routeName: '/messages', icon: Icons.message),
          BottomAppBarItem(title: 'Find Players', routeName: '/find_players', icon: Icons.search),
          BottomAppBarItem(title: 'You', routeName: '/mainMenu', icon: Icons.person),
          BottomAppBarItem(title: 'Game Library', routeName: '/game_library', icon: Icons.book),
          BottomAppBarItem(title: 'Settings', routeName: '/settings', icon: Icons.settings),
        ],
        currentRouteName: '/settings',
      ),
    );
  }

  void _changeProfilePicture(BuildContext context) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final storageRef = FirebaseStorage.instance.ref().child('userProfiles/$userId/profilePicture.png');

      try {
        // Upload the file to Firebase Storage
        await storageRef.putFile(imageFile);

        // Once the file is uploaded, get the URL
        final imageUrl = await storageRef.getDownloadURL();

        // Update the user's profile with the new imageUrl
        await FirebaseAuth.instance.currentUser!.updateProfile(photoURL: imageUrl);

        // Update the user profile in your application's data (if you have a users collection in Firestore)
        // var userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
        // await userDoc.update({'profilePictureUrl': imageUrl});

        // Update the auth provider's current user
        Provider.of<squad_seeker_auth_provider.AuthProvider>(context, listen: false).currentUser?.profilePictureUrl = imageUrl;

        // Show a snackbar or alert to inform the user of a successful upload
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated successfully!')),
        );
      } catch (e) {
        // Handle any errors here
        print('Error uploading profile picture: $e');
        // If e is a FirebaseException, we can get more detailed information like this:
        if (e is FirebaseException) {
          print('FirebaseException caught: ${e.message}, ${e.code}');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture: ${e.toString()}')),
        );
      }
    } else {
      // Handle if no image is picked
      print('No image was selected.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected.')),
      );
    }
  }
}
  Widget _buildChangeButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }

class AppearancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appearance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: myTheme.primaryColor,
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
        currentRouteName: '/settings',
      ),
    );
  }
}

class PrivacySecurityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy & Security',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: myTheme.primaryColor,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Change Password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
              );            },
          ),
          // Add more privacy and security settings here
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
        currentRouteName: '/settings',
      ),
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: myTheme.primaryColor,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('FAQs'),
          ),
          ListTile(
            title: Text('Contact Us'),
          ),
          // Add more help and support options here
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
        currentRouteName: '/settings',
      ),
    );
  }
}

class AboutPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: myTheme.primaryColor,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Version'),
            subtitle: Text('1.4.3'), // Replace with your current app version
          ),
          ListTile(
            title: Text('Terms of Service'),
          ),
          ListTile(
            title: Text('Privacy Policy'),
          ),
          // Add more about details here
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
        currentRouteName: '/settings',
      ),
    );
  }
}
