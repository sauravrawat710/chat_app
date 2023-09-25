import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:agora_chat_module/sourav_module/features/chat_module/models/conversations.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/models/domain_user.dart';
import 'package:agora_chat_module/sourav_module/features/chat_module/models/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

// ignore: constant_identifier_names
enum MessageStatus { SENDING, SEND, ERROR }

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

  Future<List<Conversations>> getConversationsByUserId(String userId) async {
    try {
      final result = await conversationRef.get();
      final json = jsonDecode(jsonEncode(result.value));
      final conversationList = <Conversations>[];
      json.forEach((key, value) {
        final conversation = Conversations.fromJson(json[key]);
        if (conversation.members.contains(userId)) {
          conversationList.add(conversation);
        }
      });
      return conversationList;
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

  Stream<MessageStatus> postNewMessage({
    required String conversationId,
    required String text,
    required MessageType type,
    required User user,
    File? imageFile,
    File? file,
    PhoneContact? contact,
  }) async* {
    try {
      final msgRef = db.ref('messages/$conversationId');

      final conversationRef = msgRef.push();

      final int timeStamp = DateTime.now().millisecondsSinceEpoch;

      Message newMessage = Message.fromJson({
        "id": conversationRef.key,
        "text": text,
        "sentAt": timeStamp,
        "seenBy": <String>[],
        "sentBy": user.uid,
        "type": type.name,
      });

      if (type == MessageType.IMAGE && imageFile != null) {
        final ref = storage.ref().child("images/");

        final storageUploadTask =
            ref.child(conversationRef.key!).putFile(imageFile);

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
              await conversationRef.update(newMessage.toJson());
              return MessageStatus.SEND;
            case TaskState.canceled:
              return MessageStatus.ERROR;
          }
        });
      } else if (type == MessageType.FILE && file != null) {
        final ref = storage.ref().child("files/");

        final storageUploadTask = ref.child(conversationRef.key!).putFile(file);

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
              await conversationRef.update(newMessage.toJson());
              return MessageStatus.SEND;
            case TaskState.canceled:
              return MessageStatus.ERROR;
          }
        });
      } else if (type == MessageType.CONTACT && contact != null) {
        yield MessageStatus.SENDING;
        newMessage = newMessage.copyWith(contactInfo: contact);
        await conversationRef.update(newMessage.toJson());
        yield MessageStatus.SEND;
      } else {
        yield MessageStatus.SENDING;
        await conversationRef.update(newMessage.toJson());
        yield MessageStatus.SEND;
      }
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
      log('markMessageAsRead() called!!!');
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
