import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NameAccount extends StatefulWidget {
  final double width;
  const NameAccount({Key? key, this.width = 280}) : super(key: key);

  @override
  State<NameAccount> createState() => _NameAccountState();
}

class _NameAccountState extends State<NameAccount> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 312,
      height: 189,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.5),
        color: AppColors.portageBg.withOpacity(0.07),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 8,
          ),
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.portage.withOpacity(0.15),
                child: SvgPicture.asset('assets/icon_user.svg'),
              ),
              Padding(
                padding: EdgeInsets.only(top: 28, left: 28),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      print('TAP PHOTO');
                    },
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.white,
                      child: SvgPicture.asset(
                          'assets/icon_photo.svg'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            width: double.infinity,
            height: 19,
            // color: Colors.cyan,
            child: Text(
              'Account`s Name',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Container(
            child: TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white.withOpacity(0.6),
                hintText: 'Enter your Account`s Name',
                hintStyle: passwordField,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.portage.withOpacity(0.12), width: 1.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
