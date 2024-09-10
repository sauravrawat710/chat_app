import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_model/chat_view_model.dart';
import 'conversation_list_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF36454F),
        body: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Login with Firebase',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(.8)),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.white..withOpacity(.8),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(.8)),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.white.withOpacity(.8),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                StatefulBuilder(builder: (context, setState) {
                  return Consumer<ChatViewModel>(
                    builder: (context, value, child) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // backgroundColor:
                        //     const Color.fromARGB(255, 98, 123, 140),
                        backgroundColor: Colors.green,
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                isLoading = true;
                              });
                              value
                                  .loginOrLogout(
                                email: emailController.text,
                                password: passwordController.text,
                              )
                                  .then((value) {
                                setState(() {
                                  isLoading = false;
                                });
                                if (value != null && value) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ConversationListScreen()),
                                  );
                                }
                              });
                            },
                      child: Text(isLoading ? 'Loading...' : 'Login'),
                    ),
                  );
                }),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  )),
                  child: const Text(
                    'Create New Account',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
