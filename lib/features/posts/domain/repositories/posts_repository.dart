import 'package:problem_solvers_hub/features/posts/domain/entities/comment.dart';
import 'package:problem_solvers_hub/shared/models/post.dart';

abstract class PostsRepository {
  /// Create a new post
  Future<Post> createPost(Post post, String userId);

  /// Get all posts
  Future<List<Post>> getAllPosts();

  /// Get user's posts
  Future<List<Post>> getUserPosts(String userId);

  /// Get a single post by ID
  Future<Post?> getPostById(String postId);

  /// Update a post
  Future<void> updatePost(Post post);

  /// Delete a post
  Future<void> deletePost(String postId);

  /// Like a post
  Future<void> likePost(String postId);

  /// Unlike a post
  Future<void> unlikePost(String postId);

  /// Add a comment to a post
  Future<PostComment> addComment(String postId, PostComment comment);

  /// Stream comments for a post
  Stream<List<PostComment>> getCommentsStream(String postId);

  /// Stream a single post for real-time updates
  Stream<Post?> getPostByIdStream(String postId);

  /// Increment view count
  Future<void> incrementViews(String postId);

  /// Stream of all posts (real-time updates)
  Stream<List<Post>> getAllPostsStream();

  /// Stream of user's posts (real-time updates)
  Stream<List<Post>> getUserPostsStream(String userId);
}
