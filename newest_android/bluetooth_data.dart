import 'dart:async';
import 'dart:convert';
import 'package:bluetooth_dev_control/permission_request.dart';
import 'package:bluetooth_dev_control/translator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:bluetooth_dev_control/app/constant/constant.dart';
import 'package:bluetooth_dev_control/utils.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'main.dart';

class BluetoothData {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState bluetoothState = BluetoothState.UNKNOWN;

  // Get the instance of the Bluetooth
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Track the Bluetooth connection with the remote device
  BluetoothConnection? connection;

  // To track whether the device is still connected to Bluetooth
  bool? get isConnected => connection != null && connection!.isConnected;

  // deviceState only used to change color, not too important
  // int deviceState = 0;
  bool isDisconnecting = false;
  bool _isConnectionLost = false;
  int _reconnectCounter = 0;
  Timer? _timer;

  BluetoothData._privateConst();

  static BluetoothData instance = BluetoothData._privateConst();
  factory BluetoothData() => instance;

  // Define some variables, which will be required later
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? device;

  Future<void> initBluetooth() async {
    // Get current state
    debugPrint('[bluetooth_data] reading bluetooth state');
    bluetoothState = await FlutterBluetoothSerial.instance.state;

    if (bluetoothState == BluetoothState.STATE_ON) {
      ctrl.isBluetoothActive.value = true;
      debugPrint('[bluetooth_data] Bluetooth already active');
      ctrl.refreshLogs(text: Translator.bluetoothAlreadyActive.trans);
      ctrl.refreshDeviceList();
    }
    else {
      enableBluetooth();
    }

    // deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up

    // Listen for further state changes
    // membaca status bluetooth ketika di aktifkan atau dimatikan
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) async {
        bluetoothState = state;

        if (bluetoothState == BluetoothState.STATE_OFF) {
          ctrl.isBluetoothActive.value = false;
          ctrl.isConnected.value = false;
          ctrl.isConnecting.value = false;
          ctrl.refreshLogs(text: Translator.bluetoothTurnedOff.trans);
          ctrl.selectedPairedDevice.value = -1;
        }
        else if (bluetoothState == BluetoothState.STATE_ON) {
          ctrl.isBluetoothActive.value = true;
          ctrl.refreshLogs(text: Translator.bluetoothTurnedOn.trans);
        }

        await getPairedDevices();
        ctrl.devIndex.value = 0;
        ctrl.refreshDeviceList();
        debugPrint('[bluetooth_data] onStateChanged, bluetooth status: ${ctrl.isBluetoothActive.value}');
    });
  }

  // Avoid memory leak and disconnect
  void dispose() {
    if (isConnected!) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    _timer?.cancel();
  }

  // Method to connect to bluetooth
  void connect() async {
    if (device == null) {
      debugPrint('No device selected');
    } else {
      ctrl.refreshLogs(text: '${Translator.connectingTo.trans} ${ctrl.selectedDevice}');
      ctrl.isConnecting.value = true;
      startTimeoutConnectionTimer();

      if (!isConnected!) {
        await BluetoothConnection.toAddress(device?.address).then((conn) {
          debugPrint('Connected to the device');
          // showSnackBar('Connected to the device')
          showGetxSnackbar(Translator.connected.trans, Translator.connectedToTheDevice.trans);

          connection = conn;
          ctrl.isConnected.value = true;
          ctrl.isConnecting.value = false;
          _timer?.cancel();
          _reconnectCounter = 0;
          _isConnectionLost = false;
          ctrl.refreshLogs(text: Translator.connected.trans);
          ctrl.deviceItems.refresh();

          // balasan/feedback dari device client selalu dibaca
          // karena subscription stream
          connection?.input?.listen((Uint8List data) {
            final dataString = ascii.decode(data, allowInvalid: true).trim();
            debugPrint('[bluetooth_data] Data incoming: $dataString');

            if (dataString.isNotEmpty) {
              ctrl.refreshLogs(sourceId: SourceId.clientId, text: dataString);
            }

            // Send data ke device client as feedback
            // Uint8List dataForDevice = utf8.encode("ok " "\r\n") as Uint8List;
            // connection?.output.add(dataForDevice);

            // if (ascii.decode(data).contains('!')) {
              // connection?.finish(); // Closing connection
              // disconnect();
              // debugPrint('[bluetooth_data] Disconnecting by local host');
              // ctrl.refreshLogs(text: 'Disconnecting by local host');
              // showGetxSnackbar('Disconnected', 'Disconnecting by local host');
            // }
          }).onDone(() {
            debugPrint('[bluetooth_data] on done');
            String status = '';

            if (isDisconnecting) {
              status = '[bluetooth_data] Disconnecting locally!';
              isDisconnecting = false;
              debugPrint(status);
            } else {
              status = '[bluetooth_data]Disconnected remotely or connection lost!';
              debugPrint(status);
              _isConnectionLost = true;
            }

            status = status.replaceAll('[bluetooth_data]', '');
            ctrl.refreshLogs(text: status);
            showGetxSnackbar(Translator.disconnected.trans, status);
            ctrl.isConnected.value = false;
            reConnect();
          });
        }).catchError((error) {
          debugPrint('[bluetooth_data] Cannot connect, exception occurred: $error');
          // showSnackBar('Cannot connect, exception occurred');
          showGetxSnackbar(Translator.failedToConnect.trans, Translator.cannotConnectExceptionOccured.trans);
          ctrl.refreshLogs(text: Translator.cannotConnect.trans);
          ctrl.isConnecting.value = false;
          _timer?.cancel();
          reConnect();
        });
      }
    }
  }

  void reConnect() {
    // info:
    // selectedDelayTimeBeforeReconnectDropdownValue dikali 5 karena:
    //    index dropdown ke 0 = "No delay"
    //    index dropdown ke 1 = "5 seconds"
    //    index dropdown ke 2 = "10 seconds"
    //    index dropdown ke 3 = "15 seconds"
    //    index dropdown ke 4 = "20 seconds"
    //    index dropdown ke 5 = "25 seconds"
    //    index dropdown ke 6 = "30 seconds"

    // selectedMaxTryReconnectDropdownValue ditambah 2 karena:
    // index dropdown ke 0 = "2 times" --> dari angka 2
    // index dropdown terakhir = "10 times" --> sampai angka 10

    if (settingsCtrl.isAutoReconnect.isTrue) {
      Future.delayed(Duration(seconds: settingsCtrl.selectedDelayTimeBeforeReconnectDropdownValue.value * 5)).then((value) {
        // if (ctrl.isAutoReconnect.isTrue && bluetoothState == BluetoothState.STATE_ON
        if (bluetoothState == BluetoothState.STATE_ON && _isConnectionLost
            && _reconnectCounter < settingsCtrl.selectedMaxTryReconnectDropdownValue.value + 2)
        {
          _reconnectCounter++;
          debugPrint('[bluetooth_data] auto reconnect active, reconnecting #$_reconnectCounter/${settingsCtrl.selectedMaxTryReconnectDropdownValue.value + 2}');
          ctrl.refreshLogs(text: '${Translator.autoReconnectActive.trans} $_reconnectCounter/${settingsCtrl.selectedMaxTryReconnectDropdownValue.value + 2}');
          showGetxSnackbar(Translator.reconnectingTitle.trans, Translator.tryingToReconnect.trans);
          BluetoothData.instance.connect();
        }
      });
    }
  }

  // Method to disconnect bluetooth
  void disconnect() async {
    // deviceState = 0;

    await connection?.close();
    // showSnackBar('Device disconnected');
    showGetxSnackbar(Translator.disconnected.trans, Translator.deviceDisconnected.trans);
    ctrl.refreshLogs(text:Translator.deviceDisconnected.trans);
    debugPrint('Device disconnected');
    // if (!connection!.isConnected) {
    //   ctrl.isConnected.value = false;
    // }
    ctrl.isConnected.value = false;
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    // bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    // if (bluetoothState == BluetoothState.STATE_OFF) {
    final isPermissionOk = await PermissionRequest.isPermissionAllowed();
    if (isPermissionOk) {
      await FlutterBluetoothSerial.instance.requestEnable();
    }

    // }
    // await getPairedDevices();
  }

  // For retrieving and storing the paired devices in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devList = [];

    if (bluetoothState == BluetoothState.STATE_ON) {
      // To get the list of paired devices
      try {
        devList = await _bluetooth.getBondedDevices();
      } on PlatformException {
        debugPrint("Error");
      }
    }

    // Store the [devices] list in the [_devicesList]
    devicesList = devList;
  }

  void startTimeoutConnectionTimer() {
    debugPrint('[bluetooth_data] start counting timeout...');
    int start = maxConnectionTimeOut;

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
        debugPrint('[bluetooth_data] time out in: $start');
        if (start == 0) {
          // if state is connecting and still not connected after >= max connection time out
          if (ctrl.isConnecting.isTrue) {
            debugPrint('[bluetooth_data] Connection timeout');
            showGetxSnackbar(Translator.failedToConnect.trans, Translator.connectionTimeOut.trans);
            ctrl.refreshLogs(text: '${Translator.failedToConnect.trans} ${Translator.connectionTimeOut.trans}', sourceId: SourceId.statusId);
            ctrl.isConnecting.value = false;
          }

          timer.cancel();
        } else {
          start--;
        }
      },
    );
  }

  Future<void> sendMessageToBluetooth(String message, bool asSwitch) async {
    if (ctrl.isConnected.isTrue) {
      Uint8List data = utf8.encode("$message" "\r\n") as Uint8List;
      connection?.output.add(data);
      await connection?.output.allSent;
    }
  }

}
