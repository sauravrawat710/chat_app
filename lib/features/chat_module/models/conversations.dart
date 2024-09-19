import 'dart:convert';
import 'package:flutter/foundation.dart'; // For Uint8List

class Conversations {
  String id;
  int createdAt;
  String createdBy;
  String? modifiedBy;
  List<String> members;
  String name;
  Map<String, Uint8List>
      encryptedSessionKeys; // Store session keys with user IDs as keys
  RecentMessage recentMessage;
  String type;
  List<String> typingUsers;

  Conversations({
    required this.id,
    required this.createdAt,
    required this.createdBy,
    this.modifiedBy,
    required this.members,
    required this.name,
    required this.encryptedSessionKeys,
    required this.recentMessage,
    required this.type,
    required this.typingUsers,
  });

  // Factory method to convert from JSON to Conversations model
  factory Conversations.fromJson(Map<String, dynamic> json) {
    // Decode the session keys map from Base64
    Map<String, Uint8List> sessionKeys = {};
    if (json['encryptedSessionKeys'] != null) {
      sessionKeys = (json['encryptedSessionKeys'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, base64Decode(value)),
      );
    }

    return Conversations(
      id: json["id"],
      createdAt: json["createdAt"],
      createdBy: json["createdBy"],
      modifiedBy: json["modifiedBy"],
      members: List<String>.from(json["members"].map((x) => x)),
      name: json["name"],
      encryptedSessionKeys: sessionKeys,
      recentMessage: RecentMessage.fromJson(json["recentMessage"]),
      type: json["type"],
      typingUsers: json["typingUsers"] != null
          ? List<String>.from(json["typingUsers"].map((x) => x))
          : [],
    );
  }

  // Convert Conversations model back to JSON (to store in Firebase)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": createdAt,
      "createdBy": createdBy,
      "modifiedBy": modifiedBy,
      "members": List<dynamic>.from(members.map((x) => x)),
      "name": name,
      "encryptedSessionKeys": encryptedSessionKeys.map(
        (key, value) => MapEntry(key, base64Encode(value)),
      ),
      "recentMessage": recentMessage.toJson(),
      "type": type,
      "typingUsers": List<dynamic>.from(typingUsers.map((x) => x)),
    };
  }
}

class RecentMessage {
  final String text;
  final ReadBy readBy;

  RecentMessage({
    required this.text,
    required this.readBy,
  });

  RecentMessage copyWith({
    String? text,
    ReadBy? readBy,
  }) =>
      RecentMessage(
        text: text ?? this.text,
        readBy: readBy ?? this.readBy,
      );

  factory RecentMessage.fromRawJson(String str) =>
      RecentMessage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecentMessage.fromJson(Map<String, dynamic> json) => RecentMessage(
        text: json["text"],
        readBy: ReadBy.fromJson(json["readBy"]),
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "readBy": readBy.toJson(),
      };
}

class ReadBy {
  final int sentAt;
  final String sentBy;

  ReadBy({
    required this.sentAt,
    required this.sentBy,
  });

  ReadBy copyWith({
    int? sentAt,
    String? sentBy,
  }) =>
      ReadBy(
        sentAt: sentAt ?? this.sentAt,
        sentBy: sentBy ?? this.sentBy,
      );

  factory ReadBy.fromRawJson(String str) => ReadBy.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReadBy.fromJson(Map<String, dynamic> json) => ReadBy(
        sentAt: json["sentAt"],
        sentBy: json["sentBy"],
      );

  Map<String, dynamic> toJson() => {
        "sentAt": sentAt,
        "sentBy": sentBy,
      };
}
