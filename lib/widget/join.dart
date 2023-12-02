import 'package:flutter/material.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  var userName = TextEditingController(); // 이름 입력 저장
  final TextEditingController _userId = TextEditingController(); // 이메일 입력 저장
  var password = TextEditingController(); // pw 입력 저장
  var passwordConfirm = TextEditingController(); // pw확인 입력 저장
  var phoneNum = TextEditingController(); // 휴대폰번호 입력 저장

  final FocusNode _emailFocus = FocusNode();

  bool checkUserName = false;
  bool checkUserIdForm = false;
  bool checkUserId = false;
  bool checkSameId = false;
  bool checkPassword = false;

  bool agree1 = false;
  bool agree2 = false;

  bool joinReady = false;

  String? _emailFormCheck(FocusNode focusNode, String value) {
    checkUserId = false;
    if (value.isEmpty) {
      focusNode.requestFocus();
      return '이메일을 입력하세요.';
    } else {
      String pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp = RegExp(pattern);
      if (!regExp.hasMatch(value)) {
        focusNode.requestFocus();
        checkUserIdForm = false;
        return '이메일 형식을 맞춰주세요.';
      } else {
        checkUserIdForm = true;
        return null;
      }
    }
  }

  bool idCheck() {
    return true;
  }

  void passwordCheck() {
    if (password == passwordConfirm) {
      checkPassword = true;
    } else {
      checkPassword = false;
    }
  }

  void joinReadyCheck() {
    if (checkUserName &&
        checkUserId &&
        checkSameId &&
        checkPassword &&
        agree1 &&
        agree2) {
      joinReady = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              // 뒤로가기 버튼을 눌렀을 때 수행할 동작
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: const Color(0xFFF5FBFF),
        body: Column(
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
            Container(
              height: 20,
            ),
            const Text(
              '회원가입',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              height: 30,
            ),
            Row(
              children: [
                Container(
                  width: 45,
                ),
                const Text(
                  '이름',
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  width: 40,
                ),
                // 이름 입력 영역
                SizedBox(
                  width: 230,
                  child: TextField(
                    controller: userName,
                    decoration: const InputDecoration(
                      hintText: '홍길동',
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 40,
                ),
                const Text(
                  '이메일',
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  width: 30,
                ),
                // 비밀번호 입력 영역
                SizedBox(
                  width: 170,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocus,
                    controller: _userId,
                    decoration: const InputDecoration(
                      hintText: 'gd@example.com',
                    ),
                    validator: (value) => _emailFormCheck(_emailFocus, value!),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (checkUserIdForm) {
                      idCheck();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(20, 35),
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFFF5FBFF), // 텍스트 색상
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 모서리를 둥글게 할지 여부
                    ),
                  ),
                  child: const Text(
                    '중복 확인',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 35,
                ),
                const Text(
                  '비밀번호',
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  width: 20,
                ),
                // 비밀번호 입력 영역
                SizedBox(
                  width: 230,
                  child: TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: '비밀번호',
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 117,
                ),
                // 비밀번호 확인 입력 영역
                SizedBox(
                  width: 230,
                  child: TextField(
                    controller: passwordConfirm,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: '비밀번호 확인',
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 20,
                ),
                const Text(
                  '휴대폰 번호',
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  width: 15,
                ),
                // 휴대폰번호 입력 영역
                SizedBox(
                  width: 230,
                  child: TextField(
                    controller: phoneNum,
                    decoration: const InputDecoration(
                      hintText: '01012345678 ( \' - \' 제외)',
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 100,
            ),
            Row(
              children: [
                Container(
                  width: 30,
                ),
                Checkbox(
                  value: agree1,
                  onChanged: (bool? value) {
                    setState(() {
                      agree1 = value ?? false; // 체크박스의 상태 업데이트
                    });
                  },
                ),
                const Text(
                  '개인정보 활용에 동의합니다',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 30,
                ),
                Checkbox(
                  value: agree2,
                  onChanged: (bool? value) {
                    setState(() {
                      agree2 = value ?? false; // 체크박스의 상태 업데이트
                    });
                  },
                ),
                const Text(
                  '마케팅 정보 수신에 동의합니다',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            Container(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () async {
                joinReadyCheck();
                if (joinReady) {
                } else {}
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 50),
                foregroundColor: Colors.black,
                backgroundColor: const Color(0xFFF5FBFF), // 텍스트 색상
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // 모서리를 둥글게 할지 여부
                ),
              ),
              child: const Text(
                '가입하기',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
