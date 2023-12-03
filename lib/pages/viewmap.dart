import 'package:elabplus/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class ViewMap extends StatefulWidget {
  const ViewMap({super.key});

  @override
  State<ViewMap> createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewMap> {

  dynamic mapDetails;
  bool isLoading = false;

  LatLng markerLatLng = LatLng(0,0);

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration.zero,(){
      mapDetails = ModalRoute.of(context)?.settings.arguments as Map?; 
      markerLatLng = LatLng(mapDetails['latitude'], mapDetails['longitude']);
      setState(() {
       isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Location',
          style: TextStyle(
              color: Colors.black,
              fontFamily: GoogleFonts.hammersmithOne().fontFamily,
              fontWeight: FontWeight.bold),
        ),
      ),
      body:isLoading?const SpinKitFadingCircle(color: ElabColors.primaryColor,): FlutterMap(
          mapController: MapController(),
          options: MapOptions(
              initialCenter: LatLng(mapDetails['latitude'], mapDetails['longitude']),
              initialZoom: 10),
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
        )
      );

  }
}