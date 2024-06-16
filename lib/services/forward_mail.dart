import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:test_drive/EmailCache/models/email.dart';

class EmailForward {
  static Future<void> forwardEmail({
    required String username,
    required String password,
    required Email originalMessage,
    required String forwardTo,
    required String forwardBody,
    required Function(String, Color) onResult,
  }) async {
    final client = SmtpClient('enough_mail', isLogEnabled: true);
    try {
      await client.connectToServer('mmtp.iitk.ac.in', 465, isSecure: true);
      await client.ehlo();

      await client.authenticate(username, password, AuthMechanism.plain);
     final forwardSubject = 'Fwd: ${originalMessage.subject }';

  final builder = MessageBuilder.prepareForwardMessage(
        originalMessage as MimeMessage,
        forwardHeaderTemplate: 'Forwarded message',
        quoteMessage: true,
        subjectEncoding: HeaderEncoding.Q,
        forwardAttachments: true,
      );
      
    builder.subject = forwardSubject;
      builder.text = forwardBody;

      final mimeMessage = builder.buildMimeMessage();
      final sendResponse = await client.sendMessage(mimeMessage);

      if (sendResponse.isOkStatus) {
        onResult('Email forwarded successfully', Colors.green);
      } else {
        onResult('Failed to forward email: Failed to establish connection with server', Colors.red);
      }
    } catch (e) {
      onResult('Failed to forward email: $e', Colors.red);
    } finally {
      await client.quit();
    }
  }
}