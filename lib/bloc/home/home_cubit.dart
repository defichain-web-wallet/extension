import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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

  updateTabIndex({int index = 0}) {
    emit(state.copyWith(
      tabIndex: index,
    ));
  }

  updateScrollView({Widget? widget}) {
    emit(state.copyWith(
      scrollView: widget,
      isShownHome: widget == null,
    ));
  }
}
