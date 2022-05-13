import 'package:flutter/material.dart';

Widget backButton(context, {double size = 16, callback}) => ElevatedButton(
      style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          primary: Colors.transparent,
          side: BorderSide(
            color: Colors.transparent,
          )),
      child: Row(
        children: [
          Icon(
            Icons.navigate_before,
            size: size,
            color: Theme.of(context).textTheme.button!.color,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                'Back',
                style: Theme.of(context).textTheme.button,
              ))
        ],
      ),
      onPressed: callback == null ? () => Navigator.pop(context) : callback,
    );
