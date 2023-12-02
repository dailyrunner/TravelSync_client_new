/*API 연동 중*/
import 'package:flutter/material.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import '../widgets/header.dart';
import '../plan/createPlan.dart';
//////API/////
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class CreateTour extends StatefulWidget {
  const CreateTour({Key? key}) : super(key: key);
  @override
  State<CreateTour> createState() => CreateTourState();
}

class CreateTourState extends State<CreateTour> {
  final TextEditingController tourName = TextEditingController();
  final TextEditingController tourCompany = TextEditingController();
  int dayCount = 1;
  void _addDay() {
    setState(() {
      dayCount++;
    });
  }

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
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const SingleChildScrollView(),
            const airplaneLogo(),
            const SizedBox(height: 20),
            const Header(textHeader: 'Create TOUR'),
            const SizedBox(height: 30),
            const TourName(),
            const SizedBox(height: 20),
            const SizedBox(
              width: 386,
              child: Divider(
                thickness: 2.0,
                color: Color.fromARGB(255, 187, 214, 255),
              ),
            ),
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int i = 1; i <= dayCount; i++)
                            GestureDetector(
                              onTap: () {
                                Text('Day$i');
                              },
                              child: Container(
                                width: 80,
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                color: Colors.white,
                                //문제가없어요//
                                child: Text(
                                  'Day$i',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _addDay,
                    icon: const Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 386,
              child: Divider(
                thickness: 2.0,
                color: Color.fromARGB(255, 187, 214, 255),
              ),
            ),
            const SizedBox(height: 12),
            Plan(dayCount: dayCount),
          ],
        ),
      ),
    );
  }
}

class TourName extends StatelessWidget {
  const TourName({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            // SingleChildScrollView(),
            Padding(
              padding: EdgeInsets.only(left: 44),
              child: Text(
                'TOUR 이름      ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                decoration: InputDecoration(
                  hintText: '일본 도쿄 투어',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 80),
              child: Text(
                '여행사      ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                decoration: InputDecoration(
                  hintText: '하나 투어',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
