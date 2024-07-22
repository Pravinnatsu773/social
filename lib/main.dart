import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/common/cubit/posting_progress_cubit.dart';
import 'package:social4/firebase_options.dart';
import 'package:social4/screens/auth/cubit/auth_cubit.dart';
import 'package:social4/screens/auth/domain/auth_repository.dart';
import 'package:social4/screens/main_screen/cubit/bottom_nav_cubit.dart';
import 'package:social4/screens/onboarding/presentation/onboarding.dart';
import 'package:social4/screens/post/cubit/comment_cubit.dart';
import 'package:social4/screens/post/cubit/post_cubit.dart';
import 'package:social4/screens/post/cubit/post_detail_cubit.dart';
import 'package:social4/screens/post/presentation/post_detail.dart';
import 'package:social4/screens/profile/cubit/profile_cubit.dart';
import 'package:social4/service/app_routes.dart';
import 'package:social4/service/notification_service.dart';
import 'package:social4/service/shared_preference_service.dart';

import 'screens/profile/cubit/profile_post_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesService().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  runApp(const SocialApp());
}

class SocialApp extends StatelessWidget {
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CommentCubit(),
        ),
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
        BlocProvider(
          create: (context) => ProfilePostCubit(),
        ),
        BlocProvider(
          create: (context) => PostDetailCubit(),
        ),
        BlocProvider(
          create: (context) => PostCubit(),
        ),
        BlocProvider(
          create: (context) => BottomNavCubit(),
        ),
        BlocProvider(
          create: (context) => PostingProgressCubit(),
        ),
        BlocProvider(
          create: (context) => ProfileCubit(),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.splashScreen,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
