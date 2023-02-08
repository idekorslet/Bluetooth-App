import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:get/get.dart';
import '../helper/command_menu.dart';
import '../models/commands.dart';
import '../models/devices.dart';
import 'device_controller.dart';

class CommandController extends GetxController {
  static List<CommandMenu> commandMenuList = <CommandMenu>[].obs;
  static var isEditCommand = false.obs;
  static var isInputCommandValid = false.obs;
  static int commandIndexToEdit = -1;
  static var commandTitleErrorText = ''.obs;
  static var commandErrorText = ''.obs;
  static String oldCommand = '';

  static TextEditingController commandTitleCtrl = TextEditingController();
  static TextEditingController commandCtrl = TextEditingController();
  static TextEditingController commandLogText = TextEditingController();

  static List<TextEditingController> commandTextEditCtrlList = List<TextEditingController>.generate(maxCommandCount, (index) => TextEditingController(), growable: false);

  static void validateCommmandInput() {
    isInputCommandValid.value = false;
    commandTitleErrorText.value = '';
    commandErrorText.value = '';

    if (commandTitleCtrl.text.length < 3) {
      debugPrint('[command_controller] input title command not valid');
      commandTitleErrorText.value = 'Title length min 3 characters';
      return;
      // return false;
    }
    else if (commandCtrl.text.isEmpty) {
      debugPrint('[command_controller] input command not valid');
      commandErrorText.value = 'Please input command';
      return;
    }

    if (DeviceController.currentDevice != null) {
      bool isTitleExists = DeviceController.currentDevice!.commandList.indexWhere((cmd) => cmd.title == commandTitleCtrl.text) > - 1;
      bool isCommandExists = DeviceController.currentDevice!.commandList.indexWhere((cmd) => cmd.command == commandCtrl.text) > - 1;

      // jika sedang menginput command baru, cek apakah title & command yang diinput, apakah sudah ada di device yang sekarang
      // jika sedang mengedit command, cek apakah title yang baru berbeda dengan title sebelumnya, jika berbeda
      // cek apakah title dan command baru tersebut sudah ada digunakan di device sekarang

      if (isEditCommand.isFalse) { // input new command
        if (isTitleExists) {
          commandTitleErrorText.value = 'Title already exists';
          // isInputCommandValid.value = false;
        } else if (isCommandExists) {
          commandErrorText.value = 'Command already used';
          // isInputCommandValid.value = false;
        } else {
          isInputCommandValid.value = true;
        }
      } else {
        if (DeviceController.selectedTitle != commandTitleCtrl.text && isTitleExists) {
          commandTitleErrorText.value = 'Title already exists';
        }
        // if old command != new command and new command already used
        else if (oldCommand != commandCtrl.text && isCommandExists) {
          commandErrorText.value = 'Command already used';
        } else {
          isInputCommandValid.value = true;
        }
      }
    } else {
      isInputCommandValid.value = true;
    }
  }

  static void saveNewCommand() {
    // jika commandMenuList = empty, berarti belum ada command custom yang dibuat
    debugPrint('[command_controller] commandMenuList.length: ${commandMenuList.length}');
    // int commandId = commandMenuList.isEmpty ? 0 : commandMenuList.length;

    int commandId = -1;
    if (isEditCommand.isTrue) {
      commandId = commandIndexToEdit;
    } else {
      commandId = commandMenuList.length;
    }

    commandTextEditCtrlList[commandId].text = commandCtrl.text;
      // add new command to the current device
      if (DeviceController.currentDevice == null) {
        debugPrint('DeviceController.deviceList.isEmpty');

        DeviceController.currentDevice = Devices(
            deviceName: DeviceController.deviceNameController.text,
            // deviceLogText: DeviceController.deviceLogTextCtrl.text,
            status: false,
            commandList: [
              Commands(
                  id: commandId,
                  title: commandTitleCtrl.text,
                  command: commandCtrl.text,
                  logText: commandLogText.text,
                  // commandTextCtrl: commandTextEditCtrlList[commandId]
              )
            ]
        );
      }
      else {
        if (isEditCommand.isTrue) { // edit the selected command in the current device
          DeviceController.currentDevice?.commandList[commandIndexToEdit] = Commands(
              id: commandIndexToEdit,
              title: commandTitleCtrl.text,
              command: commandCtrl.text,
              logText: commandLogText.text,
              // commandTextCtrl: commandTextEditCtrlList[commandIndexToEdit]
          );

        } else {  // add new command to the current device
          DeviceController.currentDevice?.commandList.add(
              Commands(
                  id: commandId,
                  title: commandTitleCtrl.text,
                  command: commandCtrl.text,
                  logText: commandLogText.text,
                  // commandTextCtrl: commandTextEditCtrlList[commandId]
              )
          );
        }
      }

      // add new command menu to the list if not in editing mode (isEditCommand == false)
      if (CommandController.isEditCommand.isFalse) {
        commandMenuList.add(
            CommandMenu(
              // index: commandId,
              titleText: commandTitleCtrl.text,
              commandText: commandCtrl.text,
              readOnly: true,
              commandController: commandTextEditCtrlList[commandId],
              onDeleteButtonPressed: DeviceController.deleteSelectedCommand,
              onEditButtonPressed: DeviceController.editSelectedCommand,
            )
        );

        // DeviceController.commandMenuTextCtrlList.add(commandTextEditCtrlList[commandId]);
      } else {
        // edit the command menu from commandMenuList by commandIndexToEdit
        commandMenuList[commandIndexToEdit] = CommandMenu(
          // index: commandId,
          titleText: commandTitleCtrl.text,
          readOnly: true,
          commandController: commandTextEditCtrlList[commandId],
          commandText: commandTextEditCtrlList[commandId].text,
          onDeleteButtonPressed: DeviceController.deleteSelectedCommand,
          onEditButtonPressed: DeviceController.editSelectedCommand,
        );

        // DeviceController.commandMenuTextCtrlList[commandIndexToEdit] = commandTextEditCtrlList[commandId];
      }

      DeviceController.refreshSaveDeviceButtonState();
    }
}