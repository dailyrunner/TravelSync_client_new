import 'package:flutter/material.dart';
import 'dart:convert'; // JSON Encode, Decode를 위한 패키지
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/models/userinfo.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:travelsync_client_new/widget/login_page.dart';
import 'package:travelsync_client_new/widget/settings_page.dart';
import 'package:travelsync_client_new/widget/validate.dart';
import 'package:travelsync_client_new/widgets/header.dart'; // flutter_secure_storage 패키지
import 'package:http/http.dart' as http;

class InfoChange extends StatefulWidget {
  const InfoChange({Key? key}) : super(key: key);

  @override
  State<InfoChange> createState() => _InfoChangeState();
}

class _InfoChangeState extends State<InfoChange> {
  late String url;

  static const storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userKey = ''; // storage에 있는 유저 정보를 저장
  dynamic userInfo = '';
  UserInfo realUserInfo = UserInfo('로딩중.....', '로딩중...', '로딩중.......');

  var userName = TextEditingController(); // 이름 입력 저장
  var password = TextEditingController(); // pw 입력 저장
  var passwordConfirm = TextEditingController(); // pw확인 입력 저장
  var phoneNum = TextEditingController(); // 휴대폰번호 입력 저장

  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _passwordConfirmFocus = FocusNode();
  final FocusNode _phoneNumFocus = FocusNode();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _asyncMethod();
    });
  }

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userKey = await storage.read(key: 'login');
    url = (await storage.read(key: 'address'))!;

    // user의 정보가 없다면 로그인 페이지로 넘어가게 합니다.
    if (userKey == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } else {
      userInfo = jsonDecode(userKey);
      await getUserInfo();
    }
  }

  getUserInfo() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      String userId = userInfo["accountName"];
      final response =
          await http.get(Uri.parse("$url/user/info/$userId"), headers: header);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        realUserInfo = UserInfo.fromJson(responseBody);
        setState(() {});
      } else {
        if (!mounted) return;
        Future.microtask(() => showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  content: const Text(" 오류가 발생했습니다."),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("닫기"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            ));
      }
    } catch (e) {
      if (!mounted) return;
      Future.microtask(() => showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                content: const Text("그룹페이지 api(그룹정보)오류"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("닫기"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          ));
    }
  }

  submitChange(
      String newUserName, String newPassword, String newPhoneNum) async {
    try {
      String userId = userInfo["accountName"];
      String putUserName = '';
      String putPhoneNum = '';

      if (newUserName.isEmpty) {
        putUserName = realUserInfo.name;
      } else {
        putUserName = newUserName;
      }

      if (newPhoneNum.isEmpty) {
        putPhoneNum = realUserInfo.phone;
      } else {
        putPhoneNum = newPhoneNum;
      }

      Map<String, String> param = {
        'userId': userId,
        'name': putUserName,
        'phone': putPhoneNum,
        'password': newPassword
      };

      if (newPassword.isEmpty) {
        param = {
          'userId': userId,
          'name': putUserName,
          'phone': putPhoneNum,
        };
      }

      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}",
        "Content-Type": "application/json",
      };

      final response = await http.put(Uri.parse("$url/user/change"),
          headers: header, body: jsonEncode(param));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  logout() async {
    await storage.delete(key: 'login');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  InputDecoration _textFormDecoration(hintText, helperText) {
    return InputDecoration(
      contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      hintText: hintText,
      helperText: helperText,
    );
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ),
        body: Form(
          key: formKey,
          child: Column(
            children: [
              const airplaneLogo(),
              Container(
                height: 10,
              ),
              const Header(textHeader: "Settings"),
              Container(
                height: 40,
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(
                      bottom: 5,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                    ),
                    width: 100,
                    child: const Text(
                      "내 정보 수정",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 20,
              ),
              //여기 이름. 휴대폰 번호 넣을건데 회원가입이랑 똑같은 형식으로
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
                    child: TextFormField(
                      controller: userName,
                      decoration: InputDecoration(
                        hintText: realUserInfo.name,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 15,
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                  ),
                  const Text(
                    '아이디',
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    width: 30,
                  ),
                  // 휴대폰번호 입력 영역
                  SizedBox(
                    width: 230,
                    child: Text(
                      realUserInfo.userId,
                      style: const TextStyle(
                        fontSize: 17,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
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
                    child: TextFormField(
                        controller: password,
                        focusNode: _passwordFocus,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: _textFormDecoration(
                            '비밀번호', '특수문자 포함 10자 이상으로 입력하세요.'),
                        validator: (value) => CheckValidate()
                            .validateChangePassword(_passwordFocus, value!)),
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
                    child: TextFormField(
                      controller: passwordConfirm,
                      focusNode: _passwordConfirmFocus,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: '비밀번호 확인',
                      ),
                      validator: (value) => CheckValidate()
                          .validateChangeSamePassword(
                              _passwordConfirmFocus, password.text, value!),
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
                    child: TextFormField(
                      controller: phoneNum,
                      keyboardType: TextInputType.phone,
                      focusNode: _phoneNumFocus,
                      decoration: InputDecoration(
                        hintText: realUserInfo.phone,
                        helperText: '01012345678 ( \' - \' 제외)',
                      ),
                      validator: (value) => CheckValidate()
                          .validateChangePhoneNum(_phoneNumFocus, value!),
                    ),
                  ),
                ],
              ),
              Container(
                height: 100,
              ),
              SizedBox(
                width: 160,
                child: Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        if (await submitChange(
                                userName.text, password.text, phoneNum.text) ==
                            true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('회원정보 수정에 성공했습니다.'),
                              duration:
                                  Duration(seconds: 1), // SnackBar가 표시되는 시간 설정
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('회원정보 수정에 실패했습니다.'),
                              duration:
                                  Duration(seconds: 1), // SnackBar가 표시되는 시간 설정
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5FbFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: const Color.fromARGB(255, 80, 80, 80)
                          .withOpacity(0.7),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 16,
                      ),
                      child: Text(
                        '수정 완료',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
