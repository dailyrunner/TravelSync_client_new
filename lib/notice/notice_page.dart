import 'package:flutter/material.dart';
import 'package:travelsync_client_new/notice/notice_create.dart';
import 'package:travelsync_client_new/widgets/header.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  late bool noticeExist = false;
  late bool isGuide = true;

  void createNotice() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const NoticeCreatePage()));
  }

  void deleteNotice() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Header(
                  textHeader: "Notice",
                ),
                const SizedBox(
                  height: 60,
                ),
                if (!noticeExist)
                  Column(
                    children: [
                      Container(
                        child: const SingleChildScrollView(
                          child: Text(
                            "그룹에 등록된 알림이 없습니다.",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 504,
                      ),
                    ],
                  ),
                if (noticeExist)
                  const Column(
                    children: [
                      Text(
                        "예정된 알림",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 160,
                        child: SingleChildScrollView(),
                      ),
                      Text(
                        "이전 알림",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 320,
                        child: SingleChildScrollView(),
                      ),
                    ],
                  ),
                if (isGuide)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: createNotice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff5fbff),
                        ),
                        child: const Text(
                          "NOTICE 만들기",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: createNotice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff5fbff),
                        ),
                        child: const Text(
                          "NOTICE 삭제",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
