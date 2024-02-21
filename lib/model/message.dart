class Message {
  late String _messageText;
  late String _userId;
  late String _type;
  late String _urlImage;
  late DateTime _createdAt;

  Message();

  get messageText => _messageText;

  set messageText(value) => _messageText = value;

  get userId => _userId;

  set userId(value) => _userId = value;

  get urlImage => _urlImage;

  set urlImage(value) => _urlImage = value;

  get type => _type;

  set type(value) => _type = value;

  get createdAt => _createdAt;

  set createdAt(value) => _createdAt = value;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_messageText': _messageText,
      '_userId': _userId,
      '_urlImage': _urlImage,
      '_type': _type,
      '_createdAt': _createdAt
    };
  }
}
