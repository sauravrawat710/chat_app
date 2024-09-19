import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:chat_app/core/utlis/encryption_generator.dart';
import 'package:chat_app/core/utlis/flutter_secure_storage.dart';

import '../../models/messages.dart';
import '../../services/realtime_db_service.dart';
import 'receiver_row_widget.dart';
import 'sender_row_view.dart';
import '../../view_model/chat_view_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({Key? key, required this.scrollController})
      : super(key: key);

  final ScrollController scrollController;

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, value, child) => FirebaseDatabaseQueryBuilder(
        query: RealtimeDBService()
            .db
            .ref('messages/${value.getSelectedConversation.id}'),
        pageSize: 20,
        builder: (context, snapshot, child) {
          if (snapshot.hasError) {
            return Text('error ${snapshot.error}');
          }

          return FutureBuilder(
              future: _parseMessages(snapshot.docs, value),
              builder: (context, data) {
                List<Message> messagesList = data.data ?? [];

                return ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  reverse: true,
                  itemCount: messagesList.length,
                  itemBuilder: (context, index) {
                    if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                      snapshot.fetchMore();
                    }
                    widget.scrollController.addListener(() {
                      if (widget.scrollController.position.pixels ==
                          widget.scrollController.position.maxScrollExtent) {
                        snapshot.fetchMore();
                        log('load more()');
                      }
                    });

                    return messagesList[index].isSender
                        ? SenderRowView(messageData: messagesList[index])
                        : ReceiverRowView(messageData: messagesList[index]);
                  },
                );
              });
        },
      ),
    );
  }

  Future<List<Message>> _parseMessages(
      List<DataSnapshot> docs, ChatViewModel vm) async {
    List<Message> messagesList = [];
    if (docs.isNotEmpty) {
      for (DataSnapshot doc in docs) {
        final mapOfData = Map<String, dynamic>.from(doc.value as Map);
        Message parsedMessage = Message.fromJson(mapOfData);

        final isSender = parsedMessage.sentBy == vm.user!.uid;

        parsedMessage = parsedMessage.copyWith(isSender: isSender);

        if (!isSender && !parsedMessage.seenBy.contains(vm.user!.uid)) {
          vm.markMessageAsRead(parsedMessage);
        }

        final encryptedSessionKey =
            vm.getSelectedConversation.encryptedSessionKeys[vm.user!.uid];

        final senderPrivateKey =
            await FlutterSecureStorageService().getDecodedPrivateKey();

        final decyptedSessionKey = EncryptionGenerator.rsaDecryptWithPrivateKey(
          encryptedSessionKey!,
          senderPrivateKey,
        );

        final decrpytedMessage = EncryptionGenerator.aesDecrypt(
          base64Decode(parsedMessage.text),
          decyptedSessionKey,
        );

        final decodedMessage = utf8.decode(base64.decode(decrpytedMessage));

        final newMessage = parsedMessage.copyWith(text: decodedMessage);

        messagesList.add(newMessage);
      }
    }
    messagesList.sort((a, b) => DateTime.fromMillisecondsSinceEpoch(b.sentAt)
        .compareTo(DateTime.fromMillisecondsSinceEpoch(a.sentAt)));
    return messagesList;
  }
}

/// Removes PKCS7 padding
Uint8List _removePadding(Uint8List paddedData) {
  int paddingLength =
      paddedData.last; // Last byte tells how many padding bytes were added
  return paddedData.sublist(
      0, paddedData.length - paddingLength); // Remove padding
}
