import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:social4/common/model/user_model.dart';
import 'package:social4/common/util/helper_functions.dart';
import 'package:social4/service/notification_service.dart';
import 'package:social4/service/shared_preference_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final sharedPreferencesService = SharedPreferencesService();

  Future<void> updateUserProfile({
    required String name,
    required String username,
    required String bio,
    required File? image,
  }) async {
    emit(ProfileUpdating());
    try {
      final userId = sharedPreferencesService.getString("userID");
      String? imagedUrl;
      if (image != null) {
        imagedUrl = await _uploadImage(image);
      }
      Map<String, dynamic> updatedProfile = imagedUrl != null
          ? {
              'name': name,
              'username': username,
              'profilePic': imagedUrl,
              "bio": bio,
            }
          : {
              'name': name,
              'username': username,
              "profilePic":
                  sharedPreferencesService.getString("profilePic") ?? "",
              "bio": bio
            };

      await _firestore.runTransaction((transaction) async {
        DocumentReference profileRef =
            _firestore.collection('users').doc(userId);
        DocumentSnapshot profileSnapshot = await transaction.get(profileRef);

        if (!profileSnapshot.exists) return;
        transaction.update(profileRef, updatedProfile);
        updatedProfile['id'] = userId;

        final userData = UserModel(
            id: updatedProfile['id'],
            name: updatedProfile['name'],
            username: updatedProfile['username'],
            profilePic: updatedProfile['profilePic'],
            bio: updatedProfile['bio']);

        _saveUserToPreferences(userData);
      });

      // toast("Profile update successfully");

      emit(ProfileUpdated(userProfile: updatedProfile));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> fetchUserProfile(String id) async {
    try {
      final curentUserId = sharedPreferencesService.getString("userID");

      DocumentSnapshot currentUserDoc =
          await _firestore.collection('users').doc(curentUserId).get();

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(id).get();

      Map<String, dynamic> currentUserProfile =
          currentUserDoc.data() as Map<String, dynamic>;

      Map<String, dynamic> userProfile = userDoc.data() as Map<String, dynamic>;

      UserModel currentUserModelData = UserModel.fromMap(currentUserProfile);
      UserModel userModelData = UserModel.fromMap(userProfile);

      bool isFollowedByMe =
          currentUserModelData.following!.contains(userModelData.id);
      final user = userModelData.copyWith(isFollowedByMe: isFollowedByMe);

      if (user.id == curentUserId) {}
      emit(ProfileLoaded(userProfile: user));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = image.path.split('/').last;
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('users/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(image);

      TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('File uploaded at $downloadUrl');

      return downloadUrl;
    } catch (e) {}
  }

  Future<void> followUser(String targetUserId) async {
    try {
      String currentUserId = sharedPreferencesService.getString("userID") ?? "";
      if (currentUserId.isEmpty) return;

      await _firestore.runTransaction((transaction) async {
        DocumentReference currentUserRef =
            _firestore.collection('users').doc(currentUserId);
        DocumentReference targetUserRef =
            _firestore.collection('users').doc(targetUserId);

        DocumentSnapshot currentUserSnapshot =
            await transaction.get(currentUserRef);
        DocumentSnapshot targetUserSnapshot =
            await transaction.get(targetUserRef);

        if (!currentUserSnapshot.exists || !targetUserSnapshot.exists) {
          throw Exception("User not found");
        }

        UserModel currentUser = UserModel.fromMap(
            currentUserSnapshot.data() as Map<String, dynamic>);

        UserModel targetUser = UserModel.fromMap(
            targetUserSnapshot.data() as Map<String, dynamic>);

        if (currentUser.following!.contains(targetUserId)) {
          // Already following, so unfollow
          transaction.update(currentUserRef, {
            'following': FieldValue.arrayRemove([targetUserId])
          });
          transaction.update(targetUserRef, {
            'followers': FieldValue.arrayRemove([currentUserId])
          });
          QuerySnapshot followSnapshot = await FirebaseFirestore.instance
              .collection('follows')
              .where('followerId', isEqualTo: currentUserId)
              .where('followingId', isEqualTo: targetUserId)
              .get();

          for (DocumentSnapshot doc in followSnapshot.docs) {
            await doc.reference.delete();
          }
        } else {
          // Not following, so follow
          transaction.update(currentUserRef, {
            'following': FieldValue.arrayUnion([targetUserId])
          });
          transaction.update(targetUserRef, {
            'followers': FieldValue.arrayUnion([currentUserId])
          });

          await FirebaseFirestore.instance.collection('follows').add({
            'followerId': currentUserId,
            'followingId': targetUserId,
          });

          String fcmToken = targetUser.fcmToken;
          NotificationService().sendFollowNotification(fcmToken, {
            "title": "${currentUser.name} followed you",
            'image': currentUser.profilePic,
          });
        }
      });

      // emit(ProfileSuccess());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _saveUserToPreferences(UserModel user) async {
    await sharedPreferencesService.saveString('userID', user.id);
    await sharedPreferencesService.saveString('userName', user.username);

    await sharedPreferencesService.saveString('name', user.name);

    await sharedPreferencesService.saveString('profilePic', user.profilePic);

    await sharedPreferencesService.saveString('bio', user.bio);
  }
}
