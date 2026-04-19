part of 'create_post_bloc.dart';

abstract class CreatePostEvent extends Equatable {
  const CreatePostEvent();

  @override
  List<Object?> get props => [];
}

class CreatePostSubmitEvent extends CreatePostEvent {
  final CreatePostFormData formData;

  const CreatePostSubmitEvent(this.formData);

  @override
  List<Object?> get props => [formData];
}
