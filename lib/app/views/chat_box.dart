import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/utils.dart';

import '../../main.dart';

class ChatBox extends StatelessWidget {
  final SourceId deviceId;
  final String teks;
  final String logTime;
  const ChatBox(
      {Key? key,
        required this.deviceId,
        required this.teks,
        required this.logTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    setAlignmentAndColorBySource(deviceId);

    return Row(
      mainAxisAlignment: chatBoxAlignment,
      // mainAxisAlignment: deviceId == SourceId.statusId
      //     ? MainAxisAlignment.center
      //     : deviceId == SourceId.hostId ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: GestureDetector(
            onLongPress: () {
              ctrl.logTextEditingController.clear();
              ctrl.logTextEditingController.value = ctrl.logTextEditingController.value.copyWith(
                text: teks.trim(),
                selection: TextSelection.collapsed(offset: teks.length),
              );
            },
            child: Stack(
              children: [
                Card(
                  color: chatBoxColor,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0, top: 2.0, right: 8.0, bottom: 2.0
                    ),
                    child: Column(
                      //     crossAxisAlignment: deviceId == SourceId.statusId
                      //         ? CrossAxisAlignment.center
                      //         : CrossAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(teks.trim(), style: TextStyle(color: chatBoxColor),),
                        Text(
                          logTime,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                Card(
                  color: chatBoxColor,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 2.0, right: 8.0, bottom: 2.0
                    ),
                    child: Text(teks.trim(), style: const TextStyle(color: Colors.white, fontSize: 14),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/**
class ChatBox extends StatelessWidget {
  final SourceId deviceId;
  final String teks;
  final String logTime;
  const ChatBox(
      {Key? key,
      required this.deviceId,
      required this.teks,
      required this.logTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    setAlignmentAndColorBySource(deviceId);

    return Row(
      mainAxisAlignment: deviceId == SourceId.statusId
          ? MainAxisAlignment.center
          : deviceId == SourceId.hostId ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              constraints: const BoxConstraints(maxWidth: maxLogContainerWidth),
              padding: const EdgeInsets.only(
                  left: 8.0, top: 2.0, right: 8.0, bottom: 2.0
              ),
              decoration: BoxDecoration(
                  color: chatBoxColor,
                  borderRadius: BorderRadius.circular(7.0)
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: deviceId == SourceId.statusId
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.end,
                children: [
                  Text(teks.trim(),
                    softWrap: true,
                    // style: TextStyle(color: Colors.yellowAccent),
                    style: TextStyle(color: chatBoxColor),
                  ),
                  Text(
                    logTime,
                    style: const TextStyle(
                      fontSize: 10.0,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.only(bottom: 4),
              constraints: const BoxConstraints(maxWidth: maxLogContainerWidth),
              padding: const EdgeInsets.only(
                  left: 8.0, top: 2.0, right: 8.0, bottom: 2.0
              ),
              decoration: BoxDecoration(
                  color: chatBoxColor,
                  // color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(7.0)
              ),
              child: Text(teks.trim(),
                softWrap: true,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

**/
