import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:problem_solvers_hub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:problem_solvers_hub/features/create/models/create_post_form_data.dart';
import 'package:problem_solvers_hub/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:problem_solvers_hub/shared/models/post.dart';

part 'create_post_event.dart';
part 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final CreatePostUsecase createPostUsecase;
  final AuthBloc authBloc;

  CreatePostBloc({required this.createPostUsecase, required this.authBloc})
    : super(const CreatePostInitial()) {
    on<CreatePostSubmitEvent>(_onCreatePostSubmit);
  }

  /// Handle post submission
  Future<void> _onCreatePostSubmit(
    CreatePostSubmitEvent event,
    Emitter<CreatePostState> emit,
  ) async {
    emit(const CreatePostLoading());
    try {
      // Get current user from auth bloc
      final authState = authBloc.state;
      if (authState is! AuthAuthenticated) {
        emit(const CreatePostError('User not authenticated'));
        return;
      }

      final user = authState.user;
      final formData = event.formData;

      // Create post with user info
      final post = Post(
        userId: user.id,
        userAvatar: user.photoUrl ?? 'https://via.placeholder.com/40',
        userName: user.displayName,
        problemTitle: formData.problemName,
        platform: formData.platform,
        difficulty: formData.difficulty,
        tags: formData.tags,
        approachPreview: formData.approachExplanation,
        approachFull: formData.approachExplanation,
        codeSnippet: formData.codeSnippet,
        likes: 0,
        comments: 0,
        views: 0,
        timestamp: DateTime.now(),
      );

      // Save to Firestore
      final createdPost = await createPostUsecase(post: post, userId: user.id);

      emit(CreatePostSuccess(createdPost));
    } catch (e) {
      emit(CreatePostError(e.toString()));
    }
  }
}
