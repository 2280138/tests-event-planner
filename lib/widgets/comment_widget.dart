import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_app/blocs/comment/comment_bloc.dart';
import 'package:event_app/blocs/comment/comment_event.dart';
import 'package:event_app/blocs/comment/comment_state.dart';
// ignore: unused_import
import 'package:event_app/models/comment_model.dart';

class CommentWidget extends StatefulWidget {
  final String postId;

  const CommentWidget({super.key, required this.postId});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final TextEditingController _controller = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  @override
  void initState() {
    super.initState();
    print("Dispatching LoadComments event for postId: ${widget
        .postId}"); // Add this print statement
    context.read<CommentBloc>().add(LoadComments(widget.postId));
  }


  void _submitComment() {
    final commentText = _controller.text.trim();
    if (commentText.isEmpty || currentUser == null) return;

    context.read<CommentBloc>().add(AddComment(
      postId: widget.postId,
      userId: currentUser!.uid,
      userName: currentUser!.displayName ?? 'Anonymous',
      comment: commentText,
    ));

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    print("Building CommentWidget for postId: ${widget
        .postId}"); // Add this print
    return Column(
      children: [
        const Text("💬 Comments",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        BlocBuilder<CommentBloc, CommentState>(
          builder: (context, state) {
            if (state is CommentLoading) {
              return const CircularProgressIndicator();
            } else if (state is CommentLoaded) {
              final comments = state.comments;
              if (comments.isEmpty) {
                return const Text("No comments yet. Be the first to comment!");
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return ListTile(
                    leading: CircleAvatar(
                        child: Text(comment.userName[0].toUpperCase())),
                    title: Text(comment.userName),
                    subtitle: Text(comment.comment),
                  );
                },
              );
            } else if (state is CommentError) {
              return Text(state.message);
            }
            return const SizedBox();
          },
        ),
        const SizedBox(height: 10),
        if (currentUser != null)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Write a comment...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: _submitComment, child: const Text("Post")),
            ],
          ),

      ],
    );
  }


}
