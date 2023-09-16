import 'dart:developer';

import 'package:agora_chat_module/main.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/models/message_data_model.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ChatViewModel extends ChangeNotifier {
  final String appKey = "611028932#1201792";

  late final ChatClient agoraChatClient;

  bool isJoined = false;

  late ScrollController scrollController;

  late TextEditingController messageBoxController;

  final List<MessageData> messageList = [];
  List<ChatGroup> groups = [];
  String selectedGroupName = '';
  XFile? imageFile;
  FilePickerResult? file;
  PhoneContact? contact;
  bool shouldShowTypingIndicator = false;
  late ChatConversation conversations;

  ChatGroup get getSelectedGroupChat =>
      groups.firstWhere((element) => element.name == selectedGroupName);

  showLog(String message) {
    scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  void setupControllers({
    required TextEditingController textEditingController,
    required ScrollController scrollController,
  }) {
    messageBoxController = textEditingController;
    this.scrollController = scrollController;
  }

  void setupChatClient() async {
    ChatOptions options = ChatOptions(
      appKey: appKey,
      autoLogin: false,
      requireDeliveryAck: true,
      requireAck: true,
    );
    agoraChatClient = ChatClient.getInstance;
    await agoraChatClient.init(options);
    await agoraChatClient.startCallback();
    if (await agoraChatClient.isLoginBefore()) {
      isJoined = true;
      fetchGroupsName();
      notifyListeners();
    }
  }

  void setupListeners() {
    agoraChatClient.addConnectionEventHandler(
      "CONNECTION_HANDLER",
      ConnectionEventHandler(
        onConnected: () => showLog("Connected"),
        // onDisconnected: onDisconnected,
        // onTokenWillExpire: onTokenWillExpire,
        // onTokenDidExpire: onTokenDidExpire,
      ),
    );

    agoraChatClient.chatManager.addEventHandler(
      "MESSAGE_HANDLER",
      ChatEventHandler(
        onMessagesReceived: onMessagesReceived,
        onGroupMessageRead: onGroupMessageRead,
        onMessagesDelivered: onMessagesDelivered,
        onCmdMessagesReceived: onCMDMessageDelivered,
      ),
    );

    agoraChatClient.chatManager.addMessageEvent(
      'UNIQUE_HANDLER_ID',
      ChatMessageEvent(
        onSuccess: (msgId, msg) {
          log('onSuccess() called!!!!');
          switch (msg.body.type) {
            case MessageType.TXT:
              ChatTextMessageBody body = msg.body as ChatTextMessageBody;
              displayMessage(
                msgId: msg.msgId,
                text: body.content,
                isSentMessage: msg.direction == MessageDirection.SEND,
                from: msg.from ?? '',
                dateTime: DateTime.fromMicrosecondsSinceEpoch(msg.localTime),
                hasRead: msg.hasRead,
                hasDelivered: msg.hasRead,
                type: body.type,
              );
              messageBoxController.clear();
              // FocusManager.instance.primaryFocus?.unfocus();
              break;
            case MessageType.IMAGE:
              ChatImageMessageBody body = msg.body as ChatImageMessageBody;
              displayMessage(
                msgId: msg.msgId,
                text: body.displayName ?? '',
                imagePath: body.remotePath,
                isSentMessage: msg.direction == MessageDirection.SEND,
                from: msg.from ?? '',
                dateTime: DateTime.fromMicrosecondsSinceEpoch(msg.localTime),
                hasRead: msg.hasRead,
                hasDelivered: msg.hasRead,
                type: body.type,
              );
              break;
            case MessageType.FILE:
              ChatFileMessageBody body = msg.body as ChatFileMessageBody;
              log('remotePath ==> ${body.remotePath}');
              displayMessage(
                msgId: msg.msgId,
                text: body.displayName ?? '',
                filePath: body.remotePath,
                isSentMessage: msg.direction == MessageDirection.SEND,
                from: msg.from ?? '',
                dateTime: DateTime.fromMicrosecondsSinceEpoch(msg.localTime),
                hasRead: msg.hasRead,
                hasDelivered: msg.hasRead,
                type: body.type,
              );
              break;
            case MessageType.CUSTOM:
              ChatCustomMessageBody body = msg.body as ChatCustomMessageBody;
              log('event ==> ${body.event}');
              displayMessage(
                msgId: msg.msgId,
                text: body.params?['name'] ?? '',
                contact: ContactData(
                  body.params?['name'] ?? '',
                  body.params?['number'] ?? '',
                ),
                from: msg.from ?? '',
                isSentMessage: msg.direction == MessageDirection.SEND,
                dateTime: DateTime.fromMicrosecondsSinceEpoch(msg.localTime),
                hasRead: msg.hasRead,
                hasDelivered: msg.hasRead,
                type: body.type,
              );
              break;
            default:
          }
        },
        onError: (msgId, msg, e) {
          log('onError() called!!!!');
          showLog(
              "Send message failed, code: ${e.code}, desc: ${e.description}");
        },
      ),
    );
  }

  void onMessagesReceived(List<ChatMessage> messages) {
    log('onMessagesReceived() called!!!!');
    for (ChatMessage msg in messages) {
      if (msg.conversationId == getSelectedGroupChat.groupId) {
        switch (msg.body.type) {
          case MessageType.TXT:
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;
            displayMessage(
              msgId: msg.msgId,
              text: body.content,
              from: msg.from ?? '',
              isSentMessage: false,
              dateTime: DateTime.fromMicrosecondsSinceEpoch(msg.localTime),
              hasRead: msg.hasRead,
              hasDelivered: msg.hasRead,
              type: body.type,
            );
            break;
          case MessageType.IMAGE:
            ChatImageMessageBody body = msg.body as ChatImageMessageBody;
            displayMessage(
              msgId: msg.msgId,
              text: body.displayName ?? '',
              imagePath: body.remotePath,
              isSentMessage: false,
              from: msg.from ?? '',
              dateTime: DateTime.fromMicrosecondsSinceEpoch(msg.localTime),
              hasRead: msg.hasRead,
              hasDelivered: msg.hasRead,
              type: body.type,
            );
            break;
          case MessageType.FILE:
            ChatFileMessageBody body = msg.body as ChatFileMessageBody;
            displayMessage(
              msgId: msg.msgId,
              text: body.displayName ?? '',
              filePath: body.remotePath,
              isSentMessage: false,
              from: msg.from ?? '',
              dateTime: DateTime.fromMicrosecondsSinceEpoch(msg.localTime),
              hasRead: msg.hasRead,
              hasDelivered: msg.hasRead,
              type: body.type,
            );
            break;
          case MessageType.CUSTOM:
            ChatCustomMessageBody body = msg.body as ChatCustomMessageBody;
            log('event ==> ${body.event}');
            displayMessage(
              msgId: msg.msgId,
              text: body.params?['name'] ?? '',
              contact: ContactData(
                body.params?['name'] ?? '',
                body.params?['number'] ?? '',
              ),
              from: msg.from ?? '',
              isSentMessage: msg.direction == MessageDirection.SEND,
              dateTime: DateTime.fromMicrosecondsSinceEpoch(msg.localTime),
              hasRead: msg.hasRead,
              hasDelivered: msg.hasRead,
              type: body.type,
            );
            break;
          default:
        }
      }
    }
  }

  void onGroupMessageRead(List<ChatGroupMessageAck> groupMessage) {
    log('onGroupMessageRead() called!!!!!');
    for (ChatGroupMessageAck msg in groupMessage) {
      final msgWhichGotRead =
          messageList.firstWhere((element) => element.msgId == msg.messageId);

      msgWhichGotRead.hasRead = true;
      notifyListeners();
    }
  }

  void onMessagesDelivered(List<ChatMessage> messages) {
    log('onMessagesDelivered() called!!!');
    for (var msg in messages) {
      final msgWhichGotDelivered =
          messageList.firstWhere((element) => element.msgId == msg.msgId);

      msgWhichGotDelivered.hasDelivered = true;
      notifyListeners();
    }
  }

  void onCMDMessageDelivered(List<ChatMessage> messages) {
    log('onCMDMessageDelivered() called!!!');
    for (ChatMessage msg in messages) {
      if (msg.conversationId == getSelectedGroupChat.groupId) {
        final body = msg.body as ChatCmdMessageBody;
        log('body.acton ==> ${body.action}');
        if (body.action == 'startTyping') {
          shouldShowTypingIndicator = true;
        } else if (body.action == 'stopTyping') {
          shouldShowTypingIndicator = false;
        }
        notifyListeners();
      }
    }
  }

  Future<void> loginOrLogout({String? userId, String? password}) async {
    try {
      if (isJoined) {
        await agoraChatClient.logout();
        isJoined = false;
        groups.clear();
      } else {
        await agoraChatClient.login(userId!, password!);

        isJoined = true;
        await fetchGroupsName();
        Navigator.of(globalKey.currentContext!).pop();
      }
    } on ChatError catch (e) {
      log('code ==> ${e.code}');
      log('error ==> ${e.description}');
    }
    notifyListeners();
  }

  void onGroupDropwdownChange(String groupName) {
    selectedGroupName = groupName;
    notifyListeners();
  }

  Future<void> fetchGroupsName() async {
    if (!await agoraChatClient.isLoginBefore()) {
      return;
    }
    final joinedGroups =
        await agoraChatClient.groupManager.fetchJoinedGroupsFromServer();
    log('joinedGroups $joinedGroups');
    if (joinedGroups.isNotEmpty) {
      groups.clear();
      groups = joinedGroups;
      selectedGroupName = joinedGroups.first.name ?? 'N/A';
      notifyListeners();
    }
  }

  void fetchPreviousMessages() async {
    log('fetchPreviousMessages() called!!!');
    final conversation = await agoraChatClient.chatManager.getConversation(
      getSelectedGroupChat.groupId,
      type: ChatConversationType.GroupChat,
      createIfNeed: true,
    );

    if (conversation != null) {
      conversations = conversation;
    }

    messageList.clear();

    log('Group ID ==> ${getSelectedGroupChat.groupId}');
    log('Conversation ID ==> ${conversation?.id}');
    log('Conversation Type ==> ${conversation?.type}');
    if (conversation != null) {
      final msgList = await conversation.loadMessages();
      conversation.markAllMessagesAsRead();
      for (ChatMessage element in msgList) {
        // await agoraChatClient.chatManager.sendGroupMessageReadAck(
        //   element.msgId,
        //   getSelectedGroupChat.groupId,
        // );

        log('read => ${element.hasRead}');
        log('hasReadAck ==> ${element.hasReadAck}');
        log('hasDeliverAck => ${element.hasDeliverAck}');
        switch (element.body.type) {
          case MessageType.TXT:
            final messageBody = element.body as ChatTextMessageBody;
            messageList.add(
              MessageData(
                msgId: element.msgId,
                message: messageBody.content,
                isSender: element.direction == MessageDirection.SEND,
                dateTime:
                    DateTime.fromMillisecondsSinceEpoch(element.localTime),
                from: element.from ?? '',
                hasRead: element.hasRead,
                hasDelivered: element.hasRead,
                type: messageBody.type,
              ),
            );
            break;

          case MessageType.IMAGE:
            final messageBody = element.body as ChatImageMessageBody;
            messageList.add(
              MessageData(
                msgId: element.msgId,
                message: messageBody.displayName ?? '',
                imagePath: messageBody.remotePath,
                isSender: element.direction == MessageDirection.SEND,
                dateTime:
                    DateTime.fromMillisecondsSinceEpoch(element.localTime),
                from: element.from ?? '',
                hasRead: element.hasRead,
                hasDelivered: element.hasRead,
                type: messageBody.type,
              ),
            );
            break;
          case MessageType.FILE:
            final messageBody = element.body as ChatFileMessageBody;
            messageList.add(
              MessageData(
                msgId: element.msgId,
                message: messageBody.displayName ?? '',
                filePath: messageBody.remotePath,
                isSender: element.direction == MessageDirection.SEND,
                dateTime:
                    DateTime.fromMillisecondsSinceEpoch(element.localTime),
                from: element.from ?? '',
                hasRead: element.hasRead,
                hasDelivered: element.hasRead,
                type: messageBody.type,
              ),
            );
            break;

          case MessageType.CUSTOM:
            ChatCustomMessageBody body = element.body as ChatCustomMessageBody;
            log('event ==> ${body.event}');
            displayMessage(
              msgId: element.msgId,
              text: body.params?['name'] ?? '',
              contact: ContactData(
                body.params?['name'] ?? '',
                body.params?['number'] ?? '',
              ),
              from: element.from ?? '',
              isSentMessage: element.direction == MessageDirection.SEND,
              dateTime: DateTime.fromMicrosecondsSinceEpoch(element.localTime),
              hasRead: element.hasReadAck,
              hasDelivered: element.hasRead,
              type: body.type,
            );
            break;
          default:
        }
        notifyListeners();
      }
    }
  }

  Future<void> pickImageAndSend() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      imageFile = pickedImage;
      sendMessage(messageType: MessageType.IMAGE);
    }
  }

  Future<void> pickFileAndSent() async {
    final filePicker = FilePicker.platform;
    final pickedFile = await filePicker.pickFiles();

    if (pickedFile != null) {
      file = pickedFile;
      sendMessage(messageType: MessageType.FILE);
    }
  }

  Future<void> pickContactAndSent() async {
    final PhoneContact contact = await FlutterContactPicker.pickPhoneContact();
    this.contact = contact;
    sendMessage(messageType: MessageType.CUSTOM);
  }

  void sendMessage({MessageType messageType = MessageType.TXT}) async {
    if (messageType == MessageType.TXT && messageBoxController.text.isEmpty) {
      showLog("Please type a message");
      return;
    }

    late ChatMessage msg;

    switch (messageType) {
      case MessageType.TXT:
        msg = ChatMessage.createTxtSendMessage(
          targetId: getSelectedGroupChat.groupId,
          content: messageBoxController.text,
          chatType: ChatType.GroupChat,
        );
        break;
      case MessageType.IMAGE:
        msg = ChatMessage.createImageSendMessage(
          targetId: getSelectedGroupChat.groupId,
          filePath: imageFile!.path,
          chatType: ChatType.GroupChat,
        );
        break;
      case MessageType.FILE:
        msg = ChatMessage.createFileSendMessage(
          targetId: getSelectedGroupChat.groupId,
          filePath: file!.files.first.path!,
          displayName: file!.files.first.name,
          fileSize: file!.files.first.size,
          chatType: ChatType.GroupChat,
        );
        break;
      case MessageType.CUSTOM:
        msg = ChatMessage.createCustomSendMessage(
          targetId: getSelectedGroupChat.groupId,
          event: 'contactType',
          params: {
            'name': contact?.fullName ?? '',
            'number': contact?.phoneNumber?.number ?? '',
          },
          chatType: ChatType.GroupChat,
        );
        break;
      default:
    }
    // msg.needGroupAck = true;

    try {
      await agoraChatClient.chatManager.sendMessage(msg);
    } on ChatError catch (e) {
      showLog(e.description);
    }
  }

  void editMessage(String msgId, String updatedMsg) async {
    var msg = ChatMessage.createTxtSendMessage(
      targetId: getSelectedGroupChat.groupId,
      content: updatedMsg,
      chatType: ChatType.GroupChat,
    );

    await conversations.updateMessage(msg);

    await agoraChatClient.chatManager.updateMessage(msg);
    messageList.firstWhere((element) => element.msgId == msgId).message =
        updatedMsg;
    // fetchPreviousMessages();
    Navigator.of(globalKey.currentContext!).pop();
    notifyListeners();
  }

  Future<void> deleteMessage(String msgId) async {
    try {
      await agoraChatClient.chatManager.deleteRemoteMessagesWithIds(
        conversationId: getSelectedGroupChat.groupId,
        type: ChatConversationType.GroupChat,
        msgIds: [msgId],
      );
      await conversations.deleteMessage(msgId);

      showLog('Message Deleted succesfully');
      fetchPreviousMessages();
      // Navigator.of(globalKey.currentContext!).pop();
    } on ChatError catch (e) {
      log('catch ==> ${e.description}');
    }
  }

  void showTypingIndicator([bool isUserTyping = false]) async {
    final msg = ChatMessage.createCmdSendMessage(
      targetId: getSelectedGroupChat.groupId,
      action: isUserTyping ? 'startTyping' : 'stopTyping',
      // params: {
      //   'userId': await agoraChatClient.getCurrentUserId() ?? '',
      //   'status': isUserTyping.toString(),
      // },
      deliverOnlineOnly: true,
      chatType: ChatType.GroupChat,
    );

    try {
      await agoraChatClient.chatManager.sendMessage(msg);
    } on ChatError catch (e) {
      showLog(e.description);
    }
  }

  void displayMessage({
    required String msgId,
    required String text,
    String? imagePath,
    String? filePath,
    ContactData? contact,
    required String from,
    required bool isSentMessage,
    required DateTime dateTime,
    required bool hasRead,
    required bool hasDelivered,
    required MessageType type,
  }) {
    messageList.add(
      MessageData(
        msgId: msgId,
        message: text,
        imagePath: imagePath,
        filePath: filePath,
        contact: contact,
        from: from,
        isSender: isSentMessage,
        dateTime: dateTime,
        hasRead: hasRead,
        hasDelivered: hasDelivered,
        type: type,
      ),
    );

    scrollController.jumpTo(scrollController.position.maxScrollExtent + 50);
    notifyListeners();
  }

  void downloadAttachments(MessageData messageData) async {
    log('messageData.filePath! ==> ${messageData.filePath!}');
    // final chatMessage = ChatMessage.createFileSendMessage(
    //   targetId: getSelectedGroupChat.groupId,
    //   filePath: messageData.filePath!,
    //   chatType: ChatType.GroupChat,
    // );
    // await agoraChatClient.chatManager.downloadAttachment(chatMessage);

    try {
      downloadFile(messageData.filePath!, messageData.message);
    } on ChatError catch (e) {
      showLog(e.description);
    } catch (e) {
      showLog(e.toString());
    }
  }

  Future<void> downloadFile(String url, String fileName) async {
    log('file to be saved ==> ${(await getExternalStorageDirectory())!.path}');
    try {
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: (await getExternalStorageDirectory())!.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
        // saveInPublicStorage: true,
      );

      log('status ==> $taskId');

      if (taskId != null) {
        await FlutterDownloader.open(taskId: taskId);
        showLog('Downloaded Completed');
      }
    } catch (e) {
      showLog(e.toString());
    }
  }

  Future<void> scrollAnimation() async {
    return await Future.delayed(
      const Duration(milliseconds: 100),
      () => scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    agoraChatClient.chatManager.removeEventHandler("MESSAGE_HANDLER");
    agoraChatClient.chatManager.removeMessageEvent('UNIQUE_HANDLER_ID');
    agoraChatClient.removeConnectionEventHandler("CONNECTION_HANDLER");
    super.dispose();
  }
}
