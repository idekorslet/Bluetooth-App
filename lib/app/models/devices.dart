import 'dart:convert';
import 'package:flutter_bluetooth/main.dart';

import 'commands.dart';

class Devices {
  String deviceName;
  // final Color logColor;
  bool status;
  List<Commands> commandList;

  Devices({required this.deviceName, required this.status,
    // required this.deviceLogText,
    required this.commandList});

  set setNewDeviceName(String newDeviceName) => deviceName = newDeviceName;
  // set setNewCommandList(List<Commands> newCommandList) => commandList = newCommandList;
}

class DeviceManager {
  // singleton
  DeviceManager._privateConst();
  static final DeviceManager instance = DeviceManager._privateConst();
  factory DeviceManager() => instance;

  String _deviceListInString = "";
  final List<bool> _statusList = [];

  List<bool> get getStatusDeviceList => _statusList;

  int get getDeviceCount {
    final String devListJsonString = prefs.getString('deviceList') ?? '{}';
    final devicesMap = json.decode(devListJsonString);
    return devicesMap.length;
  }

  void saveDeviceListIntoStorage(List<Devices> deviceList) async {
    Map<String, dynamic> dev = {};
    List<String> allCommand = [];

    for (final device in deviceList) {
      // extract command list in the current device into map string
      // int i=0;
      allCommand.clear();
      for (final cmd in device.commandList) {
        final currentCommand = cmd.toJson();
        // print('');
        // print('[devices] command index:[$i].toJson() in ${device.deviceName}');
        // print(currentCommand);

        final cmdString = json.encode(currentCommand);
        // print('after encode');
        // print(cmdString);
        // print(cmdString.runtimeType);
        // i++;

        allCommand.add(cmdString);
      }

      // print('');
      dev[device.deviceName] = {
        "deviceName": device.deviceName,
        "status": device.status.toString(),
        "commandList": allCommand.toString()
      };
      // print(allCommand);
      // print('dev value');
      // print(dev);
    }
    // print('[devices] after encode');
    // final allDev = json.encode(dev);
    // print(allDev);
    // print(allDev.runtimeType);
    _deviceListInString = json.encode(dev);
    await prefs.setString('deviceList', _deviceListInString);
  }

  List<Devices> loadDeviceListFromStorage() {
    List<Devices> allDevice = [];
    List<Commands> commandList = [];

    final String devListJsonString = prefs.getString('deviceList') ?? '{}';
    final devicesMap = json.decode(devListJsonString);
    // print(devicesMap);
    // print('devicesMap.runtime type: ${devicesMap.runtimeType}');
    // print('devicesMap.length: ${devicesMap.length}');
    // print('');
    for (final devName in devicesMap.keys) {
      // print('command list in device: $devName');

      // convert command list into map
      commandList = [];
      for (final cmdList in json.decode(devicesMap[devName]["commandList"])) {
        // print(cmdList);
        // print(cmdList.runtimeType);
        // print(json.encode(cmdList));
        // print('');
        commandList.add(Commands.fromJson(cmdList));
      }

      // print('[devices] device map');
      // print(devicesMap[devName]["status"]);
      allDevice.add(
          Devices(
            deviceName: devName,
            status: devicesMap[devName]["status"] == 'true' ? true : false,
            commandList: commandList,
          )
      );

      _statusList.add(devicesMap[devName]["status"] == 'true' ? true : false);
    }

    return allDevice;
  }
}