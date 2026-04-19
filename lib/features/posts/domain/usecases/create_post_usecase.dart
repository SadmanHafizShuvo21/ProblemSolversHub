import 'package:problem_solvers_hub/shared/models/post.dart';
import 'package:problem_solvers_hub/features/posts/domain/repositories/posts_repository.dart';

class CreatePostUsecase {
  final PostsRepository repository;

  CreatePostUsecase(this.repository);

  Future<Post> call({required Post post, required String userId}) {
    return repository.createPost(post, userId);
  }
}
