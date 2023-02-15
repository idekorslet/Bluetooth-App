import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:flutter_bluetooth/app/controllers/command_controller.dart';
import 'package:flutter_bluetooth/app/helper/command_menu.dart';
import 'package:flutter_bluetooth/app/helper/popup_dialogs.dart';
import 'package:flutter_bluetooth/app/models/devices.dart';
import 'package:flutter_bluetooth/app/views/add_device_view.dart';
import 'package:flutter_bluetooth/main.dart';
import 'package:get/get.dart';
import '../../utils.dart';

class DeviceController extends GetxController {
  static var isInsertNewDevice = false;
  static var isEditDevice = false;
  static bool isSaveDeviceBtnClicked = false;
  static var enableNewCommandBtn = false.obs;
  static var enableSaveDeviceBtn = false.obs;
  static RxList<Devices> deviceList = <Devices>[].obs;
  static Devices? currentDevice;
  static int deviceIndex = -1;
  static int deviceCount = 0;
  static Map<String, dynamic> oldDeviceData = {};

  static TextEditingController deviceNameController = TextEditingController();
  static TextEditingController turnOnTextController = TextEditingController();
  static TextEditingController turnOffTextController = TextEditingController();

  static String selectedTitle = '';
  static RxString errorText = ''.obs;
  // static List<CommandMenu> cmdMenuList = <CommandMenu>[].obs;
  // static List<TextEditingController> commandMenuTextCtrlList = List<TextEditingController>.empty(growable: true).obs;

  // this method called when editing the device name textfield
  // method ini dipanggil ketika mengedit nama device
  static void refreshNewCommandButtonState() {
    enableNewCommandBtn.value = false;

    if (deviceNameController.text.length < 3) {
      errorText.value = 'Device name minimal 3 character';
    } else {
      errorText.value = '';
      int newDevIndex = deviceList.indexWhere((element) => element.deviceName == deviceNameController.text);

      if ((isInsertNewDevice && newDevIndex > -1)
          || (isEditDevice && newDevIndex > -1 && deviceNameController.text != oldDeviceData['oldDevice']['deviceName'])
      ) {
        errorText.value = 'Device name already used';
      } else {
        if (currentDevice != null) {
          if (currentDevice!.commandList.length < maxCommandCount) {
            enableNewCommandBtn.value = true;
          }
        } else {
          enableNewCommandBtn.value = true;
        }
      }
    }
  }

  static void loadDeviceListFromStorage({bool isLoadFromInitApp=true}) {
    if (isLoadFromInitApp) {
      deviceList.clear();
      deviceList.addAll(DeviceManager.instance.loadDeviceListFromStorage());
      ctrl.refreshLogs(text: 'Devices loaded from storage on app start', sourceId: SourceId.statusId);
    } else {
      showConfirmDialog(
          context: Get.context!,
          title: 'Reload devices confirm',
          text: 'Reload all device from storage?'
              '\nDevice count in storage: ${DeviceManager.instance.getDeviceCount}',
          onOkPressed: () {
            Navigator.pop(Get.context!);
            deviceList.clear();
            deviceList.addAll(DeviceManager.instance.loadDeviceListFromStorage());
            ctrl.refreshLogs(text: 'Devices loaded from storage', sourceId: SourceId.statusId);
            showGetxSnackbar('Device loaded', 'Device loaded from storage');
          }
      );
    }
    // deviceStateList.clear();
    // deviceStateList.addAll(DeviceManager.instance.getStatusDeviceList);

    // print('[device_controller] device state list');
    // print(deviceStateList.toString());
  }

  static void saveDeviceListIntoStorage() {
    showConfirmDialog(
        context: Get.context!,
        title: 'Save devices confirm',
        text: 'Save all device into storage?',
        onOkPressed: () {
          Navigator.pop(Get.context!);
          DeviceManager.instance.saveDeviceListIntoStorage(deviceList);
          ctrl.refreshLogs(text: 'Devices saved into storage', sourceId: SourceId.statusId);
          showGetxSnackbar('Device saved', 'Devices saved into storage OK');
        }
    );
  }

  static void createNewDevice() {
    isInsertNewDevice = true;
    isEditDevice = false;
    enableSaveDeviceBtn.value = false;
    enableNewCommandBtn.value = false;
    currentDevice = null;
    isSaveDeviceBtnClicked = false;
    deviceCount = deviceList.length;
    deviceNameController.clear();
    CommandController.commandMenuList.clear();
  }

  static void editDevice() {
    isSaveDeviceBtnClicked = false;
    isInsertNewDevice = false;
    isEditDevice = true;
    errorText.value = '';

    currentDevice = deviceList[deviceIndex];
    oldDeviceData['oldDevice'] = {
      'deviceName': currentDevice!.deviceName,
      'commandList': [...currentDevice!.commandList],
    };

    deviceNameController.text = currentDevice!.deviceName;

    if (currentDevice!.commandList.length < maxCommandCount) {
      enableNewCommandBtn.value = true;
    } else {
      enableNewCommandBtn.value = false;
    }

    CommandController.commandMenuList.clear();
    // CommandController.commandMenuList.addAll(oldDeviceData['oldDevice']['commandMenuList']);

    // memvisualisasikan model command
    int index = 0;
    for (final cmd in currentDevice!.commandList) {
      CommandController.commandTextEditCtrlList[index].text = cmd.command;
      CommandController.commandMenuList.add(
          CommandMenu(
            // index: commandId,
            titleText: cmd.title,
            commandText: cmd.command,
            readOnly: true,
            commandController: CommandController.commandTextEditCtrlList[index],
            onDeleteButtonPressed: DeviceController.deleteSelectedCommand,
            onEditButtonPressed: DeviceController.editSelectedCommand,
          )
      );
      index++;
    }
  }

  static void refreshSaveDeviceButtonState() {
    if (currentDevice != null) {
      if (currentDevice!.commandList.length < minCommandCount || errorText.isNotEmpty) {
        enableSaveDeviceBtn.value = false;

        // jika enableSaveDeviceBtn = false dan errorText.isNotEmpty dan enableNewCommandBtn.isFalse
        // berarti errorText nya muncul karena user ingin menambah command baru tetapi command yang ada
        // jumlahnya sudah = maxCommandCount, maka diizinkan untuk save device
        if (errorText.isNotEmpty && enableNewCommandBtn.isFalse) {
          enableSaveDeviceBtn.value = true;
        }
      } else {
        enableSaveDeviceBtn.value = true;
      }
    }
  }

  static void saveDeviceData() {
    isSaveDeviceBtnClicked = true;

    if (currentDevice?.deviceName != deviceNameController.text) {
      ctrl.refreshLogs(text: 'Device "${currentDevice?.deviceName}" changed to "${deviceNameController.text}"');
      currentDevice?.setNewDeviceName = deviceNameController.text;
    }

    if (isEditDevice) {
      deviceList[deviceIndex] = currentDevice!;
      showGetxSnackbar('Edit success', 'Device "${currentDevice?.deviceName}" edited successfully');
      ctrl.refreshLogs(text: 'Device "${currentDevice?.deviceName}" edited successfully');
    } else {
      deviceList.add(currentDevice!);
      // showSnackBar('Device: "${currentDevice?.deviceName}" saved')
      showGetxSnackbar('Save device OK', 'Device: "${currentDevice?.deviceName}" saved');
      ctrl.refreshLogs(text: 'Device "${currentDevice?.deviceName}" saved');
    }
    for (final data in deviceList) {
      debugPrint('[device_controller] device name: ${data.deviceName}');
    }
  }

  static void onNewCommandButtonPressed() {
      CommandController.commandCtrl.clear();
      CommandController.commandTitleCtrl.clear();
      CommandController.commandLogText.clear();
  }

  static VoidCallback? editSelectedCommand() {
    debugPrint('');
    debugPrint('[device_controller] selected title to edit: $selectedTitle');
    CommandController.commandIndexToEdit = currentDevice!.commandList.indexWhere((element) => element.title == selectedTitle);
    CommandController.oldCommand = currentDevice!.commandList[CommandController.commandIndexToEdit].command;
    CommandController.isEditCommand.value = true;
    CommandController.commandTitleCtrl.text = currentDevice!.commandList[CommandController.commandIndexToEdit].title;
    CommandController.commandCtrl.text = currentDevice!.commandList[CommandController.commandIndexToEdit].command;
    // deviceLogTextCtrl.text = currentDevice!.deviceLogText;
    CommandController.commandLogText.text = currentDevice!.commandList[CommandController.commandIndexToEdit].logText;
    AddDeviceView.editCommand(Get.context!);
    return null;
  }

  static VoidCallback? deleteSelectedCommand() {
    debugPrint('[device_controller] selected title to delete: $selectedTitle from device ${currentDevice!.deviceName}');
    int commandIndexToDelete = -1;
    // bool found = false;
    // int deviceIndex = -1;
    // for (final devName in deviceList) {
    //   if (devName.deviceName == deviceNameController.text) {
    //     print('${devName.deviceName} is exists');
    //     deviceIndex = deviceList.indexOf(devName);
    //     print('device index $deviceIndex');
    //
    //     for (final cmd in devName.commandList) {
    //       if (cmd.title == selectedTitle) {
    //         print('$selectedTitle found');
    //         commandIndexToDelete = devName.commandList.indexWhere((element) => element.title == selectedTitle);
    //         print('index command: $commandIndexToDelete');
    //         found = true;
    //         break;
    //       }
    //     }
    //   }
    //   if (found) {break;}
    // }
    //
    // if (commandIndexToDelete > -1) {
    //   deviceList[deviceIndex].commandList.removeAt(commandIndexToDelete);
    //   CommandController.commandMenuList.removeAt(commandIndexToDelete);
    // }
    commandIndexToDelete = currentDevice!.commandList.indexWhere((element) => element.title == selectedTitle);

    if (currentDevice!.commandList.isNotEmpty) {
      currentDevice?.commandList.removeAt(commandIndexToDelete);
      CommandController.commandMenuList.removeAt(commandIndexToDelete);
    }
    
    refreshNewCommandButtonState();

    return null;
  }

}
