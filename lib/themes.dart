import 'package:flutter/material.dart';

// Define your theme data here
final ThemeData myTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.deepPurple, // Use purple as the primary color
    accentColor: Colors.black, // Use black as the accent color
    errorColor: Colors.red,
  ).copyWith(
    background: Colors.white, // Use white as the background color
  ),
  appBarTheme: const AppBarTheme(
    color: Colors.deepPurple, // Use purple for app bar color
  ),
  textTheme: const TextTheme(
  ),
  dialogTheme: const DialogTheme(
    backgroundColor: Colors.white, // Use white for dialog background
  ),
  useMaterial3: true,
);