import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SettingsListTile extends StatefulWidget {
  final String titleText;
  final String subtitleText;
  final Function()? onTap;

  const SettingsListTile({
    Key? key,
    required this.titleText,
    required this.subtitleText,
    this.onTap,
  }) : super(key: key);

  @override
  State<SettingsListTile> createState() => _SettingsListTileState();
}

class _SettingsListTileState extends State<SettingsListTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 41,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.titleText,
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            fontSize: 16,
                          ),
                    ),
                    Text(
                      widget.subtitleText,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            fontSize: 12,
                            color: Theme.of(context)
                                .textTheme
                                .headline4!
                                .color!
                                .withOpacity(0.5),
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      right: 2.5,
                    ),
                    child: SvgPicture.asset('assets/icons/arrow_right.svg'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
