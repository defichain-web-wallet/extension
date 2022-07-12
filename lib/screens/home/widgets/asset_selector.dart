import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/utils/custom_radio/custom_radio_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssetSelector extends StatefulWidget {
  late final String layoutSize;

  AssetSelector({Key? key, required this.layoutSize}) : super(key: key);

  @override
  State<AssetSelector> createState() => _AssetSelectorState();
}

class _AssetSelectorState extends State<AssetSelector> {
  int _startIndexBalances = 0;
  LockHelper lockHelper = LockHelper();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      if (state.status == AccountStatusList.success) {
        var balances = state.activeAccount!.balanceList!
            .where((el) => !el.isHidden!)
            .toList();

        final isScrollable = balances.length > 3;
        return Stack(
          children: [
            isScrollable
                ? Positioned(
                    top: 5,
                    left: -6,
                    child: _buildPrevIconButton(balances.length),
                  )
                : Container(),
            isScrollable
                ? Positioned(
                    top: 26,
                    left: 14,
                    child: Container(
                      height: (widget.layoutSize == 'small') ? 150 : 200,
                      child: Image.asset(
                        'assets/images/ellipse3.png',
                        color: Theme.of(context).appBarTheme.foregroundColor!,
                      ),
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ClipRect(
                child: _buildCustomRadioSelector(state, isScrollable, balances),
              ),
            ),
            isScrollable
                ? Positioned(
                    bottom: 5,
                    left: -6,
                    child: _buildNextIconButton(balances.length),
                  )
                : Container(),
          ],
        );
      } else {
        return Container();
      }
    });
  }

  Widget _buildCustomRadioSelector(state, isScrollable, balances) {
    var activeToken = state.activeAccount.activeToken;
    var balancesList;
    if (balances.length >= 3) {
      balancesList =
          balances.sublist(_startIndexBalances, _startIndexBalances + 3);
    } else {
      balancesList = balances;
    }

    List<Widget> result = [];
    balancesList.asMap().forEach((index, balance) {
      final bool selected = balance.token == activeToken;

      result.add(
        ListTile(
          contentPadding: (widget.layoutSize == 'small')
              ? EdgeInsets.only(
                  left: 10.0 + ((index == 1 && isScrollable) ? 11 : 0),
                  bottom: 3)
              : EdgeInsets.only(
                  left: 15.0 + ((index == 1 && isScrollable) ? 16 : 0),
                  bottom: 10,
                  top: 8,
                ),
          title: Align(
            alignment: Alignment(-1.4, 0),
            child: Text(
              TokensHelper().getTokenFormat(balance.token),
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          leading: CustomRadioButton(
            color: balance.color,
            selected: selected,
            onChange: (newVal) {
              _changeToken(state, balance);
            },
          ),
          onTap: () {
            if (!selected) _changeToken(state, balance);
          },
        ),
      );
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: result,
    );
  }

  void _changeToken(state, balance) {
    lockHelper.provideWithLockChecker(context, () async {
      state.activeAccount.activeToken = balance.token;
      AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
      accountCubit.updateActiveToken(balance.token);
      if (SettingsHelper.settings.network! == 'testnet') {
        accountCubit.saveAccountsToStorage(
            null, null, state.accounts, state.masterKeyPair, state.accessToken);
      } else {
        accountCubit.saveAccountsToStorage(
            state.accounts, state.masterKeyPair, null, null, state.accessToken);
      }
    });
  }

  Widget _buildPrevIconButton(balanceListLength) => Transform.rotate(
        angle: 0.8,
        child: IconButton(
          splashRadius: 22,
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).appBarTheme.actionsIconTheme!.color,
          ),
          onPressed: () {
            setState(() => {
                  if (_startIndexBalances > 0)
                    {_startIndexBalances--}
                  else
                    {_startIndexBalances = balanceListLength - 3}
                });
          },
        ),
      );

  Widget _buildNextIconButton(balanceListLength) => Transform.rotate(
        angle: 5.5,
        child: IconButton(
          splashRadius: 22,
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).appBarTheme.actionsIconTheme!.color,
          ),
          onPressed: () {
            setState(() => {
                  if (_startIndexBalances < balanceListLength - 3)
                    {_startIndexBalances++}
                  else
                    {_startIndexBalances = 0}
                });
          },
        ),
      );
}
