//main에 있는 부분 발췌
import 'package:flutter/material.dart';

class NoTourMessage extends StatelessWidget {
  const NoTourMessage({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const Text(
              '투어가 없습니다.\nTOUR 만들기로\n첫 투어를 만들어보세요!',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF003157),
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 60,
            ),
            Image.asset(
              'assets/images/tour.png',
              height: 100,
            ),
          ],
        ),
      ],
    );
  }
}
