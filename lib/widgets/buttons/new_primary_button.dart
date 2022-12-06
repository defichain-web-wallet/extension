import 'package:flutter/material.dart';

class NewPrimaryButton extends StatelessWidget {
  Function? callback;
  double width;
  String title;

  NewPrimaryButton(
      {Key? key,
      this.callback,
      this.width = double.infinity,
      this.title = 'OK'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 61.0,
      width: width,
      decoration: BoxDecoration(
        border: callback != null
            ? null
            : Border.all(
                color: Color(0xFFd1a5dd),
              ),
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: callback != null
              ? [
                  Color(0xFFBC00C0),
                  Color(0xFFFF00A3),
                ]
              : [
                  Color(0xFFecb2ec),
                  Color(0xFFffb2e3),
                ],
        ),
      ),
      child: ElevatedButton(
        onPressed: callback != null ? () {} : null,
        style: ElevatedButton.styleFrom(
          side: BorderSide(
            style: BorderStyle.solid,
            color: Color(0xFFd1a5dd),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFFFCFBFE),
          ),
        ),
      ),
    );
  }
}
