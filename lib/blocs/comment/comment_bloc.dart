import 'package:flutter_bloc/flutter_bloc.dart';
import 'comment_event.dart';
import 'comment_state.dart';
import '../../repositories/comment_repository.dart';
import '../../models/comment_model.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository commentRepo;

  CommentBloc(this.commentRepo) : super(CommentInitial()) {
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
  }

  void _onLoadComments(LoadComments event, Emitter<CommentState> emit) async {
    emit(CommentLoading());
    try {
      await emit.forEach<List<CommentModel>>(
        commentRepo.getCommentsForPost(event.postId),
        onData: (comments) {
          print("Loaded comments: ${comments.length}");  // Debugging line
          return CommentLoaded(comments);
        },
        onError: (_, __) => CommentError("Failed to load comments"),
      );
    } catch (e) {
      print("Error: $e");  // Debugging line
      emit(CommentError("Failed to load comments"));
    }
  }


  Future<void> _onAddComment(AddComment event, Emitter<CommentState> emit) async {
    try {
      await commentRepo.addComment(
        postId: event.postId,
        userId: event.userId,
        userName: event.userName,
        comment: event.comment,
      );

      // 🔁 Reload comments after adding
      add(LoadComments(event.postId));
    } catch (e) {
      emit(CommentError("Failed to add comment"));
    }
  }

}
