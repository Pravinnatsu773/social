import 'package:flutter_bloc/flutter_bloc.dart';

// Define the states

// Define the Cubit
class BottomNavCubit extends Cubit<int> {
  BottomNavCubit() : super(0);

  void updateIndex(int newIndex) {
    emit(newIndex);
  }
}
