import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 205,
          height: 185,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Logo_earth.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ],
    );
  }
}

class Email extends StatelessWidget {
  const Email({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 283,
          height: 28,
          child: Stack(
            children: [
              Positioned(
                left: 80,
                top: 0, // 변경: 텍스트와 겹치지 않도록 수정
                child: Container(
                  width: 203,
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'example@example.com',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.25),
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 0,
                top: 0,
                child: SizedBox(
                  width: 57,
                  height: 21.67,
                  child: Center(
                    // 변경: 텍스트 중앙 정렬
                    child: Text(
                      '이메일',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HalfLine extends StatelessWidget {
  const HalfLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 359,
          decoration: const ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignCenter,
                color: Color(0xFFCACACA),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
