import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/models/courierModel.dart';
import 'package:delivery_boy/services/courierServices.dart';
import 'package:delivery_boy/views/home/home_main.dart';
import 'package:delivery_boy/widgets&helpers/helpers/changeScreen.dart';
import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customButton.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customText.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  CourierServices _courierServices = new CourierServices();
  List<CourierModel> earningList = [];
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  double totalEarnings = 0;
  @override
  void initState() {
    super.initState();
    getDriverEarnings();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0), // here the desired height
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppBar(
              backgroundColor: primaryColor,
              automaticallyImplyLeading: false,
              centerTitle: true,
              elevation: 0.0,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Total Earnings',
                    style: bigWhiteHeadingStyle,
                  ),
                  heightSpace,
                  Text(
                    '${HelperClass.naira}${totalEarnings.ceilToDouble()}0'.replaceAllMapped(reg, mathFunc),
                    style: whiteHeadingStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: width,
        height: height,
        color: primaryColor,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10.0),
              topLeft: Radius.circular(10.0),
            ),
            color: scaffoldBgColor,
          ),
          child: earningList.length == 0
              ? Center(
                  child: RefreshIndicator(
                  onRefresh: () async {
                    await getDriverEarnings();
                    Fluttertoast.showToast(msg: 'Your earnings are upto date');
                  },
                  child: ListView(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 220,
                      ),
                      Center(
                        child: CustomText(
                          text: 'You have no earnings yet',
                          size: 18,
                          letterSpacing: .2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // CustomFlatButton(
                      //   radius: 30,
                      //   text: 'Get Orders',
                      //   color: primaryColor,
                      //   fontSize: 17,
                      //   fontWeight: FontWeight.w600,
                      //   textColor: whiteColor,
                      //   callback: () => changeScreenReplacement(context, HomeMain()),
                      // )
                    ],
                  ),
                ))
              : RefreshIndicator(
                  onRefresh: () async {
                    getDriverEarnings();
                  },
                  child: ListView.builder(
                    itemCount: earningList.length,
                    // physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = earningList[index];
                      return Container(
                        padding: (index == 0)
                            ? EdgeInsets.only(right: fixPadding, left: fixPadding, bottom: fixPadding, top: fixPadding * 2.0)
                            : EdgeInsets.only(right: fixPadding, left: fixPadding, bottom: fixPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(fixPadding),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.fastfood,
                                        size: 25.0,
                                        color: primaryColor,
                                      ),
                                      widthSpace,
                                      Text(item.packageType, style: headingStyle),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text('${item.earnings.ceilToDouble()}0'.replaceAllMapped(reg, mathFunc), style: greyHeadingStyle),
                                      SizedBox(height: 5.0),
                                      Text('Earning', style: appbarHeadingStyle),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Future getDriverEarnings() async {
    earningList.clear();
    totalEarnings = 0;
    earningList = await _courierServices.getEarningHistory();
    for (int i = 0; i < earningList.length; i++) {
      totalEarnings += earningList[i].earnings;
    }
    print(totalEarnings.toString());
    setState(() {});
  }
}
