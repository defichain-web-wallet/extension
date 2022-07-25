import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());

  onHide() {
    emit(state.copyWith(
      status: HomeStatusList.hide,
    ));
  }

  onShow() {
    emit(state.copyWith(
      status: HomeStatusList.show,
    ));
  }
}
