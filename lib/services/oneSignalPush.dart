import 'dart:convert';
import 'dart:io';

import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' show Client;

Client client = Client();

class OneSignalPush {
  Future sendNotification(BuildContext context, String userIds, String message, heading) async {
    String url = HelperClass.oneSignalPostUrl;

    try {
      final response = await client.post(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Basic ${HelperClass.oneSignalRestApiKey}",
          },
          body: jsonEncode(
            {
              "app_id": HelperClass.oneSignalAppId,
              // "included_segments": ["Subscribed Users"],
              "include_external_user_ids": [userIds],
              "channel_for_external_user_ids": "push",
              "data": {"foo": "bar"},
              "contents": {"en": message},
              "headings": {"en": heading}
            },
          ));
      final Map result = json.decode(response.body);
      print('ACCEPTEEEEEED');
      // Fluttertoast.showToast(msg: 'Message Placed');
      // print(result);
      if (response.statusCode == 201) {}
    } catch (e) {
      print(e.toString());
    }
  }
}
