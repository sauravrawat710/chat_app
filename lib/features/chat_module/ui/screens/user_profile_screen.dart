import 'package:chat_app/features/chat_module/ui/screens/login_screen.dart';
import 'package:chat_app/features/chat_module/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

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
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Your Profile',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              height: 45 / 30,
                            ),
                          ),
                          Icon(
                            Icons.qr_code,
                            color: Color(0XFF25D366),
                            size: 30,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0XFF202020),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage('https://i.pravatar.cc/56'),
                              radius: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<ChatViewModel>(
                                builder: (context, vm, child) {
                                  return Text(
                                    vm.currentUser?.displayName ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      height: 24 / 16,
                                    ),
                                  );
                                },
                              ),
                              const Text(
                                'Let’s not wait for it. 😎',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 24 / 16,
                                  color: Color(0XFFB9BAC7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0XFF202020),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildTiles(
                            iconData: Icons.vpn_key_outlined,
                            title: 'Accounts',
                            subtitle: 'Privacy, Security, change number',
                          ),
                          _buildTiles(
                            iconData: Icons.logout_outlined,
                            title: 'Logout',
                            subtitle: 'Logout from your account',
                            onTap: () {
                              context
                                  .read<ChatViewModel>()
                                  .logout()
                                  .then((loggedOut) {
                                if (loggedOut) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                      (route) => false);
                                }
                              });
                            },
                          ),
                          _buildTiles(
                            iconData: Icons.chat_bubble_outline,
                            title: 'Chats',
                            subtitle: 'Backup, history, wallpaper',
                          ),
                          _buildTiles(
                            iconData: Icons.notifications_none_outlined,
                            title: 'Notifications',
                            subtitle: 'Message, group & call tones',
                          ),
                          _buildTiles(
                            iconData: Icons.data_saver_off_outlined,
                            title: 'Data and storage usage',
                            subtitle: 'Network usage, auto download',
                          ),
                          _buildTiles(
                            iconData: Icons.help_center_outlined,
                            title: 'Help',
                            subtitle: 'FAQ, contact us, privacy policy',
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0XFF202020),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 5,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: const Color(0XFF128C7E),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.people_alt_outlined,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Invite Friends',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    height: 24 / 16,
                                  ),
                                ),
                                Text(
                                  'Invite new friends and earn',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    height: 24 / 16,
                                    color: Color(0XFFB9BAC7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Spacer(),
                    const Text(
                      'from',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 21 / 14,
                      ),
                    ),
                    const Text(
                      'FACEBOOK',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 21 / 14,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTiles({
    required IconData iconData,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: const Color(0XFFE2E2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 24 / 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 24 / 16,
                      color: Color(0XFFB9BAC7),
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
