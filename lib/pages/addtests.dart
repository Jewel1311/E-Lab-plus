import 'package:elabplus/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddTests extends StatefulWidget {
  const AddTests({super.key});

  @override
  State<AddTests> createState() => _AddTestsState();
}

class _AddTestsState extends State<AddTests> {

  final supabase = Supabase.instance.client;
  bool isLoading = false;

  final TextEditingController testNameController = TextEditingController();
  final TextEditingController requirementsController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  void dispose() {
    testNameController.dispose();
    requirementsController.dispose();
    priceController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
       backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text("Add Test", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: GoogleFonts.hammersmithOne().fontFamily, color: Colors.black),),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0), 
          child: isLoading?
            const SpinKitFadingCircle(color:ElabColors.primaryColor ,)
          :Column(
            children: [
              testName(),
              const SizedBox(height: 20,),
              testRequirements(),
              const SizedBox(height: 20,),
              testPrice(),
              const SizedBox(height: 20,),
              addButton()
            ],
          ),
        ),
      );
      
  
  }

  

  Column testName() {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Test Name', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: ElabColors.greyColor),),
                const SizedBox(height: 5,),
                TextField(decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: 
                Icon(Icons.science, color: Colors.black,)),
                style: const TextStyle(fontWeight: FontWeight.bold),
                controller: testNameController,
                )
              ],
            );
  }

  Column testRequirements() {
    return   Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Test Requirements', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: ElabColors.greyColor),),
                const SizedBox(height: 5,),
                TextField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration:  const InputDecoration(border: OutlineInputBorder(),
                  hintText: "Requirements if any", prefixIcon: Icon(Icons.list, color: Colors.black,)),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  controller: requirementsController,
                  )
              ],
            );
  }

  Column testPrice() {
    return  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: ElabColors.greyColor),),
                const SizedBox(height: 5,),
                TextField(decoration: const InputDecoration(border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee_sharp, color: Colors.black,),
                ), 
                style: const TextStyle(fontWeight: FontWeight.bold),
                controller: priceController,
                )
              ],
            );
  }

  SizedBox addButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
              style:const ButtonStyle(backgroundColor: MaterialStatePropertyAll(ElabColors.primaryColor)) ,
              onPressed: () {
                addTest();
              }, 
              child:
               Text('Add Test',style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily,)
               )
              ),
    );
  }


  Future addTest() async{
    if ([testNameController.text, priceController.text].any((text) => text.isEmpty)) { 

        Fluttertoast.showToast(
          msg: "All Fields are required",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0
        );
    }
    else{
      setState(() {
        isLoading = true;
      });
      dynamic labId = await supabase.from('labs').select('id').match({'user_id': supabase.auth.currentUser!.id});
      String requirements = 'None';
      if (requirementsController.text != ''){
        requirements = requirementsController.text;
      }
      

      final Map<String, dynamic> labData = {
        'lab_id': labId[0]['id'],
        'testname' : testNameController.text,
        'requirements':requirements,
        'price':int.parse(priceController.text)
      };

      await supabase.from('tests').upsert([labData]);

      testNameController.text = '';
      requirementsController.text = '';
      priceController.text = '';

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
          msg: "Test Added Successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0
        );
    }
  }
}