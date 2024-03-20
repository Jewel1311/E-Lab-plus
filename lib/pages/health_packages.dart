import 'package:elabplus/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthPackages extends StatefulWidget {
  const HealthPackages({super.key});

  @override
  State<HealthPackages> createState() => _HealthPackagesState();
}

class _HealthPackagesState extends State<HealthPackages> {

  final supabase = Supabase.instance.client;
  dynamic packages;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getPackages();
  }

  Future deletePackage(id) async{
    await supabase.from('packages').delete().match({'id':id});
    getPackages();
  }

  Future getPackages() async {
    setState(() {
      isLoading = true;
    });
    dynamic labId = await supabase.from('labs').select('id').match({'user_id':supabase.auth.currentUser!.id});
    packages = await supabase.from('packages').select().match({'lab_id':labId[0]['id']}).order('id');
    setState(() {
      isLoading = false;
    });
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Packages", style: TextStyle(fontWeight: FontWeight.bold,fontFamily: GoogleFonts.hammersmithOne().fontFamily),),
      ),
      body:Column(
        children: [
          addPackages(),
          isLoading? const SpinKitFadingCircle(color: ElabColors.primaryColor,): packageList(),
        ],
      ) ,
    );
  }

  Padding addPackages() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5,0,5,10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(onPressed: (){
                Navigator.pushNamed(context, '/add_health_packages');
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
              child: Text('Add Packages', style: TextStyle(color: Colors.white),)),

              TextButton(onPressed: (){
                getPackages();
              }, child: Text('Reload'))
            
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              isLoading ? const Text(''):Text('${packages.length} Packages', style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily,
                fontSize: 16 , fontWeight: FontWeight.bold 
              )
              ),
          ]
          ),
        ]
      ),
    );
  }

  Expanded packageList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: getPackages,
        child:ListView.builder(
        itemCount: packages.length,
        itemBuilder: (context, index){
          return InkWell(
            onTap: (){
              Navigator.pushNamed(context, '/view_packages',
              arguments: {
                'id':packages[index]['id']
              });
            }, 
            child: Container(
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
                    Text(packages[index]['name'], style:const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18
                    ),
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        const Icon(Icons.currency_rupee_sharp, color: Colors.black,),
                        Text(packages[index]['price'].toString(), style: const TextStyle(
                          fontWeight: FontWeight.bold,color: Colors.green, fontSize: 18
                        ),)
                      ],
                    ),
                  ],
                ),
                 trailing: GestureDetector(
                  onTap: () {
                    deletePackage(packages[index]['id']);
                  },
                  child: const Text('remove', style: TextStyle(color: Colors.red,fontSize: 16),),
                 )
                )

              )
          );
        }
      )
      )
      );
  }

}