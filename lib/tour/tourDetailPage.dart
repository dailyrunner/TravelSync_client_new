import 'package:flutter/material.dart';
import 'package:travelsync_client_new/models/tour.dart';

class TourDetailPage extends StatefulWidget {
  final Tour selectedTour;

  const TourDetailPage({required this.selectedTour, Key? key})
      : super(key: key);

  @override
  State<TourDetailPage> createState() => _TourDetailPageState();
}

class _TourDetailPageState extends State<TourDetailPage> {
  @override
  Widget build(BuildContext context) {
    // widget.selectedTour를 사용하여 선택한 투어의 정보에 접근할 수 있습니다.
    final selectedTour = widget.selectedTour;

    // 이제 선택한 투어의 정보를 활용하여 원하는 UI를 구성할 수 있습니다.

    return const Placeholder();
  }
}
