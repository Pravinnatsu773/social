import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:social4/common/model/user_model.dart';
import 'package:social4/common/util/helper_functions.dart';
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
              "bio": bio
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

        final userData = UserModel.fromMap(updatedProfile);

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
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(id).get();
      Map<String, dynamic> userProfile = userDoc.data() as Map<String, dynamic>;

      UserModel userModelData = UserModel.fromMap(userProfile);
      emit(ProfileLoaded(userProfile: userModelData));
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

  Future<void> _saveUserToPreferences(UserModel user) async {
    await sharedPreferencesService.saveString('userID', user.id);
    await sharedPreferencesService.saveString('userName', user.username);

    await sharedPreferencesService.saveString('name', user.name);

    await sharedPreferencesService.saveString('profilePic', user.profilePic);

    await sharedPreferencesService.saveString('bio', user.bio);
  }
}
