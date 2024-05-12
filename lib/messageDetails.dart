import 'package:flutter/material.dart';
import 'reportProfile.dart';
import 'messaging.dart';
import 'profileInfoDialog.dart';

class MessageDetailPage extends StatelessWidget {
  final Message message;

  const MessageDetailPage({Key? key, required this.message}) : super(key: key);

  void showPopupMenu(BuildContext context) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RenderBox appBar = context.findRenderObject() as RenderBox;
    final Offset target = appBar.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(target.dx, target.dy + appBar.size.height, target.dx + appBar.size.width, target.dy),
      items: [
        PopupMenuItem(
          child: Text("Remove/Add Friend"),
          onTap: () {
            // Handle Remove/Add Friend action
          },
        ),
        PopupMenuItem(
          child: Text("Report Profile"),
          onTap: () {
            // Show report profile dialog
            showDialog(
              context: context,
              builder: (context) => ReportProfileDialog(),
            );
          },
        ),
        PopupMenuItem(
          child: Text("Block User"),
          onTap: () {
            // Handle Block User action
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ProfileInfoDialog(username: message.username),
            );
          },
          child: Text(
            message.username,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Show the pop-up menu
              showPopupMenu(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Username and Back-and-forth texts
          Expanded(
            child: ListView.builder(
              itemCount: 10, // or any other message count
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Message $index',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Keyboard
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}