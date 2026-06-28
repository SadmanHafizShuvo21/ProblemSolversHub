import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment_model.dart';
import '../models/post_model.dart';

class FirebasePostsDatasource {
  final FirebaseFirestore _firestore;

  FirebasePostsDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionName = 'posts';

  /// Create a new post in Firestore
  Future<PostModel> createPost(PostModel post, String userId) async {
    try {
      // Create a new document reference
      final docRef = _firestore.collection(_collectionName).doc();

      // Create post data with document ID and user ID
      final postData = post.toJson();
      postData['id'] = docRef.id;
      postData['userId'] = userId;
      postData['createdAt'] = FieldValue.serverTimestamp();
      postData['updatedAt'] = FieldValue.serverTimestamp();

      // Save to Firestore
      await docRef.set(postData);

      // Return the created post with the document ID
      return PostModel.fromJson(postData, docRef.id);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  /// Get all posts (recent first)
  Future<List<PostModel>> getAllPosts() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  /// Get posts by user ID
  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      final posts = snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data(), doc.id))
          .toList();
      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return posts;
    } catch (e) {
      throw Exception('Failed to fetch user posts: $e');
    }
  }

  /// Get a single post by ID
  Future<PostModel?> getPostById(String postId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(postId)
          .get();

      if (!doc.exists) return null;

      return PostModel.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch post: $e');
    }
  }

  /// Update a post
  Future<void> updatePost(PostModel post) async {
    try {
      if (post.id == null) throw Exception('Post ID is required for update');

      final updateData = post.toJson();
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collectionName)
          .doc(post.id)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection(_collectionName).doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  static const String _likesCollection = 'likes';
  static const String _commentsCollection = 'comments';
  static const String _viewsCollection = 'views';

  /// Like a post by a user
  Future<void> likePost(String postId, String userId) async {
    try {
      final likeId = '${userId}_$postId';
      final likeRef = _firestore.collection(_likesCollection).doc(likeId);
      final snapshot = await likeRef.get();
      if (snapshot.exists) return;

      await likeRef.set({
        'postId': postId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection(_collectionName).doc(postId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  /// Check whether a specific user liked a post
  Future<bool> hasUserLikedPost(String postId, String userId) async {
    try {
      final likeId = '${userId}_$postId';
      final doc = await _firestore.collection(_likesCollection).doc(likeId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check like status: $e');
    }
  }

  /// Stream like status for a user on a post
  Stream<bool> getLikeStatusStream(String postId, String userId) {
    final likeId = '${userId}_$postId';
    return _firestore.collection(_likesCollection).doc(likeId).snapshots().map(
          (doc) => doc.exists,
        );
  }

  /// Unlike a post by a user
  Future<void> unlikePost(String postId, String userId) async {
    try {
      final likeId = '${userId}_$postId';
      final likeRef = _firestore.collection(_likesCollection).doc(likeId);
      final snapshot = await likeRef.get();
      if (!snapshot.exists) return;

      await likeRef.delete();
      await _firestore.collection(_collectionName).doc(postId).update({
        'likes': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }

  /// Stream total likes count for a post
  Stream<int> getLikesCountStream(String postId) {
    return _firestore
        .collection(_likesCollection)
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Stream of all posts (real-time updates)
  Stream<List<PostModel>> getAllPostsStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PostModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Stream of user's posts (real-time updates)
  Stream<List<PostModel>> getUserPostsStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final posts = snapshot.docs
              .map((doc) => PostModel.fromJson(doc.data(), doc.id))
              .toList();
          posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return posts;
        });
  }

  /// Stream a single post by ID for real-time updates
  Stream<PostModel?> getPostByIdStream(String postId) {
    return _firestore.collection(_collectionName).doc(postId).snapshots().map((
      doc,
    ) {
      if (!doc.exists || doc.data() == null) return null;
      return PostModel.fromJson(doc.data()!, doc.id);
    });
  }

  /// Record a unique view for a user on a post
  Future<void> recordView(String postId, String userId) async {
    try {
      final viewId = '${userId}_$postId';
      final viewRef = _firestore.collection(_viewsCollection).doc(viewId);
      final snapshot = await viewRef.get();
      if (snapshot.exists) return;

      await viewRef.set({
        'postId': postId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection(_collectionName).doc(postId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to record view: $e');
    }
  }

  /// Check whether a user has already viewed a post
  Future<bool> hasUserViewedPost(String postId, String userId) async {
    try {
      final viewId = '${userId}_$postId';
      final snapshot = await _firestore.collection(_viewsCollection).doc(viewId).get();
      return snapshot.exists;
    } catch (e) {
      throw Exception('Failed to check view status: $e');
    }
  }

  /// Increment the view count for a post without tracking a specific user
  Future<void> incrementViews(String postId) async {
    try {
      await _firestore.collection(_collectionName).doc(postId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment views: $e');
    }
  }

  /// Stream total views count for a post
  Stream<int> getViewsCountStream(String postId) {
    return _firestore
        .collection(_viewsCollection)
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Create a comment in the top-level comments collection
  Future<CommentModel> createComment(
    String postId,
    CommentModel comment,
  ) async {
    try {
      final commentRef = _firestore.collection(_commentsCollection).doc();

      final commentData = comment.toJson();
      commentData['id'] = commentRef.id;
      commentData['postId'] = postId;
      commentData['timestamp'] = FieldValue.serverTimestamp();

      await commentRef.set(commentData);

      await _firestore.collection(_collectionName).doc(postId).update({
        'comments': FieldValue.increment(1),
      });

      return CommentModel.fromJson(commentData, commentRef.id);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  /// Stream comments for a single post from the top-level collection
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection(_commentsCollection)
        .where('postId', isEqualTo: postId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Stream comment count for a single post
  Stream<int> getCommentsCountStream(String postId) {
    return _firestore
        .collection(_commentsCollection)
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
}
