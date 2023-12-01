import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travelsync_client_new/widgets/header.dart';

class GroupInvitePage extends StatefulWidget {
  const GroupInvitePage({super.key});

  @override
  State<GroupInvitePage> createState() => _GroupInvitePageState();
}

class _GroupInvitePageState extends State<GroupInvitePage> {
  late String username = "임성혁";
  late String guideName = "조현성";
  late String tourName = "일본 도쿄 투어";
  DateTime startDate = DateTime.now();
  late String startFormat = DateFormat('yyyy-MM-dd').format(startDate);
  DateTime endDate = DateTime(2099, 12, 31);
  late String endFormat = DateFormat('MM-dd').format(endDate);
  late String groupName = "일본 도쿄 투어(하나투어)";
  final TextEditingController groupNameController = TextEditingController();

  void acceptJoinGroup() {}
  void declineJoinGroup() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Header(textHeader: "Invite"),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  "$username님,\n 가이드 $guideName님의 초대장이 도착했어요!",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 80,
                ),
                const Icon(
                  Icons.mail_outline,
                  size: 48,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "투어 이름\n일정\n가이드",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      width: 10,
                      height: 60,
                      child: Container(
                        width: 1,
                        height: 56,
                        color: Colors.indigo,
                      ),
                    ),
                    Text(
                      "$tourName\n$startFormat~$endFormat\n$guideName",
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  "$groupName에\n초대되셨습니다.\n\n초대를 수락 하시겠습니까?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                SizedBox(
                  width: 480,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(
                        flex: 3,
                        child: Text(
                          "그룹 비밀번호",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Flexible(
                        flex: 1,
                        child: SizedBox(width: 50),
                      ),
                      Flexible(
                        flex: 3,
                        child: TextField(
                          controller: groupNameController,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: 360,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: acceptJoinGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff5fbff),
                        ),
                        child: const Text(
                          "가입",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 120,
                      ),
                      ElevatedButton(
                        onPressed: declineJoinGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff5fbff),
                        ),
                        child: const Text(
                          "거절",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
