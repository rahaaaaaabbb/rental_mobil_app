import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'views/auth/login_screen.dart';

void main() {
  runApp(const RentalJayaApp());
}

class RentalJayaApp extends StatelessWidget {
  const RentalJayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rental Jaya Abadi',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 45, 100, 66),
        primaryColor: const Color.fromARGB(255, 218, 214, 214),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 246, 247, 246),
          secondary: const Color(0xFF2B2E4A),
        ),
      ),

      home: LoginScreen(),
    );
  }
}
