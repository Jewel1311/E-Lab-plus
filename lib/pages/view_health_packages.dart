import 'package:elabplus/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewPacakges extends StatefulWidget {
  const ViewPacakges({super.key});

  @override
  State<ViewPacakges> createState() => _ViewPacakgesState();
}

class _ViewPacakgesState extends State<ViewPacakges> {

  final supabase = Supabase.instance.client;
  bool isLoading = true;
  dynamic package;
  dynamic package_id;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,(){
      package_id = ModalRoute.of(context)?.settings.arguments as Map?;
      getPackageDetails();
    });
  }

  Future getPackageDetails() async{
    package = await supabase.from('packages').select().match({'id':package_id['id']});
    print(package);

    setState(() {
      isLoading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Package Details", style: TextStyle(fontFamily: GoogleFonts.hammersmithOne().fontFamily, fontWeight: FontWeight.bold),)
      ),
      body: Column(
        children: [
          isLoading?SpinKitFadingCircle(color: ElabColors.primaryColor,):packageDetail()
        ]),
    );
  }

  Expanded packageDetail(){
    return Expanded(child: 
      Padding(padding: EdgeInsets.all(10),
      child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Text(package[0]['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,fontFamily: GoogleFonts.poppins().fontFamily),),
            const SizedBox(height: 8,),
            Row(
              children: [
                Icon(Icons.currency_rupee_sharp, color: Colors.black,),
                Text(package[0]['price'].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,color: Colors.green),),
              ],
            ),
            const SizedBox(height: 10,),

             Container(
              width: double.infinity,
              height: 1, // Adjust the height of the border line as needed
              decoration: BoxDecoration(
                color: ElabColors.greyColor2, // Color of the border line
                borderRadius:
                    BorderRadius.circular(2), // Adjust the radius as needed
              ),
            ),
            const SizedBox(height: 10,),
            Text("Test Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ElabColors.greyColor),),
            const SizedBox(height: 10,),
            Text(package[0]['description'], style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 16)),
            const SizedBox(height: 8,),
             Container(
              width: double.infinity,
              height: 1, // Adjust the height of the border line as needed
              decoration: BoxDecoration(
                color: ElabColors.greyColor2, // Color of the border line
                borderRadius:
                    BorderRadius.circular(2), // Adjust the radius as needed
              ),
            ),
            const SizedBox(height: 8,),
            Text("Test Requirements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ElabColors.greyColor), ),
            const SizedBox(height: 8,),
            Text(package[0]['requirements'],style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 16)),
           
            const SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: (){
                  Navigator.pushNamed(context, '/dashboard');
                }, 
                style:  ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(ElabColors.secondaryColor),
                  padding: const MaterialStatePropertyAll(EdgeInsets.fromLTRB(30, 10, 30, 10)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                icon:Icon(Icons.home, color: Colors.white,), 
                ),
                ElevatedButton.icon(onPressed: (){
                  Navigator.pushNamed(context, '/edit_packages',
                  arguments: {
                    'id':package[0]['id']
                  }
                  );
                }, 
                style:  ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(ElabColors.primaryColor),
                  padding: const MaterialStatePropertyAll(EdgeInsets.fromLTRB(30, 10, 30, 10)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                icon:Icon(Icons.edit, color: Colors.white,), 
                label: Text("Edit Package", style: TextStyle(color: Colors.white),)),
                
              ],
            )


          ],
        ) 
      ,)
    );
  }
}