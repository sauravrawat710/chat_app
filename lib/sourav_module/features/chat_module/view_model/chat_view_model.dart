import 'package:agora_chat_module/main.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/ui/widgets/single_chat_text_widget.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';

class ChatViewModel extends ChangeNotifier {
  final String appKey = "611028932#1201792";
  final String userId = "sourav";
  final String token =
      "007eJxTYOBXYIozWRCYccer9HoDp7uuhcbFw9OSrSSVpsrFfXZIM1ZgME9MTk42TDZJsjAwMDEwTkw0TkoyMUxNTrY0NTU0Sra8HMGQ2hDIyNDgtYqJkYGVgREIQXwVhhQDY+NUUwMDXVNDMzNdQ8PUVF1LA0tj3eSkJEtLMxPLVOPkFACvviL8";

  late final ChatClient agoraChatClient;

  bool isJoined = false;

  ScrollController scrollController = ScrollController();

  TextEditingController messageBoxController = TextEditingController();

  String messageContent = "", recipientId = "";

  final List<Widget> messageList = [];

  showLog(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void setupChatClient() async {
    ChatOptions options = ChatOptions(appKey: appKey, autoLogin: false);
    agoraChatClient = ChatClient.getInstance;
    await agoraChatClient.init(options);
    if (await agoraChatClient.isLoginBefore()) {
      isJoined = true;
      notifyListeners();
    }
  }

  void setupListeners() {
    agoraChatClient.addConnectionEventHandler(
      "CONNECTION_HANDLER",
      ConnectionEventHandler(
          onConnected: onConnected,
          onDisconnected: onDisconnected,
          onTokenWillExpire: onTokenWillExpire,
          onTokenDidExpire: onTokenDidExpire),
    );

    agoraChatClient.chatManager.addEventHandler(
      "MESSAGE_HANDLER",
      ChatEventHandler(onMessagesReceived: onMessagesReceived),
    );
  }

  void onMessagesReceived(List<ChatMessage> messages) {
    for (var msg in messages) {
      if (msg.body.type == MessageType.TXT) {
        ChatTextMessageBody body = msg.body as ChatTextMessageBody;
        displayMessage(body.content, false);
        showLog("Message from ${msg.from}");
      } else {
        String msgType = msg.body.type.name;
        showLog("Received $msgType message, from ${msg.from}");
      }
    }
  }

  void onTokenWillExpire() {
    // The token is about to expire. Get a new token
    // from the token server and renew the token.
  }
  void onTokenDidExpire() {
    // The token has expired
  }
  void onDisconnected() {
    // Disconnected from the Chat server
  }
  void onConnected() {
    showLog("Connected");
  }

  void joinLeave() async {
    if (!isJoined) {
      // Log in
      try {
        await agoraChatClient.loginWithAgoraToken(userId, token);
        showLog("Logged in successfully as $userId");
        isJoined = true;
        final list = await agoraChatClient.chatManager.loadAllConversations();

        messageList.clear();

        for (ChatConversation element in list) {
          final msgList = await element.loadMessages();
          for (ChatMessage element in msgList) {
            messageList.add(SingleChatTextWidget(
              text: (element.body as ChatTextMessageBody).content,
              isSentMessage: element.direction == MessageDirection.SEND,
            ));
          }
        }

        notifyListeners();
      } on ChatError catch (e) {
        if (e.code == 200) {
          // Already logged in

          isJoined = false;

          notifyListeners();
        } else {
          showLog("Login failed, code: ${e.code}, desc: ${e.description}");
        }
      }
    } else {
      // Log out
      try {
        await agoraChatClient.logout(true);
        showLog("Logged out successfully");
        recipientId = '';
        isJoined = false;
        messageList.clear();
        notifyListeners();
      } on ChatError catch (e) {
        showLog("Logout failed, code: ${e.code}, desc: ${e.description}");
      }
    }
  }

  void sendMessage() async {
    if (recipientId.isEmpty || messageContent.isEmpty) {
      showLog("Enter recipient user ID and type a message");
      return;
    }

    var msg = ChatMessage.createTxtSendMessage(
      targetId: recipientId,
      content: messageContent,
      // chatType: ChatType.GroupChat,
    );
    agoraChatClient.chatManager.addMessageEvent(
        'UNIQUE_HANDLER_ID',
        ChatMessageEvent(
          onSuccess: (msgId, msg) {
            displayMessage(messageContent, true);
            messageBoxController.text = "";
            messageContent = "";
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onError: (msgId, msg, e) {
            showLog(
                "Send message failed, code: ${e.code}, desc: ${e.description}");
          },
        ));

    await agoraChatClient.chatManager.sendMessage(msg);
  }

  void displayMessage(String text, bool isSentMessage) {
    messageList.add(SingleChatTextWidget(
      text: text,
      isSentMessage: isSentMessage,
    ));

    scrollController.jumpTo(scrollController.position.maxScrollExtent + 50);
    notifyListeners();
  }

  @override
  void dispose() {
    agoraChatClient.chatManager.removeEventHandler("MESSAGE_HANDLER");
    agoraChatClient.chatManager.removeMessageEvent('UNIQUE_HANDLER_ID');
    agoraChatClient.removeConnectionEventHandler("CONNECTION_HANDLER");
    super.dispose();
  }
}
