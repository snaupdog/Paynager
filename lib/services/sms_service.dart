import 'dart:io';
import 'package:easy_sms_receiver/easy_sms_receiver.dart';

class SmsService {
  final EasySmsReceiver _receiver = EasySmsReceiver.instance;

  bool get supported => Platform.isAndroid;

  void listen(void Function(String message) onMessage) {
    if (!supported) return;

    _receiver.listenIncomingSms(
      onNewMessage: (msg) => onMessage(msg.body ?? ""),
    );
  }
}

