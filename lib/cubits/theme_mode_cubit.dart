import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeModeCubit extends Cubit<bool> {
  ThemeModeCubit() : super(true);

  void toggle() {
    emit(!state);
  }
}
