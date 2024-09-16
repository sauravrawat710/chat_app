import '../../models/domain_user.dart';
import '../../services/realtime_db_service.dart';
import '../../view_model/chat_view_model.dart';
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New group',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                height: 45 / 30,
              ),
            ),
            const SizedBox(height: 32),
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
                  borderSide: BorderSide(color: Color(0XFF25D366)),
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
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        participant.displayName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      activeColor: const Color(0XFF25D366),
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
                        backgroundColor: const Color(0XFF25D366),
                      ),
                      onPressed: (selectedParticipants.isEmpty)
                          ? null
                          : () {
                              if (groupNameController.value.text.isEmpty) {
                                return;
                              }
                              context
                                  .read<ChatViewModel>()
                                  .createNewConversation(
                                    name: groupNameController.text,
                                    participants: selectedParticipants,
                                    conversationType: ConversationType.GROUP,
                                  );

                              Navigator.of(context).pop();
                            },
                      child: Text(
                        value.isLoading ? 'Creating...' : 'Create Group',
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
