import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../custom_widget/custom_button.dart';

List<Widget> standardPopupItems({required String contentText}) {
  return [
    Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(contentText, style: const TextStyle(fontSize: 18),),
          const SizedBox(height: 20),
          MyCustomButton(
              customWidget: const Text('OK'),
              isCircleButton: false, buttonWidth: 100,
              onPressedAction: () {
                // Navigator.pop(context);
                Get.back();
              }
          ),
        ],
      ),
    )
  ];
}

void showConfirmDialog({
  required BuildContext context,
  required String title,
  required String text,
  required Function() onOkPressed
}) {
  Column items = Column(
    children: [
      const SizedBox(height: 20,),
      Text(text, style: const TextStyle(fontSize: 18),),
      const SizedBox(height: 20,),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyCustomButton(
              customWidget: const Text('Cancel'),
              isCircleButton: false, buttonWidth: 100,
              onPressedAction: () {
                // Navigator.pop(context);
                Get.back();
              }
          ),
          const SizedBox(width: 20),
          MyCustomButton(
              customWidget: const Text('OK'),
              isCircleButton: false, buttonWidth: 100,
              onPressedAction: () {
                onOkPressed();
                // Get.back();
                // String deviceName = DeviceController.deviceList[DeviceController.deviceIndex].deviceName;
                // DeviceController.deviceList.removeAt(DeviceController.deviceIndex);
                // Controller.refreshLogs(text: 'Device "$deviceName" deleted');
                // // showSnackBar('Device deleted');
                // showGetxSnackbar('Device deleted', 'Device "$deviceName" deleted');
              }
          ),
        ],
      )
    ],
  );
  showCustomDialog(context: context, title: title, actionList: [items]);
}

void showCustomDialog({required BuildContext context, required String title, required List<Widget> actionList}) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: AlertDialog(
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),

                content: Container(
                    height: 44,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)
                      ),
                      color: Colors.deepPurple,
                    ),
                    // child: Center(
                    //   child: Text(
                    //     title,
                    //     style: const TextStyle(fontSize: 20, color: Colors.white),
                    //   ),
                    // )),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 10,),
                        Text(
                          title,
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    )
                ),
                actions: actionList,
            ),
          ),
        );
      }
  );
}