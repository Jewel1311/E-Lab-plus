import 'package:elabplus/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ 
          Image.asset('assets/images/home.jpg'),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.biotech_rounded ,size: 60, color: ElabColors.secondaryColor,) ,
              Text('E-Lab',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: ElabColors.secondaryColor,
                fontFamily: GoogleFonts.poppins().fontFamily
              ),
              ),
              const Icon(Icons.add, size: 45, color: ElabColors.secondaryColor,)
            ],
          ),
          const SizedBox(height: 30),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: ElevatedButton( onPressed: () {
                   Navigator.pushNamed(context, '/register');
                } ,
                style:ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor:  MaterialStatePropertyAll(ElabColors.greyColor2),
                  
                ) ,
                  child:Text('Register',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.poppins().fontFamily
                    )
                    ),
                ),
              ),
              const SizedBox(width: 20,),
              SizedBox(
                width: 200,
                child: ElevatedButton( onPressed: () {
                   Navigator.pushNamed(context, '/login');
                } ,
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor:  MaterialStatePropertyAll(ElabColors.greyColor2),
                  
                ) ,
                
                  child:Text('Log in as lab',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.poppins().fontFamily
                    )
                    ),
                ),
              ),
               const SizedBox(width: 20,),
              SizedBox(
                width: 200,
                child: ElevatedButton( onPressed: () {
                   Navigator.pushNamed(context, '/collector_login');
                } ,
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor:  MaterialStatePropertyAll(ElabColors.greyColor2),
                  
                ) ,
                  child:Text('Log in as Collector',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.poppins().fontFamily
                    )
                    ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}