import 'package:flutter/material.dart';

class CheckValidate {
  String? validatePassword(FocusNode focusNode, String value) {
    if (value.isEmpty) {
      focusNode.requestFocus();
      return '비밀번호를 입력하세요.';
    } else {
      String pattern = r'^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[$@$!%*#?&]).{10,}$';
      RegExp regExp = RegExp(pattern);
      if (!regExp.hasMatch(value)) {
        focusNode.requestFocus();
        return '특수문자 포함 10자 이상으로 입력하세요.';
      } else {
        return null;
      }
    }
  }

  String? validateSamePassword(
      FocusNode focusNode, String value1, String value2) {
    if (value2.isEmpty) {
      focusNode.requestFocus();
      return '비밀번호 확인를 입력하세요.';
    } else {
      if (value1 != value2) {
        focusNode.requestFocus();
        return '비밀번호와 동일하게 입력해주세요.';
      } else {
        return null;
      }
    }
  }

  String? validatePhoneNum(FocusNode focusNode, String value) {
    if (value.isEmpty) {
      focusNode.requestFocus();
      return '휴대폰 번호를 입력하세요.';
    } else {
      if (value.length != 11) {
        focusNode.requestFocus();
        return '휴대폰 번호를 올바르게 입력하세요.';
      } else {
        return null;
      }
    }
  }
}
