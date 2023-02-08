import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/utils.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import '../../bluetooth_data.dart';
import '../models/messages.dart';

class Controller extends GetxController {
  // -------- for data logs view command histories ---------------
  var currentLeftMargin = 0.0.obs;
  // final cmdListHistory = RxList<TextButton>([]).obs;
  final cmdListHistory = <String>[].obs;

  late TabController tabController;
  final TextEditingController logTextEditingController = TextEditingController();
  static const int _totalTab = 3;
  Timer? logTimer;
  int logHeaderDuration = 2000;
  var devIndex = 0.obs;

  var selectedTabIndex = 0.obs;
  var isBluetoothActive = false.obs;
  var isConnected = false.obs;
  var selectedDevice = ''.obs;
  var isConnecting = false.obs;
  var isAutoReconnect = true.obs;
  var isLogAsChatView = true.obs;
  RxBool showStickyHeaderLog = false.obs;

  // RxList<DropdownMenuItem<BluetoothDevice>> deviceItems = <DropdownMenuItem<BluetoothDevice>>[].obs;
  // final deviceItems = RxList<DropdownMenuItem<BluetoothDevice>>([]).obs;
  final deviceItems = RxList<BluetoothDevice>([]).obs;

  // RxList<Message> logs = RxList([]);
  // RxList<Message> logs = List<Message>[].obs;
  // List<Message> logs = List<Message>[].obs;

  // final logs = Rx<List<Message>>([]); // work to update logs view after insert new data, but should call refresh method after insert new data
  final logs = RxList<Message>([]).obs;  // work too. to insert data --> logs.value.add() and then refresh --> logs.refresh()

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    debugPrint('[global_controller] global controller ready');
  }

  @override
  void onInit() {
    super.onInit();
    refreshDeviceList();
  }

  // Create the List of devices to be shown in Dropdown Menu
  void refreshDeviceList() {
    deviceItems.value.clear();

    // if (BluetoothData.instance.devicesList.isEmpty) {
    //   deviceItems.value.add(const DropdownMenuItem(child: Text('NONE')));
    // } else {
    //   for (var device in BluetoothData.instance.devicesList) {
    //     deviceItems.value.add(DropdownMenuItem(value: device, child: Text(device.name!)));
    //   }
    // }
    if (BluetoothData.instance.devicesList.isEmpty) {
      deviceItems.value.add(const BluetoothDevice(address: '', name: 'NONE'));
    } else {
      for (var device in BluetoothData.instance.devicesList) {
        deviceItems.value.add(device);
      }
    }

    deviceItems.refresh();
    debugPrint('[global_controller] controller device items: ${deviceItems.value.length}');
  }

  void refreshLogs({SourceId sourceId=SourceId.statusId, required String text}) {
    logs.value.add(Message(whom: sourceId, text: text, logTime: DateTime.tryParse(getCurrentDateTime())!));
    logs.refresh();
    debugPrint('[global_controller] refresh logs called');
  }

  void initTabController(TickerProvider tickerProvider) {
    tabController = TabController(length: _totalTab, vsync: tickerProvider);

    tabController.addListener(() {
      if (tabController.indexIsChanging || selectedTabIndex.value != tabController.index) {
        selectedTabIndex.value = tabController.index;
        debugPrint('[global_controller] Selected Index: $selectedTabIndex');

        if (selectedTabIndex.value != 1) { // hide keyboard if tab position is not equal 1 / not in data logs view
          FocusManager.instance.primaryFocus?.unfocus();
        }
      }
    });
  }

  void resetLogTimer() {
    showStickyHeaderLog.value = true;
    logHeaderDuration = 2000;
    logTimer?.cancel(); // if log timer not null and still active, stop current log timer
  }

  void startLogTimer() {
    debugPrint('[global_controller] starting log timer...');

    const oneHundred = Duration(milliseconds: 100); // tick every 100 milisecond
    logTimer = Timer.periodic(oneHundred, (Timer timer) {
        // debugPrint('[global_controller] floating date header hiding in: $logTmerStart');

        if (logHeaderDuration <= 0) {
          showStickyHeaderLog.value = false;
          timer.cancel();
          debugPrint('[global_controller] log timer done...');
        } else {
          logHeaderDuration -= 100;
        }
      },
    );
  }

  @override
  void onClose() {
    tabController.dispose();
    logTimer?.cancel();
    logTextEditingController.dispose();
    super.onClose();
  }

}
