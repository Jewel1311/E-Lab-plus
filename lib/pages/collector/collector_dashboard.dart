import 'package:elabplus/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectorDashboard extends StatefulWidget {
  const CollectorDashboard({super.key});

  @override
  State<CollectorDashboard> createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends State<CollectorDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collector Dashboard'),
      ),
      body: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              backgroundColor: const MaterialStatePropertyAll(
                ElabColors.color3,
              ),
              elevation: const MaterialStatePropertyAll(3),
              
            ),
            onPressed: () async {      
            await Supabase.instance.client.auth.signOut();
            // ignore: use_build_context_synchronously
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
          child:const Padding(
            padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Log Out ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
                ),
                Icon(Icons.logout, color:Colors.black,)
              ],
            ),
          ),
    )
    );
  }
}