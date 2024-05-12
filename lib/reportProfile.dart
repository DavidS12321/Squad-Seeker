import 'package:flutter/material.dart';

class ReportProfileDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report Profile'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Are you sure you want to report this profile?'),
            Text('Please provide a reason for the report:'),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter reason here',
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Report'),
          onPressed: () {
            // Implement report functionality here
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}