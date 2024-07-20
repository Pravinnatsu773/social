import 'dart:io';

import 'package:flutter/material.dart';
import 'package:social4/screens/auth/presentation/login_page.dart';
import 'package:social4/screens/main_screen/presentation/main_screen.dart';
import 'package:social4/screens/onboarding/presentation/onboarding.dart';
import 'package:social4/screens/auth/presentation/sign_up_page.dart';
import 'package:social4/screens/post/presentation/create_post.dart';
import 'package:social4/screens/post/presentation/post_detail.dart';
import 'package:social4/screens/profile/presentation/edit_profile.dart';
import 'package:social4/screens/profile/presentation/freinds_profile_detail.dart';
import 'package:social4/screens/setting/setting.dart';
import 'package:social4/screens/splashscreen/splash_screen.dart';
// Add other imports for your screens

class AppRoutes {
  static const String splashScreen = '/';
  static const String onBoarding = '/onBoarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String mainScreen = "/mainScreen";
  static const String postDetail = "/postDetail";

  static const String createPostScreen = "/createPostScreen";

  static const String editProfile = "/editProfile";

  static const String friendsProfileDetail = "/friendsProfileDetail";

  static const String settingScreen = "/settingScreen";

  // Add other route names

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onBoarding:
        return MaterialPageRoute(builder: (_) => const OnBoarding());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case mainScreen:
        return MaterialPageRoute(builder: (_) => MainScreen());

      case settingScreen:
        return MaterialPageRoute(builder: (_) => const SettingScreen());

      case editProfile:
        late VoidCallback callBack;
        if (settings.arguments != null) {
          final args = settings.arguments as Map<String, dynamic>;
          callBack = args['callBack'];
        }
        return MaterialPageRoute(
            builder: (_) => EditProfile(
                  callBack: callBack,
                ));

      case createPostScreen:
        late Function(String, File?) callBack;
        if (settings.arguments != null) {
          final args = settings.arguments as Map<String, dynamic>;
          callBack = args['callBack'];
        }
        return MaterialPageRoute(
            builder: (_) => CreatePostScreen(
                  callBack: callBack,
                ));

      case postDetail:
        String postId = "";
        if (settings.arguments != null) {
          final args = settings.arguments as Map<String, dynamic>;
          postId = args['postId'] ?? "";
        }

        return MaterialPageRoute(
            builder: (_) => PostDetail(
                  postId: postId,
                ));

      case friendsProfileDetail:
        String userId = "";
        String userName = "";
        if (settings.arguments != null) {
          final args = settings.arguments as Map<String, dynamic>;
          userId = args['userId'] ?? "";
          userName = args['userName'] ?? "";
        }
        return MaterialPageRoute(
            builder: (_) => FreindsProfileDetail(
                  userId: userId,
                  userName: userName,
                ));

      // Add other case statements for your routes
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
