// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:async';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:flutter_bluetooth/utils.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import '../../bluetooth_data.dart';
import '../../main.dart';
import 'chat_box.dart';
import '../models/messages.dart';

bool showHistory = false;

class DataLogs extends StatelessWidget {
  const DataLogs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Obx(() {
      return Column(
        children: [
          ctrl.isLogAsChatView.isTrue
          ? buildChatLogViews()
          : buildStandardLogViews(),

          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            margin: EdgeInsets.only(left: ctrl.currentLeftMargin.value),
            height: 36,
            width: Get.width,
            // decoration: BoxDecoration(
                // border: Border.all(color: Colors.green),
                // borderRadius: const BorderRadius.horizontal(left: Radius.circular(20))
            // ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    showHistory = !showHistory;
                    if (showHistory) {
                      if (ctrl.currentLeftMargin.value > 0) {
                        ctrl.currentLeftMargin.value = 0;
                      }
                    } else {
                      if (ctrl.currentLeftMargin.value < Get.width - 44) {
                        ctrl.currentLeftMargin.value = Get.width - 44;
                      }
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 36,
                    decoration: const BoxDecoration(
                      // border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(20))
                    ),
                    child: const Icon(Icons.history),
                  ),
                ),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...showCommandHistories()
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6,),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl.logTextEditingController,
                    decoration: const InputDecoration(
                      hintText: 'Type command here',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(left: 8)
                    ),
                  )
                ),
                const SizedBox(width: 10,),
                IconButton(
                    onPressed: () {
                      if (ctrl.logTextEditingController.text.isNotEmpty) {
                        sendMessage();
                      }
                    },
                    icon: const Icon(Icons.send)
                )
              ],
            ),
          )
        ],
      );
    });
  }

  Widget buildStandardLogViews() {
    final List<Text> logList = ctrl.logs.value.reversed.map((message) {
      return Text('${DateFormat('Hms').format(message.logTime)}: ${message.text}',
        style: TextStyle(
          color: message.whom == SourceId.hostId ? Colors.blue : message.whom == SourceId.clientId ? Colors.black : Colors.green
        ),
      );
    }).toList();

    return Expanded(
      child: ListView(
        reverse: true,
        padding: const EdgeInsets.all(12.0),
        controller: listScrollController,
        children: logList,
      ),
    );
  }

  Widget buildChatLogViews() {
    return
      Expanded(
        child: NotificationListener(
          onNotification: (t) {
            if (t is ScrollStartNotification) {
              // print('');
              // print('scroling');
              ctrl.resetLogTimer();
            }
            else if (t is ScrollEndNotification) {
              // print('scroll stopped');
              // print(_listScrollController.position.pixels);
              if (ctrl.showStickyHeaderLog.isTrue) {
                ctrl.startLogTimer();
              }
            }

            return true;
          },
          child: GroupedListView<Message, DateTime>(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12.0),
            reverse: true,
            order: GroupedListOrder.DESC,
            // itemComparator: (date1, date2) => date1.logTime.compareTo(date2.logTime),
            useStickyGroupSeparators: ctrl.showStickyHeaderLog.value,
            floatingHeader: ctrl.showStickyHeaderLog.value,
            elements: ctrl.logs.value,
            groupBy: (message) => DateTime(
              message.logTime.year,
              message.logTime.day,
              // message.logTime.minute,
            ),
            groupHeaderBuilder: (Message message) => FittedBox(
              fit: BoxFit.scaleDown,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    DateFormat('d MMM y').format(message.logTime),
                    // DateFormat('mm').format(message.logTime),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            itemBuilder: (context, Message message) {
              return ChatBox(key: UniqueKey(), deviceId: message.whom, teks: message.text, logTime: DateFormat('Hms').format(message.logTime));
            },
          ),
        ),
      );
  }

  void sendMessage() {
    String text = ctrl.logTextEditingController.text.trim();
    ctrl.logTextEditingController.clear();

    if (text.isNotEmpty) {
      try {
        // BluetoothData.instance.connection!.output
        //     .add(Uint8List.fromList(utf8.encode("$text\r\n")));
        // await BluetoothData.instance.connection!.output.allSent;
        // final logTime = getCurrentDateTime();
        BluetoothData.instance.sendMessageToBluetooth(text, false);
        ctrl.refreshLogs(sourceId: SourceId.hostId, text: text);
        addNewCommandHistories(text);

        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if(listScrollController.hasClients){
        //     listScrollController.animateTo(
        //         // listScrollController.position.maxScrollExtent,
        //         listScrollController.position.minScrollExtent,
        //         duration: const Duration(milliseconds: 500), curve: Curves.easeInOut
        //     );
        //   }
        // });
      } catch (e) {
        // Ignore error, but notify state
        debugPrint('[data_logs] send message error: $e');
        ctrl.refreshLogs(sourceId: SourceId.hostId, text: 'send message error: $e');
      }
    }
  }

  buildHistoryCommandContainer(String teks) {
    return TextButton(
        onPressed: () {
          ctrl.logTextEditingController.text = teks;
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.only(left: 6, right: 6),
          backgroundColor: AppColors.inActiveButton,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.inActiveButton),
            borderRadius: BorderRadius.circular(25),
          ),
          // fixedSize: const Size.fromHeight(20)
        ),
        child: Text(teks,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        )
    );
  }

  // addNewCommandHistories(String teks) {
  //   if (ctrl.cmdListHistory.value.length >= maxCommandHistoryCount) {
  //     ctrl.cmdListHistory.value.removeAt(maxCommandHistoryCount - 1);
  //
  //   ctrl.cmdListHistory.value.insert(0, buildHistoryCommandContainer(teks));
  // }

  // List<Row> showCommandHistories() {
  //   return ctrl.cmdListHistory.value.map<Row>((command) {
  //     return Row(
  //       children: [
  //         SizedBox(height: 30, child: command),
  //         const SizedBox(width: 6,)
  //       ],
  //     );
  //   }).toList();
  // }

  addNewCommandHistories(String teks) {
    int newCommandIndex = ctrl.cmdListHistory.indexOf(teks);

    // if new command not exists
    if (newCommandIndex < 0) {
      if (ctrl.cmdListHistory.length >= maxCommandHistoryCount) {
        ctrl.cmdListHistory.removeAt(maxCommandHistoryCount - 1);
      }
    } else {
      // if new command already exists, remove old command
      ctrl.cmdListHistory.removeAt(newCommandIndex);
    }

    ctrl.cmdListHistory.insert(0, teks);
  }

  List<Row> showCommandHistories() {
    return List.generate(ctrl.cmdListHistory.length, (index) {
      return Row(
        children: [
          SizedBox(height: 30, child: buildHistoryCommandContainer(ctrl.cmdListHistory[index])),
          const SizedBox(width: 6,)
        ],
      );
    });
  }

}
