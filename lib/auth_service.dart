import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'User.dart' as CustomUser;

class AuthService {
  static FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  static Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch additional user data from the database
      CustomUser.User? user = await fetchUserDataFromDatabase(credential.user!.uid);

      // Return the user data
      return user != null;
    } catch (e) {
      // Handle specific authentication errors here
      print('----------------Sign-in error: $e');
      return false;
    }
  }

  static Future<CustomUser.User?> fetchUserDataFromDatabase(String uid) async {
    try {
      print("Attempting to fetch data for UID: $uid"); // Log the UID being queried
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users').child(uid);
      DatabaseEvent event = await userRef.once();
      DataSnapshot snapshot = event.snapshot; // Correctly access the snapshot from the event

      if (snapshot.exists) { // Use the exists property to check if the snapshot has data
        print("Data found for UID: $uid"); // Log success
        Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;

        // Construct the User object
        CustomUser.User user = CustomUser.User(
          username: userData['username'] ?? '',
          email: userData['email'] ?? '',
          password: '', // It's important to not handle the password this way in a real app
          phoneNumber: userData['phoneNumber'] ?? '',
          region: userData['region'] ?? '',
          language: userData['language'] ?? '',
        );
        return user;
      } else {
        print("No data found for UID: $uid"); // Log failure
        return null;
      }
    } catch (error) {
      print('Error fetching user data for UID: $uid - $error'); // Log any errors
      return null;
    }
  }
}