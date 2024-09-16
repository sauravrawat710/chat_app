import 'package:chat_app/features/chat_module/ui/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';

class ConversationListHeadingWidget extends StatelessWidget {
  const ConversationListHeadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Whatsapp',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 45 / 30,
          ),
        ),
        const Spacer(),
        const Icon(Icons.search, size: 30, color: Colors.white),
        const SizedBox(width: 22),
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const UserProfileScreen(),
          )),
          child: const CircleAvatar(
            backgroundColor: Colors.black,
            backgroundImage: NetworkImage(
              'https://gravatar.com/avatar/933ed8cbddab2ac4d08106c7841dddf0?s=400&d=robohash&r=x',
            ),
          ),
        ),
      ],
    );
  }
}
