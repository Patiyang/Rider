import 'package:cloud_firestore/cloud_firestore.dart';

class CourierModel {
  static const PLACEDON = 'placedOn';
  static const PACKAGETYPE = 'packageType';
  static const STATUS = 'status';
  static const EARNINGS = 'earnings';
  static const PAYMENTMODE = 'paymentMode';
  static const SERVICEID = 'serviceId';
  static const SENDERLOCATION = 'senderLocation';
  static const RECIPIENTLOCATION = 'recipientLocation';
  static const DRIVERLOCATION = 'driverLocation';
  static const ISNEW = 'isNew';
  static const ORDERNUMBER = 'orderNumber';
  static const SENDEROTP = 'senderOtp';
  static const RECIPIENTOTP = 'recipientOtp';
  static const SERVICEREQUESTS = 'serviceRequests';
  static const ARRIVALTIME = 'arrivalTime';
  static const VEHICLETYPE = 'vehicleType';
  static const DISTANCE = 'distance';
  static const DRIVERID = 'driverId';
  static const SENDERID = 'senderID';
  static const ACCEPTEDTRANSITON = 'acceptedTransitOn';
  static const STARTEDTRANSITON = 'startedTransitOn';
  static const COMPLETEDTRANSITON = ' completedTransitOn';

  static const INTRANSIT = 'In Transit';
  static const COMPLETED = 'Completed';
  static const ACCEPTED = 'Accepted';

//Sender Addresses
  static const SENDERDETAILS = 'senderDetails';
  static const SENDERPHONE = 'senderPhone';
  static const SENDERNAME = 'senderName';
  static const SENDERADDRESS = 'senderAddress';
  static const SENDERLANDMARK = 'landMark';
  static const SENDEREMAIL = 'senderEmail';
  // static const DRIVERID = 'driverId';
//Recipient addresses
  static const RECIPIENTDETAILS = 'recipientDetails';
  static const RECEPIENTADDRESS = 'recipientAddress';
  static const RECEPIENTLANDMARK = 'recipientLandMark';
  static const RECEPIENTNAMES = 'recipientNames';
  static const RECEPIENTPHONENUMBER = 'recipientPhoneNumber';
  static const RECEPIENTEMAILADDRESS = 'recipientEmailAddress';
//Driver details
  static const DRIVERDETAILS = 'driverDetails';
  static const DRIVERFIRSTNAME = 'firstName';
  static const DRIVERLASTNAME = 'lastName';
  static const DRIVERPHONENUMBER = 'phoneNumber';
  static const DRIVERVEHICLETYPE = 'vehicleType';

  Timestamp _placedOn;
  String _packageType;
  String _status;
  int _earnings;
  String _paymentMode;
  String _serviceId;
  GeoPoint _senderLocation;
  GeoPoint _recipientLocation;
  GeoPoint _driverLocation;
  bool _isNew;
  int _orderNumber;
  int _senderOtp;
  int _recipientOtp;
  String _arrivalTime;
  String _vehicleType;
  int _distance;
  String _senderId;
  int _acceptedTransitOn;
  int _startedTransitOn;
  int _completedTransitOn;
  Map _senderDetails;
  String _senderPhone;
  String _senderEmail;
  String _senderName;
  String _senderAddress;
  String _senderLandMark;
  Map _recipientDetails;
  String _recipientPhone;
  String _recipientEmail;
  String _recipientName;
  String _recipientAddress;
  String _recipientLandMark;
  Map _driverDetails;
  String _driverFirstName;
  String _driverLastName;
  String _driverPhoneNumber;
  String _driverVehicleType;

  Timestamp get placedOn => _placedOn;
  String get packageType => _packageType;
  String get status => _status;
  int get earnings => _earnings;
  String get paymentMode => _paymentMode;
  String get serviceId => _serviceId;
  GeoPoint get senderLocation => _senderLocation;
  GeoPoint get recipientLocation => _recipientLocation;
  GeoPoint get driverLocation => _driverLocation;
  bool get isNew => _isNew;
  int get orderNumber => _orderNumber;
  int get senderOtp => _senderOtp;
  int get recipientOtp => _recipientOtp;
  String get arrivalTime => _arrivalTime;
  String get vehicleType => _vehicleType;
  int get distance => _distance;
  String get senderId => _senderId;
  int get acceptedTransitOn => _acceptedTransitOn;
  int get startedTransitOn => _startedTransitOn;
  int get completedTransitON => _completedTransitOn;
  //the sender details
  Map get senderDetails => _senderDetails;
  String get senderPhone => _senderPhone;
  String get senderEmail => _senderEmail;
  String get senderName => _senderName;
  String get senderAddress => _senderAddress;
  String get senderLandMark => _senderLandMark;
  //the recipient details
  Map get recipientDetails => _recipientDetails;
  String get recipientPhone => _recipientPhone;
  String get recipientEmail => _recipientEmail;
  String get recipientname => _recipientName;
  String get recipientAddress => _recipientAddress;
  String get recipientLanMark => _recipientLandMark;
  //Driver details
  Map get driverDetails => _driverDetails;
  String get driverFirstName => _driverFirstName;
  String get driverLastName => _driverLastName;
  String get driverPhoneNumber => _driverPhoneNumber;
  String get driverVehicleType => _driverVehicleType;

  CourierModel.fromSnapshot(DocumentSnapshot snapshot) {
    _placedOn = snapshot.data()[PLACEDON];
    _packageType = snapshot.data()[PACKAGETYPE];
    _status = snapshot.data()[STATUS];
    _earnings = snapshot.data()[EARNINGS];
    _paymentMode = snapshot.data()[PAYMENTMODE];
    _serviceId = snapshot.data()[SERVICEID];
    _senderLocation = snapshot.data()[SENDERLOCATION];
    _recipientLocation = snapshot.data()[RECIPIENTLOCATION];
    _isNew = snapshot.data()[ISNEW];
    _orderNumber = snapshot.data()[ORDERNUMBER];
    _senderOtp = snapshot.data()[SENDEROTP];
    _recipientOtp = snapshot.data()[RECIPIENTOTP];
    _arrivalTime = snapshot.data()[ARRIVALTIME];
    _vehicleType = snapshot.data()[VEHICLETYPE];
    _distance = snapshot.data()[DISTANCE];
    _senderId = snapshot.data()[SENDERID];
    _acceptedTransitOn = snapshot.data()[ACCEPTEDTRANSITON];
    _startedTransitOn = snapshot.data()[STARTEDTRANSITON];
    _completedTransitOn = snapshot.data()[COMPLETEDTRANSITON];
//sendersnap
    _senderEmail = snapshot.data()[SENDERDETAILS][SENDEREMAIL];
    _senderPhone = snapshot.data()[SENDERDETAILS][SENDERPHONE];
    _senderName = snapshot.data()[SENDERDETAILS][SENDERNAME];
    _senderAddress = snapshot.data()[SENDERDETAILS][SENDERADDRESS];
    _senderLandMark = snapshot.data()[SENDERDETAILS][SENDERLANDMARK];
//recipientsnap
    _recipientEmail = snapshot.data()[RECIPIENTDETAILS][RECEPIENTEMAILADDRESS];
    _recipientPhone = snapshot.data()[RECIPIENTDETAILS][RECEPIENTPHONENUMBER];
    _recipientName = snapshot.data()[RECIPIENTDETAILS][RECEPIENTNAMES];
    _recipientAddress = snapshot.data()[RECIPIENTDETAILS][RECEPIENTADDRESS];
    _recipientLandMark = snapshot.data()[RECIPIENTDETAILS][RECEPIENTLANDMARK];

//driversnap
    _driverFirstName = snapshot.data()[DRIVERDETAILS] == null ? '' : snapshot.data()[DRIVERDETAILS][DRIVERFIRSTNAME];
    _driverLastName = snapshot.data()[DRIVERDETAILS] == null ? '' : snapshot.data()[DRIVERDETAILS][DRIVERLASTNAME];
    _driverPhoneNumber = snapshot.data()[DRIVERDETAILS] == null ? '' : snapshot.data()[DRIVERDETAILS][DRIVERPHONENUMBER];
    _driverFirstName = snapshot.data()[DRIVERDETAILS] == null ? '' : snapshot.data()[DRIVERDETAILS][DRIVERVEHICLETYPE];
  }
}
