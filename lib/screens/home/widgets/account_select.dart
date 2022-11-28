import 'dart:developer';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/services/logger_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/password_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AccountSelect extends StatefulWidget {
  final double width;
  final isFullScreen;

  const AccountSelect({
    Key? key,
    required this.width,
    this.isFullScreen = false,
  }) : super(key: key);

  @override
  State<AccountSelect> createState() => AccountSelectState();
}

class AccountSelectState extends State<AccountSelect> {
  static const _tileHeight = 38.0;
  final FocusNode _focusNode = FocusNode();
  GlobalKey _selectKey = GlobalKey();
  bool _isOpen = false;
  late OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;
  late AccountModel _activeAccount;
  late List<AccountModel> _accountList;
  LockHelper lockHelper = LockHelper();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
      } else {}
    });
  }

  @override
  void dispose() {
    hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      if (state.status == AccountStatusList.success) {
        _activeAccount = state.activeAccount!;
        _accountList = state.accounts!;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              child: Container(
                key: _selectKey,
                height: _tileHeight,
                width: widget.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                  borderRadius: _isOpen
                      ? BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))
                      : BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isOpen ? 'Select account' : _activeAccount.name!,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline4!.apply(
                                color: _isOpen
                                    ? Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .color!
                                        .withOpacity(0.5)
                                    : Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .color!,
                              ),
                        ),
                        Icon(
                          _isOpen
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Theme.of(context)
                              .appBarTheme
                              .actionsIconTheme!
                              .color,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              onTap: () async {
                await lockHelper.provideWithLockChecker(context, () async {
                  _showOverlay(context, _accountList, _activeAccount, state);
                });
              }),
        );
      } else {
        return Container();
      }
    });
  }

  void hideOverlay() {
    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (_) {}
    }
    try {
      setState(() {
        _isOpen = false;
      });
    } catch (error) {
      log(error.toString());
    }
  }

  void _showOverlay(
      BuildContext context, _accountList, _activeAccount, state) async {
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
    if (_isOpen) {
      hideOverlay();
    } else {
      setState(() {
        _isOpen = true;
      });
      final keyContext = _selectKey.currentContext;
      _overlayState = Overlay.of(keyContext!);
      final box = keyContext.findRenderObject() as RenderBox;
      final pos = box.localToGlobal(Offset.zero);

      _overlayEntry = OverlayEntry(builder: (context) {
        return Positioned(
          top: pos.dy + box.size.height,
          left: pos.dx,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: box.size.width,
              height: (_accountList.length > 5
                      ? (_tileHeight) * 6
                      : (_accountList.length + 1) * (_tileHeight)) +
                  2,
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0)),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: ListView.builder(
                itemCount: _accountList.length + 1,
                itemBuilder: (context, index) {
                  if (index == _accountList.length) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          shadowColor: Colors.transparent,
                          primary: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0))),
                          side: BorderSide(
                            color: Colors.transparent,
                          )),
                      child: Container(
                        height: _tileHeight,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0))),
                        child: Center(
                          child: Text(
                            '+ Create new account',
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .apply(color: AppTheme.pinkColor),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        hideOverlay();
                        widget.isFullScreen
                            ? PasswordBottomSheet.provideWithPasswordFullScreen(
                                context, _activeAccount, (password) async {
                                AccountModel account =
                                    await accountCubit.addAccount();
                                if (SettingsHelper.isBitcoin()) {
                                  await bitcoinCubit
                                      .loadDetails(account.bitcoinAddress!);
                                }
                                LoggerService.invokeInfoLogg(
                                    'user created new account');
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            HomeScreen(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              })
                            : PasswordBottomSheet.provideWithPassword(
                                context, _activeAccount, (password) async {
                                AccountModel account =
                                    await accountCubit.addAccount();
                                if (SettingsHelper.isBitcoin()) {
                                  await bitcoinCubit
                                      .loadDetails(account.bitcoinAddress!);
                                }
                                LoggerService.invokeInfoLogg(
                                    'user created new account');
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            HomeScreen(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              });
                      },
                    );
                  } else {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                        shadowColor: Colors.transparent,
                        primary: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        side: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      child: Container(
                        height: _tileHeight,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1.0))),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _accountList[index].name,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headline4!,
                              ),
                              _accountList[index].index == _activeAccount.index
                                  ? SvgPicture.asset(
                                      'assets/wallet_enable_pink.svg',
                                      color: AppTheme.pinkColor,
                                    )
                                  : SvgPicture.asset(
                                      'assets/wallet_disable.svg',
                                      color: AppTheme.lightGreyColor,
                                    ),
                            ],
                          ),
                        ),
                      ),
                      onPressed: () async {
                        await lockHelper.provideWithLockChecker(context,
                            () async {
                          hideOverlay();
                          accountCubit
                              .updateActiveAccount(_accountList[index].index!);
                          await bitcoinCubit
                              .loadDetails(_accountList[index].bitcoinAddress!);
                        });
                      },
                    );
                  }
                },
              ),
            ),
          ),
        );
      });
      _overlayState!.insert(_overlayEntry!);
    }
  }
}
