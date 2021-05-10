import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/models/courierModel.dart';
import 'package:delivery_boy/services/courierServices.dart';
import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customButton.dart';
import 'package:delivery_boy/widgets&helpers/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class DeliveryMapAlternate extends StatefulWidget {
  final String vehicleType;
  final String firstName;
  final String lastName;

  const DeliveryMapAlternate({Key key, this.vehicleType, this.firstName, this.lastName}) : super(key: key);
  @override
  _DeliveryMapAlternateState createState() => _DeliveryMapAlternateState();
}

class _DeliveryMapAlternateState extends State<DeliveryMapAlternate> {
  MapBoxNavigation _directions = MapBoxNavigation();

  String _instruction = "";
  String _platformVersion = 'Unknown';
  double _distanceRemaining, _durationRemaining;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  // bool _arrived = false;
  bool loading = false;
  MapBoxOptions _options;
  bool _isMultipleStop = false;
  MapBoxNavigationViewController _controller;

  String status = '';

  List<WayPoint> wayPoints = [];
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  CourierModel ongoingOrder;
  List<CourierModel> serviceRequests = [];
  CourierServices courierServices = new CourierServices();
  LatLng currentPosition;
  // final origin = WayPoint(name: name, latitude: latitude, longitude: longitude)
  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: loading == true
            ? Loading(
                text: 'Please wait..preparing your route..',
                fontWeight: FontWeight.w800,
                spinkitColor: primaryColor,
              )
            : Column(
                children: [
                  Container(
                    height: 400,
                    child: MapBoxNavigationView(
                        options: _options,
                        onRouteEvent: _onEmbeddedRouteEvent,
                        onCreated: (MapBoxNavigationViewController controller) async {
                          _controller = controller;
                          controller.initialize();
                        }),
                  ),
                  Spacer(),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20, top: 20, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Duration Remaining:"),
                                Text(_durationRemaining != null ? "${(_durationRemaining / 60).toStringAsFixed(0)} minutes" : "---")
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Distance Remaining: "),
                                Text(_distanceRemaining != null ? "${(_distanceRemaining * 0.000621371).toStringAsFixed(1)} miles" : "---")
                              ],
                            ),
                          ],
                        ),
                      ),
                      CustomFlatButton(
                        text: _routeBuilt && !_isNavigating ? "Clear Route" : "Build Route",
                        fontSize: 17,
                        radius: 30,
                        fontWeight: FontWeight.bold,
                        callback: () {
                          if (_isNavigating) {
                            Fluttertoast.showToast(msg: 'Navigation has already started');
                          } else {
                            if (_routeBuilt) {
                              _controller.clearRoute();
                            } else {
                              _isMultipleStop = wayPoints.length > 2;
                              _controller.buildRoute(wayPoints: wayPoints, options: _options);
                              print(wayPoints.length);
                            }
                          }
                        },
                      ),
                      CustomFlatButton(
                        callback: () {
                          // _controller.startNavigation();
                          // _directions.startNavigation(wayPoints: wayPoints, options: _options);
                          if (_routeBuilt && !_isNavigating) {
                            Fluttertoast.showToast(msg: '''msg''');
                            try {
                              _controller.startNavigation(options: _options);
                            } catch (e) {
                              print(e.toString());
                            }
                          } else {
                            Fluttertoast.showToast(msg: 'your route is not yet built');
                            print('is navigating' + _isNavigating.toString());
                            print('routebuilding' + _routeBuilt.toString());
                          }
                        },
                        text: 'start navigation',
                        fontSize: 17,
                        radius: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      CustomFlatButton(
                        callback: () {
                          _controller.finishNavigation();
                          _directions.finishNavigation();
                          if (_isNavigating) {}
                        },
                        text: 'finish navigation',
                        fontSize: 17,
                        radius: 30,
                        fontWeight: FontWeight.bold,
                      ),

                      // Padding(
                      //   padding: EdgeInsets.only(left: 20.0, right: 20, top: 20, bottom: 10),
                      //   child: Column(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: <Widget>[
                      //       Row(
                      //         children: <Widget>[
                      //           Text("Duration Remaining:"),
                      //           Text(_durationRemaining != null ? "${(_durationRemaining / 60).toStringAsFixed(0)} minutes" : "---")
                      //         ],
                      //       ),
                      //       Row(
                      //         children: <Widget>[
                      //           Text("Distance Remaining: "),
                      //           Text(_distanceRemaining != null ? "${(_distanceRemaining * 0.000621371).toStringAsFixed(1)} miles" : "---")
                      //         ],
                      //       ),
                      // Center(
                      //   child: Padding(
                      //     padding: EdgeInsets.all(10),
                      //     child: Text(
                      //       "Long-Press Embedded Map to Set Destination",
                      //       textAlign: TextAlign.center,
                      //     ),
                      //   ),
                      // ),
                      // Container(
                      //   color: Colors.grey,
                      //   width: double.infinity,
                      //   child: Padding(
                      //     padding: EdgeInsets.all(10),
                      //     child: (Text(
                      //       _instruction == null || _instruction.isEmpty ? "Banner Instruction Here" : _instruction,
                      //       style: TextStyle(color: Colors.white),
                      //       textAlign: TextAlign.center,
                      //     )),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.only(left: 20.0, right: 20, top: 20, bottom: 10),
                      //   child: Column(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: <Widget>[
                      //       Row(
                      //         children: <Widget>[
                      //           Text("Duration Remaining:"),
                      //           Text(_durationRemaining != null ? "${(_durationRemaining / 60).toStringAsFixed(0)} minutes" : "---")
                      //         ],
                      //       ),
                      //       Row(
                      //         children: <Widget>[
                      //           Text("Distance Remaining: "),
                      //           Text(_distanceRemaining != null ? "${(_distanceRemaining * 0.000621371).toStringAsFixed(1)} miles" : "---")
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Divider()
                    ],
                  ),
                ],
              ),
      ),
    );
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
      wayPoints.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // for (int i = 0; i < polylineCoordinates.length; i++) {
    //   wayPoints.add(WayPoint(name: '${polylineCoordinates.length + 1}', latitude: currentPosition.latitude, longitude: currentPosition.longitude));
    //   wayPoints.add(WayPoint(name: 'one', latitude: polylineCoordinates[0].latitude, longitude: polylineCoordinates[0].longitude));
    //   wayPoints.add(WayPoint(name: 'two', latitude: polylineCoordinates[1].latitude, longitude: polylineCoordinates[1].longitude));
    //   wayPoints.add(WayPoint(name: 'three', latitude: polylineCoordinates[2].latitude, longitude: polylineCoordinates[2].longitude));
    //   wayPoints.add(WayPoint(name: 'four', latitude: polylineCoordinates[3].latitude, longitude: polylineCoordinates[3].longitude));
    // }
    wayPoints.add(WayPoint(name: 'user', latitude: currentPosition.latitude, longitude: currentPosition.longitude));
    wayPoints.add(WayPoint(name: 'one', latitude: polylineCoordinates[0].latitude, longitude: polylineCoordinates[0].longitude));
    wayPoints.add(WayPoint(name: 'two', latitude: polylineCoordinates[1].latitude, longitude: polylineCoordinates[1].longitude));
    wayPoints.add(WayPoint(name: 'three', latitude: polylineCoordinates[2].latitude, longitude: polylineCoordinates[2].longitude));
    wayPoints.add(WayPoint(name: 'four', latitude: polylineCoordinates[3].latitude, longitude: polylineCoordinates[3].longitude));
    print('THE WAYPOINTS ARE ' + wayPoints.length.toString());
    var id = Uuid();
    String polyId = id.v1();
    _addPolyLine(polyId);
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    _distanceRemaining = await _directions.distanceRemaining;
    _durationRemaining = await _directions.durationRemaining;
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        courierServices.updateVehiclePositionOrder(ongoingOrder.serviceId);
        print('progress changed');
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null) _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        if (mounted) {
          setState(() {
            _routeBuilt = true;
          });
        }
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        print('progress altered');
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _controller.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      default:
        break;
    }
    setState(() {});
  }

  Future<void> initialize() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = LatLng(position.latitude, position.longitude);
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      loading = true;
    });
    serviceRequests = await courierServices.getActiveServiceRequests(widget.vehicleType);
    // setState(() {
    ongoingOrder = serviceRequests[0];
    currentPosition = LatLng(position.latitude, position.longitude);
    _directions = MapBoxNavigation(onRouteEvent: _onEmbeddedRouteEvent);
    _options = MapBoxOptions(
        isOptimized: true,
        initialLatitude: currentPosition.longitude,
        initialLongitude: currentPosition.latitude,
        zoom: 12.0,
        tilt: 45.0,
        bearing: 0.0,
        enableRefresh: true,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: VoiceUnits.imperial,
        simulateRoute: false,
        animateBuildRoute: true,
        longPressDestinationEnabled: false,
        language: "en");
    _getPolyline(position.latitude, position.longitude);
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _directions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    // print(wayPoints);
    setState(() {
      _platformVersion = platformVersion;
      loading = false;
    });
  }
}
