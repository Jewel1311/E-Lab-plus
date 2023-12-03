import 'package:elabplus/pages/addtests.dart';
import 'package:elabplus/pages/bookings.dart';
import 'package:elabplus/pages/profile.dart';
import 'package:elabplus/pages/tests.dart';
import 'package:elabplus/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  final supabase = Supabase.instance.client;
  dynamic labName;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getLabName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: labName == null?const Text(''): Text(labName,
          style: TextStyle(fontFamily: GoogleFonts.hammersmithOne().fontFamily,color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),

      body:  IndexedStack(
        index: _selectedIndex,
        children:const [
          ViewBookings(),
          Tests(),
          AddTests(),
          Profile(),
        ],
        ),
      bottomNavigationBar:  Padding(
        padding: const EdgeInsets.fromLTRB(8,8,8,10),
        child: ClipRRect(
            borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
            bottomLeft:Radius.circular(15.0),
            bottomRight:Radius.circular(15.0),
          ),
        child: 
      BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'Tests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add Tests'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: ElabColors.greyColor2,
        onTap: _onItemTapped,
        iconSize: 25,
        showUnselectedLabels: true,
        selectedItemColor: ElabColors.primaryColor,
        unselectedItemColor: ElabColors.secondaryColor,
        
      )
        )
        )
    );
  }

  void _onItemTapped( int index) {
    setState(() {
    _selectedIndex = index;
    });
  }

  Future getLabName() async {
    dynamic lab = await supabase.from('labs').select('labname').match({'user_id': supabase.auth.currentUser!.id});
    setState(() {
      labName = lab[0]['labname'];
    });
  }
}


