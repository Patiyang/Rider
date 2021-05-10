import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_boy/models/courierModel.dart';
import 'package:delivery_boy/models/userModel.dart';
import 'package:delivery_boy/services/oneSignalPush.dart';
import 'package:delivery_boy/views/home/home_main.dart';
import 'package:delivery_boy/widgets&helpers/helpers/changeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class CourierServices {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  OneSignalPush oneSignalPush = new OneSignalPush();

  Future<List<CourierModel>> getServiceRequests(String vehicleType) async {
    List<CourierModel> courierRequests = [];
    await _firestore
        .collection(CourierModel.SERVICEREQUESTS)
        // .where(CourierModel.VEHICLETYPE, isEqualTo: vehicleType)
        .where(CourierModel.STATUS, isEqualTo: 'Unasigned')
        .orderBy('placedOn', descending: true)
        .get()
        .then((value) {
      for (DocumentSnapshot courierRequest in value.docs) {
        print(value.docs[0][CourierModel.VEHICLETYPE]);
        courierRequests.add(CourierModel.fromSnapshot(courierRequest));
      }
    });
    return courierRequests;
  }

  Future<List<CourierModel>> getActiveServiceRequests(String vehicleType) async {
    List<CourierModel> courierRequests = [];
    String uid = auth.currentUser.uid;
    await _firestore.collection(CourierModel.SERVICEREQUESTS).where(CourierModel.DRIVERID, isEqualTo: uid).get().then((value) {
      for (DocumentSnapshot courierRequest in value.docs) {
        // print();
        if (courierRequest.data()[CourierModel.STATUS] == 'In Transit' || courierRequest.data()[CourierModel.STATUS] == 'Accepted') {
          courierRequests.add(CourierModel.fromSnapshot(courierRequest));
        }
      }
    });
    // print(courierRequests);
    return courierRequests;
  }

  Future<List<CourierModel>> getEarningHistory() async {
    List<CourierModel> courierRequests = [];
    String uid = auth.currentUser.uid;
    await _firestore.collection(CourierModel.SERVICEREQUESTS).where(CourierModel.DRIVERID, isEqualTo: uid).get().then((value) {
      for (DocumentSnapshot courierRequest in value.docs) {
        if (courierRequest.data()[CourierModel.STATUS] == 'Completed') {
          courierRequests.add(CourierModel.fromSnapshot(courierRequest));
        }
      }
    });
    print(courierRequests);
    return courierRequests;
  }

  Future<List<CourierModel>> getDriverOrderHistory() async {
    List<CourierModel> courierRequests = [];
    String uid = auth.currentUser.uid;
    await _firestore.collection(CourierModel.SERVICEREQUESTS).where(CourierModel.DRIVERID, isEqualTo: uid).get().then((value) {
      for (DocumentSnapshot courierRequest in value.docs) {
        // if (courierRequest.data()[CourierModel.STATUS] == 'Completed') {
        courierRequests.add(CourierModel.fromSnapshot(courierRequest));
        // }
      }
    });
    print(courierRequests);
    return courierRequests;
  }

  Future updateServiceRequest(String serviceId) async {
    try {
      await _firestore.collection(CourierModel.SERVICEREQUESTS).doc(serviceId).update(
        {
          'isNew': false,
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future updateAcceptedOrder(String driverId, String serviceId) async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    GeoPoint currentPosition = GeoPoint(position.latitude, position.longitude);
    try {
      await _firestore.collection(CourierModel.SERVICEREQUESTS).doc(serviceId).update(
        {
          CourierModel.DRIVERID: driverId,
          CourierModel.STATUS: 'Accepted',
          CourierModel.DRIVERLOCATION: currentPosition,
          CourierModel.ACCEPTEDTRANSITON: DateTime.now().millisecondsSinceEpoch
        },
      );
      // print('cdcdcavfavdav');
    } catch (e) {
      print(e.toString());
    }
  }

  Future updateCommenced(String serviceId) async {
    try {
      await _firestore.collection(CourierModel.SERVICEREQUESTS).doc(serviceId).update(
        {CourierModel.STATUS: 'In Transit', CourierModel.STARTEDTRANSITON: DateTime.now().millisecondsSinceEpoch},
      );
      updateVehiclePositionOrder(serviceId);
      Fluttertoast.showToast(msg: 'Your trip has now started');
    } catch (e) {
      print(e.toString());
    }
  }

  Future updateCompleted(String serviceId, BuildContext context, String senderId, int orderNumber, String firstName, String lastName) async {
    String message = 'The Order #$orderNumber has been Completed by $firstName $lastName successfully';
    try {
      await _firestore.collection(CourierModel.SERVICEREQUESTS).doc(serviceId).update(
        {CourierModel.STATUS: 'Completed', CourierModel.COMPLETEDTRANSITON: DateTime.now().millisecondsSinceEpoch},
      );
      Fluttertoast.showToast(msg: 'Your trip has been completed successfully');
      updateVehiclePositionOrder(serviceId);
      oneSignalPush
          .sendNotification(context, senderId, message, 'Your order has been completed')
          .then((value) => changeScreenReplacement(context, HomeMain(isOnline: true)));
    } catch (e) {
      print(e.toString());
    }
  }

  Future updateVehiclePositionOrder(String serviceId) async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    GeoPoint currentPosition = GeoPoint(position.latitude, position.longitude);
    try {
      await _firestore.collection(CourierModel.SERVICEREQUESTS).doc(serviceId).update(
        {CourierModel.DRIVERLOCATION: currentPosition},
      );
      // print('cdcdcavfavdav');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<UserModel> getUserById(String id) => _firestore.collection('users').doc(id).get().then((doc) {
        return UserModel.fromSnapshot(doc);
      });

  Future<CourierModel> getHistoryServiceDetails(String id) => _firestore.collection(CourierModel.SERVICEREQUESTS).doc(id).get().then((doc) {
        return CourierModel.fromSnapshot(doc);
      });
}
