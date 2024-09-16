import 'package:chat_app/features/chat_module/ui/screens/start_new_conversation_screen.dart';
import 'package:chat_app/features/chat_module/ui/widgets/conversation_list_heading_widget.dart';
import 'package:chat_app/features/chat_module/ui/widgets/conversation_list_widget.dart';
import 'package:chat_app/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'dart:math' as math;

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().initFirebaseUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const ConversationListHeadingWidget(),
              const SizedBox(height: 30),
              ToggleSwitch(
                initialLabelIndex: 0,
                totalSwitches: 3,
                minHeight: 48,
                minWidth: double.infinity,
                activeBgColor: const [Colors.white],
                activeFgColor: const Color(0XFF128C7E),
                customTextStyles: const [
                  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 24 / 16,
                  )
                ],
                inactiveBgColor: const Color(0Xff1A1A1A),
                labels: const ['Favourites', 'Friends', 'Groups'],
                onToggle: (index) {},
              ),
              const SizedBox(height: 32),
              const Expanded(child: ConversationListWidget()),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          backgroundColor: const Color(0XFF25D366),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const StartNewConversationScreen(),
          )),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: const Icon(
              Icons.chat,
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          unselectedFontSize: 16,
          selectedFontSize: 16,
          iconSize: 28,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedItemColor: Colors.white,
          selectedItemColor: const Color(0XFF25D366),
          items: [
            BottomNavigationBarItem(
              label: 'Chats',
              icon: Column(
                children: [
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: const Icon(
                      Icons.chat,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chats',
                    style: TextStyle(
                      color: Color(0XFF25D366),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            BottomNavigationBarItem(
              label: 'Calls',
              icon: Column(
                children: const [
                  Icon(
                    Icons.phone,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Calls',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            BottomNavigationBarItem(
              label: 'Status',
              icon: Column(
                children: const [
                  Icon(
                    Icons.camera_alt,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
