import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/helper/widget_helper.dart';
import '../custom_widget/custom_button.dart';

class CommandMenu extends StatelessWidget {
  String titleText;
  final String commandText;
  final TextEditingController? commandController;
  final bool readOnly;
  // final int index;
  final VoidCallback? onDeleteButtonPressed;
  final VoidCallback? onEditButtonPressed;
  CommandMenu({Key? key,
    required this.titleText,
    required this.commandText,
    // required this.titleController,
    // this.index=-1,
    this.readOnly=false,
    // this.commandController,
    required this.commandController,
    this.onEditButtonPressed,
    this.onDeleteButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildDeviceCommandMenu(
        title: titleText,
        commandText: commandText,
        isTextEditingReadOnly: readOnly,
        onEditButtonPressed: onEditButtonPressed,
        onDeleteButtonPressed: onDeleteButtonPressed,
        cmdController: commandController!
    );
  }

  // set setNewCommandMenuTitle(String newTitle) => titleText = newTitle;

  buildDeviceCommandMenu({required String title, required String commandText,
    // required TextEditingController titleController,
    required TextEditingController cmdController,
    bool isTextEditingReadOnly=false,

    void Function()? onEditButtonPressed,
    void Function()? onDeleteButtonPressed,
    // VoidCallback? onEditButtonPressed,
    // VoidCallback? onDeleteButtonPressed,
  }) {
    return
      Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                // color: Colors.deepPurple,
                border: Border.all(color: Colors.deepPurple)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Text(text),
                Flexible(
                  child: SizedBox(
                    width: 220,
                    height: 40,
                    child: buildTextField(
                        title: title,
                        // titleTextController: titleController,
                        commandTextController: cmdController,
                        commandText: commandText,
                        isReadOnly: isTextEditingReadOnly,
                    ),
                  ),
                ),
                MyCustomButton(
                  commandTitle: title,
                  customWidget: const Icon(Icons.edit), onPressedAction: onEditButtonPressed
                ),
                MyCustomButton(
                  commandTitle: title,
                  customWidget: const Icon(Icons.delete), onPressedAction: onDeleteButtonPressed
                ),
                // Switch(
                //     value: true,
                //     onChanged: (newValue) {
                //
                //     }
                // )
              ],
            ),
          ),
          const SizedBox(height: 10,),
        ],
      );
  }
}
