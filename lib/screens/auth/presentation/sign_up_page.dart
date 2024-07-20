import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/common/ui/custom_button.dart';
import 'package:social4/common/ui/custom_input_field.dart';
import 'package:social4/screens/auth/cubit/auth_cubit.dart';
import 'package:social4/service/app_routes.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isSubimited = false;

  final usernameController = TextEditingController();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final passwordConfirmController = TextEditingController();

  bool showPassword = false;
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
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                    child: Column(
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
                              const Text(
                                "Create Account",
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Color(0xff08051B),
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Create account with your email and password.",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xff9794A1),
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              CustomInputField(
                                enabled: !isSubimited,
                                hintText: "Full Name",
                                // allowSpace: false,
                                controller: fullNameController,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              CustomInputField(
                                enabled: !isSubimited,
                                hintText: "username",
                                allowSpace: false,
                                controller: usernameController,
                                prefix: Container(
                                  // width: 12,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "@",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Color(0xff8F8D9B),
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                onChanged: (value) {},
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                              CustomInputField(
                                enabled: !isSubimited,
                                hintText: "Email",
                                allowSpace: false,
                                controller: emailController,
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                              CustomInputField(
                                enabled: !isSubimited,
                                hintText: "Create Password",
                                allowSpace: false,
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
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 100,
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: CustomButton(
                        text: "Create Account",
                        onPressed: () {
                          isSubimited = true;
                          setState(() {});

                          context.read<AuthCubit>().signUp(
                              emailController.text,
                              passwordController.text,
                              usernameController.text,
                              fullNameController.text.trim());
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
