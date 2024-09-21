import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/core/utlis/flutter_secure_storage.dart';
import 'package:chat_app/core/utlis/encryption_generator.dart';
import 'package:chat_app/features/chat_module/services/presence_system_service.dart';

import '../../../main.dart';
import '../models/conversations.dart';
import '../models/domain_user.dart';
import '../models/messages.dart';
import '../services/realtime_db_service.dart';
import '../../noitifications/notification_controller.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as loc;
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart' as permission;

class ChatViewModel extends ChangeNotifier {
  ChatViewModel() {
    initFirebaseUser();
  }

  void initFirebaseUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isLoading = true;
      notifyListeners();
      this.user = user;

      _dbService.getUsersFromUserIds([user.uid]).then((users) {
        if (users.isEmpty) {
          this.user = null;
          isJoined = false;
          isLoading = false;
          return;
        } else {
          currentUser = users.first;
          _presenceService.monitorUserPresence();
        }
      });
      isLoading = false;
      notifyListeners();
    }
  }

  User? user;

  final _dbService = RealtimeDBService();
  final _presenceService = PresenceSystemService();

  bool isJoined = false;
  bool isLoading = false;

  late ScrollController scrollController;
  late TextEditingController messageBoxController;
  MessageStatus? messageStatus;

  XFile? imageFile;
  FilePickerResult? document;
  PhoneContact? contact;
  FilePickerResult? audioFile;
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

  void showLog(String message) {
    scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  List<Conversations> conversationsList = [];
  late String selectedConversationId;
  Conversations get getSelectedConversation => conversationsList
      .firstWhere((element) => element.id == selectedConversationId);
  DomainUser? currentUser;
  List<DomainUser> allUserInfo = [];
  List<DomainUser> groupMembers = [];

  late loc.Location location = loc.Location();
  late LocationData locationData;

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

  Future<bool?> login({required String email, required String password}) async {
    try {
      isLoading = true;
      notifyListeners();

      final auth = FirebaseAuth.instance;

      final userCred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCred.user != null) {
        user = userCred.user!;
        isJoined = true;
        await fetchConversations();
        isLoading = false;
        notifyListeners();
        return true;
      }

      return false;
    } on FirebaseAuthException catch (e) {
      showLog(e.message!);
    } catch (e) {
      showLog(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<bool> logout() async {
    try {
      final auth = FirebaseAuth.instance;
      await auth.signOut();
      isJoined = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      showLog(e.message!);
      return false;
    } catch (e) {
      showLog(e.toString());
      return false;
    }
  }

  Future<bool> createNewUser({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final storage = FlutterSecureStorageService();
      final keyPair = await EncryptionGenerator.generateRSAKeyPair();
      await storage.storeKeys(keyPair);
      final publicKey = await storage.getPublicKey();

      if (publicKey == null) {
        return false;
      }

      final userCred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCred.user != null) {
        return await _dbService.createNewUserInDB(
          userID: userCred.user!.uid,
          displayName: displayName,
          email: email,
          publicKey: publicKey,
        );
      }
      return false;
    } on FirebaseAuthException catch (e) {
      showLog(e.message!);
      return false;
    } catch (e) {
      showLog(e.toString());
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllUserOnboard() async {
    if (user == null) {
      return;
    }
    allUserInfo.clear();
    isLoading = true;
    final users = await _dbService.getAllUsersFromDB();
    for (var element in users) {
      if (element.id != user!.uid) {
        allUserInfo.add(element);
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> setupLocation() async {
    final location = loc.Location();

    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<Conversations> createNewConversation({
    required String name,
    required List<String> participants,
    required ConversationType conversationType,
  }) async {
    if (conversationsList.any((element) => element.name == name)) {
      return conversationsList.firstWhere((element) => element.name == name);
    } else {
      try {
        isLoading = true;
        notifyListeners();

        // Generate a session key for the conversation
        final sessionKey = EncryptionGenerator.generateAESKey();

        // Map to hold encrypted session keys for all participants
        final Map<String, String> encryptedSessionKeys = {};

        // Encrypt session key for each participant
        for (var participantId in participants) {
          final participant =
              allUserInfo.firstWhere((element) => element.id == participantId);

          // Get participant's public key
          final encodedParticipantPublicKey = participant.publicKey;

          // Decode the public key from PEM format
          final decodedParticipantPublicKey =
              EncryptionGenerator.decodePublicKeyFromPem(
                  encodedParticipantPublicKey);

          // Encrypt the session key with the participant's public key
          final encryptedSessionKeyForParticipant =
              EncryptionGenerator.rsaEncryptWithPublicKey(
                  sessionKey, decodedParticipantPublicKey);

          // Add encrypted session key to the map
          encryptedSessionKeys[participantId] =
              base64Encode(encryptedSessionKeyForParticipant);
        }

        // Also encrypt the session key for the current user (sender)
        final decodedSenderPublicKey =
            await FlutterSecureStorageService().getDecodedPublicKey();
        final encryptedSessionKeyForSender =
            EncryptionGenerator.rsaEncryptWithPublicKey(
                sessionKey, decodedSenderPublicKey);
        encryptedSessionKeys[user!.uid] =
            base64Encode(encryptedSessionKeyForSender);

        return await _dbService.createNewConversationInDB(
          name: name,
          participants: [...participants, user!.uid],
          createdBy: user!.uid,
          encryptedSessionKeys: encryptedSessionKeys,
          conversationType: conversationType,
        );
      } catch (e) {
        showLog(e.toString());
        rethrow;
      } finally {
        await fetchConversations();
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchConversations() async {
    try {
      isLoading = true;
      notifyListeners();
      _dbService.getConversationsByUserId(user!.uid).listen((conv) async {
        conversationsList = conv;

        for (var conversation in conversationsList) {
          if (conversation.recentMessage.text.isNotEmpty) {
            await _decyptRecentMessages(conversation);
          }
        }

        conversationsList.sort((a, b) =>
            DateTime.fromMillisecondsSinceEpoch(b.recentMessage.readBy.sentAt)
                .compareTo(DateTime.fromMillisecondsSinceEpoch(
                    a.recentMessage.readBy.sentAt)));

        notifyListeners();
      });
    } catch (e) {
      showLog(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _decyptRecentMessages(Conversations conversation) async {
    final encryptedSessionKey = conversation.encryptedSessionKeys[user!.uid];

    final privateKey =
        await FlutterSecureStorageService().getDecodedPrivateKey();

    final decyptedSessionKey = EncryptionGenerator.rsaDecryptWithPrivateKey(
      encryptedSessionKey!,
      privateKey,
    );

    final decrpytedMessage = EncryptionGenerator.aesDecrypt(
      base64Decode(conversation.recentMessage.text),
      decyptedSessionKey,
    );

    final decodedMessage = utf8.decode(base64.decode(decrpytedMessage));

    final newMessage =
        conversation.recentMessage.copyWith(text: decodedMessage);
    conversation.recentMessage = newMessage;
  }

  void fetchConversationByConversationId() async {
    _dbService
        .streamConversationsByConversationId(getSelectedConversation.id)
        .listen((conv) {
      if (conv.typingUsers.isNotEmpty) {
        final isOtherUserTyping = !(conv.typingUsers.length == 1 &&
            conv.typingUsers.contains(user!.uid));
        if (isOtherUserTyping) {
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

  void fetchGroupConversationMembers(String conversationId) async {
    selectedConversationId = conversationId;
    final listOfMembers = await _dbService.getGroupsMembers(
        conversationId: getSelectedConversation.id, currentUserUid: user!.uid);

    groupMembers.clear();
    _suggestions.clear();
    for (DomainUser user in listOfMembers) {
      if (user.id == this.user!.uid) {
        currentUser = user;
      } else {
        groupMembers.add(user);
        _suggestions.add(user.displayName);
      }
    }
    notifyListeners();
  }

  void detectUserMention() {
    final text = messageBoxController.text;
    if (messageBoxController.selection.baseOffset == -1) {
      return;
    }
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
      document = pickedFile;
      sendMessage(MessageType.FILE);
    }
  }

  Future<void> pickContactAndSent() async {
    final PhoneContact contact = await FlutterContactPicker.pickPhoneContact();
    this.contact = contact;
    sendMessage(MessageType.CONTACT);
  }

  Future<void> pickAudioAndSent() async {
    final audioFile = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (audioFile != null) {
      this.audioFile = audioFile;
      sendMessage(MessageType.AUDIO);
    }
  }

  Future<void> pickLocationAndSent() async {
    final canSendLocation = await setupLocation();
    if (canSendLocation != true) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //         "We can't access your location at this time. Did you allow location access?"),
      //   ),
      // );
    }

    final loc = await location.getLocation();

    locationData = LocationData(
      latitude: loc.latitude!,
      longitude: loc.longitude!,
    );
    sendMessage(MessageType.LOCATION);
  }

  void sendMessage([MessageType type = MessageType.TEXT]) async {
    if (type == MessageType.TEXT && messageBoxController.text.isEmpty) {
      return;
    }

    final conversationId = getSelectedConversation.id;

    switch (type) {
      case MessageType.TEXT:
        final senderEncryptedSessionKey =
            getSelectedConversation.encryptedSessionKeys[user!.uid]!;

        final senderPrivateKey =
            await FlutterSecureStorageService().getDecodedPrivateKey();

        final decyptedSessionKey = EncryptionGenerator.rsaDecryptWithPrivateKey(
          senderEncryptedSessionKey,
          senderPrivateKey,
        );

        final message = base64.encode(utf8.encode(messageBoxController.text));

        final encrpytedMessage = EncryptionGenerator.aesEncrypt(
          message,
          decyptedSessionKey,
        );

        _dbService
            .postNewMessage(
          user: user!,
          conversationId: conversationId,
          text: base64Encode(encrpytedMessage),
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
          text: document!.names.first!,
          type: type,
          docFile: File(document!.paths.first!),
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
      case MessageType.AUDIO:
        _dbService
            .postNewMessage(
          user: user!,
          conversationId: conversationId,
          text: 'audio',
          type: type,
          audioFile: File(audioFile!.paths.first!),
        )
            .listen((event) {
          if (messageStatus != event) {
            messageStatus = event;
            notifyListeners();
          }
        });
        break;
      case MessageType.LOCATION:
        _dbService
            .postNewMessage(
          user: user!,
          conversationId: conversationId,
          text: 'location',
          type: type,
          locationData: LocationData(
            latitude: locationData.latitude,
            longitude: locationData.longitude,
          ),
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
    final typers = {...getSelectedConversation.typingUsers};
    if (isUserTyping) {
      // if (!typers.contains(user!.uid)) {
      //   return;
      // }
      typers.add(user!.uid);
    } else {
      typers.remove(user!.uid);
    }

    print('typers ==> $typers');

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
      '007eJxTYOBRiD2/YWrf1vOck1ouHmOyl7Y8GH38bCWvnNoj4eN6pfMVGMwTk5OTDZNNkiwMDEwMjBMTjZOSTAxTk5MtTU0NjZItddeJpTYEMjJUtDCzMDJAIIgvzJCaU5SaoluSWlySmZeum16UX1rAwAAA1zAjXQ==';
  late AgoraClient client;
  late RtcEngine agoraEngine;
  bool _isUserJoined = false;

  List<DomainUser> listOfRemoteUserJoined = [];

  bool _isMuted = false;
  bool get isMuted => _isMuted;
  int speakerVolume = 0;

  Future<void> initializeVideoAgoraSDK() async {
    try {
      // Instantiate the client
      client = AgoraClient(
        agoraConnectionData: AgoraConnectionData(
          uid: currentUser?.agoraId ?? 0,
          appId: appId,
          channelName: getSelectedConversation.name,
          tempToken: token,
        ),
        agoraChannelData: AgoraChannelData(
          channelProfileType: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
        agoraEventHandlers: AgoraRtcEventHandlers(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            showLog("Local user uid:${connection.localUid} joined the channel");
            _isUserJoined = true;
            final content = NotificationContent(
              id: -1, // -1 is replaced by a random number
              channelKey: 'alerts',
              title: '${getSelectedConversation.name} calling you',
              body:
                  "${currentUser?.displayName} has initiated a group video call",
              notificationLayout: NotificationLayout.BigText,
            );

            NotificationController.createNewNotification(content);
            notifyListeners();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            showLog("Remote user uid:$remoteUid joined the channel");
            // _listOfRemoteUserJoined.add(remoteUid);
            // notifyListeners();
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            showLog("Remote user uid:$remoteUid left the channel");

            // _listOfRemoteUserJoined.remove(remoteUid);
            _isUserJoined = false;
            notifyListeners();
          },
        ),
        agoraRtmChannelEventHandler: AgoraRtmChannelEventHandler(
          onMemberJoined: (member) {
            showLog("Remote user uid:${member.userId} joined the channel");

            // _listOfRemoteUserJoined.add(member.userId);
            // notifyListeners();
          },
          onMemberLeft: (member) {
            showLog("Remote user uid:${member.userId} left the channel");

            // _listOfRemoteUserJoined.remove(member.userId);
            // notifyListeners();
          },
          onMemberCountUpdated: (count) {
            showLog("Total user count: $count");
          },
        ),
      );

      await client.initialize();
    } on AgoraRtcException catch (e) {
      showLog(e.message ?? '');
    } on AgoraRtmChannelException catch (e) {
      showLog(e.reason);
    } on AgoraRtmClientException catch (e) {
      showLog(e.reason);
    } catch (e) {
      showLog(e.toString());
    }
  }

  Future<void> setupAudioSDKEngine() async {
    try {
      log('setupAudioSDKEngine() called!!');
      // retrieve or request camera and microphone permissions
      await [Permission.microphone].request();

      //create an instance of the Agora engine
      agoraEngine = createAgoraRtcEngine();
      await agoraEngine.initialize(RtcEngineContext(appId: appId));

      // agoraEngine.registerAudioSpectrumObserver(AudioSpectrumObserver(
      //   onLocalAudioSpectrum: (data) {},
      // ));

      // Register the event handler
      agoraEngine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            showLog("Local user uid:${connection.localUid} joined the channel");
            log('Local user id ==> ${connection.localUid}');
            _isUserJoined = true;

            final content = NotificationContent(
              id: -1, // -1 is replaced by a random number
              channelKey: 'alerts',
              title: '${getSelectedConversation.name} calling you',
              body:
                  "${currentUser?.displayName} has initiated a group audio call",
              notificationLayout: NotificationLayout.BigText,
              payload: {'notificationId': '1234567890'},
            );

            NotificationController.createNewNotification(content);
            listOfRemoteUserJoined.clear();
            notifyListeners();
          },
          onUserJoined:
              (RtcConnection connection, int remoteUid, int elapsed) async {
            // for (DomainUser user in listOfRemoteUserJoined) {
            // if (user.agoraId != remoteUid) {
            final user = await _dbService.getUsersFromAgoraIds([remoteUid]);
            print('user ==> ${user.first}');

            listOfRemoteUserJoined.add(user.first);
            showLog("Remote user uid:$remoteUid joined the channel");
            showLog("listOfRemoteUserJoined ${listOfRemoteUserJoined.length}");
            notifyListeners();
            // }
            // }
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            showLog("Remote user uid:$remoteUid left the channel");

            final userToRemove = listOfRemoteUserJoined
                .firstWhere((element) => element.agoraId == remoteUid);

            listOfRemoteUserJoined.remove(userToRemove);
            notifyListeners();
          },
        ),
      );
    } on AgoraRtcException catch (e) {
      showLog(e.message ?? '');
    } on AgoraRtmChannelException catch (e) {
      showLog(e.reason);
    } on AgoraRtmClientException catch (e) {
      showLog(e.reason);
    } catch (e) {
      showLog(e.toString());
    }
  }

  void disposeAudioAgora() async {
    try {
      await agoraEngine.leaveChannel();
      await agoraEngine.release();
    } on AgoraRtcException catch (e) {
      showLog(e.message ?? '');
    } on AgoraRtmChannelException catch (e) {
      showLog(e.reason);
    } on AgoraRtmClientException catch (e) {
      showLog(e.reason);
    } catch (e) {
      showLog(e.toString());
    }
  }

  void join() async {
    try {
      // Set channel options including the client role and channel profile
      ChannelMediaOptions options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        autoSubscribeAudio: true,
        publishMicrophoneTrack: true,
      );

      await agoraEngine.muteLocalAudioStream(_isMuted);
      await agoraEngine.muteAllRemoteAudioStreams(false);
      await agoraEngine.enableAudioVolumeIndication(
        interval: 100, // Reporting interval in milliseconds
        smooth: 3, // Smoothing factor
        reportVad: true,
      );
      await agoraEngine.enableAudioSpectrumMonitor();
      await agoraEngine.joinChannel(
        token: token,
        channelId: getSelectedConversation.name,
        options: options,
        uid: currentUser?.agoraId ?? 0,
      );
    } on AgoraRtcException catch (e) {
      showLog(e.message ?? '');
    } on AgoraRtmChannelException catch (e) {
      showLog(e.reason);
    } on AgoraRtmClientException catch (e) {
      showLog(e.reason);
    } catch (e) {
      showLog(e.toString());
    }
  }

  void leaveAudioCall() async {
    try {
      _isUserJoined = false;
      // _listOfRemoteUserJoined.clear();
      await agoraEngine.leaveChannel();
      await agoraEngine.release();
      _isMuted = false;
      notifyListeners();
      Navigator.of(globalKey.currentContext!).pop();
    } on AgoraRtcException catch (e) {
      showLog(e.message ?? '');
    } on AgoraRtmChannelException catch (e) {
      showLog(e.reason);
    } on AgoraRtmClientException catch (e) {
      showLog(e.reason);
    } catch (e) {
      showLog(e.toString());
    }
  }

  onMuteClicked(bool value) async {
    try {
      _isMuted = value;
      await agoraEngine.muteLocalAudioStream(_isMuted);
      notifyListeners();
    } on AgoraRtcException catch (e) {
      showLog(e.message ?? '');
    } on AgoraRtmChannelException catch (e) {
      showLog(e.reason);
    } on AgoraRtmClientException catch (e) {
      showLog(e.reason);
    } catch (e) {
      showLog(e.toString());
    }
  }

  // void disposeVoiceAgora() async {
  //   await agoraEngine.leaveChannel();
  //   agoraEngine.release();
  // }
}
