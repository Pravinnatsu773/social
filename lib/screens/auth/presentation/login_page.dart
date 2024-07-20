import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/common/ui/custom_button.dart';
import 'package:social4/common/ui/custom_input_field.dart';
import 'package:social4/common/ui/custom_text.dart';
import 'package:social4/screens/auth/cubit/auth_cubit.dart';
import 'package:social4/service/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();

  bool showPassword = false;
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoaded) {
              if (state.user != null) {
                Navigator.popUntil(context, (route) => false);
                Navigator.of(context).pushNamed(AppRoutes.mainScreen);
              }
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? "")),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    state is AuthLoading
                        ? SizedBox(
                            height: 2,
                            child: const LinearProgressIndicator(
                              color: Color(0xff5348EE),
                            ),
                          )
                        : const SizedBox(
                            height: 2,
                          ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                            text: "Sign In",
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const CustomText(
                              text:
                                  "Sign in to Social with your email and password.",
                              fontSize: 16,
                              textColor: Color(0xff9794A1),
                              fontWeight: FontWeight.w400),
                          const SizedBox(
                            height: 16,
                          ),
                          CustomInputField(
                            enabled: state is! AuthLoading,
                            hintText: "Email",
                            controller: emailController,
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          CustomInputField(
                            enabled: state is! AuthLoading,
                            hintText: "Password",
                            obscureText: !showPassword,
                            controller: passwordController,
                            suffix: GestureDetector(
                              onTap: () {
                                showPassword = !showPassword;
                                setState(() {});
                              },
                              child: Icon(
                                Icons.remove_red_eye,
                                color: !showPassword
                                    ? Colors.black.withOpacity(0.35)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              CustomText(
                                  text: "Forgot username or password?",
                                  fontSize: 14,
                                  textColor: Color(0xff9794A1),
                                  fontWeight: FontWeight.w700),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      width: MediaQuery.of(context).size.width,
                      child: CustomButton(
                        text: "Sign In",
                        onPressed: () {
                          context.read<AuthCubit>().login(
                                emailController.text,
                                passwordController.text,
                              );
                        },
                        height: 56,
                      )),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
