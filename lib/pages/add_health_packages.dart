import 'package:elabplus/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPackages extends StatefulWidget {
  const AddPackages({super.key});

  @override
  State<AddPackages> createState() => _AddPackagesState();
}

class _AddPackagesState extends State<AddPackages> {

  final supabase = Supabase.instance.client;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController requirementsController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
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
          title: Text("Add Package", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: GoogleFonts.hammersmithOne().fontFamily, color: Colors.black),),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0), 
          child: isLoading?
            const SpinKitFadingCircle(color:ElabColors.primaryColor ,)
          : SingleChildScrollView( child: Column(
            children: [
              packageName(),
              const SizedBox(height: 20,),
              packageDescription(),
              const SizedBox(height: 20,),
              packageRequirements(),
              const SizedBox(height: 20,),
              packagePrice(),
              const SizedBox(height: 20,),
              addButton()
            ],
          ),
          )
        ),
      );
      
  
  }

  

  Column packageName() {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Test Name', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: ElabColors.greyColor),),
                const SizedBox(height: 5,),
                TextField(decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: 
                Icon(Icons.science, color: Colors.black,)),
                style: const TextStyle(fontWeight: FontWeight.bold),
                controller: nameController,
                )
              ],
            );
  }
  Column packageDescription() {
    return   Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Test Description', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: ElabColors.greyColor),),
                const SizedBox(height: 5,),
                TextField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration:  const InputDecoration(border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.list_alt_outlined, color: Colors.black,)),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  controller: descriptionController,
                  )
              ],
            );
  }

  Column packageRequirements() {
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

  Column packagePrice() {
    return  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: ElabColors.greyColor),),
                const SizedBox(height: 5,),
                TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
                ], 
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
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
              style:  ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(ElabColors.primaryColor),
                  padding: const MaterialStatePropertyAll(EdgeInsets.fromLTRB(30, 10, 30, 10)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),   
              onPressed: () {
                addPackage();
              }, 
              child:
               Text('Add Package',style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily, color: Colors.white)
               )
              ),
    );
  }


  Future addPackage() async{
    if ([nameController.text, priceController.text, descriptionController.text].any((text) => text.isEmpty)) { 

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
        'name' : nameController.text,
        'description': descriptionController.text,
        'requirements':requirements,
        'price':int.parse(priceController.text)
      };

      await supabase.from('packages').upsert([labData]);

      nameController.text = '';
      requirementsController.text = '';
      descriptionController.text = '';
      priceController.text = '';

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
          msg: "Package Added Successfully",
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