import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/problem_model.dart';

class FirebaseProblemsDataSource {
  final FirebaseFirestore _firestore;

  FirebaseProblemsDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionName = 'problems';

  /// Create a new problem in Firestore
  Future<ProblemModel> createProblem(
    ProblemModel problem,
    String userId,
  ) async {
    try {
      // Create a new document reference
      final docRef = _firestore.collection(_collectionName).doc();

      // Create problem data with document ID and user ID
      final problemData = problem.toJson();
      problemData['id'] = docRef.id;
      problemData['userId'] = userId;
      problemData['createdAt'] = FieldValue.serverTimestamp();
      problemData['updatedAt'] = FieldValue.serverTimestamp();

      // Save to Firestore
      await docRef.set(problemData);

      // Return the created problem with the document ID
      return ProblemModel.fromJson({...problemData, 'id': docRef.id});
    } catch (e) {
      throw Exception('Failed to create problem: $e');
    }
  }

  /// Get all problems
  Future<List<ProblemModel>> getAllProblems() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProblemModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch problems: $e');
    }
  }

  /// Get problems by user ID
  Future<List<ProblemModel>> getUserProblems(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProblemModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user problems: $e');
    }
  }

  /// Get a single problem by ID
  Future<ProblemModel?> getProblemById(String problemId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(problemId)
          .get();

      if (!doc.exists) return null;

      return ProblemModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch problem: $e');
    }
  }

  /// Update a problem
  Future<void> updateProblem(ProblemModel problem) async {
    try {
      if (problem.id == null) {
        throw Exception('Problem ID is required for update');
      }

      final updateData = problem.toJson();
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collectionName)
          .doc(problem.id)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update problem: $e');
    }
  }

  /// Delete a problem
  Future<void> deleteProblem(String problemId) async {
    try {
      await _firestore.collection(_collectionName).doc(problemId).delete();
    } catch (e) {
      throw Exception('Failed to delete problem: $e');
    }
  }

  /// Stream of user's problems (real-time updates)
  Stream<List<ProblemModel>> getUserProblemsStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProblemModel.fromJson(doc.data()))
            .toList());
  }

  /// Stream of all problems (real-time updates)
  Stream<List<ProblemModel>> getAllProblemsStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProblemModel.fromJson(doc.data()))
            .toList());
  }
}
