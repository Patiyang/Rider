import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/models/courierModel.dart';
import 'package:delivery_boy/services/courierServices.dart';
import 'package:delivery_boy/services/userServices.dart';
import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customListTIle.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customText.dart';
import 'package:delivery_boy/widgets&helpers/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HistoryDetails extends StatefulWidget {
  final String serviceId;

  const HistoryDetails({Key key, this.serviceId}) : super(key: key);
  @override
  _HistoryDetailsState createState() => _HistoryDetailsState();
}

class _HistoryDetailsState extends State<HistoryDetails> {
  CourierServices _courierServices = new CourierServices();
  UserServices userServices = new UserServices();
  FirebaseAuth auth = FirebaseAuth.instance;
  CourierModel singleService;
  bool loading = false;
  String profilePicture = '';
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  @override
  void initState() {
    getHistoryDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return singleService == null
        ? Container(
            color: whiteColor,
            child: loading == true
                ? Loading(
                    text: '',
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await getHistoryDetails();
                      Fluttertoast.showToast(msg: 'Order details for #${singleService.orderNumber} are upto date');
                    },
                    child: ListView(
                      children: [
                        SizedBox(height: 220),
                        Center(
                          child: CustomText(
                              textAlign: TextAlign.center,
                              text: 'You have no items in your history, swipe down to refresh',
                              maxLines: 2,
                              size: 20,
                              letterSpacing: .2,
                              fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
          )
        : Scaffold(
            appBar: AppBar(
              title: CustomText(
                text: 'Order details for ' + singleService.senderName,
                color: whiteColor,
              ),
            ),
            body: RefreshIndicator(
                onRefresh: () async {
                  await getHistoryDetails();
                  Fluttertoast.showToast(msg: 'Order details for #${singleService.orderNumber} are upto date');
                },
                child: ListView(
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: ClipOval(
                        child: Container(
                          width: 120.0,
                          height: 120.0,
                          child: profilePicture == null ? Image.asset(HelperClass.noImage) : Image.network(profilePicture, fit: BoxFit.cover),
                          decoration: BoxDecoration(
                            color: blackColor,
                            // shape: BoxShape.circle,
                            //  border: Border.all(color: whiteColor),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomListTile(
                      title: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.amber[400], borderRadius: BorderRadius.all(Radius.circular(10))),
                            child: CustomText(
                              text: 'Accepted On:',
                              color: whiteColor,
                            ),
                          ),
                          SizedBox(width: 20),
                          CustomText(
                              text: singleService.acceptedTransitOn == null
                                  ? 'TBD'
                                  : DateTime.fromMillisecondsSinceEpoch(singleService.acceptedTransitOn).toString().substring(0, 16),
                              fontWeight: FontWeight.w600)
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomListTile(
                      title: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.purple[400], borderRadius: BorderRadius.all(Radius.circular(10))) ?? '',
                            child: CustomText(
                              text: 'Started Transit On:',
                              color: whiteColor,
                            ),
                          ),
                          SizedBox(width: 20),
                          CustomText(
                              text: singleService.startedTransitOn == null
                                  ? 'TBD'
                                  : DateTime.fromMillisecondsSinceEpoch(singleService.startedTransitOn).toString().substring(0, 16),
                              fontWeight: FontWeight.w600)
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomListTile(
                      title: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.green[400], borderRadius: BorderRadius.all(Radius.circular(10))),
                            child: CustomText(
                              text: 'Completed Transit On:',
                              color: whiteColor,
                            ),
                          ),
                          SizedBox(width: 20),
                          CustomText(
                              text: singleService.completedTransitON == null
                                  ? 'TBD'
                                  : DateTime.fromMillisecondsSinceEpoch(singleService.completedTransitON).toString().substring(0, 16) ?? '',
                              fontWeight: FontWeight.w600)
                        ],
                      ),
                    ),
                    CartItemRich(
                      lightFont: 'Placed On: ',
                      boldFont: singleService.placedOn.toDate().toString().substring(0, 16),
                      lightFontSize: 13,
                      boldFontSize: 15,
                    ),
                    SizedBox(height: 5),
                    CartItemRich(
                      lightFont: 'Sender Name: ',
                      boldFont: singleService.senderName,
                      lightFontSize: 13,
                      boldFontSize: 15,
                    ),
                    SizedBox(height: 5),
                    CartItemRich(
                      lightFont: 'Recipient Name: ',
                      boldFont: singleService.recipientname,
                      lightFontSize: 13,
                      boldFontSize: 15,
                    ),
                    SizedBox(height: 5),
                    CartItemRich(
                      lightFont: 'Payment Mode: ',
                      boldFont: singleService.paymentMode,
                      lightFontSize: 13,
                      boldFontSize: 15,
                    ),
                    SizedBox(height: 5),
                    CartItemRich(
                      lightFont: 'Package Type: ',
                      boldFont: singleService.packageType,
                      lightFontSize: 13,
                      boldFontSize: 15,
                    ),
                    SizedBox(height: 5),
                    CartItemRich(
                      lightFont: 'Earnings: ',
                      boldFont: '${HelperClass.naira}${singleService.earnings.ceilToDouble()}0'.replaceAllMapped(reg, mathFunc),
                      lightFontSize: 13,
                      boldFontSize: 15,
                    ),
                    SizedBox(height: 10),
                  ],
                )),
          );
  }

  Future getHistoryDetails() async {
    setState(() {
      loading = true;
    });
    singleService = await _courierServices.getHistoryServiceDetails(widget.serviceId);
    getCurrentUserDetails();
    setState(() {
      loading = false;
    });
  }

  getCurrentUserDetails() async {
    await userServices.getUserById(auth.currentUser.uid).then((value) {
      print(value.phoneNumber);
      setState(() {
        profilePicture = value.profilePicture;
      });
    });
  }
}
