import 'package:agora_chat_module/sourav_module/features/chat_module/ui/screens/group_chat_screen.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectGroupScreen extends StatefulWidget {
  const SelectGroupScreen({super.key});

  @override
  State<SelectGroupScreen> createState() => _SelectGroupScreenState();
}

class _SelectGroupScreenState extends State<SelectGroupScreen> {
  @override
  void didChangeDependencies() {
    final chatvm = context.read<ChatViewModel>();
    chatvm.setupChatClient();
    chatvm.setupListeners();
    chatvm.fetchGroupsName();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36454F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF36454F),
        title: const Text(
          'Select Group',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Consumer<ChatViewModel>(
            builder: (context, value, child) => TextButton(
              onPressed: value.isJoined
                  ? value.loginOrLogout
                  : () => _showLoginDialog(context, value),
              child: Text(
                value.isJoined ? 'Logout' : 'Login',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 189, 216, 235),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Consumer<ChatViewModel>(
                builder: (context, value, child) => DropdownButton<String>(
                  value: value.selectedGroupName,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      value.onGroupDropwdownChange(newValue);
                    }
                  },
                  items: value.groups.map((group) {
                    return DropdownMenuItem<String>(
                      value: group.name,
                      child: Text(
                        group.name ?? '',
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(
                height: 20.0), // Add spacing between dropdown and button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GroupChatScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 80, 99, 111),
                elevation: 4.0, // Add button elevation
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Enter Group Chat',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showLoginDialog(BuildContext context, ChatViewModel value) {
    final userNameController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        elevation: 0,
        backgroundColor: const Color(0xFF36454F),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Login with Agora',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: userNameController,
                  decoration: InputDecoration(
                    hintText: 'User ID',
                    hintStyle: const TextStyle(color: Colors.white),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.white,
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
                    hintStyle: const TextStyle(color: Colors.white),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.white,
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
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 98, 123, 140),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              isLoading = true;
                            });
                            value
                                .loginOrLogout(
                                  userId: userNameController.text,
                                  password: passwordController.text,
                                )
                                .then((value) => setState(() {
                                      isLoading = false;
                                    }));
                          },
                    child: Text(isLoading ? 'Loading...' : 'Login'),
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
