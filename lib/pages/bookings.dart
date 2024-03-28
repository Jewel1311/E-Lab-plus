import 'package:elabplus/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewBookings extends StatefulWidget {
  const ViewBookings({super.key});

  @override
  State<ViewBookings> createState() => _ViewBookingsState();
}

class _ViewBookingsState extends State<ViewBookings> {

  bool isLoading = false;
  dynamic bookingsStream;
  dynamic bookingsData;
  dynamic bookingCount;
  dynamic labId;
  bool isStream = true;
  String selectedButtton = 'tests';

  final List<String> status = ['All','Pending', 'Confirmed', 'Rejected', 'Completed'];
  String selectedStatus =  'All';

  final supabase = Supabase.instance.client;


  @override
  void initState() {
    super.initState();
    getLabStream();
  }

  Future getLabStream() async{
    setState(() {
      isLoading = true;
      isStream = true;
    });

    labId = await supabase.from('labs').select('id').match({'user_id':supabase.auth.currentUser!.id});
    bookingsStream =  supabase.from('booking').stream(primaryKey:['id']).eq('lab_id', labId[0]['id']).order('id');
    bookingCount = await supabase.from('booking').select('id').match({'lab_id':labId[0]['id']});
    setState(() {
      isLoading = false;
    });
    
  }

  Future getBookingData(String status) async {
    setState(() {
      isLoading = true;
      isStream = false;
    });

    bookingsData=  await supabase.from('booking').select().match({'lab_id':labId[0]['id'], 'status':status}).order('id');

    bookingCount = await supabase.from('booking').select('id').match({'lab_id':labId[0]['id'],
    'status': status});

    setState(() {
      isLoading = false;
    });

  }
  Future getPrescriptionData(String status) async {
    setState(() {
      isLoading = true;
      isStream = false;
    });

    if(status == 'all'){
      bookingsData=  await supabase.from('prescription').select().match({'lab_id':labId[0]['id']}).order('id');

      bookingCount = await supabase.from('prescription').select('id').match({'lab_id':labId[0]['id'],});
    }
    else{

      bookingsData=  await supabase.from('prescription').select().match({'lab_id':labId[0]['id'], 'status':status}).order('id');

      bookingCount = await supabase.from('prescription').select('id').match({'lab_id':labId[0]['id'],
      'status': status});
    }

    setState(() {
      isLoading = false;
    });

  }
  Future getPackageData(String status) async {
    setState(() {
      isLoading = true;
      isStream = false;
    });

    if(status == 'all'){
      bookingsData=  await supabase.from('packages_booking').select().match({'lab_id':labId[0]['id']}).order('id');

      bookingCount = await supabase.from('packages_booking').select('id').match({'lab_id':labId[0]['id'],});
    }
    else{

      bookingsData=  await supabase.from('packages_booking').select().match({'lab_id':labId[0]['id'], 'status':status}).order('id');

      bookingCount = await supabase.from('packages_booking').select('id').match({'lab_id':labId[0]['id'],
      'status': status});
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

  String formatToCustomFormat(String inputDate) {
    DateTime dateTime = DateFormat('yyyy-MM-dd').parse(inputDate);
    String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    return formattedDate;
  }

  String convert24HourTo12Hour(String time24) {
    DateTime dateTime = DateFormat('HH:mm').parse(time24);
    String time12 = DateFormat('h:mm a').format(dateTime);
    return time12;
  }
  @override
  Widget build(BuildContext context) {
    return isLoading?

    const Center(child: Text("Loading...", style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold
        ),
       ),
      )

      :

     Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10,0,10,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bookings',style: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ), 
                ),
                statusDropdown(),
              ],
            ),
          ),
          showBookingTypes(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8,0,8,0),
            child: Row(
              children: [
                Text('Showing results of '),
                Text(selectedButtton,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
          child: 
            bookingCount.length == 0 ?
            const Center(child: Text("No bookings yet", style: TextStyle(fontWeight: FontWeight.bold,
            fontSize: 16),),)
            :
            isStream? showBookings():showBookingData(),
          )
        ],
    );
  }

  Padding showBookingTypes() {
    return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(onPressed: (){
                setState(() {
                  selectedButtton = 'tests';
                });
                getLabStream();
              }, 
              style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(ElabColors.secondaryColor),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
                    ),
              child: Text('Tests', style: TextStyle(color: Colors.white),)),

              ElevatedButton(onPressed: (){
                setState(() {
                  selectedButtton = 'prescription';
                });
                 getPrescriptionData('all');
              }, 
              style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(ElabColors.secondaryColor),
                  
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
                    ),
              child: Text('Prescription', style: TextStyle(color: Colors.white),)),

              ElevatedButton(onPressed: (){
                setState(() {
                  selectedButtton = 'packages';
                });
                 getPackageData('all');

              }, 
              style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(ElabColors.secondaryColor),
                  
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
                    ),
              child: Text('Packages', style: TextStyle(color: Colors.white),)),
            
            ],
          ),
        );
  }

  ListView showBookingData() {
    return ListView.builder(
          itemCount: bookingsData.length,
          itemBuilder: (context, index){
           return GestureDetector(
              onTap: () {
                if(selectedButtton == 'tests'){
                  Navigator.pushNamed(context,'/bookingdetails', arguments: {
                  'bookingId' : bookingsData[index]['id']
                });
                }
                else if(selectedButtton == 'prescription'){
                  Navigator.pushNamed(context,'/prescription_details', arguments: {
                  'bookingId' : bookingsData[index]['id']
                });
                }
                
              },
              child: Container(
            margin: const EdgeInsets.fromLTRB(10,8,10,10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
            ),
            child:Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                      Row(
                        children: [
                          Text(formatToCustomFormat( bookingsData[index]['date'].toString()),
                                  style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 16) ,
                                  ),
                          const Text(" | ", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),

                          Text(convert24HourTo12Hour(bookingsData[index]['time'].toString()), style: const TextStyle(fontSize: 16),)
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          const Text('status: '),
                          Text(bookingsData[index]['status'],
                          style: TextStyle(color: _getStatusColor(bookingsData[index]['status']), fontSize: 15, fontFamily: GoogleFonts.poppins().fontFamily),
                          ),
                        ],
                      ),
                      ]
                  ),
                  const Icon(Icons.chevron_right_outlined,size: 40,)
                ],
              ),
            )
            )
           );
          }
          
        );
  }

  DropdownButton<String> statusDropdown() {
    return DropdownButton<String>(
              value: selectedStatus,
              // The items shown in the dropdown menu
              items: status.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8,8,0,8),
                    child: Text(item, style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: GoogleFonts.poppins().fontFamily),),
                  ),
                );
              }).toList(),
              // Called when the user selects an item
              onChanged: (String? value) {
                setState(() {
                  selectedStatus = value!;
                  if(selectedStatus == 'Confirmed' || selectedStatus == 'Rejected' || selectedStatus == 'Pending' || selectedStatus == 'Completed'){
                    if(selectedButtton == 'prescription')
                      getPrescriptionData(selectedStatus.toLowerCase());
                    else if(selectedButtton == 'packages')
                      getPackageData(selectedStatus.toLowerCase());
                    else
                      getBookingData(selectedStatus.toLowerCase());

                  }else{
                    if(selectedButtton == 'prescription')
                      getPrescriptionData('all');
                    else if(selectedButtton == 'packages')
                      getPackageData('all');
                    else
                      getLabStream();
                  }
                });
              },
              elevation: 8,
      );
  }

  StreamBuilder<List<dynamic>> showBookings() {
    return StreamBuilder(
    stream: bookingsStream,
    builder: (context, AsyncSnapshot snapshot){
        if(snapshot.hasData){
          final booking = snapshot.data!;
          return ListView.builder(
            itemCount: booking.length,
            itemBuilder: (context, index){
             return GestureDetector(
                onTap: () {
                 Navigator.pushNamed(context,'/bookingdetails', arguments: {
                  'bookingId' : booking[index]['id']
                });
                },
                child:Container(
              margin: const EdgeInsets.fromLTRB(10,8,10,10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
              ),
              child:Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                        Row(
                          children: [
                            Text(formatToCustomFormat( booking[index]['date'].toString()),
                                    style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 16) ,
                                    ),
                            const Text(" | ", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),

                            Text(convert24HourTo12Hour(booking[index]['time'].toString()), style: const TextStyle(fontSize: 16),)
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          children: [
                            const Text('status: '),
                            Text(booking[index]['status'],
                            style: TextStyle(color:_getStatusColor(booking[index]['status']), fontSize: 15, fontFamily: GoogleFonts.poppins().fontFamily),
                            ),
                          ],
                        ),
                        ]
                    ),
                    const Icon(Icons.chevron_right_outlined,size: 40,)
                  ],
                ),
              )
              )
             );
            }
            
          );
        }
        return Container();
    }
  );
  }
}