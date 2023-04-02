import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/models/easter_egg_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

part 'easter_egg_state.dart';

class EasterEggCubit extends Cubit<EasterEggState> {
  EasterEggCubit() : super(EasterEggState());

  getStatuses() async {
    emit(state.copyWith(
      status: EasterEggStatusList.loading,
      eggsStatus: state.eggsStatus,
    ));

    EasterEggModel currentStatuses;

    var box = await Hive.openBox(HiveBoxes.client);
    var easterEggJson;
    easterEggJson = await box.get(HiveNames.easterEgg);
    box.close();
    try {
      if (easterEggJson == null) {
        currentStatuses = EasterEggModel();
      } else {
        currentStatuses = EasterEggModel.fromJson(easterEggJson);
      }
    } catch (err) {
      currentStatuses = EasterEggModel();
    }

    emit(state.copyWith(
      status: EasterEggStatusList.success,
      eggsStatus: currentStatuses,
    ));
  }

  saveStatuses(EasterEggModel newStatuses) async {
    emit(state.copyWith(
      status: EasterEggStatusList.loading,
      eggsStatus: newStatuses,
    ));

    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.easterEgg, newStatuses.toJson());
    box.close();

    emit(state.copyWith(
      status: EasterEggStatusList.success,
      eggsStatus: newStatuses,
    ));
  }
}
