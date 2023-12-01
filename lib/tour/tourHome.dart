import 'package:flutter/material.dart';
import '../tour/emptyTour.dart';

class TourHome extends StatelessWidget {
  const TourHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: NoTourMessage(),
        ),
      ],
    );
  }
}
