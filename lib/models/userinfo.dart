class UserInfo {
  final String userId;
  final String name;
  final String phone;

  UserInfo(this.userId, this.name, this.phone);

  UserInfo.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        name = json['name'],
        phone = json['phone'];
}
