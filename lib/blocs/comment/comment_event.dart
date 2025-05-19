import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadComments extends CommentEvent {
  final String postId;

  LoadComments(this.postId);
}

class AddComment extends CommentEvent {
  final String postId;
  final String userId;
  final String userName;
  final String comment;

  AddComment({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.comment,
  });
}
