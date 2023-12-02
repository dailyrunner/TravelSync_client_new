import 'package:flutter/material.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/tour/tourListView.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import '../../widgets/header.dart';

class TourListPage extends StatelessWidget {
  const TourListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
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
              navigatorKey.currentState?.pop();
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const airplaneLogo(),
              const SizedBox(height: 40),
              const Header(textHeader: 'TOUR List'), //title
              const SizedBox(height: 70),
              const TourListView(),
              const SizedBox(height: 240),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: () {
                        navigatorKey.currentState
                            ?.pushNamed('/main/tour/createTour');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF5FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: const Color.fromARGB(255, 80, 80, 80)
                            .withOpacity(0.7),
                        elevation: 2.0,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 16,
                        ),
                        child: Text(
                          'TOUR 만들기',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: () {
                        navigatorKey.currentState
                            ?.pushNamed('/main/tour/createTour');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5FbFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: const Color.fromARGB(255, 80, 80, 80)
                            .withOpacity(0.7),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 16,
                        ),
                        child: Text(
                          'TOUR 삭제',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
