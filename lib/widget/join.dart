import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'globals.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  late String url;

  static const storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userInfo = ''; // storage에 있는 유저 정보를 저장

  //flutter_secure_storage 사용을 위한 초기화 작업
  @override
  void initState() {
    super.initState();

    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userInfo = await storage.read(key: 'login');
    url = (await storage.read(key: 'address'))!;

    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (userInfo != null) {
      Navigator.pushNamed(context, '/main');
    }
  }

  var userName = TextEditingController(); // 이름 입력 저장
  var userId = TextEditingController(); // 이메일 입력 저장
  var password = TextEditingController(); // pw 입력 저장
  var passwordConfirm = TextEditingController(); // pw확인 입력 저장
  var phoneNum = TextEditingController(); // 휴대폰번호 입력 저장

  bool checkUserName = false;
  bool checkUserIdForm = false;
  bool checkUserId = false;
  bool checkSameId = false;
  bool checkPassword = false;

  bool agree1 = false;
  bool agree2 = false;

  bool joinReady = true;

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

  submitJoin(userName, userId, password, phoneNum) async {
    try {
      var dio = Dio();
      var param = {
        'userId': '$userId',
        'name': '$userName',
        'phone': '$userId',
        'password': '$password'
      };

      Response response = await dio.post('$url/user/signup', data: param);

      if (response.statusCode == 200) {
        print(response.data);
        String result = response.data;

        if (result.compareTo('SignUp Success') == 0) {
          print('회원가입 성공');
          return true;
        } else {
          print('회원가입 실패');
          return false;
        }
      } else {
        print('error');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: snackbarKey,
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
              navigatorKey.currentState?.pop();
            },
          ),
        ),
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
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: userId,
                    decoration: const InputDecoration(
                      hintText: 'gd@example.com',
                    ),
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
                //joinReadyCheck();
                if (joinReady) {
                  if (await submitJoin(userName.text, userId.text,
                          password.text, phoneNum.text) ==
                      true) {
                    Navigator.pushNamed(context, '/');
                  } else {
                    const SnackBar snackBar = SnackBar(
                      content: Text("회원가입에 실패했습니다."),
                      duration: Duration(seconds: 1),
                    );
                    snackbarKey.currentState?.showSnackBar(snackBar);
                  }
                } else {
                  const SnackBar snackBar = SnackBar(
                    content: Text("올바르게 기입 후 다시 시도하세요."),
                    duration: Duration(seconds: 1),
                  );
                  snackbarKey.currentState?.showSnackBar(snackBar);
                }
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
