import 'package:defi_wallet/widgets/fields/input_text_field.dart';
import 'package:flutter/material.dart';

class UiKit extends StatefulWidget {
  const UiKit({Key? key}) : super(key: key);

  @override
  State<UiKit> createState() => _UiKitState();
}

class _UiKitState extends State<UiKit> {
  TextEditingController controller = TextEditingController();
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ui kit'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            InputTextField(
              controller: controller,
              hint: 'Password',
              label: 'Password',
              isShowObscureIcon: true,
              isObscure: isObscure,
              onPressObscure: () {
                setState(() {
                  isObscure = !isObscure;
                });
              }
            ),
          ],
        ),
      ),
    );
  }
}
