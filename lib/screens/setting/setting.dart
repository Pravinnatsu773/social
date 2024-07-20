import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/common/ui/custom_button.dart';
import 'package:social4/screens/auth/cubit/auth_cubit.dart';
import 'package:social4/service/app_routes.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(
          "Settings",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: Icon(Icons.notifications_outlined),
          // )
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
          child: CustomButton(
        width: 100,
        text: "Log out",
        onPressed: () {
          context.read<AuthCubit>().logout(context);
        },
        color: Colors.black,
      )),
    );
  }
}
