import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class Helpfile extends StatefulWidget {
  const Helpfile({Key? key}) : super(key: key);

  @override
  State<Helpfile> createState() => _HelpfileState();
}

class _HelpfileState extends State<Helpfile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Column(
        children: [

          // TODO: change to ListView
          Divider(
            height: 1,
            color: Theme.of(context)
                .dividerColor
                .withOpacity(0.05),
            thickness: 1,
          ),
          Container(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              mainAxisAlignment:
              MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors
                          .portage
                          .withOpacity(0.16),
                      child: Text(
                        'J',
                        style:
                        headline4.copyWith(
                            fontSize: 11,
                            color: AppColors
                                .portage),
                      ),
                    ),
                    SizedBox(
                      width: 6.4,
                    ),
                    Text(
                      'Jelly Fishy',
                      style: Theme.of(context)
                          .textTheme
                          .headline5,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 14,
          ),
          Divider(
            height: 1,
            color: Theme.of(context)
                .dividerColor
                .withOpacity(0.05),
            thickness: 1,
          ),
        ],
      ),
    );
  }
}
