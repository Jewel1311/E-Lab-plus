import 'dart:convert';
import 'dart:io';
import 'package:elabplus/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;


class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  final supabase = Supabase.instance.client;
  bool isLoading = false;
  dynamic labDetails;
  dynamic bookingDetails;
  dynamic bookingStatus = '';
  dynamic bookingId;
  dynamic patientDetails;
  dynamic contactDetails;
  List testDetails = [];
  int totalPrice = 0;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });

    Future.delayed(Duration.zero, () {
      bookingId = ModalRoute.of(context)?.settings.arguments as Map?;
      getBookingInfo();
    });
  }

  Future getBookingInfo() async {
    bookingDetails = await supabase
        .from('booking')
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

    for (int id in bookingDetails[0]['tests']) {
      final testDetail =
          await supabase.from('tests').select().match({'id': id});
      testDetails.add(testDetail);
      totalPrice = totalPrice + int.parse(testDetail[0]['price'].toString());
    }
    setState(() {
      isLoading = false;
    });
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

  String addOneHourToCurrentTime(String currentTime) {
    DateTime parsedTime = DateFormat('h:mm a').parse(currentTime);
    DateTime newTime = parsedTime.add(const Duration(hours: 1));
    String formattedTime = DateFormat('h:mm a').format(newTime);
    return formattedTime;
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


  Future sendPushNotification(String userId, String message) async {

    await dotenv.load(fileName: ".env");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': dotenv.env['URL']!,
    };

    var body = {
      'app_id': dotenv.env['APP_ID']!,
      'include_player_ids': [userId],
      'contents': {'en': message},
    };

    await http.post(
      Uri.parse("https://onesignal.com/api/v1/notifications"),
      headers: headers,
      body: jsonEncode(body),
    );

  }


  Future uploadResult() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    setState(() {
      isUploading = true;
    });
    try {
      if (result != null) {
        final File file = File(result.files.first.path!);

        await supabase.storage.from('testresults').upload(
              "results/${bookingDetails[0]['id']}",
              file,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );

        await supabase.from('booking').update({'status': 'completed', 'pay_status':'paid'}).match(
            {'id': bookingDetails[0]['id']});

        final profile = await supabase.from('profile').select('onesignaluserid').match({'user_id':bookingDetails[0]['user_id']});

        const message = "Your test results are now available. Please proceed to the Results section on the app to view them.";

        sendPushNotification(profile[0]['onesignaluserid'], message);

        Fluttertoast.showToast(
            msg: "Result uploaded",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: ElabColors.greyColor,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          bookingStatus = 'completed';
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Unable to upload",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    setState(() {
      isUploading = false;
    });
  }

  Future downloadResult() async {
    try {
      final Uint8List file = await supabase.storage
          .from('testresults')
          .download("results/${bookingDetails[0]['id']}");
      DateTime now = DateTime.now();
      String concatenatedTime =
          '${now.hour}${now.minute}${now.second}${now.millisecond}';
      final targetFile = File(
          'storage/emulated/0/Download/Elab_$concatenatedTime${bookingDetails[0]['id']}.pdf');
      targetFile.writeAsBytesSync(file);

      Fluttertoast.showToast(
          msg: "File saved to Downloads ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Unable to download ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isLoading
          ? null
          : AppBar(
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0,
              backgroundColor: Colors.white,
              title: Text(
                'Booking Details',
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: GoogleFonts.hammersmithOne().fontFamily,
                    fontWeight: FontWeight.bold),
              ),
            ),
      body: isLoading
          ? const Center(
              child: SpinKitFadingCircle(color: ElabColors.primaryColor),
            )
          : SingleChildScrollView(child: listBookingDetails()),
      bottomNavigationBar: isLoading
          ? null
          : bookingStatus == 'pending'
              ? bottomNavBar()
              : null,
    );
  }

  Column listBookingDetails() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            const Text(
              "Tests Selected",
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
              height: 15,
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: testDetails.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testDetails[index][0]['testname'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee,
                            color: Colors.black,
                            size: 20,
                          ),
                          Text(
                            testDetails[index][0]['price'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  );
                }),
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
            Row(
              children: [
                const Text(
                  "Total amount: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Icon(Icons.currency_rupee),
                Text(
                  totalPrice.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green),
                ),
                Text(" ("+bookingDetails[0]['pay_status']+")",style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily, fontWeight: FontWeight.bold),)
              ],
            ),
          ],
        ),
      ),

      //upload file
      const SizedBox(
        height: 10,
      ),
      bookingStatus == 'confirmed'
          ? Center(
              child: SizedBox(
                width: 170,
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                      onPressed: () {
                        isUploading ? null : uploadResult();
                      },
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(ElabColors.primaryColor),
                      ),
                      icon: const Icon(Icons.upload),
                      label: isUploading
                          ? const SpinKitFadingCircle(
                              color: Colors.white,
                              size: 30,
                            )
                          : const Text("Upload Result")),
                ),
              ),
            )
          : const Text(''),

      //download file
      bookingStatus == 'completed'
          ? Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,15),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                      onPressed: () {
                        downloadResult();
                      },
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(ElabColors.primaryColor),
                      ),
                      icon: const Icon(Icons.download),
                      label: isUploading
                          ? const SpinKitFadingCircle(
                              color: Colors.white,
                              size: 30,
                            )
                          : const Text("Result")),
                  const SizedBox(width: 10,),
                  ElevatedButton.icon(
                    onPressed: () {
                      showRemove(context, 'Are you sure you want to remove the uploaded result?');
                    },
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(ElabColors.secondaryColor),
                    ),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Remove'),
                  ),
                ],
              ),
          )
          : const Text('')
    ]);
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
                ),
                child: Text('Reject',
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 15, 8),
              child: ElevatedButton(
                onPressed: () async {
                  await supabase
                      .from('booking')
                      .update({'status': 'confirmed'}).match(
                          {'id': bookingDetails[0]['id']});
                  
                  setState(() {
                    bookingStatus = 'confirmed';
                  });
                  final profile = await supabase.from('profile').select('onesignaluserid').match({'user_id':bookingDetails[0]['user_id']});

                  final message = "Your test booking for ${ formatToCustomFormat(bookingDetails[0]['date'].toString())} has been confirmed";

                  sendPushNotification(profile[0]['onesignaluserid'], message);

                  Fluttertoast.showToast(
                      msg: "Booking Confirmed",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      timeInSecForIosWeb: 2,
                      backgroundColor: ElabColors.greyColor,
                      textColor: Colors.white,
                      fontSize: 16.0);
                },
                style: ButtonStyle(
                  backgroundColor:
                      const MaterialStatePropertyAll(ElabColors.primaryColor),
                  fixedSize: MaterialStateProperty.all(
                    const Size(100, 40),
                  ),
                ),
                child: Text('Accept',
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontWeight: FontWeight.bold,
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

                final profile = await supabase.from('profile').select('onesignaluserid').match({'user_id':bookingDetails[0]['user_id']});
                  final paymessage = bookingDetails[0]['pay_status'] == 'paid'?"Refund will be credited in 2-3 working days" :""; 
                  final message = "Your test booking for ${ formatToCustomFormat(bookingDetails[0]['date'].toString())} has been rejected. "+paymessage;

                  sendPushNotification(profile[0]['onesignaluserid'], message);

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

  void showRemove(BuildContext context, String message) {
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
                Navigator.pop(context);
                setState(() {
                  isLoading = true;
                });
              await supabase
                .storage
                .from('testresults')
                .remove(["results/${bookingDetails[0]['id']}"]);
              await supabase
                    .from('booking')
                    .update({'status': 'confirmed'}).match(
                        {'id': bookingDetails[0]['id']});

                setState(() {
                  isLoading = false;
                  bookingStatus = 'confirmed';
                });
                Fluttertoast.showToast(
                    msg: "Result removed",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 2,
                    backgroundColor: ElabColors.greyColor,
                    textColor: Colors.white,
                    fontSize: 16.0);
                // ignore: use_build_context_synchronously
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
