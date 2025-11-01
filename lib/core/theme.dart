import 'package:flutter/material.dart';

enum AppColors {
  primary(Colors.teal, Colors.white),
  secondary(Colors.tealAccent, Colors.black);

  final Color background;
  final Color foreground;

  const AppColors(this.background, this.foreground);
}

ThemeData get appTheme => ThemeData.dark().copyWith(
  appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
  scaffoldBackgroundColor: Colors.black,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary.background,
      foregroundColor: AppColors.primary.foreground,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary.background,
    foregroundColor: AppColors.primary.foreground,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedItemColor: AppColors.primary.background,
  ),
  listTileTheme: ListTileThemeData(iconColor: AppColors.primary.background),
);
