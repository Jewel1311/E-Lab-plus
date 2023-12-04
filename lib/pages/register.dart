import 'package:elabplus/style/colors.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  bool emailValidationError = false;
  bool passwordValidationError = false;
  bool isLoading = false;
  TimeOfDay? selectedTime;
  bool confirmpasswordError = false;
  bool mapValidationError = false;


  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController opentimeController = TextEditingController(text: "6:00 AM");
  final TextEditingController closetimeController = TextEditingController(text: "6:00 PM");
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  MapController mapController = MapController();
  LatLng markerLatLng = LatLng(0, 0);
  dynamic initialLatitude  = 9.580;
  dynamic initialLongitude = 76.803;

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    cityController.dispose();
    passwordController.dispose();
    opentimeController.dispose();
    closetimeController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool timeValidation(String opentime, String closetime){
    final format = DateFormat('h:mm a');
    final openhour = format.parse(opentime).hour;
    final closehour = format.parse(closetime).hour;
    if((openhour < 6 || openhour >= 18)|| (closehour > 18 || closehour <= 6 )){
      return true;
    }
    else if(closehour == 18 ){
      if(format.parse(closetime).minute == 0){
        return false;
      }  
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isLoading? null :
      AppBar(
        elevation: 0,
         iconTheme: const IconThemeData(
          color: ElabColors.greyColor,
        ),
        backgroundColor: Colors.white,
      ),
      body: isLoading? loadingView():registrationForm(context),
    );
  }


  // check input validations
  void onCreate() {
    if ([emailController.text, nameController.text, cityController.text, passwordController.text, opentimeController.text, closetimeController.text, confirmPasswordController.text].any((text) => text.isEmpty)) { 

        Fluttertoast.showToast(
          msg: "All Fields are required",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0
        );
    }else{
        setState(() {
          emailValidationError = false;
          passwordValidationError = false;
          confirmpasswordError = false;
        });
        // email validation
        if(! EmailValidator.validate(emailController.text.trim())){
          setState(() {
            emailValidationError = true;
          });
        }

        if(timeValidation(opentimeController.text, closetimeController.text)){
            showAlert(context, 'Time must be between 6:00 AM and 6:00 PM');
        }
        
        //password validation
        if(passwordController.text.trim().length < 6){
          setState(() {
            passwordValidationError = true;
          });
        }
        if(passwordController.text.trim() != confirmPasswordController.text.trim()){
          setState(() {
            confirmpasswordError = true;
          });
        }
        if(markerLatLng.latitude == 0 || markerLatLng.longitude == 0 ){
          mapValidationError = true;
          Fluttertoast.showToast(
          msg: "Select lab location on map",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0
        );
        }
        else{
          mapValidationError = false;
        }

        if( emailValidationError == false && passwordValidationError == false && confirmpasswordError == false && mapValidationError == false){
          registerLab();
        }
    }
  }

  Future registerLab() async{
    setState(() {
        isLoading = true;
    });
    final supabase = Supabase.instance.client;
    try{
      try{
        await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      }catch(e){
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
          msg: "Email already exists",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0
          );
        throw Exception();
      }
      
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );


      final Map<String, dynamic> labData = {
        'labname': nameController.text.trim(),
        'city': cityController.text.trim(),
        'opentime':  convert12HourTo24Hour(opentimeController.text.trim()),
        'closetime': convert12HourTo24Hour(closetimeController.text.trim()),
        'phone': phoneController.text.trim(),
        'latitude': markerLatLng.latitude,
        'longitude': markerLatLng.longitude
      };

  
      await supabase
      .from('labs') 
      .upsert([labData]);

      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);

    }catch(e){
      if (supabase.auth.currentUser != null){
        String uid = supabase.auth.currentUser!.id; 
        final supabaseadmin = SupabaseClient(dotenv.env['URL']!, dotenv.env['SERVICE_KEY']!);
        await supabaseadmin.auth.signOut(); // Sign out the user
        await supabaseadmin.auth.admin.deleteUser(uid);

        setState(() {
          isLoading = false;
        });
        
        Fluttertoast.showToast(
          msg: "Unable to create account",
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

  
  //loading view
  Center loadingView() => const Center(child: SpinKitThreeBounce(color: ElabColors.primaryColor,));


  //registration form
  SingleChildScrollView registrationForm(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20,5,20,20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text('Register your lab',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.hammersmithOne().fontFamily
          )
          ),
          const SizedBox(height: 5),
          Text('Take the inaugural step',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 146, 146, 146), fontFamily: GoogleFonts.poppins().fontFamily)
          ),
          const SizedBox(height: 20),
          emailField(),
          const SizedBox(height: 15),
          labnameField(),
          const SizedBox(height: 15),
          cityField(),
          const SizedBox(height: 15),
          phoneField(),
          const SizedBox(height: 15),
          const Text("Time must be between 6:00 AM and 6:00 PM", style: TextStyle(
            color: Colors.black,
          ),),
          const SizedBox(height: 5,),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                openTimeField(),
                closeTimeField()
              ],
          ),
          const SizedBox(height: 15),
          passwordField(),
          const SizedBox(height: 15),
          confirmPasswordField(),
          const SizedBox(height: 15),
          Text('Select lab location',style: TextStyle(fontSize: 16, color: ElabColors.greyColor, fontWeight: FontWeight.bold),),
          const SizedBox(height: 15),
          mapView(),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (){
                onCreate();
              }, 
              style: ButtonStyle(
                backgroundColor: const MaterialStatePropertyAll(ElabColors.primaryColor),
                padding: const MaterialStatePropertyAll(EdgeInsets.fromLTRB(30, 10, 30, 10)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                    ),
                  ),
              ),
              child:Text('Register', 
              style: TextStyle(
                fontSize: 16,
                fontFamily: GoogleFonts.poppins().fontFamily
              )
              )
              ),
          ),
             const SizedBox(height: 20),
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: GoogleFonts.poppins().fontFamily
                ),),
                GestureDetector(
                  onTap:() {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(' Log In', style: 
                  TextStyle(color:ElabColors.primaryColor, fontSize: 16,fontFamily: GoogleFonts.poppins().fontFamily),)
                ),
              ],
            )
        ],
      ),
    )
    );
  }
Container mapView() {
    return Container(
        width: double.infinity,
        height: 400,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
              onTap: (tapPosition, point) {
                setState(() {
                  markerLatLng = point;
                });
              },
              initialCenter: LatLng(initialLatitude, initialLongitude),
              
              initialZoom: 9.2),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            MarkerLayer(markers: [
              Marker(
                  point: markerLatLng,
                  child: Icon(
                    Icons.location_on,
                    size: 40,
                    color: Colors.red,
                  ))
            ])
          ],
        ));
  }

  Column emailField() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
            TextField(
                controller: emailController,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: const InputDecoration(
                  prefixIcon:Icon(Icons.alternate_email_rounded, color:Colors.black,size: 20, ),
                ),     
              ),
              // show email validation error
               if (emailValidationError)
                Text(
                'Enter a valid email',
                style: TextStyle(color: Colors.red, fontFamily: GoogleFonts.poppins().fontFamily),   
              )
          
            ],
          );
  }


  Column labnameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lab Name', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
        TextField(
          controller: nameController,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          decoration: const InputDecoration(
            prefixIcon:Icon(Icons.biotech, color:Colors.black,size: 20, ),
          ),     
        ),
      ],
    );
  }

  Column phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.digitsOnly,
             // Allow only digits
          ], 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          decoration: const InputDecoration(
            prefixIcon:Icon(Icons.phone, color:Colors.black,size: 20, ),
            
          ),     
        ),
      ],
    );
  }


  Column cityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('City', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
        TextField(
          controller: cityController,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          decoration: const InputDecoration(
            prefixIcon:Icon(Icons.business, color:Colors.black,size: 20, ),
          ),     
        ),
      ],
    );
  }

  SizedBox openTimeField() {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking open from', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
          TextField(
            controller: opentimeController,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            decoration: const InputDecoration(
              prefixIcon:Icon(Icons.access_time, color:Colors.black,size: 20, ),
            ), 
            onTap: () {
              _selectTime(context, opentimeController);
            },    
          ),
        ],
      ),
    );
  }

  SizedBox closeTimeField() {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking open till', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
          TextField(
            controller: closetimeController,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            decoration: const InputDecoration(
              prefixIcon:Icon(Icons.timelapse, color:Colors.black,size: 20, ),
            ), 
            onTap: () {
              _selectTime(context, closetimeController);
            },    
          ),
        ],
      ),
    );
  }



Column passwordField() {
      return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Password (minimum 6 characters)', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: const InputDecoration(
                  prefixIcon:Icon(Icons.key, color:Colors.black,size: 20, ),
                ),     
              ),
                // show email validation error
                if (passwordValidationError)
                  Text(
                  'Minimum 6 characters required',
                  style: TextStyle(color: Colors.red, fontFamily: GoogleFonts.poppins().fontFamily),   
                ),         
              ],
            );
    }

    
Column confirmPasswordField() {
      return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Confirm Password', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: const InputDecoration(
                  prefixIcon:Icon(Icons.keyboard, color:Colors.black,size: 20, ),
                ),     
              ),
                // show email validation error
                if (confirmpasswordError)
                  Text(
                  "Passwords don't match",
                  style: TextStyle(color: Colors.red, fontFamily: GoogleFonts.poppins().fontFamily),   
                ),         
              ],
            );
    }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        controller.text = picked.format(context);
      });
    }
  }

  String convert12HourTo24Hour(String time12Hour) {
    final inputFormat = DateFormat('h:mm a');
    final outputFormat = DateFormat('HH:mm:ss');
    final dateTime = inputFormat.parse(time12Hour);
    final time24Hour = outputFormat.format(dateTime);
    return time24Hour;
  }

void showAlert(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the alert dialog
            },
            child: const Text('Ok'),
          ),
          
        ],
      );
    },
  );
}

}

