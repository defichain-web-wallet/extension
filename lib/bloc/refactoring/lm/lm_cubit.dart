import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_lm_provider_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'lm_state.dart';

class LmCubit extends Cubit<LmState> {
  LmCubit() : super(LmState());

  setInitial() {
    emit(state.copyWith(status: LmStatusList.initial));
  }

  search(String value) {
    if (value == '') {
      emit(state.copyWith(foundedPools: state.availablePools));
    } else {
      List<LmPoolModel> pools = [];

      state.availablePools!.forEach((element) {
        if (element.displaySymbol.contains(value.toUpperCase())) {
          pools.add(element);
        }
      });
      emit(state.copyWith(foundedPools: pools));
    }
  }

  List<double> calculateAmountFromLiqudity(int amount, LmPoolModel pair) {
    var amountA =
        (amount / state.activeNetwork!.toSatoshi(pair.percentages![2])) *
            pair.percentages![0];
    var amountB =
        (amount / state.activeNetwork!.toSatoshi(pair.percentages![2])) *
            pair.percentages![1];
    return [amountA, amountB];
  }

  double calculateShareOfPool(
      int balance, double currentSliderValue, LmPoolModel pair) {
    return (balance *
        (currentSliderValue / 100) /
        state.activeNetwork!.toSatoshi(pair.percentages![2]));
  }

  Future<TxErrorModel> removeLiqudity(
      String password, LmPoolModel pool, double amount, context) {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var application = walletCubit.state.applicationModel!;
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    return state.lmProvider!.removeBalance(
        account, activeNetwork, password, pool, amount, application);
  }

  getAvailableBalances(LmPoolModel pool, context) async {
    emit(state.copyWith(
      status: LmStatusList.loading,
    ));
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var balanceA = await activeNetwork.getAvailableBalance(
        account: account, token: pool.tokens[0], type: TxType.addLiq);
    var balanceB = await activeNetwork.getAvailableBalance(
        account: account, token: pool.tokens[1], type: TxType.addLiq);
    emit(state.copyWith(
        status: LmStatusList.success, availableBalances: [balanceA, balanceB]));
  }

  List<BalanceModel> getBalances(LmPoolModel pool, context) {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var balances = account.getPinnedBalances(activeNetwork);
    BalanceModel balanceA = BalanceModel(balance: 0, token: pool.tokens[0]);
    BalanceModel balanceB = BalanceModel(balance: 0, token: pool.tokens[1]);
    balances.forEach((element) {
      if (element.token != null) {
        if (element.token!.compare(pool.tokens[0])) {
          balanceA.balance = element.balance;
        }
        if (element.token!.compare(pool.tokens[1])) {
          balanceB.balance = element.balance;
        }
      }
    });
    return [balanceA, balanceB];
  }

  int getPoolBalance(LmPoolModel pool, context) {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var balances = account.getPinnedBalances(activeNetwork, onlyPairs: true);
    int balance = 0;
    balances.forEach((element) {
      if (element.lmPool != null) {
        if (element.lmPool!.id == pool.id) {
          balance = element.balance;
        }
      }
    });
    return balance;
  }

  Future<TxErrorModel> addLiqudity(
      String password, LmPoolModel pool, List<double> amounts, context) {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var application = walletCubit.state.applicationModel!;
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    return state.lmProvider!.addBalance(
        account, activeNetwork, password, pool, amounts, application);
  }

  init(context) async {
    emit(state.copyWith(status: LmStatusList.loading));

    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var pairBalances =
        account.getPinnedBalances(activeNetwork, onlyPairs: true);
    var lmProviders = activeNetwork.getLmProviders();
    var lmProvider = lmProviders[0];
    var pools = await lmProvider.getAvailableLmPools(activeNetwork);
    pairBalances.forEach((balance) {
      var pool = pools.firstWhere((pool) => balance.lmPool!.compare(pool));
      balance.lmPool = pool;
    });
    var maxApr = _getMaxAPR(pools);
    var averageApr = _calculateAverageAPR(pools);
    emit(state.copyWith(
        status: LmStatusList.success,
        //liquidity
        averageApr: _getAprFormat(averageApr, false),
        maxApr: _getAprFormat(maxApr, true),
        pairBalances: pairBalances,
        availablePools: pools,
        foundedPools: pools,
        activeNetwork: activeNetwork,
        lmProvider: lmProvider));
  }

  double _getMaxAPR(List<LmPoolModel> tokenPairs) {
    double maxValue = 0;

    tokenPairs.forEach((element) {
      if (maxValue < element.apr!) {
        maxValue = element.apr!;
      }
    });
    return maxValue;
  }

  double _calculateAverageAPR(List<LmPoolModel> tokenPairs) {
    double totalPairsAPR = 0;
    int countPairs = 0;
    tokenPairs.forEach((element) {
      countPairs += 1;
      totalPairsAPR += element.apr!;
    });

    return countPairs > 0 ? totalPairsAPR / countPairs : 0;
  }

  String _getAprFormat(double apr, bool isPersentSymbol) {
    dynamic result;

    if (apr != 0) {
      result =
          '${(apr * 100).toStringAsFixed(2)} ${isPersentSymbol == true ? '%' : ''}';
    } else {
      result = 'N/A';
    }
    return '$result';
  }
}
