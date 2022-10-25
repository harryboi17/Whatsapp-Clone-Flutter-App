class Call {
  final String callerId;
  final String callerName;
  final String callerPic;
  final String callerPhoneNumber;
  final String receiverId;
  final String receiverName;
  final String receiverPic;
  final String receiverPhoneNumber;
  final String callId;
  final bool hasDialled;
  final bool isGroupCall;
  final DateTime callTime;
  final bool isMissedCall;
  final bool isVideoCall;


  const Call({
    required this.callerId,
    required this.callerName,
    required this.callerPic,
    required this.callerPhoneNumber,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPic,
    required this.receiverPhoneNumber,
    required this.callId,
    required this.hasDialled,
    required this.isGroupCall,
    required this.isMissedCall,
    required this.isVideoCall,
    required this.callTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerPic': callerPic,
      'callerPhoneNumber' : callerPhoneNumber,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPic': receiverPic,
      'receiverPhoneNumber' : receiverPhoneNumber,
      'callId': callId,
      'hasDialled': hasDialled,
      'isGroupCall': isGroupCall,
      'callTime': callTime.millisecondsSinceEpoch,
      'isMissedCall': isMissedCall,
      'isVideoCall': isVideoCall,
    };
  }

  factory Call.fromMap(Map<String, dynamic> map) {
    return Call(
      callerId: map['callerId'] as String,
      callerName: map['callerName'] as String,
      callerPic: map['callerPic'] as String,
      callerPhoneNumber: map['callerPhoneNumber'] as String,
      receiverId: map['receiverId'] as String,
      receiverName: map['receiverName'] as String,
      receiverPic: map['receiverPic'] as String,
      receiverPhoneNumber: map['receiverPhoneNumber'] as String,
      callId: map['callId'] as String,
      hasDialled: map['hasDialled'] as bool,
      isGroupCall: map['isGroupCall'] as bool,
      callTime: DateTime.fromMillisecondsSinceEpoch(map['callTime']),
      isMissedCall: map['isMissedCall'] as bool,
      isVideoCall: map['isVideoCall'] as bool,
    );
  }
}