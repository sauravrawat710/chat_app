import 'package:agora_chat_module/sourav_module/features/chat_module/ui/screens/login_screen.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
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
                  'Create New User',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: displayNameController,
                  decoration: InputDecoration(
                    hintText: 'Display name',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(.8)),
                    prefixIcon: Icon(
                      Icons.smart_display,
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
                                  .createNewUser(
                                displayName: displayNameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                              )
                                  .then((isCreated) {
                                setState(() {
                                  isLoading = false;
                                });

                                if (isCreated) {
                                  Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ));
                                }
                              });
                            },
                      child: Text(isLoading ? 'Creating...' : 'Create'),
                    ),
                  );
                }),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  )),
                  child: const Text(
                    'Already have an account?',
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
