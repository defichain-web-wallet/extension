class StakingModel {
  int id;
  String status;
  String strategy;
  String depositAddress;
  List<MinimalDeposit> minimalDeposits;
  double fee;
  List<StakingBalanceModel> balances;
  List<RewardRouteModel> rewardRoutes;

  StakingModel({
    required this.id,
    required this.status,
    required this.strategy,
    required this.depositAddress,
    required this.minimalDeposits,
    required this.fee,
    required this.balances,
    required this.rewardRoutes,
  });

  factory StakingModel.fromJson(Map<String, dynamic> json) {
    var minimalDepositsList = json['minimalDeposits'] as List;
    var balancesList = json['balances'] as List;
    var rewardRoutesList = json['rewardRoutes'] as List;
    List<MinimalDeposit> minimalDeposits =
        minimalDepositsList.map((i) => MinimalDeposit.fromJson(i)).toList();
    List<StakingBalanceModel> balances =
        balancesList.map((i) => StakingBalanceModel.fromJson(i)).toList();
    List<RewardRouteModel> rewardRoutes =
        rewardRoutesList.map((i) => RewardRouteModel.fromJson(i)).toList();
    return StakingModel(
      id: json['id'],
      status: json['status'],
      strategy: json['strategy'],
      depositAddress: json['depositAddress'],
      minimalDeposits: minimalDeposits,
      fee: json['fee'],
      balances: balances,
      rewardRoutes: rewardRoutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'strategy': strategy,
        'depositAddress': depositAddress,
        'minimalDeposits':
            List<dynamic>.from(minimalDeposits.map((x) => x.toJson())),
        'fee': fee,
        'balances': List<dynamic>.from(balances.map((x) => x.toJson())),
        'rewardRoutes': List<dynamic>.from(rewardRoutes.map((x) => x.toJson())),
      };
}

class MinimalDeposit {
  double amount;
  String asset;

  MinimalDeposit({
    required this.amount,
    required this.asset,
  });

  factory MinimalDeposit.fromJson(Map<String, dynamic> json) => MinimalDeposit(
        amount: json['amount'],
        asset: json['asset'],
      );

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'asset': asset,
      };
}

class StakingBalanceModel {
  String asset;
  double balance;
  double pendingDeposits;
  double pendingWithdrawals;

  StakingBalanceModel({
    required this.asset,
    required this.balance,
    required this.pendingDeposits,
    required this.pendingWithdrawals,
  });

  factory StakingBalanceModel.fromJson(Map<String, dynamic> json) => StakingBalanceModel(
        asset: json['asset'],
        balance: json['balance'],
        pendingDeposits: json['pendingDeposits'],
        pendingWithdrawals: json['pendingWithdrawals'],
      );

  Map<String, dynamic> toJson() => {
        'asset': asset,
        'balance': balance,
        'pendingDeposits': pendingDeposits,
        'pendingWithdrawals': pendingWithdrawals,
      };
}

class RewardRouteModel {
  int id;
  String label;
  double rewardPercent;
  String targetAsset;
  String targetAddress;
  String targetBlockchain;

  RewardRouteModel({
    required this.id,
    required this.label,
    required this.rewardPercent,
    required this.targetAsset,
    required this.targetAddress,
    required this.targetBlockchain,
  });

  factory RewardRouteModel.fromJson(Map<String, dynamic> json) => RewardRouteModel(
        id: json['id'],
        label: json['label'],
        rewardPercent: json['rewardPercent'],
        targetAsset: json['targetAsset'],
        targetAddress: json['targetAddress'],
        targetBlockchain: json['targetBlockchain'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'rewardPercent': rewardPercent,
        'targetAsset': targetAsset,
        'targetAddress': targetAddress,
        'targetBlockchain': targetBlockchain,
      };
}
