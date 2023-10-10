import 'package:agora_chat_module/sourav_module/features/chat_module/models/domain_user.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/services/realtime_db_service.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key, this.selectedUser}) : super(key: key);

  final Set<DomainUser>? selectedUser;

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  late final TextEditingController groupNameController;
  List<String> selectedParticipants = [];

  @override
  void initState() {
    super.initState();
    groupNameController = TextEditingController();
    context.read<ChatViewModel>().fetchAllUserOnboard();
    if (widget.selectedUser != null) {
      selectedParticipants = widget.selectedUser!.map((e) => e.id).toList();
    }
  }

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'New group',
              style: TextStyle(fontSize: 16, letterSpacing: 1.3),
            ),
            Text(
              'Add participants',
              style: TextStyle(fontSize: 12, letterSpacing: 1.1),
            ),
          ],
        ),
        leadingWidth: 30,
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.search),
          )
        ],
        backgroundColor: const Color(0xFF36454F).withOpacity(.92),
      ),
      backgroundColor: const Color(0XFF111B21),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Group Name',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: groupNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter group name',
                hintStyle: TextStyle(color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Participants',
              style: TextStyle(color: Colors.white),
            ),
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (context, value, child) => ListView.builder(
                  itemCount: value.allUserInfo.length,
                  itemBuilder: (context, index) {
                    final participant = value.allUserInfo[index];
                    return CheckboxListTile(
                      title: Text(
                        participant.displayName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      activeColor: Colors.green,
                      side: const BorderSide(color: Colors.white),
                      value: selectedParticipants.contains(participant.id),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null && value) {
                            selectedParticipants.add(participant.id);
                          } else {
                            selectedParticipants.remove(participant.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Consumer<ChatViewModel>(
                    builder: (context, value, child) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () {
                        context.read<ChatViewModel>().createNewConversation(
                              name: groupNameController.text,
                              participants: selectedParticipants,
                              conversationType: ConversationType.GROUP,
                            );

                        Navigator.of(context).pop();
                      },
                      child: Text(
                        value.isLoading ? 'loading...' : 'Create Group',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
