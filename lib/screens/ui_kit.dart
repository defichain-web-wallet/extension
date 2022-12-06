import 'package:defi_wallet/bloc/theme/theme_cubit.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/fields/input_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UiKit extends StatefulWidget {
  const UiKit({Key? key}) : super(key: key);

  @override
  State<UiKit> createState() => _UiKitState();
}

class _UiKitState extends State<UiKit> {
  TextEditingController controller = TextEditingController();
  bool isObscure1 = false;
  bool isObscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ui kit'),
        actions: [
          ElevatedButton(
              onPressed: () {
                SettingsHelper settingsHelper = SettingsHelper();
                SettingsModel localSettings = SettingsHelper.settings.clone();
                localSettings.theme =
                    (localSettings.theme == 'Dark') ? 'Light' : 'Dark';
                SettingsHelper.settings = localSettings;
                settingsHelper.saveSettings();
                ThemeCubit themeCubit = BlocProvider.of<ThemeCubit>(context);
                themeCubit.changeTheme();
              },
              child: Icon(Icons.lightbulb))
        ],
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
                isObscure: isObscure1,
                onPressObscure: () {
                  setState(() {
                    isObscure1 = !isObscure1;
                  });
                }),
            InputTextField(
                controller: controller,
                hint: 'Password',
                label: 'Password',
                isShowObscureIcon: true,
                isObscure: isObscure2,
                onPressObscure: () {
                  setState(() {
                    isObscure2 = !isObscure2;
                  });
                }),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: NewPrimaryButton(
                title: "Create a new wallet",
                callback: null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: NewPrimaryButton(
                title: "Create a new wallet",
                callback: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NewPrimaryButton(
                    width: 250,
                    title: '250',
                    callback: () {},
                  ),
                  NewPrimaryButton(
                    width: 150,
                    title: '150',
                    callback: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
