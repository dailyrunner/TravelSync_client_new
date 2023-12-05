class GroupDetail {
  final int groupId;
  final String guide;
  final String groupName;
  final String startDate;
  final String endDate;
  final String nation;
  final String tourCompany;
  bool toggleLoc;
  final int? tourId;

  GroupDetail.fromJson(Map<String, dynamic> json)
      : groupId = json['groupId'],
        guide = json['guide'],
        groupName = json['groupName'],
        startDate = json['startDate'],
        endDate = json['endDate'],
        nation = json['nation'],
        tourCompany = json['tourCompany'],
        toggleLoc = json['toggleLoc'],
        tourId = json['tourId'];
}

class Group {
  final int groupId;
  final String guide;
  final String groupName;
  final String startDate;
  final String endDate;
  final String tourCompany;

  Group.fromJson(Map<String, dynamic> json)
      : groupId = json['groupId'],
        guide = json['guide'],
        groupName = json['groupName'],
        startDate = json['startDate'],
        endDate = json['endDate'],
        tourCompany = json['tourCompany'];
}

class GuideInfo {
  final String userId;
  final String name;
  final String phone;

  GuideInfo.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        name = json['name'],
        phone = json['phone'];
}
