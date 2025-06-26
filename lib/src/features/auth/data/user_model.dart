// User model representing the user data stored in Firestore
// This model is used to represent both the authenticated user and other users in the app

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String bio;
  final List<String> interestTags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.bio,
    required this.interestTags,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a UserModel from a Firestore document
  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data()!;
    return UserModel(
      id: snapshot.id,
      email: data['email'] as String,
      username: data['username'] as String,
      bio: data['bio'] as String,
      interestTags: List<String>.from(data['interest_tags'] as List),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert UserModel to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'bio': bio,
      'interest_tags': interestTags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? email,
    String? username,
    String? bio,
    List<String>? interestTags,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      interestTags: interestTags ?? this.interestTags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
