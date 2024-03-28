import 'package:elabplus/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrescriptionDetails extends StatefulWidget {
  const PrescriptionDetails({super.key});

  @override
  State<PrescriptionDetails> createState() => _PrescriptionDetailsState();
}

class _PrescriptionDetailsState extends State<PrescriptionDetails> {

  final supabase = Supabase.instance.client;

  bool isLoading = true;
  dynamic bookingId;
  dynamic bookingDetails;
  dynamic bookingStatus;
  dynamic labDetails;
  dynamic patientDetails;
  dynamic contactDetails;
  String imageUrl="";

  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      bookingId = ModalRoute.of(context)?.settings.arguments as Map?;
      getBookingInfo();
    });
  }

  Future getBookingInfo() async {
    bookingDetails = await supabase
        .from('prescription')
        .select()
        .match({'id': bookingId['bookingId']});
    bookingStatus = bookingDetails[0]['status'];

    labDetails = await supabase
        .from('labs')
        .select()
        .match({'id': bookingDetails[0]['lab_id']});

    patientDetails = await supabase
        .from('patient')
        .select()
        .match({'id': bookingDetails[0]['patient_id']});

    contactDetails = await supabase
        .from('contact')
        .select()
        .match({'id': bookingDetails[0]['contact_id']});

    
    imageUrl = supabase
    .storage
    .from('prescription')
    .getPublicUrl('booking/${bookingId['bookingId']}');

    print(imageUrl);

    setState(() {
      isLoading = false;
    });
  }

  String convert24HourTo12Hour(String time24) {
    DateTime dateTime = DateFormat('HH:mm').parse(time24);
    String time12 = DateFormat('h:mm a').format(dateTime);
    return time12;
  }

  String formatToCustomFormat(String inputDate) {
    DateTime dateTime = DateFormat('yyyy-MM-dd').parse(inputDate);
    String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    return formattedDate;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'rejected':
        return Colors.red;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return ElabColors.primaryColor;
      default:
        return Colors.amberAccent.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription Details', style: TextStyle(
                    color: Colors.black,
                    fontFamily: GoogleFonts.hammersmithOne().fontFamily,
                    fontWeight: FontWeight.bold),),
      ),
      body: isLoading?SpinKitFadingCircle(color: ElabColors.primaryColor,): SingleChildScrollView(child: PrescriptionDetails(context)),
      bottomNavigationBar: isLoading?Text(""):bottomNavBar(),
    );
  }



  Column PrescriptionDetails(BuildContext context) {
    return Column(
      children: [
        Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('status: '),
              Text(
                bookingStatus,
                style: TextStyle(
                    color: _getStatusColor(bookingStatus),
                    fontSize: 15,
                    fontFamily: GoogleFonts.poppins().fontFamily),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          
          InkWell(
            onTap: (){
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: Container(
                      width: double.infinity,
                      height: 500,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            },
            child: Image.network(
                    imageUrl,
                    height: 300,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
          ),

          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            height: 1, // Adjust the height of the border line as needed
            decoration: BoxDecoration(
              color: ElabColors.greyColor2, // Color of the border line
              borderRadius:
                  BorderRadius.circular(2), // Adjust the radius as needed
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          


          
          const Text(
            "Date and Time",
            style: TextStyle(
                color: ElabColors.greyColor,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            height: 1, // Adjust the height of the border line as needed
            decoration: BoxDecoration(
              color: ElabColors.greyColor2, // Color of the border line
              borderRadius:
                  BorderRadius.circular(2), // Adjust the radius as needed
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            formatToCustomFormat(bookingDetails[0]['date'].toString()),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            convert24HourTo12Hour(bookingDetails[0]['time']),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Patient Details",
            style: TextStyle(
                color: ElabColors.greyColor,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            height: 1, // Adjust the height of the border line as needed
            decoration: BoxDecoration(
              color: ElabColors.greyColor2, // Color of the border line
              borderRadius:
                  BorderRadius.circular(2), // Adjust the radius as needed
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            patientDetails[0]['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Age : ${patientDetails[0]['age']}  Gender: ${patientDetails[0]['gender']}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Contact Details",
            style: TextStyle(
                color: ElabColors.greyColor,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            height: 1, // Adjust the height of the border line as needed
            decoration: BoxDecoration(
              color: ElabColors.greyColor2, // Color of the border line
              borderRadius:
                  BorderRadius.circular(2), // Adjust the radius as needed
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            contactDetails[0]['address'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Phone : ${contactDetails[0]['phone']} ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Landmark : ${contactDetails[0]['landmark']} ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10,),
          ElevatedButton.icon(onPressed: (){
            Navigator.pushNamed(context, '/viewmap',arguments: {
              'latitude': contactDetails[0]['latitude'],
              'longitude': contactDetails[0]['longitude']
            });
          }, 
          icon: Icon(Icons.pin_drop_outlined, color: Colors.black,), label: Text("View Location", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
          style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(ElabColors.greyColor2)),
          ),
          const SizedBox(
            height: 20,
          ),
          
        ],
      ),
    ),
      ],
    );
  }


 Material bottomNavBar() {
    return Material(
        elevation: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 15, 8),
              child: ElevatedButton(
                onPressed: () {
                  showAlert(context, 'Are you sure you want to reject?');
                },
                style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(
                      Color.fromARGB(255, 211, 78, 78)),
                  fixedSize: MaterialStateProperty.all(
                    const Size(100, 40),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  
                ),
                child: Text('Reject',
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 15, 8),
              child: ElevatedButton(
                onPressed: () async {
                 
                  addPrice(context);

                },
                style: ButtonStyle(
                  backgroundColor:
                      const MaterialStatePropertyAll(ElabColors.primaryColor),
                  fixedSize: MaterialStateProperty.all(
                    const Size(100, 40),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: Text('Accept',
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    )),
              ),
            ),
          ],
        ));
  }


  void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await supabase
                    .from('booking')
                    .update({'status': 'rejected'}).match(
                        {'id': bookingDetails[0]['id']});
                setState(() {
                  bookingStatus = 'rejected';
                });


                Fluttertoast.showToast(
                    msg: "Booking Rejected",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 2,
                    backgroundColor: ElabColors.greyColor,
                    textColor: Colors.white,
                    fontSize: 16.0);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void addPrice(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Price'),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async{
                if(priceController.text!=''){
                  await supabase.from('prescription').update({'status':'confirmed','price':priceController.text})
                  .match({'id':bookingId['bookingId']});
                }
                else{
                  Fluttertoast.showToast(
                    msg: "Price is required",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 2,
                    backgroundColor: ElabColors.greyColor,
                    textColor: Colors.white,
                    fontSize: 16.0);
                }
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

}