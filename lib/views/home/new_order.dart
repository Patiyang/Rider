import 'dart:collection';
import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/models/courierModel.dart';
import 'package:delivery_boy/services/courierServices.dart';
import 'package:delivery_boy/services/oneSignalPush.dart';
import 'package:delivery_boy/services/userServices.dart';
import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customButton.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customText.dart';
import 'package:delivery_boy/widgets&helpers/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class NewOrder extends StatefulWidget {
  final bool online;

  const NewOrder({Key key, this.online}) : super(key: key);
  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  CourierServices _courierServices = new CourierServices();
  UserServices userServices = new UserServices();
  String vehicleType = '';
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  String profilePicture = '';
  String gender = '';
  List<CourierModel> serviceRequests = [];
  List<CourierModel> activeRequsts = [];
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  OneSignalPush oneSignalPush = new OneSignalPush();
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  HashMap<String, Object> testTriggers = new HashMap<String, Object>();
  bool loading = false;
  bool acceptOderPermission = false;
  var permission = Permission.location.status;
  // var grantPermision = Permission.location.request();
  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    rejectreasonDialog() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // return object of type Dialog
          return Dialog(
            elevation: 0.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Wrap(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: width,
                      padding: EdgeInsets.all(fixPadding),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          topLeft: Radius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        'Reason to Reject',
                        style: wbuttonWhiteTextStyle,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(fixPadding),
                      alignment: Alignment.center,
                      child: Text('Write a specific reason to reject order'),
                    ),
                    Container(
                      width: width,
                      padding: EdgeInsets.all(fixPadding),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Enter Reason Here',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          fillColor: Colors.grey.withOpacity(0.1),
                          filled: true,
                        ),
                      ),
                    ),
                    heightSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: (width / 3.5),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              'Cancel',
                              style: buttonBlackTextStyle,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: (width / 3.5),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              'Send',
                              style: wbuttonWhiteTextStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    heightSpace,
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    orderAcceptDialog(CourierModel courierModel) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // return object of type Dialog
          return Dialog(
            elevation: 0.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Wrap(
              children: <Widget>[
                Container(
                  width: width,
                  height: height / 1.2,
                  child: ListView(
                    children: <Widget>[
                      Container(
                        width: width,
                        padding: EdgeInsets.all(fixPadding),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10.0),
                            topLeft: Radius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          'Order Id: ${courierModel.orderNumber}',
                          style: wbuttonWhiteTextStyle,
                        ),
                      ),

                      // Order Start
                      Container(
                        margin: EdgeInsets.all(fixPadding),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              blurRadius: 1.5,
                              spreadRadius: 1.5,
                              color: Colors.grey[200],
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(fixPadding),
                              decoration: BoxDecoration(
                                  color: lightGreyColor,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5.0),
                                    topLeft: Radius.circular(5.0),
                                  )),
                              child: Text(
                                'Order',
                                style: buttonBlackTextStyle,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(fixPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: CustomText(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          text: courierModel.paymentMode == 'cash' ? 'Payable Amount' : 'Amount Paid',
                                          // style: listItemTitleStyle,
                                        ),
                                      ),
                                      Text(
                                        '${HelperClass.naira} ${courierModel.earnings.ceilToDouble().toString().replaceAllMapped(reg, mathFunc)}0',
                                        style: listItemTitleStyle,
                                      ),
                                    ],
                                  ),
                                  heightSpace,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Distance to cover',
                                        style: listItemTitleStyle,
                                      ),
                                      Text(
                                        '${courierModel.distance} Kms',
                                        style: listItemTitleStyle,
                                      ),
                                    ],
                                  ),
                                  heightSpace,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Package Type',
                                        style: listItemTitleStyle,
                                      ),
                                      Text(
                                        '${courierModel.packageType}',
                                        style: listItemTitleStyle,
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Total',
                                        style: headingStyle,
                                      ),
                                      Text(
                                        '${HelperClass.naira} ${courierModel.earnings.ceilToDouble().toString().replaceAllMapped(reg, mathFunc)}0',
                                        style: priceStyle,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Order End
                      // Location Start
                      Container(
                        margin: EdgeInsets.all(fixPadding),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              blurRadius: 1.5,
                              spreadRadius: 1.5,
                              color: Colors.grey[200],
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(fixPadding),
                              decoration: BoxDecoration(
                                  color: lightGreyColor,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5.0),
                                    topLeft: Radius.circular(5.0),
                                  )),
                              child: Text(
                                'Location',
                                style: buttonBlackTextStyle,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(fixPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: ((width - fixPadding * 13) / 2.0),
                                        child: Text(
                                          'Pickup Location',
                                          style: listItemTitleStyle,
                                        ),
                                      ),
                                      widthSpace,
                                      Container(
                                        width: ((width - fixPadding * 13) / 2.0),
                                        child: Text(
                                          courierModel.recipientAddress,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: listItemTitleStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  heightSpace,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: ((width - fixPadding * 13) / 2.0),
                                        child: Text(
                                          'Delivery Location',
                                          style: listItemTitleStyle,
                                        ),
                                      ),
                                      widthSpace,
                                      Container(
                                        width: ((width - fixPadding * 13) / 2.0),
                                        child: Text(
                                          courierModel.senderAddress,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: listItemTitleStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Location End

                      // Customer Start
                      Container(
                        margin: EdgeInsets.all(fixPadding),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              blurRadius: 1.5,
                              spreadRadius: 1.5,
                              color: Colors.grey[200],
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(fixPadding),
                              decoration: BoxDecoration(
                                  color: lightGreyColor,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5.0),
                                    topLeft: Radius.circular(5.0),
                                  )),
                              child: Text(
                                'Customer',
                                style: buttonBlackTextStyle,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(fixPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Name',
                                        style: listItemTitleStyle,
                                      ),
                                      Text(
                                        courierModel.senderName,
                                        style: listItemTitleStyle,
                                      ),
                                    ],
                                  ),
                                  heightSpace,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Phone',
                                        style: listItemTitleStyle,
                                      ),
                                      Text(
                                        courierModel.senderPhone,
                                        style: listItemTitleStyle,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Customer End

                      // Payment Start
                      Container(
                        margin: EdgeInsets.all(fixPadding),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              blurRadius: 1.5,
                              spreadRadius: 1.5,
                              color: Colors.grey[200],
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(fixPadding),
                              decoration: BoxDecoration(
                                  color: lightGreyColor,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5.0),
                                    topLeft: Radius.circular(5.0),
                                  )),
                              child: Text(
                                'Payment',
                                style: buttonBlackTextStyle,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(fixPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          'Payment',
                                          style: listItemTitleStyle,
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          courierModel.paymentMode,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: listItemTitleStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Payment End
                      heightSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          CustomFlatButton(
                            text: 'Accept',
                            callback: () async {
                              Fluttertoast.showToast(msg: 'Please wait...');

                              if (acceptOderPermission == true) {
                                String pushMessage =
                                    'The Order #${courierModel.orderNumber} has been Accepted by $firstName $lastName who will be with you soon';
                                if (activeRequsts.length > 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      backgroundColor: greyColor[400],
                                      content: CustomText(
                                        text: 'You already have an ongoing order',
                                        color: Colors.red,
                                        textAlign: TextAlign.center,
                                        fontWeight: FontWeight.bold,
                                        size: 16,
                                      )));
                                } else {
                                  try {
                                    await _courierServices.updateAcceptedOrder(_auth.currentUser.uid, courierModel.serviceId).then((value) {
                                      setState(() {
                                        serviceRequests.removeAt(serviceRequests.indexOf(courierModel));
                                        oneSignalPush.sendNotification(context, courierModel.senderId, pushMessage,
                                            'Order #${courierModel.orderNumber} for${courierModel.packageType} has been accepted');
                                      });
                                      Fluttertoast.showToast(msg: 'You have accepted Order #${courierModel.orderNumber}');
                                    });
                                    Navigator.pop(context);
                                  } catch (e) {
                                    Fluttertoast.showToast(msg: 'An error was encountered when processing this order');
                                    Navigator.pop(context);
                                    print(e.toString());
                                  }
                                }
                                // Navigator.pop(context);
                              } else {
                                print('object');
                                await Permission.location.request();
                              }
                            },
                            radius: 5,
                            width: (width / 3.5),
                            textColor: whiteColor,
                          ),
                          // InkWell(
                          //   onTap: () async {
                          //     if (acceptOderPermission == true) {
                          //       String pushMessage =
                          //           'The Order #${courierModel.orderNumber} has been Accepted by $firstName $lastName who will be with you soon';
                          //       if (activeRequsts.length > 0) {
                          //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          //             backgroundColor: greyColor[400],
                          //             content: CustomText(
                          //               text: 'You already have an ongoing order',
                          //               color: Colors.red,
                          //               textAlign: TextAlign.center,
                          //               fontWeight: FontWeight.bold,
                          //               size: 16,
                          //             )));
                          //       } else {
                          //         await _courierServices.updateAcceptedOrder(_auth.currentUser.uid, courierModel.serviceId).then((value) {
                          //           setState(() {
                          //             serviceRequests.removeAt(serviceRequests.indexOf(courierModel));
                          //             oneSignalPush.sendNotification(context, courierModel.senderId, pushMessage,
                          //                 'Order #${courierModel.orderNumber} for${courierModel.packageType} has been accepted');
                          //           });
                          //           Fluttertoast.showToast(msg: 'You have accepted Order #${courierModel.orderNumber}');
                          //         });
                          //       }
                          //       Navigator.pop(context);
                          //     } else {
                          //       print('object');
                          //       await Permission.location.request();
                          //     }
                          //   },
                          //   child: Container(
                          //     width: (width / 3.5),
                          //     alignment: Alignment.center,
                          //     padding: EdgeInsets.all(10.0),
                          //     decoration: BoxDecoration(
                          //       color: primaryColor,
                          //       borderRadius: BorderRadius.circular(5.0),
                          //     ),
                          //     child: Text(
                          //       'Accept',
                          //       style: wbuttonWhiteTextStyle,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      heightSpace,
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return (serviceRequests.length == 0 || widget.online == false)
        ? Center(
            child: loading == true
                ? Loading(
                    color: whiteColor,
                    spinkitColor: darkPrimaryColor,
                    text: 'Please wait, Fetching New orders..',
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      if (widget.online == true) {
                        getUserDetails();
                        Fluttertoast.showToast(msg: 'Your order requests have been updated');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: CustomText(
                          text: 'Currently Offline!!',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .2,
                          size: 17,
                          textAlign: TextAlign.center,
                        )));
                      }
                    },
                    child: widget.online == false
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    HelperClass.offline,
                                    fit: BoxFit.contain,
                                    height: 70,
                                    width: 250,
                                  ),
                                  SizedBox(height: 10),
                                  CustomText(
                                    text: 'You\'re currently offline, Change your online status to view the lates order requests',
                                    size: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: .3,
                                    maxLines: 4,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView(
                            children: <Widget>[
                              SizedBox(
                                height: 225,
                              ),
                              Icon(Icons.local_mall, color: Colors.grey, size: 60.0),
                              SizedBox(height: 20.0),
                              Text(
                                'No new orders.',
                                textAlign: TextAlign.center,
                                style: greyHeadingStyle.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
          )
        : RefreshIndicator(
            onRefresh: () async {
              serviceRequests = await _courierServices.getServiceRequests(vehicleType);
              setState(() {});
              Fluttertoast.showToast(msg: 'Your order requests have been updated');
            },
            child: ListView.builder(
              itemCount: serviceRequests.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final item = serviceRequests[index];
                return Container(
                  padding: EdgeInsets.all(fixPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              blurRadius: 1.5,
                              spreadRadius: 1.5,
                              color: Colors.grey[200],
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(fixPadding),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Icon(Icons.local_shipping, color: primaryColor, size: 25.0),
                                      widthSpace,
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('#' + item.orderNumber.toString(), style: headingStyle),
                                          heightSpace,
                                          heightSpace,
                                          Text('Payment Mode', style: lightGreyStyle),
                                          Text(item.paymentMode, style: headingStyle),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      CustomFlatButton(
                                        text: 'Order Details',
                                        callback: () => orderAcceptDialog(item),
                                        radius: 5,
                                        width: 100,
                                        textColor: whiteColor,
                                      ),
                                      heightSpace,
                                      Text('Payment', style: lightGreyStyle),
                                      Text('${HelperClass.naira} ${item.earnings.ceilToDouble()}0'.replaceAllMapped(reg, mathFunc), style: headingStyle),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(fixPadding),
                              decoration: BoxDecoration(
                                color: lightGreyColor,
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(5.0),
                                  bottomLeft: Radius.circular(5.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    width: (width - fixPadding * 4.0) / 3.2,
                                    child: Text(
                                      item.senderAddress,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: buttonBlackTextStyle,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.location_on,
                                        color: primaryColor,
                                        size: 20.0,
                                      ),
                                      getDot(),
                                      getDot(),
                                      getDot(),
                                      getDot(),
                                      getDot(),
                                      Icon(
                                        Icons.navigation,
                                        color: primaryColor,
                                        size: 20.0,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: (width - fixPadding * 4.0) / 3.2,
                                    child: Text(
                                      item.recipientAddress,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: buttonBlackTextStyle,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }

  getDot() {
    return Container(
      margin: EdgeInsets.only(left: 2.0, right: 2.0),
      width: 4.0,
      height: 4.0,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }

  void getUserDetails() async {
    if (widget.online == true) {
      setState(() {
        loading = true;
      });
      userServices.getUserById(_auth.currentUser.uid).then((value) {
        vehicleType = value.vehicleType;
        firstName = value.firstName;
        lastName = value.lastName;
        gender = value.gender;
        print(vehicleType);
      }).then((value) async {
        serviceRequests = await _courierServices.getServiceRequests(vehicleType);
        activeRequsts = await _courierServices.getActiveServiceRequests(vehicleType);
        print(activeRequsts.length.toString() + "");
        acceptOderPermission = await permission.isGranted;

        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      });
    }
  }
}
