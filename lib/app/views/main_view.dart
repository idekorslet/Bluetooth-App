import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/controllers/device_controller.dart';
import 'package:flutter_bluetooth/app/helper/popup_dialogs.dart';
import 'package:flutter_bluetooth/app/views/connection_view.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'data_logs_view.dart';
import 'devices_view.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
enum DevicePopupMenuItem {newDevice, saveDevice, loadDevice}

class MainView extends StatelessWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Flutter Bluetooth"),
        backgroundColor: Colors.deepPurple,
        actions:
        [
          Padding(
            padding: const EdgeInsets.only(right: 14.0, top: 10, bottom: 6),
              child: Obx(() {
                return
                  Visibility(
                    visible: (ctrl.selectedTabIndex.value == 1 && ctrl.logs.value.isNotEmpty) || ctrl.selectedTabIndex.value == 2,
                    child: ctrl.selectedTabIndex.value == 1
                        ? Row(
                          children: [
                            // switch logs view as chat view or standard view
                            IconButton(
                                onPressed: () {
                                  ctrl.isLogAsChatView.value = !ctrl.isLogAsChatView.value;
                                },
                                icon: Icon(ctrl.isLogAsChatView.isTrue ? Icons.table_rows_rounded : Icons.chat)
                            ),

                            const SizedBox(width: 40,),

                            InkWell(
                                onTap: () {
                                  showConfirmDialog(
                                      context: context,
                                      title: 'Delete logs confirm',
                                      text: 'Delete all log?',
                                      onOkPressed: deleteLogs
                                  );
                                },
                                child: const Icon(Icons.delete),
                            ),
                          ],
                        )
                        :
                          // OutlinedButton(
                          //     onPressed: () {
                          //       const DevicesView().createNewDevice(context);
                          //     },
                          //     style: buildButtonStyle(borderColor: Colors.grey, splashColor: Colors.yellow),
                          //     child: const Text('New Device', style: TextStyle(color: Colors.white),)
                          // ),
                    PopupMenuButton<DevicePopupMenuItem>(
                        onSelected: (DevicePopupMenuItem item) {

                          if (item == DevicePopupMenuItem.newDevice) {
                            const DevicesView().createNewDevice(context);
                          } else if (item == DevicePopupMenuItem.saveDevice){
                            if (DeviceController.deviceList.isNotEmpty) {
                              DeviceController.saveDeviceListIntoStorage();
                            } else {
                              null;
                            }
                          } else {
                            DeviceController.loadDeviceListFromStorage(isLoadFromInitApp: false);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<DevicePopupMenuItem>(
                              value: DevicePopupMenuItem.newDevice,
                              child: Row(
                                children: const [
                                  Text('New Device'),
                                  Expanded(child: SizedBox(width: 10,)),
                                  Icon(Icons.add_rounded, size: 20.0, color: Colors.black)
                                ],
                              ),
                            ),
                            PopupMenuItem<DevicePopupMenuItem>(
                              value: DevicePopupMenuItem.saveDevice,
                              child: Row(
                                children: [
                                  Text(
                                    'Save Device',
                                    style: TextStyle(color: DeviceController.deviceList.isNotEmpty ? Colors.black : Colors.grey),
                                  ),
                                  const Expanded(child: SizedBox(width: 10,)),
                                  Icon(
                                      Icons.save_alt_outlined,
                                      size: 20.0,
                                      color: DeviceController.deviceList.isNotEmpty ? Colors.black : Colors.grey
                                  )
                                ],
                              ),
                            ),
                            PopupMenuItem<DevicePopupMenuItem>(
                              value: DevicePopupMenuItem.loadDevice,
                              child: Row(
                                children: const [
                                  Text('Load Device'),
                                  Expanded(child: SizedBox(width: 10,)),
                                  Icon(Icons.upload_outlined, size: 20.0, color: Colors.black,)
                                ],
                              ),
                            ),
                          ];
                        }
                    )
                  );
              }),
          )
        ],

        bottom: TabBar(
          controller: ctrl.tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.bluetooth),
                // SizedBox(width: 10,),
                Text('Connection')
              ],)
            ),

            Tab(icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.terminal),
                SizedBox(width: 10,),
                Text('Data Logs')
              ],)
            ),

            Tab(icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.list_alt_outlined),
                SizedBox(width: 4,),
                Text('Device List')
              ],)
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - kToolbarHeight * 1.2,
          child: TabBarView(
            controller: ctrl.tabController,
            children: const [
              // bluetooth connection tab
              ConnectionView(),

              // Data logs tab
              DataLogs(),

              // device list tab
              DevicesView(),
            ],
          ),
        ),
      ),
    );
  }

  void deleteLogs() {
    Get.back();
    ctrl.logs.value.clear();
    ctrl.logs.refresh();
    debugPrint('[main_view] Logs deleted');
  }


}
