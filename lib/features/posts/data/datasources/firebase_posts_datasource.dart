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
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data(), doc.id))
          .toList();
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

  /// Like a post
  Future<void> likePost(String postId) async {
    try {
      await _firestore.collection(_collectionName).doc(postId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  /// Unlike a post
  Future<void> unlikePost(String postId) async {
    try {
      await _firestore.collection(_collectionName).doc(postId).update({
        'likes': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }

  /// Increment view count
  Future<void> incrementViews(String postId) async {
    try {
      await _firestore.collection(_collectionName).doc(postId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment views: $e');
    }
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
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PostModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
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

  /// Create a comment in a post comments subcollection
  Future<CommentModel> createComment(
    String postId,
    CommentModel comment,
  ) async {
    try {
      final commentRef = _firestore
          .collection(_collectionName)
          .doc(postId)
          .collection('comments')
          .doc();

      final commentData = comment.toJson();
      commentData['id'] = commentRef.id;
      commentData['postId'] = postId;
      commentData['createdAt'] = FieldValue.serverTimestamp();

      await commentRef.set(commentData);

      await _firestore.collection(_collectionName).doc(postId).update({
        'comments': FieldValue.increment(1),
      });

      return CommentModel.fromJson(commentData, commentRef.id);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  /// Stream comments for a single post
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection(_collectionName)
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }
}
