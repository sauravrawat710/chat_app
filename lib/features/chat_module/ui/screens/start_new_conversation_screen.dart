import '../../models/domain_user.dart';
import 'create_group_screen.dart';
import '../widgets/build_new_group_button.dart';
import '../widgets/build_participants_widget.dart';
import '../../view_model/chat_view_model.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Icon(
              Icons.arrow_back_ios,
              size: 22,
            ),
          ),
        ),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            : [],
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, value, child) => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: value.allUserInfo.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Select contact',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 45 / 30,
                    ),
                  ),
                  SizedBox(height: 12),
                  BuildNewGroupButton(),
                  SizedBox(height: 10),
                  Text(
                    'Contacts on elRed',
                    style: TextStyle(
                      color: Color.fromARGB(255, 153, 189, 206),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              );
            } else {
              final user = value.allUserInfo[index - 1];
              return BuildParticipateWidget(
                user: user,
                isSelected: selectedUsers.contains(user),
                shouldStartConversation: selectedUsers.isEmpty,
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
