enum MessageEnum{
  text('text'),
  image('image'),
  audio('audio'),
  video('video'),
  gif('gif');

  const MessageEnum(this.type);
  final String type;
}

extension ConvertMessage on String {
  MessageEnum toEnum() {
    switch (this) {
      case 'audio':
        return MessageEnum.audio;
      case 'image':
        return MessageEnum.image;
      case 'text':
        return MessageEnum.text;
      case 'gif':
        return MessageEnum.gif;
      case 'video':
        return MessageEnum.video;
      default:
        return MessageEnum.text;
    }
  }
}

String displayMessageForMessageType(messageEnum){
  switch(messageEnum){
    case MessageEnum.image:
      return '📷 Photo';
    case MessageEnum.audio:
      return '🎧 Audio';
    case MessageEnum.video:
      return '🎥 Video';
    case MessageEnum.gif:
      return '👾 GIF';
    default:
      return '📄 Document';
  }
}