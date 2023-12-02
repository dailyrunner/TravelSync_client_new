import 'package:flutter/material.dart';
import 'package:travelsync_client_new/models/notice.dart';

/* 버튼 중앙 1개 */
/* 변수:text, onPressed(), buttonColor, width 4 개임 */
/* 회원 탈퇴 등은 회색임 */
class NoticeButton extends StatelessWidget {
  final Notice notice;
  final Function onPressed;
  final Color buttonColor;
  final double width; //버튼 크기

  const NoticeButton({
    Key? key,
    required this.notice,
    required this.onPressed,
    required this.buttonColor,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 64,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => onPressed()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEFF5FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: const Color.fromARGB(255, 80, 80, 80).withOpacity(0.7),
          elevation: 2.0,
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text(
                      "위치\n시간",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.5, vertical: 10),
                      child: Container(
                        width: 1,
                        height: 44,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "${notice.noticeTitle}\n${notice.parseHour()}:${notice.parseMinute()}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (notice.noticeLatitude != 0 && notice.noticeLongitude != 0)
                  const Icon(Icons.location_on)
              ],
            )),
      ),
    );
  }
}
