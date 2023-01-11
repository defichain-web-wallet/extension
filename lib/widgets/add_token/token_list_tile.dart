import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/defi_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TokenListTile extends StatefulWidget {
  final Function()? onTap;
  final bool isSelect;
  final bool isConfirm;
  final String imgPath;
  final String tokenName;
  final String availableTokenName;
  final Color? tokenColor;

  const TokenListTile({
    Key? key,
    this.onTap,
    required this.isSelect,
    this.isConfirm = false,
    required this.imgPath,
    required this.tokenName,
    required this.availableTokenName,
    this.tokenColor,
  }) : super(key: key);

  @override
  State<TokenListTile> createState() => _TokenListTileState();
}

class _TokenListTileState extends State<TokenListTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isConfirm ? null : widget.onTap,
      child: MouseRegion(
        cursor: widget.isConfirm ? MouseCursor.defer : SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.all(1),
          height: 64,
          width: double.infinity,
          decoration: BoxDecoration(
            color:
                !widget.isSelect ? AppColors.portage.withOpacity(0.12) : null,
            gradient: widget.isSelect ? gradientBottomToUpCenter : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: Theme.of(context).cardColor,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: widget.isSelect
                    ? AppColors.portageBg.withOpacity(0.07)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 11,
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.tokenColor!.withOpacity(0.16),
                              ),
                              child: SvgPicture.asset(
                                widget.imgPath,
                                height: 32,
                                width: 32,
                              ),
                            ),
                            SizedBox(
                              width: 11,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${widget.tokenName}',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  '${widget.availableTokenName}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!
                                            .withOpacity(0.3),
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: widget.isConfirm ? 150 : 38,
                    child: Column(
                      crossAxisAlignment: widget.isConfirm
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isConfirm)
                          Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Text(
                              '0 ${widget.availableTokenName}',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ),
                        if (widget.isSelect)
                          DefiCheckbox(
                            callback: (val) {
                              widget.onTap!();
                            },
                            value: true,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
