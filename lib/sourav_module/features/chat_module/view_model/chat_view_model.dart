import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:agora_chat_module/main.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/models/conversations.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/models/domain_user.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/models/messages.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/services/realtime_db_service.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  MessageStatus? messageStatus;

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
        .streamConversationsByConversationId(getSelectedConversation.id)
        .listen((conv) {
      if (conv.typingUsers.isNotEmpty) {
        if (!(conv.typingUsers.length == 1 &&
            conv.typingUsers.contains(user!.uid))) {
          conversationsList = conversationsList.map((e) {
            if (e.id == conv.id) {
              return conv;
            }
            return e;
          }).toList();
          shouldShowTypingIndicator = true;
        }
      } else {
        shouldShowTypingIndicator = false;
      }
      notifyListeners();
    });
  }

  void fetchGroupConversationMembers() async {
    final listOfMembers = await _dbService.getGroupsMembers(
        conversationId: getSelectedConversation.id, currentUserUid: user!.uid);

    groupMembers.clear();
    _suggestions.clear();
    for (DomainUser user in listOfMembers) {
      if (user.id != this.user!.uid) {
        groupMembers.add(user);
        _suggestions.add(user.displayName);
      }
    }
    notifyListeners();
  }

  void detectUserMention() {
    final text = messageBoxController.text;
    final index =
        text.lastIndexOf('@', messageBoxController.selection.baseOffset);

    if (index >= 0 && index < text.length - 1) {
      notifyListeners();
      // Find the first space after the '@' character.
      final endIndex = text.indexOf(' ', index);
      final mentionedName = endIndex != -1
          ? text.substring(index + 1, endIndex).toLowerCase()
          : text.substring(index + 1).toLowerCase();

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

  void onUserMentionTap({required String name}) {
    final mention = name;
    final text = messageBoxController.text;
    final selection = messageBoxController.selection;

    // Find the last index of '@' before the cursor position.
    final indexs = text.lastIndexOf('@', selection.baseOffset);

    if (indexs >= 0) {
      final newText = '${text.substring(0, indexs + 1)}$mention';
      final newSelection = TextSelection(
        baseOffset: indexs + mention.length + 1, // +1 for the '@' character.
        extentOffset: indexs + mention.length + 1,
      );

      messageBoxController.value = TextEditingValue(
        text: newText + text.substring(selection.baseOffset),
        selection: newSelection,
      );

      setFilteredSuggestions = [];
      notifyListeners();
    }
  }

  Future<void> pickImageAndSend(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

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

  void sendMessage([MessageType type = MessageType.TEXT]) async {
    if (type == MessageType.TEXT && messageBoxController.text.isEmpty) {
      return;
    }

    final conversationId = getSelectedConversation.id;

    switch (type) {
      case MessageType.TEXT:
        _dbService
            .postNewMessage(
          user: user!,
          conversationId: conversationId,
          text: messageBoxController.text,
          type: type,
        )
            .listen((event) {
          if (messageStatus != event) {
            messageStatus = event;
            notifyListeners();
          }
          if (messageStatus == MessageStatus.SEND) {
            messageBoxController.clear();
            scrollController.animateTo(
              0.0,
              duration: const Duration(seconds: 2),
              curve: Curves.fastOutSlowIn,
            );
          }
        });
        break;
      case MessageType.IMAGE:
        _dbService
            .postNewMessage(
          user: user!,
          conversationId: conversationId,
          text: imageFile!.name,
          type: type,
          imageFile: File(imageFile!.path),
        )
            .listen((event) {
          log('event ==> $event');
          if (messageStatus != event) {
            messageStatus = event;
            notifyListeners();
          }
        });
        break;
      case MessageType.FILE:
        _dbService
            .postNewMessage(
          user: user!,
          conversationId: conversationId,
          text: file!.names.first!,
          type: type,
          file: File(file!.paths.first!),
        )
            .listen((event) {
          if (messageStatus != event) {
            messageStatus = event;
            notifyListeners();
          }
        });
        break;
      case MessageType.CONTACT:
        _dbService
            .postNewMessage(
          user: user!,
          conversationId: conversationId,
          text: 'contacts',
          type: type,
          contact: contact,
        )
            .listen((event) {
          if (messageStatus != event) {
            messageStatus = event;
            notifyListeners();
          }
        });
        break;
    }
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
      final taskId = await FlutterDownloader.enqueue(
        url: message.fileUrl!,
        savedDir: (await getExternalStorageDirectory())!.path,
        fileName: message.text,
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

  //agora audio/video
  final String appId = '7accc1c4b800403aa3bb41ecc95512c9';
  final String token =
      '007eJxTYHgYKr3311lxG9Y18+Qrefjyf63TT6maLLnw4dMXrBZr2q0VGMwTk5OTDZNNkiwMDEwMjBMTjZOSTAxTk5MtTU0NjZItHfMEUxsCGRny6/lZGRkgEMQXZkjNKUpN0S1JLS7JzEvXTS/KLy1gYAAA+wYjrA==';
  late final RtcEngine agoraEngine;
  bool _isUserJoined = false;
  List<int> _listOfRemoteUserJoined = [];

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    final agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(RtcEngineContext(appId: appId));

    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showLog("Local user uid:${connection.localUid} joined the channel");
          // setState(() {
          _isUserJoined = true;
          notifyListeners();
          // });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          showLog("Remote user uid:$remoteUid joined the channel");

          _listOfRemoteUserJoined.add(remoteUid);
          notifyListeners();
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showLog("Remote user uid:$remoteUid left the channel");

          _listOfRemoteUserJoined.remove(remoteUid);
          notifyListeners();
        },
      ),
    );
  }

  void join() async {
    await agoraEngine.startPreview();

    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: getSelectedConversation.id,
      options: options,
      uid: 0,
    );
  }

  void leave() {
    _isUserJoined = false;
    _listOfRemoteUserJoined.clear();
    agoraEngine.leaveChannel();
    notifyListeners();
  }

  void disposeAgora() async {
    await agoraEngine.leaveChannel();
    agoraEngine.release();
  }
}
