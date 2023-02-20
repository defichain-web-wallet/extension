import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class AssetTextField extends StatefulWidget {
  const AssetTextField({Key? key}) : super(key: key);

  @override
  State<AssetTextField> createState() => _AssetTextFieldState();
}

class _AssetTextFieldState extends State<AssetTextField> {
  FocusNode _focusNode = FocusNode();
  bool isFocus = false;

  @override
  void initState() {
    _focusNode.addListener(() {
      if(_focusNode.hasFocus) {
        setState(() {
          isFocus = true;
        });
      } else {
        setState(() {
          isFocus = false;
        });
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: GestureDetector(
        onTap: () {
          if(!_focusNode.hasFocus) {
            _focusNode.requestFocus();
          }
        },
        child: Container(
          // width: 328,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.8),
            border: Border.all(
              color: isFocus ? AppColors.pinkColor : AppColors.lavenderPurple.withOpacity(0.32),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 38,
                      child: TextFormField(
                        focusNode: _focusNode,
                        scrollPadding: EdgeInsets.zero,
                        style: Theme.of(context).textTheme.headline4,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Text(
                          '\$365.50',
                          style: Theme.of(context).textTheme.headline6!.apply(
                              color: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .color!
                                  .withOpacity(0.3)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: (){},
                        child: Container(
                          height: 38,
                          width: 92,
                          decoration: BoxDecoration(
                            color: AppColors.portage.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Available: 35.02',
                          style: Theme.of(context).textTheme.headline6!.apply(
                              color: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .color!
                                  .withOpacity(0.3)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
