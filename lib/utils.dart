
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'app/views/main_view.dart';

// const int hostId = 0;   // 0 --> untuk id device host (flutter)
// const int clientId = 1; // 1 --> untuk id device client (ESP32)
// const int statusId = 2; // 2 --> untuk id status
enum SourceId {hostId, clientId, statusId}

late Color chatBoxColor;
late MainAxisAlignment chatBoxAlignment;

String getCurrentDateTime() {
  return DateFormat('y-MM-dd').add_Hms().format(DateTime.now());
}

void setAlignmentAndColorBySource(SourceId sourceId) {
  if (sourceId == SourceId.hostId) {
    chatBoxAlignment = MainAxisAlignment.end;
    chatBoxColor = Colors.blue;
  }
  else if (sourceId == SourceId.clientId) {
    chatBoxAlignment = MainAxisAlignment.start;
    chatBoxColor = Colors.black;
  }
  else {
    chatBoxAlignment = MainAxisAlignment.center;
    chatBoxColor = Colors.grey;
  }
}

showGetxSnackbar(String title, String description) {
  Get.snackbar(
    title,
    '',
    messageText: Text(description, style: const TextStyle(fontSize: 16),),
    backgroundColor: Colors.white.withOpacity(0.6),
    duration: const Duration(seconds: 2)
  );
}

// Method to show a SnackBar, taking message as the text
Future showSnackBar(String message, {Duration duration = const Duration(seconds: 3),}) async {
  await Future.delayed(const Duration(milliseconds: 100));

  ScaffoldMessenger.of(scaffoldKey.currentContext!).hideCurrentSnackBar();
  ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      duration: duration,
    ),
  );
}