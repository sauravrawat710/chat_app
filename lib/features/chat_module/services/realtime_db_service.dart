// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/features/chat_module/models/conversations.dart';
import 'package:chat_app/features/chat_module/models/domain_user.dart';
import 'package:chat_app/features/chat_module/models/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

enum MessageStatus { SENDING, SEND, ERROR }

enum ConversationType { PRIVATE, GROUP }

class RealtimeDBService {
  final db = FirebaseDatabase.instance;
  final storage = FirebaseStorage.instance;
  late DatabaseReference conversationRef;
  late DatabaseReference messagesRef;
  late DatabaseReference usersRef;

  RealtimeDBService() {
    conversationRef = db.ref('conversations');
    messagesRef = db.ref('messages');
    usersRef = db.ref('users');
    db.setPersistenceEnabled(true);
    db.ref().keepSynced(true);
  }

  Stream<List<Conversations>> getConversationsByUserId(String userId) async* {
    try {
      final streamOfData = conversationRef.onValue;

      yield* streamOfData.asyncMap((event) {
        final json = jsonDecode(jsonEncode(event.snapshot.value));
        final conversationList = <Conversations>[];
        json.forEach((key, value) {
          final conversation = Conversations.fromJson(json[key]);
          if (conversation.members.contains(userId)) {
            conversationList.add(conversation);
          }
        });
        return conversationList;
      });
    } on FirebaseException catch (e) {
      log(e.message.toString());
      rethrow;
    } catch (e) {
      log('err =>$e');
      rethrow;
    }
  }

  Stream<Conversations> streamConversationsByConversationId(
      String conversationId) async* {
    try {
      final streamOfData = conversationRef.child(conversationId).onValue;

      yield* streamOfData.asyncMap((event) {
        final json = jsonDecode(jsonEncode(event.snapshot.value));
        final conversation = Conversations.fromJson(json);
        return conversation;
      });
    } on FirebaseException catch (e) {
      log(e.message.toString());
      rethrow;
    } catch (e) {
      log('err =>$e');
      rethrow;
    }
  }

  Future<Conversations> createNewConversationInDB({
    required String name,
    required String createdBy,
    required List<String> participants,
    required ConversationType conversationType,
  }) async {
    try {
      final result = conversationRef.push();

      await result.update({
        "id": result.key,
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "createdBy": createdBy,
        "modifiedby": null,
        "members": participants,
        "name": name,
        "recentMessage": {
          "text": "this is latest message",
          "readBy": {
            "sentAt": DateTime.now().millisecondsSinceEpoch,
            "sentBy": createdBy,
          }
        },
        "type":
            conversationType == ConversationType.GROUP ? "group" : "private",
        "typingUsers": []
      });

      final conversation = await conversationRef.child(result.key!).get();
      final json = jsonDecode(jsonEncode(conversation.value));

      return Conversations.fromJson(json);
    } on FirebaseException catch (e) {
      log(e.message.toString());
      rethrow;
    } catch (e) {
      log('errrrrr =>$e');
      rethrow;
    }
  }

  Future<List<DomainUser>> getGroupsMembers(
      {required String conversationId, required String currentUserUid}) async {
    try {
      final ref = conversationRef.child(conversationId).child('members');

      final result = await ref.get();

      final listOfMembersId = List<String>.from(result.value as Iterable);

      return getUsersFromUserIds(listOfMembersId);
    } on FirebaseException catch (e) {
      log(e.message.toString());
      rethrow;
    } catch (e) {
      log('errrrrr =>$e');
      rethrow;
    }
  }

  Future<bool> createNewUserInDB({
    required String userID,
    required String displayName,
    required String email,
  }) async {
    try {
      final newUserRef = usersRef.child(userID);

      await newUserRef.update({
        "id": userID,
        "displayName": displayName,
        "email": email,
        "photoUrl": "",
        "conversations": []
      });

      return true;
    } on FirebaseException catch (e) {
      log(e.message.toString());
      rethrow;
    } catch (e) {
      log('err =>$e');
      rethrow;
    }
  }

  Future<List<DomainUser>> getAllUsersFromDB() async {
    final List<DomainUser> usersList = [];
    final result = await usersRef.get();
    final mapOfData = Map<String, dynamic>.from(result.value as Map);
    for (var e in mapOfData.entries) {
      final map = Map<String, dynamic>.from(e.value);
      final domainUser = DomainUser.fromJson(map);
      usersList.add(domainUser);
    }
    return usersList;
  }

  Future<List<DomainUser>> getUsersFromUserIds(
      List<String> listOfUserId) async {
    final List<DomainUser> usersList = [];
    for (String userId in listOfUserId) {
      final result = await usersRef.child(userId).get();
      final mapOfData = Map<String, dynamic>.from(result.value as Map);
      final domainUser = DomainUser.fromJson(mapOfData);
      usersList.add(domainUser);
    }
    return usersList;
  }

  Future<List<DomainUser>> getUsersFromAgoraIds(List<int> listOfAgoraId) async {
    final List<DomainUser> usersList = [];
    try {
      for (int id in listOfAgoraId) {
        final result = await usersRef.orderByChild('agoraId').equalTo(id).get();
        final mapOfData = Map<String, dynamic>.from(result.value as Map);
        log('mapOfData in agoraid ==> $mapOfData');
        final domainUser = mapOfData.entries
            .map((e) => DomainUser.fromJson(Map<String, dynamic>.from(e.value)))
            .toList();
        usersList.add(domainUser.first);
        continue;
      }
      return usersList;
    } catch (e) {
      log('error ==> $e');
      rethrow;
    }
  }

  Stream<MessageStatus> postNewMessage({
    required String conversationId,
    required String text,
    required MessageType type,
    required User user,
    File? imageFile,
    File? docFile,
    PhoneContact? contact,
    File? audioFile,
    LocationData? locationData,
  }) async* {
    try {
      final msgRef = db.ref('messages/$conversationId');

      final conversationNode = msgRef.push();

      final int timeStamp = DateTime.now().millisecondsSinceEpoch;

      Message newMessage = Message.fromJson({
        "id": conversationNode.key,
        "text": text,
        "sentAt": timeStamp,
        "seenBy": <String>[],
        "sentBy": user.uid,
        "type": type.name,
      });

      if (type == MessageType.IMAGE && imageFile != null) {
        final ref = storage.ref().child("images/");

        final storageUploadTask =
            ref.child(conversationNode.key!).putFile(imageFile);

        yield* storageUploadTask.snapshotEvents.asyncMap((event) async {
          switch (event.state) {
            case TaskState.error:
              return MessageStatus.ERROR;
            case TaskState.paused:
              return MessageStatus.ERROR;
            case TaskState.running:
              return MessageStatus.SENDING;
            case TaskState.success:
              final url = await event.ref.getDownloadURL();
              newMessage = newMessage.copyWith(imageUrl: url);
              await conversationNode.update(newMessage.toJson());
              return MessageStatus.SEND;
            case TaskState.canceled:
              return MessageStatus.ERROR;
          }
        });
      } else if (type == MessageType.AUDIO && audioFile != null) {
        final ref = storage.ref().child("audio/");

        final storageUploadTask =
            ref.child(conversationNode.key!).putFile(audioFile);

        yield* storageUploadTask.snapshotEvents.asyncMap((event) async {
          switch (event.state) {
            case TaskState.error:
              return MessageStatus.ERROR;
            case TaskState.paused:
              return MessageStatus.ERROR;
            case TaskState.running:
              return MessageStatus.SENDING;
            case TaskState.success:
              final url = await event.ref.getDownloadURL();
              newMessage = newMessage.copyWith(audioUrl: url);
              await conversationNode.update(newMessage.toJson());
              return MessageStatus.SEND;
            case TaskState.canceled:
              return MessageStatus.ERROR;
          }
        });
      } else if (type == MessageType.FILE && docFile != null) {
        final ref = storage.ref().child("files/");

        final storageUploadTask =
            ref.child(conversationNode.key!).putFile(docFile);

        yield* storageUploadTask.snapshotEvents.asyncMap((event) async {
          switch (event.state) {
            case TaskState.error:
              return MessageStatus.ERROR;
            case TaskState.paused:
              return MessageStatus.ERROR;
            case TaskState.running:
              return MessageStatus.SENDING;
            case TaskState.success:
              final url = await event.ref.getDownloadURL();
              newMessage = newMessage.copyWith(fileUrl: url);
              await conversationNode.update(newMessage.toJson());
              return MessageStatus.SEND;
            case TaskState.canceled:
              return MessageStatus.ERROR;
          }
        });
      } else if (type == MessageType.CONTACT && contact != null) {
        yield MessageStatus.SENDING;
        newMessage = newMessage.copyWith(contactInfo: contact);
        await conversationNode.update(newMessage.toJson());
        yield MessageStatus.SEND;
      }
      if (type == MessageType.LOCATION && locationData != null) {
        yield MessageStatus.SENDING;
        newMessage = newMessage.copyWith(location: locationData);
        await conversationNode.update(newMessage.toJson());
        yield MessageStatus.SEND;
      } else {
        yield MessageStatus.SENDING;
        await conversationNode.update(newMessage.toJson());
        yield MessageStatus.SEND;
      }

      await conversationRef.child(conversationId).update({
        "recentMessage": {
          "text": newMessage.text,
          "readBy": {
            "sentAt": newMessage.sentAt,
            "sentBy": newMessage.sentBy,
          }
        },
      });
    } on FirebaseException catch (e) {
      log(e.message.toString());
      yield MessageStatus.ERROR;
    } catch (e) {
      log('err => $e');
      rethrow;
    }
  }

  Future<bool> updateMessage(
      String conversationId, Message updatedMessage) async {
    try {
      final msgRef = db.ref('messages/$conversationId/${updatedMessage.id}');

      await msgRef.update({"text": updatedMessage.text});

      await conversationRef.child(conversationId).update({
        "recentMessage": {
          "text": updatedMessage.text,
          "readBy": {
            "sentAt": updatedMessage.sentAt,
            "sentBy": updatedMessage.sentBy,
          }
        },
      });
      return true;
    } on FirebaseException catch (e) {
      log(e.message.toString());
      return false;
    } catch (e) {
      log('err =>$e');
      rethrow;
    }
  }

  Future<bool> deleteMessageById(
      {required String conversationId, required String messageId}) async {
    try {
      final msgRef = db.ref('messages/$conversationId/$messageId');

      await msgRef.remove();
      return true;
    } on FirebaseException catch (e) {
      log(e.message.toString());
      return false;
    } catch (e) {
      log('err =>$e');
      rethrow;
    }
  }

  void markMessageAsRead({
    required String conversationId,
    required String messageId,
    required List<String> updatedSeenBy,
  }) async {
    try {
      await messagesRef
          .child(conversationId)
          .child(messageId)
          .update({"seenBy": updatedSeenBy});
    } on FirebaseException catch (e) {
      log(e.message.toString());
    } catch (e) {
      log('err =>$e');
      rethrow;
    }
  }

  void updateUserAsTyper({
    required String conversationId,
    required List<String> updatedTypers,
  }) async {
    try {
      await conversationRef
          .child(conversationId)
          .update({"typingUsers": updatedTypers});
    } on FirebaseException catch (e) {
      log(e.message.toString());
    } catch (e) {
      log('err =>$e');
      rethrow;
    }
  }
}
