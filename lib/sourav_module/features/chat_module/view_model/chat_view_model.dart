import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:agora_chat_module/main.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/models/conversations.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/models/domain_user.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/models/message_data_model.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/models/messages.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/services/realtime_db_service.dart';
// import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      this.user = user;
    }
  }

  User? user;

  final _dbService = RealtimeDBService();

  bool isJoined = false;
  bool isLoading = false;

  late ScrollController scrollController;
  late TextEditingController messageBoxController;
  late StreamController<Conversations> streamController;

  XFile? imageFile;
  FilePickerResult? file;
  PhoneContact? contact;
  bool shouldShowTypingIndicator = false;

  final List<String> _suggestions = [];
  List<String> get suggestions => _suggestions;
  String? _mention;
  String? get mention => _mention;
  set setMention(newValue) => _mention = newValue;

  List<String> _filteredSuggestions = [];
  List<String> get filteredSuggestions => _filteredSuggestions;
  set setFilteredSuggestions(List<String> newList) =>
      _filteredSuggestions = newList;

  showLog(String message) {
    scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  List<Conversations> conversationsList = [];
  late String selectedConversationName = conversationsList.first.name;
  Conversations get getSelectedConversation => conversationsList
      .firstWhere((element) => element.name == selectedConversationName);
  List<DomainUser> groupMembers = [];

  void setupControllers({
    required TextEditingController textEditingController,
    required ScrollController scrollController,
  }) {
    messageBoxController = textEditingController;
    this.scrollController = scrollController;
  }

  void checkIfUserLoggedIn() async {
    if (user != null) {
      isJoined = true;
      fetchConversations();
      notifyListeners();
    }
  }

  Future<void> loginOrLogout({String? email, String? password}) async {
    try {
      final auth = FirebaseAuth.instance;

      if (!isJoined) {
        final userCred = await auth.signInWithEmailAndPassword(
          email: email!,
          password: password!,
        );

        if (userCred.user != null) {
          user = userCred.user!;
          isJoined = true;
          await fetchConversations();
          notifyListeners();
          Navigator.of(globalKey.currentContext!).pop();
        }
      } else {
        await auth.signOut();
        isJoined = false;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      showLog(e.message!);
    }
  }

  void onConversationDropwdownChange(String conversationName) {
    selectedConversationName = conversationName;
    notifyListeners();
  }

  Future<void> fetchConversations() async {
    try {
      // isLoading = true;
      // notifyListeners();
      conversationsList = await _dbService.getConversationsByUserId(user!.uid);
    } catch (e) {
      showLog(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void fetchConversationByConversationId() async {
    _dbService
        .streamConversationsByConversationId('-NeabC6k0rHJ_dGwZuuV')
        .listen((conv) {
      if (conv.typingUsers.isNotEmpty &&
          !(conv.typingUsers.length == 1 &&
              conv.typingUsers.first == user!.uid)) {
        shouldShowTypingIndicator = true;
      } else {
        shouldShowTypingIndicator = false;
      }
      notifyListeners();
    });
  }

  // void fetchAllMessagesInSelectedConversation([bool paginate = false]) async {
  //   try {
  //     _dbService
  //         .fetchMessagesByConversationId(getSelectedConversation.id, paginate)
  //         .listen((listOfMessages) {
  //       messagesList.addAll(listOfMessages);
  //       log('length ==> ${messagesList.length}');
  //       messagesList.sort((a, b) =>
  //           DateTime.fromMillisecondsSinceEpoch(b.sentAt)
  //               .compareTo(DateTime.fromMillisecondsSinceEpoch(a.sentAt)));
  //       notifyListeners();
  //     });
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }

  void fetchGroupConversationMembers() async {
    final listOfMembers = await _dbService.getGroupsMembers(
        conversationId: getSelectedConversation.id, currentUserUid: user!.uid);

    groupMembers.clear();

    groupMembers = listOfMembers;
    _suggestions.clear();
    for (DomainUser user in groupMembers) {
      // if (user.id != this.user!.uid) {
      _suggestions.add(user.displayName);
      // }
    }
  }

  void detectUserMention() {
    final text = messageBoxController.text;

    final index = text.lastIndexOf('@');
    if (index >= 0 && index < text.length - 1) {
      final mentionedName = text.substring(index + 1).toLowerCase();
      if (mentionedName != mention) {
        setMention = mentionedName;
        setFilteredSuggestions = suggestions
            .where((name) => name.toLowerCase().startsWith(mention!))
            .toList();
      }
    } else {
      setMention = null;
      setFilteredSuggestions = [];
    }
    notifyListeners();
  }

  void onUserMentionTap({required int index}) {
    final mention = filteredSuggestions[index];
    final text = messageBoxController.text;
    final indexs = text.lastIndexOf('@');
    messageBoxController.value = TextEditingValue(
      text: text.substring(0, indexs + 1) + mention,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setFilteredSuggestions = [];
    notifyListeners();
  }

  Future<void> pickImageAndSend() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      imageFile = pickedImage;
      sendMessage(MessageType.IMAGE);
    }
  }

  Future<void> pickFileAndSent() async {
    final filePicker = FilePicker.platform;
    final pickedFile = await filePicker.pickFiles();

    if (pickedFile != null) {
      file = pickedFile;
      sendMessage(MessageType.FILE);
    }
  }

  Future<void> pickContactAndSent() async {
    final PhoneContact contact = await FlutterContactPicker.pickPhoneContact();
    this.contact = contact;
    sendMessage(MessageType.CONTACT);
  }

  void sendMessage(MessageType type) async {
    final conversationId = getSelectedConversation.id;

    switch (type) {
      case MessageType.TEXT:
        await _dbService.postNewMessage(
          user: user!,
          conversationId: conversationId,
          text: messageBoxController.text,
          type: type,
        );
        break;
      case MessageType.IMAGE:
        await _dbService.postNewMessage(
          user: user!,
          conversationId: conversationId,
          text: imageFile!.name,
          type: type,
          imageFile: File(imageFile!.path),
        );
        break;
      case MessageType.FILE:
        await _dbService.postNewMessage(
          user: user!,
          conversationId: conversationId,
          text: file!.names.first!,
          type: type,
          file: File(file!.paths.first!),
        );
        break;
      case MessageType.CONTACT:
        await _dbService.postNewMessage(
          user: user!,
          conversationId: conversationId,
          text: 'contacts',
          type: type,
          contact: contact,
        );
        break;
    }
    messageBoxController.clear();
  }

  void editMessage(Message updatedMsg) async {
    await _dbService.updateMessage(
      getSelectedConversation.id,
      updatedMsg,
    );
    Navigator.of(globalKey.currentContext!).pop();
  }

  Future<void> deleteMessage(String msgId) async {
    try {
      await _dbService.deleteMessageById(
        conversationId: getSelectedConversation.id,
        messageId: msgId,
      );
    } on Error catch (e) {
      log('catch ==> $e');
    }
  }

  void markMessageAsRead(Message message) async {
    try {
      _dbService.markMessageAsRead(
        conversationId: getSelectedConversation.id,
        messageId: message.id,
        updatedSeenBy: [...message.seenBy, user!.uid],
      );
    } catch (e) {
      showLog(e.toString());
    }
  }

  void showTypingIndicator([bool isUserTyping = false]) async {
    final typers = [...getSelectedConversation.typingUsers];
    if (isUserTyping) {
      typers.add(user!.uid);
    } else {
      typers.remove(user!.uid);
    }

    try {
      _dbService.updateUserAsTyper(
        conversationId: getSelectedConversation.id,
        updatedTypers: typers,
      );
    } catch (e) {
      showLog(e.toString());
    }
  }

  void downloadAttachments(Message message) async {
    try {
      downloadFile(message.fileUrl!, message.text);
    } catch (e) {
      showLog(e.toString());
    }
  }

  Future<void> downloadFile(String url, String fileName) async {
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
}
