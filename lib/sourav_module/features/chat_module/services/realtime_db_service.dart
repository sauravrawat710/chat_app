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

class RealtimeDBService {
  final db = FirebaseDatabase.instance;
  final storage = FirebaseStorage.instance;
  late DatabaseReference conversationRef;
  late DatabaseReference messagesRef;
  late DatabaseReference usersRef;
  // int limitTo = 5;
  // int? startAfter;
  // int? endAt;

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

  // Stream<List<Message>> fetchMessagesByConversationId(
  //     String conversationId, bool paginate) async* {
  //   try {
  //     // print('limitTo ==> $limitTo');
  //     // print('startAfter ==> $startAfter');
  //     // print('endAt ==> $endAt');
  //     late final Query msgRef;
  //     // if (!paginate) {
  //     msgRef = db.ref('messages/$conversationId').limitToLast(10);
  //     // startAfter = limitTo;
  //     // endAt = limitTo + limitTo;
  //     // } else {
  //     //   msgRef = db
  //     //       .ref('messages/$conversationId')
  //     //       .limitToLast(limitTo)
  //     //       .startAfter(startAfter)
  //     //       .endAt(endAt);
  //     //   startAfter = endAt!;
  //     //   endAt = startAfter! + limitTo;
  //     // }
  //     final streamOfData = msgRef.onValue;

  //     yield* streamOfData.asyncMap((event) {
  //       if (event.snapshot.value != null) {
  //         final mapOfData = Map.from(event.snapshot.value as Map);
  //         final messageList = mapOfData.entries
  //             .map((e) => Message.fromJson({
  //                   "id": e.key,
  //                   "sentAt": e.value["sentAt"],
  //                   "sentBy": e.value["sentBy"],
  //                   "text": e.value["text"],
  //                   "type": e.value["type"],
  //                   "imageUrl": e.value["imageUrl"],
  //                   "fileUrl": e.value["fileUrl"],
  //                   "contactInfo": e.value["contactInfo"],
  //                 }))
  //             .toList();

  //         final newMessageList = messageList.map((e) {
  //           if (e.sentBy == currentUser?.uid) {
  //             return e.copyWith(isSender: true);
  //           }
  //           return e;
  //         }).toList();

  //         return newMessageList;
  //       } else {
  //         return [];
  //       }
  //     });
  //   } on FirebaseException catch (e) {
  //     log(e.message.toString());
  //     rethrow;
  //   } catch (e) {
  //     log('errrrrr =>$e');
  //     rethrow;
  //   }
  // }

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

  Future<bool> postNewMessage({
    required String conversationId,
    required String text,
    required MessageType type,
    required User user,
    File? imageFile,
    File? file,
    PhoneContact? contact,
  }) async {
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

        storageUploadTask.snapshotEvents.listen((event) async {
          if (event.state == TaskState.success) {
            final url = await event.ref.getDownloadURL();
            newMessage = newMessage.copyWith(imageUrl: url);
            await conversationRef.update(newMessage.toJson());
          }
        });
        return true;
      } else if (type == MessageType.FILE && file != null) {
        final ref = storage.ref().child("files/");

        final storageUploadTask = ref.child(conversationRef.key!).putFile(file);

        storageUploadTask.snapshotEvents.listen((event) async {
          if (event.state == TaskState.success) {
            final url = await event.ref.getDownloadURL();
            newMessage = newMessage.copyWith(fileUrl: url);
            await conversationRef.update(newMessage.toJson());
          }
        });
        return true;
      } else if (type == MessageType.CONTACT && contact != null) {
        newMessage = newMessage.copyWith(contactInfo: contact);
        await conversationRef.update(newMessage.toJson());
        return true;
      } else {
        await conversationRef.update(newMessage.toJson());
        return true;
      }
    } on FirebaseException catch (e) {
      log(e.message.toString());
      return false;
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

  // void addUser() async {
  //   await usersRef.child('MWj7occq8XRfkNTjT2UlAtU4O8R2').set({
  //     "id": "MWj7occq8XRfkNTjT2UlAtU4O8R2",
  //     "displayName": "Sourav",
  //     "email": "sourav@elred.com",
  //     "photoUrl": "",
  //     "conversations": ["-NeabC6k0rHJ_dGwZuuV"]
  //   });
  // }
}
