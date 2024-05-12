import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:squad_seeker/login.dart';
import 'auth_provider.dart';
import 'themes.dart';
import 'package:squad_seeker/User.dart';

List<String> regions = ['North America', 'Europe', 'Asia', 'South America', 'Africa', 'Australia'];

List<String> languages = ['English', 'Spanish', 'French', 'German', 'Chinese', 'Italian', 'Portuguese', 'Japanese', 'Korean'];

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  String _email = '';
  String _password = '';
  String _username = '';
  String _phoneNumber = '';
  String _region = ''; // No default region
  String _language = ''; // No default language

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Squad Seeker',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              _buildTextFieldWithLabel(
                  'Email', onChanged: (value) => _email = value),
              _buildTextFieldWithLabel(
                  'Username', onChanged: (value) => _username = value),
              _buildTextFieldWithLabel(
                  'Password', obscureText: true,
                  onChanged: (value) => _password = value),
              _buildPhoneNumberField(),
              _buildRegionDropdown(),
              _buildLanguageDropdown(),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _createAccount(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: myTheme.colorScheme.primary,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Create Account',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Region',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        DropdownButton<String>(
          value: _region.isEmpty ? null : _region, // No default value
          onChanged: (String? newValue) {
            setState(() {
              _region = newValue!;
            });
          },
          items: regions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Language',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        DropdownButton<String>(
          value: _language.isEmpty ? null : _language, // No default value
          onChanged: (String? newValue) {
            setState(() {
              _language = newValue!;
            });
          },
          items: languages.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithLabel(String labelText,
      {bool obscureText = false, required void Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 40.0, // Adjust the height as needed
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: TextField(
              obscureText: obscureText,
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        SizedBox(
          height: 40.0, // Adjust the height as needed
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: TextField(
              keyboardType: TextInputType.phone,
              onChanged: (value) => _phoneNumber = value,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createAccount(BuildContext context) async {
    print('Create Account button pressed');

    // Check if any field is empty
    if (_username.isEmpty || _email.isEmpty || _password.isEmpty ||
        _phoneNumber.isEmpty || _region.isEmpty || _language.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill out all fields.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the function early if any field is empty
    }

    try {
      AuthProvider authProvider = Provider.of<AuthProvider>(
          context, listen: false);

      if (_password.length < 6) {
        throw WeakPasswordException(
          'Password must be at least 6 characters long.',
        );
      }
      RegExp specialCharRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
      RegExp numberRegExp = RegExp(r'[0-9]');

      if (!specialCharRegExp.hasMatch(_password)) {
        throw WeakPasswordException(
          'Password must contain at least one special character.',
        );
      }
      if (!numberRegExp.hasMatch(_password)) {
        throw WeakPasswordException(
          'Password must contain at least one number.',
        );
      }
      try {
        AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
        firebase_auth.UserCredential userCredential = await authProvider.signUpWithEmailAndPassword(_email, _password);
        String uid = userCredential.user!.uid; // UID from the firebase_auth User

        // Create a new User instance from your custom User class
        User user = User(
          username: _username,
          email: _email,
          password: '', // Don't store password locally
          phoneNumber: _phoneNumber,
          region: _region,
          language: _language,
        );

        await authProvider.login(user);

        // Save the user data under the UID in the Realtime Database
        DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('users');
        await usersRef.child(uid).set({
          'username': _username,
          'email': _email,
          'phoneNumber': _phoneNumber,
          'region': _region,
          'language': _language,
        });

      } catch (error) {
        // ... existing error handling code ...
      }

      print("--------------Username is" + _username);

      // Show a dialog to inform the user to verify their email
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Account Created!'),
            content: Text(
                'An account has been created with email:  $_email'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to the home page or any other desired page after successful creation
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LoginPage(), // Replace LoginPage with your desired page
                    ),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } on WeakPasswordException catch (e) {
      // Display password requirement error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(e.message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      // Handle other account creation errors
      print('Error creating account: $error');
      // Display a general error message to the user if necessary
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while creating your account. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
class WeakPasswordException implements Exception {
  final String message;
  WeakPasswordException(this.message);
}