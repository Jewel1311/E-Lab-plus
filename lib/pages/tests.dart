import 'package:elabplus/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Tests extends StatefulWidget {
  const Tests({super.key});

  @override
  State<Tests> createState() => _TestsState();
}

class _TestsState extends State<Tests> {

  final supabase = Supabase.instance.client;
  dynamic tests;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getTests();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          addTest(),
          isLoading? const SpinKitFadingCircle(color: ElabColors.primaryColor,): testList()
        ],
      ),
    );
  }


  Padding addTest() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5,0,5,10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isLoading ? const Text(''):Text('${tests.length} Tests', style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily,
            fontSize: 16 , fontWeight: FontWeight.bold 
          )
          ),
          ElevatedButton(onPressed: () {
              Navigator.pushNamed(context, '/addtests');
          }, 
          style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(ElabColors.primaryColor)),
          child:
              Text('Add Test', style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.bold),) 
          ),
      ]
      ),
    );
  }

  Expanded testList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: getTests,
        child:ListView.builder(
        itemCount: tests.length,
        itemBuilder: (context, index){
          return Container(
            margin: const EdgeInsets.fromLTRB(5,8,5,5),
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
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tests[index]['testname'], style:const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18
                    ),
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        const Icon(Icons.currency_rupee_sharp, color: Colors.black,),
                        Text(tests[index]['price'].toString(), style: const TextStyle(
                          fontWeight: FontWeight.bold,color: Colors.green, fontSize: 18
                        ),)
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Text('Requirements', style: TextStyle(color: ElabColors.greyColor,fontFamily: GoogleFonts.poppins().fontFamily, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 10,),
                    Text(tests[index]['requirements'],)
                  ],
                ),
                 trailing: GestureDetector(
                  onTap: () {
                    deleteTest(tests[index]['id']);
                  },
                  child: const Text('remove', style: TextStyle(color: Colors.red),),
                 )
                )

              );
        }
      )
      )
      );
  }

  Future deleteTest(id) async{
    await supabase.from('tests').delete().match({'id':id});
    getTests();
  }

  Future getTests() async {
    setState(() {
      isLoading = true;
    });
    dynamic labId = await supabase.from('labs').select('id').match({'user_id':supabase.auth.currentUser!.id});
    tests = await supabase.from('tests').select().match({'lab_id':labId[0]['id']});
    setState(() {
      isLoading = false;
    });
  }  

}