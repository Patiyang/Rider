import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/models/courierModel.dart';
import 'package:delivery_boy/models/utils.dart';
import 'package:delivery_boy/services/courierServices.dart';
import 'package:delivery_boy/services/oneSignalPush.dart';
import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customButton.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customListTIle.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customText.dart';
import 'package:delivery_boy/widgets&helpers/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:map_launcher/map_launcher.dart' as eos;

class DeliveryMap extends StatefulWidget {
  final String vehicleType;
  final String firstName;
  final String lastName;
  const DeliveryMap({Key key, this.vehicleType, this.firstName, this.lastName}) : super(key: key);
  @override
  _DeliveryMapState createState() => _DeliveryMapState();
}

class _DeliveryMapState extends State<DeliveryMap> {
  GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
  CourierServices courierServices = new CourierServices();
  GeocodingPlatform geocodingPlatform;
  CameraPosition cameraPosition;
  LatLng currentPosition;
  LatLng lastPosition;
  LatLng destination;
  double cameraZoom = 12;
  bool loading = false;
  List<Marker> markerList = [];
  Map<PolylineId, Polyline> polylines = {};
  Completer<GoogleMapController> mapsController = Completer();
  GoogleMapController mapcontroller;
  PolylinePoints polylinePoints = PolylinePoints();

  List<LatLng> polylineCoordinates = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  // double _originLatitude = -2.4219983, _originLongitude = 38.084;
  BitmapDescriptor currentLocationIcon;
  BitmapDescriptor locationIndicatorIcon;
  List<CourierModel> serviceRequests = [];
  CourierModel ongoingOrder;
  String driverId = '';
  String status = '';
  String requesterProfilePicture = '';
  double distanceBetween = 0;
  BuildContext currentContext;
  OneSignalPush oneSignalPush = OneSignalPush();
  @override
  void initState() {
    super.initState();
    _getUPickUpLocation();
  }

  @override
  Widget build(BuildContext context) {
    // _getPolyline(currentPosition.latitude, currentPosition.longitude);
    getLocationIcons(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          mapsScreen(),
          Padding(
            padding: const EdgeInsets.only(bottom: 23.0, right: 10),
            child: Align(alignment: Alignment.bottomRight, child: zoomButtons()),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 0.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: MaterialButton(
                onPressed: () => showBarModalBottomSheet(
                    elevation: 4,
                    bounce: true,
                    context: context,
                    builder: (_) {
                      if (ongoingOrder.status == 'Accepted') {
                        return Container(
                          height: 300,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.amber[600], borderRadius: BorderRadius.all(Radius.circular(18))
                                      // border: Border.all(color: Colors.amber)
                                      ),
                                  padding: EdgeInsets.all(8),
                                  child: CustomText(
                                    text: ongoingOrder.status,
                                    size: 16,
                                    fontWeight: FontWeight.bold,
                                    color: whiteColor,
                                  ),
                                ),
                                SizedBox(height: 10),
                                CustomText(text: 'Order id: #${ongoingOrder.orderNumber.toString()}', fontWeight: FontWeight.bold, size: 18),
                                ClipOval(
                                  child: Container(
                                    decoration: BoxDecoration(border: Border.all(color: greyColor[400])),
                                    height: 70,
                                    width: 70,
                                    child: requesterProfilePicture == null
                                        ? Image.asset(
                                            HelperClass.noImage,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            requesterProfilePicture,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),

                                // CartItemRich(lightFont: , boldFont: , lightFontSize: 16, boldFontSize: 17),
                                SizedBox(height: 5),
                                CartItemRich(lightFont: 'Placed On:', boldFont: ongoingOrder.placedOn.toDate().toString().substring(0, 16)),
                                SizedBox(height: 10),
                                CartItemRich(lightFont: 'Placed By:', boldFont: ongoingOrder.senderName, lightFontSize: 14, boldFontSize: 16),
                                SizedBox(height: 5),
                                CartItemRich(lightFont: 'Pick up address:', boldFont: ongoingOrder.senderAddress, lightFontSize: 14, boldFontSize: 16),
                                SizedBox(height: 5),
                                CartItemRich(lightFont: 'Nearby landMark:', boldFont: ongoingOrder.senderLandMark, lightFontSize: 14, boldFontSize: 16),
                                SizedBox(height: 5),
                                CartItemRich(lightFont: 'Placement Date:', boldFont: ongoingOrder.placedOn.toDate().toString().substring(0, 16)),
                                SizedBox(height: 5),

                                MaterialButton(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                  onPressed: () async {
                                    Fluttertoast.showToast(msg: 'please wait');
                                    if (ongoingOrder.status == 'Accepted') {
                                      // await courierServices.updateVehiclePositionOrder(ongoingOrder.serviceId);
                                      commenceTrip();
                                    }
                                  },
                                  color: primaryColor,
                                  child: loading == true
                                      ? Container(
                                          width: 200,
                                          child: SpinKitCircle(
                                            color: whiteColor,
                                            size: 20,
                                          ))
                                      : Container(
                                          width: 200,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.drive_eta, color: whiteColor),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              CustomText(
                                                textAlign: TextAlign.center,
                                                text: 'Start Trip',
                                                fontWeight: FontWeight.bold,
                                                color: whiteColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                                // CustomFlatButton(
                                //   iconColor: whiteColor,
                                //   fontSize: 16,
                                //   color: Colors.indigo[300],
                                //   textColor: whiteColor,
                                //   radius: 30,
                                //   text: 'Start Trip',
                                //   icon: Icons.drive_eta,
                                //   callback: () {
                                //     if (loading = false) {
                                //       commenceTrip();
                                //     }
                                //   },
                                // )
                              ],
                            ),
                          ),
                        );
                      }

                      if (ongoingOrder.status == 'In Transit') {
                        return Container(
                          height: 300,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.purple[600], borderRadius: BorderRadius.all(Radius.circular(18))
                                      // border: Border.all(color: Colors.amber)
                                      ),
                                  padding: EdgeInsets.all(8),
                                  child: CustomText(
                                    text: ongoingOrder.status,
                                    size: 16,
                                    fontWeight: FontWeight.bold,
                                    color: whiteColor,
                                  ),
                                ),
                                SizedBox(height: 10),
                                CustomText(text: 'Order id: #${ongoingOrder.orderNumber.toString()}', fontWeight: FontWeight.bold, size: 18),
                                ClipOval(
                                  child: Container(
                                    decoration: BoxDecoration(border: Border.all(color: greyColor[400])),
                                    height: 70,
                                    width: 70,
                                    child: requesterProfilePicture == null
                                        ? Image.asset(
                                            HelperClass.noImage,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            requesterProfilePicture,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),

                                // CartItemRich(lightFont: , boldFont: , lightFontSize: 16, boldFontSize: 17),
                                SizedBox(height: 5),
                                CartItemRich(lightFont: 'Placed On:', boldFont: ongoingOrder.placedOn.toDate().toString().substring(0, 16)),

                                SizedBox(height: 10),
                                CartItemRich(lightFont: 'Placed By:', boldFont: ongoingOrder.senderName, lightFontSize: 14, boldFontSize: 16),
                                SizedBox(height: 5),
                                CartItemRich(lightFont: 'Drop Off address:', boldFont: ongoingOrder.recipientAddress, lightFontSize: 14, boldFontSize: 16),
                                SizedBox(height: 5),
                                CartItemRich(lightFont: 'Nearby landMark:', boldFont: ongoingOrder.recipientLanMark, lightFontSize: 14, boldFontSize: 16),
                                SizedBox(height: 5),
                                CartItemRich(lightFont: 'Placement Date:', boldFont: ongoingOrder.placedOn.toDate().toString().substring(0, 16)),
                                SizedBox(height: 5),
                                MaterialButton(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                  // await   courierServices.updateVehiclePositionOrder(ongoingOrder.serviceId);
                                  onPressed: () {
                                    if (ongoingOrder.status == 'In Transit') {
                                      finishTrip();
                                    } else {
                                      Fluttertoast.showToast(msg: 'Please wait');
                                    }
                                  },
                                  color: Colors.green[300],
                                  // minWidth: 200,
                                  child: loading == true
                                      ? Container(
                                          width: 200,
                                          child: SpinKitCircle(
                                            color: whiteColor,
                                            size: 20,
                                          ))
                                      : Container(
                                          width: 200,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.drive_eta, color: whiteColor),
                                              CustomText(
                                                textAlign: TextAlign.center,
                                                text: 'Finish Trip',
                                                fontWeight: FontWeight.w700,
                                                color: whiteColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                )
                                // CustomFlatButton(
                                //   iconColor: whiteColor,
                                //   fontSize: 16,
                                //   color: Colors.green[300],
                                //   textColor: whiteColor,
                                //   radius: 30,
                                //   text: 'Finish Trip',
                                //   icon: Icons.drive_eta,
                                //   callback: () {
                                //     finishTrip().then((value) => Navigator.pop(context));

                                //   },
                                // )
                              ],
                            ),
                          ),
                        );
                      }
                      return Container(
                        height: MediaQuery.of(context).size.height / 2,
                        width: 100,
                        child: Column(children: []),
                      );
                    }),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))),
                color: Colors.white,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward),
                      CustomText(
                        text: 'View trip info',
                        color: blackColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 43.0, right: 10),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  cameraZoom++;
                  _getUserLocation();
                  _getPolyline(currentPosition.latitude, currentPosition.longitude);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: whiteColor,
                    boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 2, spreadRadius: 1, offset: Offset(2, 3))],
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.my_location_rounded,
                    size: 30,
                    // color: white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget zoomButtons() {
    return Container(
      // height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              // cameraZoom++;
              // zoomIn(cameraZoom);
              // _getPolyline(currentPosition.latitude, currentPosition.longitude);
              if (await eos.MapLauncher.isMapAvailable(eos.MapType.google)) {
                if (ongoingOrder.status == 'Accepted') {
                  await eos.MapLauncher.showDirections(
                    mapType: eos.MapType.google,
                    destination: eos.Coords(ongoingOrder.senderLocation.latitude, ongoingOrder.senderLocation.longitude),
                  );
                }
                if (ongoingOrder.status == 'In Transit') {
                  await eos.MapLauncher.showDirections(
                    mapType: eos.MapType.google,
                    destination: eos.Coords(ongoingOrder.recipientLocation.latitude, ongoingOrder.recipientLocation.longitude),
                  );
                }
              }
              print(polylineCoordinates.length);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: whiteColor,
                boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 2, spreadRadius: 1, offset: Offset(2, 3))],
              ),
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.directions, size: 30,
                // color: white,
              ),
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              cameraZoom++;
              zoomIn(cameraZoom);
              _getPolyline(currentPosition.latitude, currentPosition.longitude);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: whiteColor,
                boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 2, spreadRadius: 1, offset: Offset(2, 3))],
              ),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.add, size: 30
                  // color: white,
                  ),
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              cameraZoom--;
              zoomOut(cameraZoom);
              _getPolyline(currentPosition.latitude, currentPosition.longitude);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: whiteColor,
                boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 2, spreadRadius: 1, offset: Offset(1, 1))],
              ),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.remove, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget mapsScreen() {
    return FutureBuilder(
      future: _getUPickUpLocation(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        cameraPosition = snapshot.data;
        // print(snapshot.connectionState);
        if (snapshot.hasData) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              // liteModeEnabled: true,
              tiltGesturesEnabled: false,
              compassEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (GoogleMapController controller) async {
                // controller.setMapStyle(Utils.mapStyles);

                mapsController.complete(controller);
              },
              // onCameraMoveStarted: ,
              markers: Set.from(markerList),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              trafficEnabled: false,
              mapType: MapType.normal,
              initialCameraPosition: cameraPosition,
              onCameraMove: onCameraMove,
              polylines: Set<Polyline>.of(polylines.values),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading(
            text: 'Please wait..preparing your location data',
            size: 14,
            // color: primaryColor.withOpacity(.4),
            textColor: greyColor[900],
            fontWeight: FontWeight.w700,
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: CustomText(
              text: 'Failed to load location data',
              textAlign: TextAlign.center,
            ),
          );
        }
        return Loading();
      },
    );
  }

  Future<CameraPosition> _getUPickUpLocation() async {
    driverId = auth.currentUser.uid;
    var position = await GeolocatorPlatform.instance.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // currentPostion = LatLng(-2.4213, 38.084);
    // courierServices.getActiveServiceRequests(vehicleType)
    if (mounted) {
      serviceRequests = await courierServices.getActiveServiceRequests(widget.vehicleType);
      if (serviceRequests.length == 0) {
        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          ongoingOrder = serviceRequests[0];
        });
      }
    }
    currentPosition = LatLng(position.latitude, position.longitude);
    if (ongoingOrder.senderLocation != null && ongoingOrder.recipientLocation != null) {
      // _getPolyline(currentPosition.latitude, currentPosition.longitude);
      markerList.add(
        Marker(
          markerId: MarkerId(ongoingOrder.senderAddress),
          position: LatLng(ongoingOrder.senderLocation.latitude, ongoingOrder.senderLocation.longitude),
          infoWindow: InfoWindow(title: ongoingOrder.senderAddress, snippet: 'Pick UP: ${ongoingOrder.senderName}'),
          icon: locationIndicatorIcon,
        ),
      );
      markerList.add(
        Marker(
          markerId: MarkerId(ongoingOrder.recipientAddress),
          position: LatLng(ongoingOrder.recipientLocation.latitude, ongoingOrder.recipientLocation.longitude),
          infoWindow: InfoWindow(title: ongoingOrder.recipientAddress, snippet: 'Drop Off: ${ongoingOrder.recipientname}'),
          icon: locationIndicatorIcon,
        ),
      );
      // _getUserLocation().then((value) => );
      // courierServices.updateVehiclePositionOrder(ongoingOrder.serviceId);
      // print(ongoingOrder.status);
      // final GoogleMapController controller = await mapsController.future;
      //  controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      // Fluttertoast.showToast(msg: '${currentPosition.latitude} ${currentPosition.longitude}');
      markerList.add(Marker(
        markerId: MarkerId(driverId),
        position: LatLng(currentPosition.latitude, currentPosition.longitude),
        // infoWindow: InfoWindow(title: driverId),
        icon: currentLocationIcon,
      ));
    }
    if (ongoingOrder.status == 'Accepted') {
      distanceBetween = Geolocator.distanceBetween(
          ongoingOrder.senderLocation.latitude, ongoingOrder.senderLocation.longitude, currentPosition.latitude, currentPosition.longitude);
      if (distanceBetween < 300) {
        sendRecipientPickUpNotification();
      }
    }
    if (ongoingOrder.status == 'In Transit') {
      distanceBetween = Geolocator.distanceBetween(
          ongoingOrder.recipientLocation.latitude, ongoingOrder.recipientLocation.longitude, currentPosition.latitude, currentPosition.longitude);
      if (distanceBetween == 300) {
        sendRecipientDropOffNotification();
      }
    }
    cameraPosition = CameraPosition(
      target: LatLng(currentPosition.latitude, currentPosition.longitude),
      zoom: 15,
      tilt: 50,
      bearing: 45,
    );
    courierServices.getUserById(ongoingOrder.senderId).then((value) {
      requesterProfilePicture = value.profilePicture;
      // Fluttertoast.showToast(msg: value.profilePicture);
    });
    return cameraPosition;
  }

  onCameraMove(CameraPosition position) {
    if (mounted) {
      setState(() {
        lastPosition = position.target;
      });
    }
  }

  _addPolyLine(String polyId) {
    PolylineId id = PolylineId(polyId);
    Polyline polyline = Polyline(polylineId: id, color: primaryColor, points: polylineCoordinates, width: 3, endCap: Cap.roundCap, jointType: JointType.round);
    polylines[id] = polyline;
    if (mounted) {
      setState(() {});
    }
  }

  _getPolyline(double latitude, double longitude) async {
    PolylineResult result = PolylineResult();
    status = ongoingOrder.status;
    if (status == 'Accepted') {
      result = await polylinePoints.getRouteBetweenCoordinates(
        HelperClass.googleKey,
        PointLatLng(ongoingOrder.senderLocation.latitude, ongoingOrder.senderLocation.longitude),
        PointLatLng(latitude, longitude),
      );
    }
    if (status == 'In Transit') {
      result = await polylinePoints.getRouteBetweenCoordinates(
        HelperClass.googleKey,
        PointLatLng(ongoingOrder.recipientLocation.latitude, ongoingOrder.recipientLocation.longitude),
        PointLatLng(latitude, longitude),
      );
    }

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    print('object$polylineCoordinates');
    var id = Uuid();
    String polyId = id.v1();
    _addPolyLine(polyId);
  }

  Future<void> zoomIn(double zoomValue) async {
    final GoogleMapController controller = await mapsController.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> zoomOut(double zoomValue) async {
    final GoogleMapController controller = await mapsController.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> _getUserLocation() async {
    final GoogleMapController controller = await mapsController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: currentPosition,
      zoom: 15,
      tilt: 40,
      bearing: 45,
    )));
  }

  getLocationIcons(BuildContext context) async {
    if (currentContext == null) {
      currentContext = context;
      final ImageConfiguration currentLocatonConfiguration = createLocalImageConfiguration(currentContext, size: Size(10, 10));
      final ImageConfiguration locationIndicatorConfiguration = createLocalImageConfiguration(currentContext, size: Size(10, 10));

      currentLocationIcon = await BitmapDescriptor.fromAssetImage(currentLocatonConfiguration, HelperClass.currentlocationMarker);
      locationIndicatorIcon = await BitmapDescriptor.fromAssetImage(locationIndicatorConfiguration, HelperClass.pickUplocationMarker);
    }
  }

  commenceTrip() async {
    String message = 'The Order #${ongoingOrder.orderNumber} has been Started by ${widget.firstName} ${widget.lastName} who will be with you soon';

    setState(() {
      loading = true;
    });
    await courierServices
        .updateCommenced(ongoingOrder.serviceId)
        .then((value) => oneSignalPush.sendNotification(context, ongoingOrder.senderId, message, 'Your order has been accepted'))
        .then((value) {
      setState(() {
        status = 'In Transit';
        loading = false;
      });
      Navigator.pop(context);
    });
  }

  sendRecipientPickUpNotification() {
    String message = '${widget.firstName} ${widget.lastName} is close by for pick up';
    oneSignalPush.sendNotification(context, ongoingOrder.senderId, message, 'Pick Up proximity alert for order #${ongoingOrder.orderNumber}');
  }

  sendRecipientDropOffNotification() {
    String message = '${widget.firstName} ${widget.lastName} is close to ${ongoingOrder.recipientAddress}';
    oneSignalPush.sendNotification(context, ongoingOrder.senderId, message, 'Drop Off proximity alert for order #${ongoingOrder.orderNumber}');
  }

  Future finishTrip() async {
    setState(() {
      loading = true;
    });
    await courierServices
        .updateCompleted(ongoingOrder.serviceId, context, ongoingOrder.senderId, ongoingOrder.orderNumber, widget.firstName, widget.lastName)
        .then((value) {
      setState(() {
        status = 'Completed';
        loading = false;
      });
    });
  }
}
