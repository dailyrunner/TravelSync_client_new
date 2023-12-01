import 'package:flutter/material.dart';

class airplaneLogo extends StatelessWidget {
  const airplaneLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 150,
          height: 50,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/airplane_travelsync.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ],
    );
  }
}
