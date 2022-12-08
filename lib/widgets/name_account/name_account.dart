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
        color: Color(0x129B73EE),
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
                backgroundColor: Color(0x269490EA),
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
                      backgroundColor: Color(0xffffffff),
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Container(
            child: TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFFFFFFF),
                hintText: 'Enter your Account`s Name',
                hintStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff12052F).withOpacity(0.3),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xffebe9fa), width: 1.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
