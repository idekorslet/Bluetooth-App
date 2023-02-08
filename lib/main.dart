// For performing some operations asynchronously
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/utils.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/controllers/device_controller.dart';
import 'app/controllers/global_controller.dart';
import 'app/views/main_view.dart';
import 'bluetooth_data.dart';

DateTime? currentBackPressTime;
late Controller ctrl;
late ScrollController listScrollController;
late SharedPreferences prefs;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[main] building UI');
    ctrl = Get.put(Controller());

    return GetMaterialApp(
      title: 'Flutter Bluetooth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WillPopScope(
        child: const BluetoothApp(),
        onWillPop: ()=> onWillPop(),
      ),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  const BluetoothApp({super.key});

  @override
  BluetoothAppState createState() => BluetoothAppState();
}

class BluetoothAppState extends State<BluetoothApp> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

    ctrl.initTabController(this);
    init();

    listScrollController = ScrollController(initialScrollOffset: 50.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(listScrollController.hasClients){
        listScrollController.animateTo(
            listScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500), curve: Curves.easeInOut
        );
      }
    });
  }

  @override
  void dispose() {
    BluetoothData.instance.dispose();
    listScrollController.dispose();
    super.dispose();
  }

  Future init() async {
    prefs = await SharedPreferences.getInstance();
    // load the saved device list
    DeviceController.loadDeviceListFromStorage();
    await BluetoothData.instance.initBluetooth();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(), // to hide keyboard if the screen tapped outside of the keyboard
        child: const MainView()
    );
  }
}

Future<bool> onWillPop() {
  DateTime now = DateTime.now();
  if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
    currentBackPressTime = now;
    // Fluttertoast.showToast(msg: "Press again to exit");
    showGetxSnackbar("Exit app", "Press again to exit");
    return Future.value(false);
  }
  return Future.value(true);
}