import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final List<BottomAppBarItem> items;
  final String currentRouteName;

  const CustomBottomAppBar({
    Key? key,
    required this.items,
    required this.currentRouteName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).appBarTheme.backgroundColor, // Use the same color as the app bar
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Adjusted to increase gap
            children: items
                .map((item) => IconButton(
                onPressed: () {
                  if (item.routeName != currentRouteName) {
                    Navigator.pushReplacementNamed(context, item.routeName);
                  }
                },
              icon: Icon(item.icon),
            ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class BottomAppBarItem {
  final String title;
  final String routeName;
  final IconData icon;

  BottomAppBarItem({
    required this.title,
    required this.routeName,
    required this.icon,
  });
}