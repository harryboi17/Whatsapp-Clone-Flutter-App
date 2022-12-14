
class Status{
  final String uid;
  final String photoUrl;
  final DateTime createdAt;
  final List<String> whoCanSee;

  Status({
    required this.uid,
    required this.photoUrl,
    required this.createdAt,
    required this.whoCanSee
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'whoCanSee': whoCanSee,
    };
  }

  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      uid: map['uid'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      whoCanSee: List<String>.from(map['whoCanSee']),
    );
  }
}

class UserStatus{
  final String uid;
  final String name;
  final String profilePic;
  final List<String> statusId;
  final List<String> photoUrl;
  final List<bool> isSeenStatus;
  final DateTime lastUploadedStatusTime;
  final String phoneNumber;

  UserStatus({
    required this.name,
    required this.uid,
    required this.profilePic,
    required this.photoUrl,
    required this.statusId,
    required this.isSeenStatus,
    required this.lastUploadedStatusTime,
    required this.phoneNumber
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'profilePic': profilePic,
      'statusId' : statusId,
      'uid' : uid,
      'isSeenStatus' : isSeenStatus,
      'lastUploadedStatusTime' : lastUploadedStatusTime,
      'phoneNumber' : phoneNumber,
    };
  }

  factory UserStatus.fromMap(Map<String, dynamic> map) {
    return UserStatus(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      photoUrl: List<String>.from(map['photoUrl']),
      statusId: List<String>.from(map['statusId']),
      profilePic: map['profilePic'],
      isSeenStatus: List<bool>.from(map['isSeenStatus']),
      lastUploadedStatusTime: map['lastUploadedStatusTime'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}