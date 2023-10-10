import 'package:agora_chat_module/sourav_module/features/chat_module/models/domain_user.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/screens/create_group_screen.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/build_new_group_button.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/build_participants_widget.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartNewConversationScreen extends StatefulWidget {
  const StartNewConversationScreen({super.key});

  @override
  State<StartNewConversationScreen> createState() =>
      _StartNewConversationScreenState();
}

class _StartNewConversationScreenState
    extends State<StartNewConversationScreen> {
  final Set<DomainUser> selectedUsers = <DomainUser>{};

  @override
  void initState() {
    super.initState();
    context.read<ChatViewModel>().fetchAllUserOnboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2C33).withOpacity(.92),
      appBar: AppBar(
        backgroundColor: const Color(0xFF36454F),
        title: const Text(
          'Select contact',
          style: TextStyle(fontSize: 16),
        ),
        leadingWidth: 40,
        titleSpacing: 1,
        actions: selectedUsers.isNotEmpty
            ? [
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            CreateGroupScreen(selectedUser: selectedUsers),
                      ));
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'New group',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ]
            : const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.search),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.more_vert),
                ),
              ],
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, value, child) => ListView.builder(
          itemCount: value.allUserInfo.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  BuildNewGroupButton(),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Contacts on elRed',
                      style: TextStyle(
                        color: Color.fromARGB(255, 153, 189, 206),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              final user = value.allUserInfo[index - 1];
              return BuildParticipateWidget(
                user: user,
                isSelected: selectedUsers.contains(user),
                onUserSelected: (isSelected) {
                  setState(() {
                    if (isSelected) {
                      selectedUsers.add(user);
                    } else {
                      selectedUsers.remove(user);
                    }
                  });
                },
              );
            }
          },
        ),
      ),
    );
  }
}
