// ignore_for_file: public_member_api_docs, sort_constructors_first
class Chat {
  late String _name;
  late String _message;
  late String _photoPath;

  get name => _name;

  set name(value) => _name = value;

  get message => _message;

  set message(value) => _message = value;

  get photoPath => _photoPath;

  set photoPath(value) => _photoPath = value;

  Chat(
    this._name,
    this._message,
    this._photoPath,
  );
  
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_name': _name,
    };
  }
}
