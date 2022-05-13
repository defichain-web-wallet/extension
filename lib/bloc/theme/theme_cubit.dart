import 'package:bloc/bloc.dart';
import 'package:defi_wallet/bloc/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeChangedState());

  Future<void> changeTheme() async {
    emit(ThemeChangedState());
  }
}