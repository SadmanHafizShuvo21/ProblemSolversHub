part of 'create_post_bloc.dart';

abstract class CreatePostState extends Equatable {
  const CreatePostState();

  @override
  List<Object?> get props => [];
}

class CreatePostInitial extends CreatePostState {
  const CreatePostInitial();
}

class CreatePostLoading extends CreatePostState {
  const CreatePostLoading();
}

class CreatePostSuccess extends CreatePostState {
  final Post post;

  const CreatePostSuccess(this.post);

  @override
  List<Object?> get props => [post];
}

class CreatePostError extends CreatePostState {
  final String message;

  const CreatePostError(this.message);

  @override
  List<Object?> get props => [message];
}
