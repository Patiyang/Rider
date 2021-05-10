import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  String email = 'noreply@armotale.com';
  String password = 'Kinyanju1!';
  String name = 'Armotale';
  Future sendPickUpOtp(String senderEmail, String senderOtp, String senderName, String orderNumber) async {
    final smtpServer = gmail(email, password);
    String messageText = 'Dear $senderName the OTP for task #$orderNumber is $senderOtp please present this to our pilot to start the Pick Up';

    final message = Message()
      ..from = Address(email, name)
      ..recipients.add(senderEmail)
      // ..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'This is an OTP for task #$orderNumber'
      ..text = messageText;
    // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      print(e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  Future sendDropOffOtp(String recipientEmail, String recipientOtp, String recipientName, String orderNumber) async {
    final smtpServer = gmail(email, password);
    String messageText = 'Dear $recipientName the OTP for task #$orderNumber is $recipientOtp please present this to our pilot to start the Pick Up';

    final message = Message()
      ..from = Address(email)
      ..recipients.add(recipientEmail)
      // ..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'This is an OTP for task #$orderNumber'
      ..text = messageText;
    // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent to Recipient: $recipientName: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      print(e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  Future sendWelcomeEmail(String names, String recipientEmail) async {
    final smtpServer = gmail(email, password);
    String messageText = 'Dear $names We are really pleased to have you as one of ours';

    final message = Message()
      ..from = Address(email, name)
      ..recipients.add(recipientEmail)
      // ..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'Welcome to the Armotale team $names, it\'s nice to have you here'
      ..text = messageText
      ..html = HelperClass.welcomeHtml;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent to Recipient: $names: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      print(e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
