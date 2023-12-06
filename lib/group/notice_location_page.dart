import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NoticeLocationPage extends StatefulWidget {
  final double latitude, longitude;
  const NoticeLocationPage(
      {super.key, required this.latitude, required this.longitude});

  @override
  State<NoticeLocationPage> createState() => _NoticeLocationPageState();
}

class _NoticeLocationPageState extends State<NoticeLocationPage> {
  late Set<Marker> marker;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    marker = {
      Marker(
        markerId: const MarkerId('selected'),
        position: LatLng(widget.latitude, widget.longitude),
      )
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          tooltip: '뒤로가기',
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(widget.latitude, widget.longitude), zoom: 15.0),
            markers: marker),
      ),
    );
  }
}
