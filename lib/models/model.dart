class Login {
  final String accountName;
  final String password;
  final String accessToken;
  final String refreshToken;

  Login(
    this.accountName,
    this.password,
    this.accessToken,
    this.refreshToken,
  );

  Login.fromJson(Map<String, dynamic> json)
      : accountName = json['accountName'],
        password = json['password'],
        accessToken = json['accessToken'],
        refreshToken = json['refreshToken'];

  Map<String, dynamic> toJson() => {
        'accountName': accountName,
        'password': password,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}
