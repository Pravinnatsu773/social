// import 'package:firebase_auth/firebase_auth.dart';
// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/common/model/user_model.dart';

import 'package:social4/screens/auth/domain/auth_repository.dart';
import 'package:social4/service/app_routes.dart';
import 'package:social4/service/shared_preference_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _authRepository = AuthRepository();

  final _sharedPreferencesService = SharedPreferencesService();

  AuthCubit() : super(AuthInitial());

  Future<void> signUp(
      String email, String password, String userName, String name) async {
    emit(AuthLoading());

    try {
      User? user = await _authRepository.signUp(email, password);
      if (user != null) {
        UserModel userData = UserModel(
            id: user.uid,
            name: name,
            username: userName,
            profilePic: "",
            bio: "",
            followers: [],
            following: []);
        await _firestore
            .collection('users')
            .doc(userData.id)
            .set(userData.toMap());
        await _saveUserToPreferences(userData);

        emit(AuthLoaded(user: userData));
      }
    } catch (e) {
      emit(AuthError(errorMessage: e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      User? user = await _authRepository.login(email, password);
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        Map<String, dynamic> userMap = userDoc.data() as Map<String, dynamic>;
        UserModel userData = UserModel.fromMap(userMap);
        await _saveUserToPreferences(userData);
        emit(AuthLoaded(user: userData));
      }
    } catch (e) {
      emit(AuthError(errorMessage: e.toString()));
    }
  }

  checkUserLoggedIn(BuildContext context) {
    final userId = _sharedPreferencesService.getString("userID");
    final name = _sharedPreferencesService.getString("name");
    final username = _sharedPreferencesService.getString("userName");
    final profilePic = _sharedPreferencesService.getString("profilePic");
    if (userId != null) {
      UserModel userData = UserModel(
          id: userId,
          name: name ?? "",
          username: username ?? '',
          profilePic: profilePic ?? '',
          bio: "",
          followers: [],
          following: []);
      emit(AuthLoaded(user: userData));
      Navigator.pushReplacementNamed(context, AppRoutes.mainScreen);
    } else {
      emit(AuthInitial());
      Navigator.pushReplacementNamed(context, AppRoutes.onBoarding);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _authRepository.logout();
    await _sharedPreferencesService.clear();
    emit(AuthLoaded(user: null));

    Navigator.popUntil(context, (route) => false);
    Navigator.pushNamed(context, AppRoutes.onBoarding);
  }

  Future<void> _saveUserToPreferences(UserModel user) async {
    await _sharedPreferencesService.saveString('userID', user.id);
    await _sharedPreferencesService.saveString('userName', user.username);

    await _sharedPreferencesService.saveString('name', user.name);

    await _sharedPreferencesService.saveString('profilePic', user.profilePic);

    await _sharedPreferencesService.saveString('bio', user.bio);
  }
}
