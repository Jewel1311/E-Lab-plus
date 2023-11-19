import 'package:elabplus/pages/addtests.dart';
import 'package:elabplus/pages/bookingdetails.dart';
import 'package:elabplus/pages/bookings.dart';
import 'package:elabplus/pages/dashboard.dart';
import 'package:elabplus/pages/home.dart';
import 'package:elabplus/pages/login.dart';
import 'package:elabplus/pages/register.dart';
import 'package:elabplus/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() { 
  runApp(const ElabPlus());
}


class ElabPlus extends StatelessWidget {
  const ElabPlus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      title: 'Elab',
      
      initialRoute: '/',
      routes: {
        '/' :(context) => const SplashScreen(),
        '/home' :(context) => const Home(),
        '/register' :(context) => const Register(),
        '/login' :(context) => const Login(),
        '/dashboard':(context) => const Dashboard(),
        '/addtests' :(context) => const AddTests(),
        '/bookings' :(context) => const ViewBookings(),
        '/bookingdetails' :(context) => const BookingDetails()
      },
    );
  }
}
