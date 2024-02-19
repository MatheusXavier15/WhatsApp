class UserModel {
  late String _name;
  late String _email;
  late String _password;
  late String _imageProfileUrl;

  UserModel();

  get password => _password;

  set password(value) {
    _password = value;
  }

  get imageProfileUrl => _imageProfileUrl;

  set imageProfileUrl(value) {
    _imageProfileUrl = value;
  }

  get email => _email;

  set email(value) {
    _email = value;
  }

  get name => _name;

  set name(value) {
    _name = value;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_name': _name,
      '_email': _email,
    };
  }
}
