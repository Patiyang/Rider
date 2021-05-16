import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/models/courierModel.dart';
import 'package:delivery_boy/models/userModel.dart';
import 'package:delivery_boy/services/courierServices.dart';
import 'package:delivery_boy/services/userServices.dart';
import 'package:delivery_boy/views/home/deliveryMap.dart';
import 'package:delivery_boy/views/home/deliveryMapAlternate.dart';
import 'package:delivery_boy/widgets&helpers/helpers/changeScreen.dart';
import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customButton.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customListTIle.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customText.dart';
import 'package:delivery_boy/widgets&helpers/widgets/loading.dart';
import 'package:delivery_boy/widgets&helpers/widgets/textField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

enum ViewMode { sender, recipient }

class ActiveOrder extends StatefulWidget {
  final bool online;
  final bool loaded;
  const ActiveOrder({Key key, this.online, this.loaded}) : super(key: key);
  @override
  _ActiveOrderState createState() => _ActiveOrderState();
}

class _ActiveOrderState extends State<ActiveOrder> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  CourierServices _courierServices = new CourierServices();

  UserServices userServices = new UserServices();
  String vehicleType = '';
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  String profilePicture = '';
  String pushMessage = '';
  List<CourierModel> serviceRequests = [];
  CourierModel ongoingOrder;
  final emailController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  ViewMode view = ViewMode.sender;

  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';

  @override
  void initState() {
    getServices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.online == false
        ? Container(
          child:widget.loaded==true? Padding(
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
            ):SpinKitFadingCube(color: blackColor,size: 20),
        )
        : Container(
            child: serviceRequests.length == 0
                ? Center(
                    child: loading == true
                        ? Loading(
                            color: whiteColor,
                            spinkitColor: darkPrimaryColor,
                            text: 'Please wait, Fetching Active orders..',
                            fontWeight: FontWeight.w700,
                            fontSize: 19,
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await getServices();
                              Fluttertoast.showToast(msg: 'Your active service info has been updated...');
                            },
                            child: ListView(
                              children: <Widget>[
                                SizedBox(height: 225),
                                Icon(Icons.local_mall, color: Colors.grey, size: 60.0),
                                SizedBox(height: 20.0),
                                Text(
                                  'No Active orders.',
                                  style: greyHeadingStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ))
                : Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: whiteColor,
                                  border: Border.all(color: greyColor),
                                  borderRadius: BorderRadius.all(Radius.circular(15)
                                      // topLeft: Radius.circular(30),
                                      // topRight: Radius.circular(5),
                                      // bottomLeft: Radius.circular(5),
                                      // bottomRight: Radius.circular(5),
                                      )),
                              child: StreamBuilder(
                                stream: userServices.getCustomerById(ongoingOrder.senderId).asStream(),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    UserModel customer = snapshot.data;
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CustomText(
                                          text: 'Order #' + ongoingOrder.orderNumber.toString(),
                                          fontWeight: FontWeight.bold,
                                          size: 20,
                                        ),
                                        ClipOval(
                                          child: Container(
                                            height: 70,
                                            width: 70,
                                            child: customer.profilePicture == null
                                                ? Image.asset(HelperClass.noImage, fit: BoxFit.cover, height: 70, width: 70)
                                                : Image.network(customer.profilePicture, fit: BoxFit.cover),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        CustomText(text: 'Contact ' + ongoingOrder.senderName, fontWeight: FontWeight.w700, size: 16),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // SizedBox(width: 20),
                                            GestureDetector(
                                              onTap: () => makePhoneCall('tel: 234${ongoingOrder.senderPhone}'),
                                              child: Container(
                                                decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
                                                padding: EdgeInsets.all(13),
                                                child: Icon(Icons.call, color: whiteColor),
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            GestureDetector(
                                              onTap: () => writeMessgae('sms: ${ongoingOrder.senderPhone}'),
                                              child: Container(
                                                decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
                                                padding: EdgeInsets.all(13),
                                                child: Icon(Icons.message, color: whiteColor),
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            GestureDetector(
                                              onTap: () => showEmailDialog(),
                                              // createEmail('mailto:ohwotemuphillip@gmail.com?subject=Order # ${widget.deliveryModel.orderNumber}&body=New%20plugin'),
                                              child: Container(
                                                decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
                                                padding: EdgeInsets.all(13),
                                                child: Icon(Icons.email, color: whiteColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Loading(
                                      size: 15,
                                    );
                                  }
                                  return Container();
                                },
                              ),
                            ),
                            // SizedBox(height: 7),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    view = ViewMode.sender;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    color: view == ViewMode.sender ? primaryColor : greyColor[300],
                                  ),
                                  child: CustomText(
                                    text: 'Sender Details',
                                    color: view == ViewMode.sender ? whiteColor : blackColor,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    view = ViewMode.recipient;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    color: view == ViewMode.recipient ? primaryColor : greyColor[300],
                                  ),
                                  child: CustomText(
                                    text: 'Recipient Details',
                                    color: view == ViewMode.recipient ? whiteColor : blackColor,
                                  ),
                                ),
                              ),
                            ]),
                            SizedBox(height: 10),
                            selectedPage()
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14.0, bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // GestureDetector(
                              //   onTap: () => changeScreen(
                              //       context,
                              //       DeliveryMapAlternate(
                              //         vehicleType: vehicleType,
                              //         firstName: firstName,
                              //         lastName: lastName,
                              //       )),
                              //   child: FittedBox(
                              //     fit: BoxFit.scaleDown,
                              //     child: Container(
                              //       decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
                              //       padding: EdgeInsets.all(13),
                              //       child: Icon(Icons.directions, color: whiteColor, size: 22),
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: 10,
                              // ),
                              GestureDetector(
                                onTap: () => changeScreen(
                                    context,
                                    DeliveryMap(
                                      vehicleType: vehicleType,
                                      firstName: firstName,
                                      lastName: lastName,
                                    )),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.all(Radius.circular(30))),
                                    padding: EdgeInsets.all(13),
                                    child: Row(
                                      children: [
                                        CustomText(text: 'View Directions', color: whiteColor, size: 17, letterSpacing: .3, fontWeight: FontWeight.w400),
                                        SizedBox(width: 10),
                                        Icon(Icons.directions, color: whiteColor, size: 22),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          );
  }

  Widget selectedPage() {
    switch (view) {
      case ViewMode.sender:
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: CustomListTile(
                color: greyColor[100],
                title: Center(
                    child: CartItemRich(
                  lightFont: 'Pick Up OTP is: ',
                  boldFont: ongoingOrder.senderOtp.toString(),
                  boldFontSize: 20,
                  lightFontSize: 15,
                )),
              ),
            ),
            SizedBox(height: 10),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Sender Name', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: ongoingOrder.senderName, size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 7),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Address', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: ongoingOrder.senderAddress, size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 7),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Placed On', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: ongoingOrder.placedOn.toDate().toLocal().toString().substring(0, 16), size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 10),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Contact', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: ongoingOrder.senderPhone, size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 7),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Email', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: ongoingOrder.senderEmail, size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 7),
            Visibility(
              visible: ongoingOrder.paymentMode == 'cash',
              child: Container(
                child: Column(
                  children: [
                    CustomListTile(
                      color: Colors.transparent,
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'Total fare', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                          SizedBox(height: 4),
                          CustomText(
                              text: '${HelperClass.naira}${(ongoingOrder.earnings).ceilToDouble().toString()}0'.replaceAllMapped(reg, mathFunc),
                              size: 14,
                              fontWeight: FontWeight.w700),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomListTile(
                      color: Colors.transparent,
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'Payment Mode', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                          SizedBox(height: 4),
                          CustomText(text: ongoingOrder.paymentMode, size: 14, fontWeight: FontWeight.w700),
                        ],
                      ),
                    ),
                    SizedBox(height: 7),
                    CustomListTile(
                      color: Colors.transparent,
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'Amount to collect', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                          SizedBox(height: 4),
                          CustomText(
                              text: '${HelperClass.naira}${(ongoingOrder.earnings).ceilToDouble().toString()}0'.replaceAllMapped(reg, mathFunc),
                              size: 14,
                              fontWeight: FontWeight.w700),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: ongoingOrder.paymentMode == 'card',
              child: CustomListTile(
                color: Colors.transparent,
                leading: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: 'Payment Mode', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                    SizedBox(height: 4),
                    CustomText(text: ongoingOrder.paymentMode, size: 14, fontWeight: FontWeight.w700),
                  ],
                ),
              ),
            )
          ],
        );
        break;
      case ViewMode.recipient:
        return Column(
          children: [
            CustomListTile(
              color: greyColor[100],
              title: Center(
                  child: CartItemRich(
                lightFont: 'Your OTP is: ',
                boldFont: ongoingOrder.recipientOtp.toString(),
                boldFontSize: 20,
                lightFontSize: 15,
              )),
            ),
            SizedBox(height: 10),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Name', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: ongoingOrder.recipientname, size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 7),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Address', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: ongoingOrder.recipientAddress, size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 7),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Placed On', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: ongoingOrder.placedOn.toDate().toLocal().toString().substring(0, 16), size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 10),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Contact', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: ongoingOrder.recipientPhone, size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 7),
            CustomListTile(
              color: Colors.transparent,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: 'Email', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                  SizedBox(height: 4),
                  CustomText(text: ongoingOrder.recipientEmail, size: 14, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            SizedBox(height: 7),
            Visibility(
              visible: ongoingOrder.paymentMode == 'cash',
              child: Container(
                child: Column(
                  children: [
                    CustomListTile(
                      color: Colors.transparent,
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'Total fare', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                          SizedBox(height: 4),
                          CustomText(
                              text: '${HelperClass.naira}${(ongoingOrder.earnings).ceilToDouble().toString()}0'.replaceAllMapped(reg, mathFunc),
                              size: 14,
                              fontWeight: FontWeight.w700),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomListTile(
                      color: Colors.transparent,
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'Payment Mode', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                          SizedBox(height: 4),
                          CustomText(text: ongoingOrder.paymentMode, size: 14, fontWeight: FontWeight.w700),
                        ],
                      ),
                    ),
                    SizedBox(height: 7),
                    CustomListTile(
                      color: Colors.transparent,
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'Amount to collect', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                          SizedBox(height: 4),
                          CustomText(
                              text: '${HelperClass.naira}${(ongoingOrder.earnings).ceilToDouble().toString()}0'.replaceAllMapped(reg, mathFunc),
                              size: 14,
                              fontWeight: FontWeight.w700),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: ongoingOrder.paymentMode == 'card',
              child: CustomListTile(
                color: Colors.transparent,
                leading: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: 'Payment Mode', color: greyColor[600], size: 12, fontWeight: FontWeight.w700),
                    SizedBox(height: 4),
                    CustomText(text: ongoingOrder.paymentMode, size: 14, fontWeight: FontWeight.w700),
                  ],
                ),
              ),
            )
          ],
        );
        break;
      default:
        return Container();
    }
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

  // void getUserDetails() async {
  //   if (mounted) {
  //     setState(() {
  //       loading = true;
  //     });
  //   }
  // }

  Future<List<CourierModel>> getServices() async {
    if (widget.loaded == true && widget.online==true){
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        setState(() {
          loading = true;
        });
        userServices.getUserById(_auth.currentUser.uid).then((value) {
          vehicleType = value.vehicleType;
          firstName = value.firstName;
          lastName = value.lastName;
          print(value.vehicleType);
        }).then((value) async {
          serviceRequests = await _courierServices.getActiveServiceRequests(vehicleType);
          if (mounted) {
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
        });
        // print(vehicleType);
        // setState(() {
        //   loading = false;
        // });
      });
    }
    return serviceRequests;
  }

  Future<void> makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> writeMessgae(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> createEmail(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  showEmailDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  width: MediaQuery.of(context).size.width,
                  // height: 200,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: 'Please type in the email to send below',
                          size: 15,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          width: MediaQuery.of(context).size.width,
                          child: LoginTextField(
                            maxLines: 4,
                            hint: 'Enter your email message',
                            controller: emailController,
                            validator: (v) {
                              if (v.isEmpty)
                                return 'email message cannot be empty';
                              else
                                return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        CustomFlatButton(
                          icon: Icons.send,
                          radius: 30,
                          text: 'Send',
                          textColor: whiteColor,
                          fontSize: 16,
                          callback: () {
                            if (formKey.currentState.validate()) {
                              createEmail(
                                      'mailto:${ongoingOrder.senderEmail}?subject=Order # ${ongoingOrder.orderNumber} follow up by ${ongoingOrder.senderName}&body=${emailController.text}')
                                  .then((value) => Navigator.pop(context));
                            }
                          },
                        )
                      ],
                    ),
                  )),
            ),
          );
        });
  }
}
