import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:social4/common/ui/custom_button.dart';
import 'package:social4/service/app_routes.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.bottomCenter,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/login.jpeg"),
                fit: BoxFit.cover)),
        // padding: const EdgeInsets.all(16.0),
        child: const SafeArea(
          child: SizedBox(child: FadingEdgesContainer()),
        ),
      ),
    );
  }
}

class FadingEdgesContainer extends StatelessWidget {
  const FadingEdgesContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            Colors.transparent,
            Colors.transparent,
            Colors.black,
            Colors.black,
          ],
          stops: [0.0, 0.6, 0.9, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstOut,
      child: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.bottomCenter,
          height: 400,
          color: Colors.black.withOpacity(0.6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                  text: "Create Account",
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signup);
                  }),
              const SizedBox(
                height: 16,
              ),
              CustomButton(
                text: "Sign In",
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                color: Colors.white,
                textColor: const Color(0xff08051B),
              ),
              const SizedBox(
                height: 16,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'By using this app, you agree to our\n',
                  style:
                      TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontSize: 14),
                    ),
                    TextSpan(
                      text: ' and ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontSize: 14),
                    ),
                    TextSpan(
                      text: '.',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
