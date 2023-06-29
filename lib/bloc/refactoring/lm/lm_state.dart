part of 'lm_cubit.dart';

enum LmStatusList { initial, loading, success, restore, failure }

class LmState extends Equatable {
  final LmStatusList status;
  final List<AbstractLmProviderModel>? lmList;
  final String? maxApr;
  final String? averageApr;
  final List<BalanceModel>? pairBalances;
  final List<LmPoolModel>? availablePools;
  final List<LmPoolModel>? foundedPools;
  final AbstractNetworkModel? activeNetwork;
  final AbstractLmProviderModel? lmProvider;
  final List<double>? availableBalances;

  LmState({
    this.status = LmStatusList.initial,
    this.lmList,
    this.maxApr,
    this.averageApr,
    this.pairBalances,
    this.availablePools,
    this.foundedPools,
    this.activeNetwork,
    this.lmProvider,
    this.availableBalances,
  });

  double get balance =>
      this.pairBalances!.fold(0.0, (sum, balance) => sum + balance.balance);

  @override
  List<Object?> get props => [
        status,
        lmList,
    maxApr,
    averageApr,
    pairBalances,
    availablePools,
    foundedPools,
    activeNetwork,
    lmProvider,
    availableBalances,
      ];

  LmState copyWith({
    LmStatusList? status,
    List<AbstractLmProviderModel>? lmList,
    String? maxApr,
    String? averageApr,
    List<BalanceModel>? pairBalances,
    List<LmPoolModel>? availablePools,
    List<LmPoolModel>? foundedPools,
    AbstractNetworkModel? activeNetwork,
    AbstractLmProviderModel? lmProvider,
    List<double>? availableBalances,
  }) {
    return LmState(
      status: status ?? this.status,
      lmList: lmList ?? this.lmList,
      maxApr: maxApr ?? this.maxApr,
      averageApr: averageApr ?? this.averageApr,
      pairBalances: pairBalances ?? this.pairBalances,
      availablePools: availablePools ?? this.availablePools,
      foundedPools: foundedPools ?? this.foundedPools,
      activeNetwork: activeNetwork ?? this.activeNetwork,
      lmProvider: lmProvider ?? this.lmProvider,
      availableBalances: availableBalances ?? this.availableBalances,
    );
  }
}
