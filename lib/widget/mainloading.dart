import 'package:flutter/material.dart';

class Mainloading extends StatelessWidget {
  const Mainloading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Color(0xFFF5FBFF)),
        child: Stack(
          children: [
            Positioned(
              left: MediaQuery.of(context).size.width * 0.16,
              top: MediaQuery.of(context).size.height * 0.37,
              child: Container(
                width: 297,
                height: 275,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Logo_earth.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.30,
              top: MediaQuery.of(context).size.height * 0.34,
              child: Container(
                width: 168,
                height: 52,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo_sentence.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
