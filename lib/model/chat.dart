// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  late String _name;
  late String _message;
  late String _photoPath;
  late String _senderId;
  late String _receiverId;
  late String _type;

  get senderId => _senderId;

  set senderId(value) => _senderId = value;

  get receiverId => _receiverId;

  set receiverId(value) => _receiverId = value;

  get type => _type;

  set type(value) => _type = value;

  get name => _name;

  set name(value) => _name = value;

  get message => _message;

  set message(value) => _message = value;

  get photoPath => _photoPath;

  set photoPath(value) => _photoPath = value;

  Chat();

  save() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("chats")
        .doc(_senderId)
        .collection("lastChat")
        .doc(_receiverId)
        .set(toMap());
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_name': _name,
      '_message': _message,
      '_photoPath': _photoPath,
      '_senderId': _senderId,
      '_receiverId': _receiverId,
      '_type': _type,
      '_createdAt': DateTime.now()
    };
  }
}
