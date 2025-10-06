import 'package:cloud_firestore/cloud_firestore.dart';

class BlogModel {
  final String id;
  final String title;
  final String content;
  final String prefectId;
  final String? assetName;
  final String? assetUrl;
  final Timestamp? createdAt;

  BlogModel({
    required this.id,
    required this.title,
    required this.content,
    required this.prefectId,
    this.assetName,
    this.assetUrl,
    this.createdAt,
  });

  factory BlogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlogModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      prefectId: data['prefectId'] ?? '',
      assetName: data['assetName'],
      assetUrl: data['assetUrl'],
      createdAt: data['createdAt'],
    );
  }
}
