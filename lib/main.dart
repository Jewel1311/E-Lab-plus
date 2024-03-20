import 'package:elabplus/pages/add_health_packages.dart';
import 'package:elabplus/pages/addtests.dart';
import 'package:elabplus/pages/bookingdetails.dart';
import 'package:elabplus/pages/bookings.dart';
import 'package:elabplus/pages/collector/collector_dashboard.dart';
import 'package:elabplus/pages/collector/collector_login.dart';
import 'package:elabplus/pages/dashboard.dart';
import 'package:elabplus/pages/edit_packages.dart';
import 'package:elabplus/pages/health_packages.dart';
import 'package:elabplus/pages/home.dart';
import 'package:elabplus/pages/login.dart';
import 'package:elabplus/pages/register.dart';
import 'package:elabplus/pages/view_health_packages.dart';
import 'package:elabplus/pages/viewmap.dart';
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
        '/bookingdetails' :(context) => const BookingDetails(),
        '/viewmap': (context) => const ViewMap(),
        '/health_packages':(context) => const HealthPackages(),
        '/add_health_packages':(context) => const AddPackages(),
        '/collector_login':(context) => const CollectorLogin(),
        '/collector_dashboard':(context) => const CollectorDashboard(),
        '/view_packages':(context) => const ViewPacakges(),
        '/edit_packages':(context) => const EditPackages(),

      },
    );
  }
}
