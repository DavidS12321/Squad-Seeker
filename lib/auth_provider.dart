import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'User.dart' as CustomUser;

class AuthProvider extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  CustomUser.User? _currentUser;

  bool get isLoggedIn => _currentUser != null;

  CustomUser.User? get currentUser => _currentUser;

  AuthProvider() {
    // Enable Firebase Auth persistence
    _auth.setPersistence(Persistence.LOCAL);

    // Optionally, you can listen for auth state changes and update the current user accordingly
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print("SIGNED IN");
        getCurrentUser();
      } else {
        print("SIGNED OUT");
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Modify the return type to Future<UserCredential> to return the credential
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      // Sign up the user with Firebase Authentication
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      // Create a new User object with the necessary information
      _currentUser = CustomUser.User(
        username: '', // You will likely want to set this with actual data
        email: credential.user!.email ?? '',
        password: '', // Don't store password in memory
        phoneNumber: '', // You will likely want to set this with actual data
        region: '', // You will likely want to set this with actual data
        language: '', // You will likely want to set this with actual data
        // You might need to include any other fields required by your User class
      );

      notifyListeners();

      return credential; // Return the UserCredential for further use
    } on FirebaseAuthException catch (e) {
      print('Error signing up: ${e.message}');
      // Optionally handle the FirebaseAuthException by re-throwing it or returning null
      // so the calling code can handle the sign-up failure
      throw e;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await getCurrentUser(); // Call getCurrentUser to fetch and set user data
    } on FirebaseAuthException catch (e) {
      print('Error signing in: ${e.message}');
      // Handle error
    }
  }

  Future<void> getCurrentUser() async {
    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${firebaseUser.uid}');
        DataSnapshot snapshot = await userRef.get();
        print('Attempting to fetch user data for UID: ${firebaseUser.uid}');

        if (snapshot.exists) {
          Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
          _currentUser = CustomUser.User(
            username: userData['username'] ?? '',
            email: userData['email'] ?? '',
            password: userData[''] ?? '',
            phoneNumber: userData['phoneNumber'] ?? '',
            region: userData['region'] ?? '',
            language: userData['language'] ?? '',
            profilePictureUrl: userData['profilePictureURL'] ?? '',
          );
          print("Fetched user data: $_currentUser");
        } else {
          print("No user data found for UID: ${firebaseUser.uid}");
          _currentUser = null;
        }
        notifyListeners();
      } else {
        print("No logged in user.");
        _currentUser = null;
      }
    } catch (error) {
      print('Error fetching user information: $error');
      _currentUser = null;
    }
  }

  Future<void> login(CustomUser.User user) async {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      // Handle error
    }
  }

  Future<void> changeProfilePicture(File imageFile) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      print('No user logged in.');
      return;
    }

    final storageRef = FirebaseStorage.instance.ref().child('profile_pictures').child(user.uid);

    try {
      // Upload the file to Firebase Storage
      final uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot storageSnapshot = await uploadTask;

      // Get the download URL of the uploaded image
      final String downloadURL = await storageSnapshot.ref.getDownloadURL();

      // Update the user's profile picture URL in Firestore
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userRef.update({'profile_picture': downloadURL});

      // Additionally, update the current user's profile picture URL in the auth provider
      if (_currentUser != null) {
        _currentUser!.profilePictureUrl = downloadURL; // Set the new profile picture URL
        notifyListeners(); // Notify all listening widgets to rebuild
      }

      print('Profile picture updated successfully to: $downloadURL');
    } catch (e) {
      // Handle errors
      print('Error changing profile picture: $e');
    }
  }
}