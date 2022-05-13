class FocusModel {
  bool isFocus;
  FocusModel({this.isFocus = false});

  void setFocus(FocusModel data, bool focus) {
    data.isFocus = focus;
  }
}