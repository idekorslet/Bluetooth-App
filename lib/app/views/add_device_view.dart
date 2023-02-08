import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:flutter_bluetooth/app/controllers/device_controller.dart';
import 'package:flutter_bluetooth/app/views/add_command_view.dart';
import 'package:get/get.dart';
import '../controllers/command_controller.dart';
import '../helper/widget_helper.dart';
import '../helper/popup_dialogs.dart';

class AddDeviceView extends StatelessWidget {
  final String title;
  const AddDeviceView({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 250),
            child: SingleChildScrollView(
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      // width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          color: Colors.deepPurple,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Obx(() {
                        return Column(
                          children: [
                            buildTextField(
                                title: 'Device Name',
                                commandText: DeviceController.deviceNameController.text,
                                errorText: DeviceController.errorText.value,
                                onChanged: DeviceController.refreshNewCommandButtonState,
                                commandTextController: DeviceController.deviceNameController
                            ),
                            // const SizedBox(height: 4,),

                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 14.0),
                                  child: Text('Commands:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                ),
                                const Expanded(
                                    child: SizedBox(
                                      width: 20,
                                    )),
                                OutlinedButton(
                                    onPressed: () {
                                      CommandController.isEditCommand.value = false;

                                      if (DeviceController.enableNewCommandBtn.isTrue) {
                                        // DeviceController.errorText.value = '';
                                        createNewCommand(context);
                                      } else {
                                        if (DeviceController.deviceNameController.text.length < 3) {
                                          DeviceController.errorText.value = 'Device name minimal 3 character';
                                        } else {
                                          DeviceController.errorText.value = 'Max command is $maxCommandCount';
                                        }
                                        null;
                                      }
                                    },
                                    style: buildButtonStyle(borderColor: Colors.grey, buttonWidth: 80),
                                    child: const Text('New Command')
                                )
                              ],
                            ),
                            const SizedBox(height: 4,),
                            ...CommandController.commandMenuList,

                            const Divider(thickness: 2,),
                            const SizedBox(height: 10,),
                            saveButton(context)
                          ],
                        );

                      })
                    ),
                  ],
                )
            ),
          )
      );

  }

  saveButton(BuildContext context) {
    return
      SizedBox(
          width: 200,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              if (DeviceController.currentDevice == null || DeviceController.currentDevice!.commandList.length < minCommandCount) {
                showCustomDialog(context: context,
                    actionList: standardPopupItems(contentText: 'Please add minimal $minCommandCount command'),
                    title: 'Command < $minCommandCount'
                );
              }
              else {
                DeviceController.refreshSaveDeviceButtonState();

                if (DeviceController.enableSaveDeviceBtn.isTrue) {
                  DeviceController.saveDeviceData();
                  Navigator.of(context).pop();
                }

              }
            },
            style: buildButtonStyle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.save),
                SizedBox(width: 10,),
                Text('Save Device', ),
              ],
            ),
          )
      );
  }

  static void editCommand(BuildContext context) {
    showCustomDialog(
        context: context,
        // actionList: CommandView.commandItems(context),
        actionList: [const CommandView()],
        title: 'Edit Command'
    );
  }

  void createNewCommand(BuildContext context) {
    DeviceController.onNewCommandButtonPressed();
    showCustomDialog(
        context: context,
        // actionList: CommandView.commandItems(context),
        actionList: [const CommandView()],
        title: 'Create New Command'
    );
  }
}
