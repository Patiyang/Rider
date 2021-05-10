import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/models/courierModel.dart';
import 'package:delivery_boy/services/courierServices.dart';
import 'package:delivery_boy/views/home/historyDetails.dart';
import 'package:delivery_boy/widgets&helpers/helpers/changeScreen.dart';
import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customText.dart';
import 'package:delivery_boy/widgets&helpers/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  CourierServices _courierServices = new CourierServices();
  List<CourierModel> driverOrderHistory = [];
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  bool loading = true;
  @override
  void initState() {
    super.initState();
    getDriverOrderHistory();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return driverOrderHistory.length == 0
        ? Container(
            child: Center(
              child: loading==true? Loading(text: 'Updating your history',) :RefreshIndicator(
                onRefresh: () async {
                  await getDriverOrderHistory();
                  Fluttertoast.showToast(msg: 'Your order history is upto date');
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
            ),
          )
        : ListView.builder(
            itemCount: driverOrderHistory.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = driverOrderHistory[index];
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
                                        Text('#${item.orderNumber}', style: headingStyle),
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
                                    InkWell(
                                      onTap: () =>changeScreen(context, HistoryDetails(serviceId: item.serviceId,)),
                                      borderRadius: BorderRadius.circular(25.0),
                                      child: Container(
                                        height: 40.0,
                                        width: 100.0,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(25.0),
                                          color: primaryColor,
                                        ),
                                        child: Text(
                                          'View Progress',
                                          style: wbuttonWhiteTextStyle,
                                        ),
                                      ),
                                    ),
                                    heightSpace,
                                    Text('Payment', style: lightGreyStyle),
                                    Text('${HelperClass.naira}${item.earnings.ceilToDouble()}0'.replaceAllMapped(reg, mathFunc), style: headingStyle),
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

  getDriverOrderHistory() async {
    setState(() {
      loading = true;
    });
    driverOrderHistory = await _courierServices.getDriverOrderHistory();
        setState(() {
        loading = false;
      });
  }
}
