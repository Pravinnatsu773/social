import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/screens/auth/cubit/auth_cubit.dart';
import 'package:social4/service/app_routes.dart';
import 'package:social4/service/shared_preference_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final sharedPreferencesService = SharedPreferencesService();
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 0), () {
      context.read<AuthCubit>().checkUserLoggedIn(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
