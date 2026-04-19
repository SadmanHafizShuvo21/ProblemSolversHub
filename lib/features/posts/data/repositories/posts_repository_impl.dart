import 'package:problem_solvers_hub/shared/models/post.dart';
import 'package:problem_solvers_hub/features/posts/data/datasources/firebase_posts_datasource.dart';
import 'package:problem_solvers_hub/features/posts/data/models/comment_model.dart';
import 'package:problem_solvers_hub/features/posts/data/models/post_model.dart';
import 'package:problem_solvers_hub/features/posts/domain/entities/comment.dart';
import 'package:problem_solvers_hub/features/posts/domain/repositories/posts_repository.dart';

class PostsRepositoryImpl implements PostsRepository {
  final FirebasePostsDatasource datasource;

  PostsRepositoryImpl(this.datasource);

  @override
  Future<Post> createPost(Post post, String userId) async {
    final postModel = PostModel.fromPost(post);
    final result = await datasource.createPost(postModel, userId);
    return result.toEntity();
  }

  @override
  Future<List<Post>> getAllPosts() async {
    final posts = await datasource.getAllPosts();
    return posts.map((p) => p.toEntity()).toList();
  }

  @override
  Future<List<Post>> getUserPosts(String userId) async {
    final posts = await datasource.getUserPosts(userId);
    return posts.map((p) => p.toEntity()).toList();
  }

  @override
  Future<Post?> getPostById(String postId) async {
    final post = await datasource.getPostById(postId);
    return post?.toEntity();
  }

  @override
  Future<void> updatePost(Post post) async {
    final postModel = PostModel.fromPost(post);
    await datasource.updatePost(postModel);
  }

  @override
  Future<void> deletePost(String postId) async {
    await datasource.deletePost(postId);
  }

  @override
  Future<void> likePost(String postId) async {
    await datasource.likePost(postId);
  }

  @override
  Future<void> unlikePost(String postId) async {
    await datasource.unlikePost(postId);
  }

  @override
  Future<PostComment> addComment(String postId, PostComment comment) async {
    final commentModel = CommentModel.fromPostComment(comment);
    final result = await datasource.createComment(postId, commentModel);
    return result.toEntity();
  }

  @override
  Stream<List<PostComment>> getCommentsStream(String postId) {
    return datasource
        .getCommentsStream(postId)
        .map(
          (comments) => comments.map((comment) => comment.toEntity()).toList(),
        );
  }

  @override
  Stream<Post?> getPostByIdStream(String postId) {
    return datasource.getPostByIdStream(postId).map((post) => post?.toEntity());
  }

  @override
  Future<void> incrementViews(String postId) async {
    await datasource.incrementViews(postId);
  }

  @override
  Stream<List<Post>> getAllPostsStream() {
    return datasource.getAllPostsStream().map(
      (posts) => posts.map((p) => p.toEntity()).toList(),
    );
  }

  @override
  Stream<List<Post>> getUserPostsStream(String userId) {
    return datasource
        .getUserPostsStream(userId)
        .map((posts) => posts.map((p) => p.toEntity()).toList());
  }
}
