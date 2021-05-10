import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  static const UID = 'userId';
  static const EMAIL = 'emailAddress';
  static const PHONENUMBER = 'phoneNumber';
  static const USERNAME = 'userName';
  static const GENDER = 'gender';
  static const BIRTHDAY = 'birthDay';
  static const PROFILEPICTURE = 'profilePicture';
  static const VEHICLETYPE = 'vehicleType';
  static const FIRSTNAME = 'firstName';
  static const LASTNAME = 'lastName';
  static const PASSWORD = 'password';
  static const VERIFIED = 'verified';
  static const IDENTIFICATIONUMBER = 'idNumber';
  static const IDENTIFICATIONTYPE = 'identificationType';
  static const IDPHOTO = 'identificationPicture';
  static final users = 'drivers';
  static final customers = 'customers';

  String _userId;
  String _email;
  String _phoneNumber;
  String _userName;
  String _gender;
  DateTime _birthDay;
  String _profilePicture;
  String _vehicleType;
  String _firstName;
  String _lastName;
  String _password;
  bool _vertified;
  String _identificationNumber;
  String _identificationPicture;
  String _identificationType;

  String get id => _userId;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String get userName => _userName;
  String get gender => _gender;
  DateTime get birthDay => _birthDay;
  String get profilePicture => _profilePicture;
  String get vehicleType => _vehicleType;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get password => _password;
  bool get verified => _vertified;
  String get identificationNumber => _identificationNumber;
  String get identificationPicture => _identificationPicture;
  String get identificationType => _identificationType;

  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    _userId = snapshot.data()[UID];
    _email = snapshot.data()[EMAIL];
    _phoneNumber = snapshot.data()[PHONENUMBER];
    _userName = snapshot.data()[USERNAME];
    _gender = snapshot.data()[GENDER];
    _birthDay = snapshot.data()[BIRTHDAY];
    _profilePicture = snapshot.data()[PROFILEPICTURE];
    _vehicleType = snapshot.data()[VEHICLETYPE];
    _firstName = snapshot.data()[FIRSTNAME];
    _lastName = snapshot.data()[LASTNAME];
    _password = snapshot.data()[PASSWORD];
    _vertified = snapshot.data()[VERIFIED];
    _identificationNumber = snapshot.data()[IDENTIFICATIONUMBER];
    _identificationPicture = snapshot.data()[IDPHOTO];
  }
}
