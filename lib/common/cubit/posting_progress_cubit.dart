import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'posting_progress_state.dart';

class PostingProgressCubit extends Cubit<PostingProgressState> {
  PostingProgressCubit() : super(PostingProgressInitial());

  inProgress() {
    emit(PostingProgressLoading());
  }

  done() {
    emit(PostingProgressLoaded());
  }
}
