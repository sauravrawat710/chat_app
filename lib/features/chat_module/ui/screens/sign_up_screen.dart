import 'package:chat_app/features/chat_module/ui/screens/conversation_list_screen.dart';
import 'package:chat_app/features/chat_module/ui/screens/login_screen.dart';
import 'package:chat_app/features/chat_module/ui/widgets/signup_custom_text_field.dart';
import 'package:chat_app/features/chat_module/ui/widgets/social_media_login_button.dart';
import 'package:chat_app/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/gestures.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final TextEditingController displayNameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  bool isLoading = false;
  bool isTermsAndConditionAccepted = false;

  @override
  void initState() {
    super.initState();
    displayNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    displayNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          const Text(
                            'Hey, Hello ',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              height: 37 / 32,
                            ),
                          ),
                          LottieBuilder.asset(
                            'assets/lottie/hey_animation.json',
                            height: 40,
                            width: 40,
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Enter your details to create\nyour account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 22 / 18,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SocialMediaLoginButton(
                            labelText: 'Google',
                            labelLogo: 'assets/icons/Google.svg',
                          ),
                          SizedBox(width: 20),
                          SocialMediaLoginButton(
                            labelText: 'Apple',
                            labelLogo: 'assets/icons/apple.svg',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: const [
                          Expanded(child: Divider(color: Colors.white38)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                height: 25 / 20,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white38)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SignUpCustomTextField(
                        controller: displayNameController,
                        labelText: 'Name',
                      ),
                      const SizedBox(height: 20),
                      SignUpCustomTextField(
                        controller: emailController,
                        labelText: 'Email address',
                      ),
                      const SizedBox(height: 20),
                      SignUpCustomTextField(
                        controller: passwordController,
                        labelText: 'Password',
                        isPasswordField: true,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Checkbox(
                            value: isTermsAndConditionAccepted,
                            side: MaterialStateBorderSide.resolveWith(
                                (states) =>
                                    const BorderSide(color: Colors.white)),
                            shape: const CircleBorder(),
                            onChanged: (value) {
                              setState(() {
                                isTermsAndConditionAccepted = value ?? false;
                              });
                            },
                          ),
                          RichText(
                            text: const TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(
                                color: Color(0XFF777777),
                                fontSize: 16,
                              ),
                              children: [
                                TextSpan(
                                  text: ' Terms & Privacy',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Consumer<ChatViewModel>(builder: (context, vm, child) {
                        return Material(
                          borderRadius: BorderRadius.circular(10),
                          color: isTermsAndConditionAccepted
                              ? const Color(0XFF128C7E)
                              : const Color(0xff333333),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: vm.isLoading
                                ? null
                                : isTermsAndConditionAccepted
                                    ? () {
                                        if (displayNameController
                                                .text.isEmpty &&
                                            emailController.text.isEmpty &&
                                            passwordController.text.isEmpty) {
                                          return;
                                        }

                                        context
                                            .read<ChatViewModel>()
                                            .createNewUser(
                                              displayName: displayNameController
                                                  .text
                                                  .trim(),
                                              email:
                                                  emailController.text.trim(),
                                              password: passwordController.text
                                                  .trim(),
                                            )
                                            .then(
                                          (isLoggedIn) {
                                            if (isLoggedIn) {
                                              return Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const ConversationListScreen()),
                                                      (route) => false);
                                            }
                                          },
                                        );
                                      }
                                    : null,
                            child: SizedBox(
                              height: 48,
                              child: Center(
                                child: Text(
                                  vm.isLoading ? 'Creating user...' : 'Sign Up',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    height: 31 / 22,
                                    color: !isTermsAndConditionAccepted
                                        ? Colors.grey.shade700
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 32),
                      RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            height: 22 / 18,
                          ),
                          children: [
                            TextSpan(
                                text: "Login",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  height: 22 / 18,
                                  color: Color(0XFF0098FF),
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ));
                                  }),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          '© 2024 SO, All right Reserved',
                          style: TextStyle(
                            color: Color(0XFF777777),
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            height: 18 / 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
