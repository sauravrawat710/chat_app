import '../screens/create_group_screen.dart';
import 'package:flutter/material.dart';

class BuildNewGroupButton extends StatelessWidget {
  const BuildNewGroupButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
      )),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: Row(
          children: const [
            CircleAvatar(
              backgroundColor: Color(0XFF25D366),
              child: Icon(
                Icons.group,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'New group',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
