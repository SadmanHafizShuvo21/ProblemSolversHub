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

  /// Like a post as a specific user
  Future<void> likePost(String postId, {String? userId});

  /// Unlike a post as a specific user
  Future<void> unlikePost(String postId, {String? userId});

  /// Check whether a user has already liked a post
  Future<bool> hasUserLikedPost(String postId, String userId);

  /// Stream the current user's like status for a post
  Stream<bool> getLikeStatusStream(String postId, String userId);

  /// Stream the total likes count for a post
  Stream<int> getLikesCountStream(String postId);

  /// Add a comment to a post
  Future<PostComment> addComment(String postId, PostComment comment);

  /// Stream comments for a post
  Stream<List<PostComment>> getCommentsStream(String postId);

  /// Stream the total comments count for a post
  Stream<int> getCommentsCountStream(String postId);

  /// Stream a single post for real-time updates
  Stream<Post?> getPostByIdStream(String postId);

  /// Record a view for a specific user, counting only once per user per post
  Future<void> recordView(String postId, {String? userId});

  /// Check whether a user has viewed a post
  Future<bool> hasUserViewedPost(String postId, String userId);

  /// Stream the total views count for a post
  Stream<int> getViewsCountStream(String postId);

  /// Increment view count
  Future<void> incrementViews(String postId);

  /// Stream of all posts (real-time updates)
  Stream<List<Post>> getAllPostsStream();

  /// Stream of user's posts (real-time updates)
  Stream<List<Post>> getUserPostsStream(String userId);
}
