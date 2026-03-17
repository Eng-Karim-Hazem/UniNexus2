import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/community_model.dart';

class CommunityService {
  final CollectionReference _postsRef =
  FirebaseFirestore.instance.collection('community_posts');

  Future<void> createPost(CommunityPostModel post) async {
    try {
      await _postsRef.add(post.toMap());
    } catch (e) {
      throw Exception("Failed to add post: $e");
    }
  }

  Stream<List<CommunityPostModel>> getPostsStream() {
    return _postsRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommunityPostModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addReply(String postId, CommunityReplyModel reply) async {
    try {
      await _postsRef.doc(postId).collection('replies').add(reply.toMap());
      await _postsRef.doc(postId).update({
        'replyCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception("Failed to add reply: $e");
    }
  }

  Stream<List<CommunityReplyModel>> getRepliesStream(String postId) {
    return _postsRef
        .doc(postId)
        .collection('replies')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommunityReplyModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // --- ADDED DELETE FUNCTION ---
  Future<void> deletePost(String postId) async {
    try {
      // 1. Get reference to the replies sub-collection
      final repliesRef = _postsRef.doc(postId).collection('replies');

      // 2. Get all documents in the sub-collection
      final snapshot = await repliesRef.get();

      // 3. Delete each reply document
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // 4. Finally, delete the main post document
      await _postsRef.doc(postId).delete();
    } catch (e) {
      throw Exception("Failed to delete post and replies: $e");
    }
  }
}