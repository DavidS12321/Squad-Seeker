import 'package:flutter/material.dart';

class ProfileInfoDialog extends StatelessWidget {
  final String username;

  const ProfileInfoDialog({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20.0),
          Placeholder(
            // Placeholder for profile image
            fallbackHeight: 100.0,
            fallbackWidth: 100.0,
          ),
          SizedBox(height: 20.0),
          Text(
            'Hi $username!',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.0),
          Text(
            'Ratings (num ratings)',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Reviews (num reviews)',
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Close'),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }
}