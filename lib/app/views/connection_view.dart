import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import '../../bluetooth_data.dart';
import '../../main.dart';
import '../../utils.dart';

class ConnectionView extends StatelessWidget {
  const ConnectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Obx(() {
          return Visibility(
            visible: ctrl.isConnecting.value,
            child: const LinearProgressIndicator(
              backgroundColor: Colors.yellow,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          );
        }),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Obx(() {
                  return
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Switch(
                          // value: BluetoothData.instance.bluetoothState.isEnabled,
                          value: ctrl.isBluetoothActive.value,
                          onChanged: (bool value) async {
                            if (value) {
                              await FlutterBluetoothSerial.instance.requestEnable();
                              await BluetoothData.instance.getPairedDevices();
                            } else {
                              if (ctrl.isConnected.isTrue) {
                                BluetoothData.instance.disconnect();
                              }
                              await FlutterBluetoothSerial.instance.requestDisable();
                            }
                          },
                        ),
                        const SizedBox(width: 4,),
                        const Text(
                          'Enable Bluetooth',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const Expanded(child: SizedBox()),

                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                (ctrl.selectedDevice.value != 'NONE' &&
                                    ctrl.selectedDevice.value != '' &&
                                    ctrl.isConnecting.isFalse &&
                                    ctrl.isBluetoothActive.isTrue)
                                    ? AppColors.activeButton
                                    : AppColors.inActiveButton
                            ),
                          ),
                          onPressed: () {
                            onPressedConnectButton();
                          },

                          child: Text(ctrl.isConnected.isTrue
                              ? 'Disconnect'
                              : ctrl.isConnecting.isTrue
                              ? 'Connecting'
                              : 'Connect'
                          ),
                        ),
                      ],
                    );
                }),

                const Divider(thickness: 1.0,),
                const SizedBox(height: 20,),
                const Text(
                  "PAIRED DEVICES",
                  style: TextStyle(fontSize: 24, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),

                Obx((){
                  return
                    Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              'Device:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            buildDeviceDropDown(),

                            refreshButton()
                          ],
                        ),

                        const Divider(thickness: 1.0,),
                        const SizedBox(height: 20,),
                        // auto reconnect switch
                        Row(
                          children: [
                            Switch(
                                value: ctrl.isAutoReconnect.value,
                                onChanged: (bool newVal) {
                                  ctrl.isAutoReconnect.value = newVal;
                                }
                            ),
                            const SizedBox(width: 4,),
                            const Text('Auto reconnect if connection lost',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                }),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "NOTE: If you cannot find the device in the list, please pair the device by going to the bluetooth settings",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              // elevation: 2,
                              child: const Text("Bluetooth Settings"),
                              onPressed: () {
                                FlutterBluetoothSerial.instance.openSettings();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )

      ],
    );
  }

  refreshButton() {
    return
      ElevatedButton.icon(
        icon: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
        label: const Text(
          "Refresh",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
              ctrl.isBluetoothActive.value ? AppColors.activeButton : AppColors.inActiveButton
          ),
        ),
        onPressed: () async {
          // So, that when new devices are paired
          // while the app is running, user can refresh
          // the paired devices list.
          if (ctrl.isBluetoothActive.value) {
            await BluetoothData.instance.getPairedDevices().then((_) {
              // showSnackBar('Device list refreshed');
              showGetxSnackbar('Devices refreshed', 'Device list refreshed');
              ctrl.refreshDeviceList();
              ctrl.refreshLogs(text:'Device list refreshed');
            });
          } else {
            null;
          }
        },
      );
  }

  void onPressedConnectButton() {
    // if bluetooth not active or bluetooth active but still connecting, then
    // nothing to_do if user press the button
    if (ctrl.isBluetoothActive.isFalse || ctrl.isConnecting.isTrue) {
      null;
    }
    else {
      if (ctrl.selectedDevice.value != '' &&
          ctrl.selectedDevice.value != 'NONE') {
        if (ctrl.isConnecting.isFalse) {
          if (ctrl.isConnected.isTrue) {
            BluetoothData.instance.isDisconnecting = true;
            BluetoothData.instance.disconnect();
          } else {
            debugPrint('[connection_view] connecting...');
            BluetoothData.instance.connect();
          }
        }
      }
    }
  }

  buildDeviceDropDown() {
    var devList = ctrl.deviceItems.value.map<DropdownMenuItem<BluetoothDevice>>((dev) {
      return DropdownMenuItem(value: dev, child: Text(dev.name!));
    }).toList();

    return
      DropdownButton(
          menuMaxHeight: 200,
          items: devList,
          onChanged: (value) {
            if (value != null && value.name != 'NONE') {
              BluetoothData.instance.device = value;
              ctrl.devIndex.value = ctrl.deviceItems.value.indexWhere((element) {
                return element.name == value.name;
              });
            }

            ctrl.selectedDevice.value = value!.name!;

            // print('[connection_view] ctrl.devIndex.value ${ctrl.devIndex.value}');
            // print('[connection_vew] value.name ${value?.name}');

            // ctrl.selectedDevice.value = value == null ? 'NONE' : '${value.name}\n${value.address}';
            // ctrl.selectedDevice.value = value == null ? 'NONE' : '${value.name}';
          },
          value: ctrl.deviceItems.value[ctrl.devIndex.value]
      );
  }

}