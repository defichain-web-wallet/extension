import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/models/lock_reward_routes_model.dart';
import 'package:defi_wallet/widgets/fields/invested_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RewardRoutesList extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isDisabled;

  const RewardRoutesList({
    Key? key,
    required this.controllers,
    required this.focusNodes,
    required this.isDisabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);

    return BlocBuilder<LockCubit, LockState>(
      builder: (context, lockState) {
        List<LockRewardRoutesModel> rewards =
            lockState.lockStakingDetails!.rewardRoutes!;

        if (lockState.lastEditedRewardIndex > 0) {
          focusNodes[lockState.lastEditedRewardIndex].requestFocus();
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(rewards.length, (index) {
            return InvestedField(
              label: rewards[index].label!,
              tokenName: rewards[index].targetAsset!,
              controller: controllers[index],
              focusNode: focusNodes[index],
              isDeleteBtn: isDisabled,
              isDisable: !isDisabled,
              isReinvest: rewards[index].label! == 'Reinvest',
              onRemove: () {
                lockCubit.removeRewardRoute(index);
              },
              onChange: (value) {
                if (value.isNotEmpty) {
                  List<double> rewardPercentages =
                  controllers.map((e) => double.parse(e.text) / 100).toList();
                  lockCubit.updateRewardPercentages(
                    rewardPercentages,
                    index: index,
                  );
                }
              },
            );
          }),
        );
      },
    );
  }
}
