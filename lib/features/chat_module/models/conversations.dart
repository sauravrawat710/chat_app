import 'dart:developer';

import 'package:meta/meta.dart';
import 'dart:convert';

class Conversations {
  final String id;
  final int createdAt;
  final String createdBy;
  final String? modifiedBy;
  final List<String> members;
  final String name;
  final RecentMessage recentMessage;
  final String type;
  final List<String> typingUsers;

  Conversations({
    required this.id,
    required this.createdAt,
    required this.createdBy,
    this.modifiedBy,
    required this.members,
    required this.name,
    required this.recentMessage,
    required this.type,
    required this.typingUsers,
  });

  Conversations copyWith({
    String? id,
    int? createdAt,
    String? createdBy,
    String? modifiedBy,
    List<String>? members,
    String? name,
    RecentMessage? recentMessage,
    String? type,
    List<String>? typingUsers,
  }) =>
      Conversations(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        modifiedBy: modifiedBy ?? this.modifiedBy,
        members: members ?? this.members,
        name: name ?? this.name,
        recentMessage: recentMessage ?? this.recentMessage,
        type: type ?? this.type,
        typingUsers: typingUsers ?? this.typingUsers,
      );

  factory Conversations.fromRawJson(String str) =>
      Conversations.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Conversations.fromJson(Map<String, dynamic> json) {
    log(json['id'].toString());
    return Conversations(
      id: json["id"],
      createdAt: json["createdAt"],
      createdBy: json["createdBy"],
      modifiedBy: json["modifiedBy"],
      members: List<String>.from(json["members"].map((x) => x)),
      name: json["name"],
      recentMessage: RecentMessage.fromJson(json["recentMessage"]),
      type: json["type"],
      typingUsers: json["typingUsers"] != null
          ? List<String>.from(json["typingUsers"].map((x) => x))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt,
        "createdBy": createdBy,
        "modifiedBy": modifiedBy,
        "members": List<String>.from(members.map((x) => x)),
        "name": name,
        "recentMessage": recentMessage.toJson(),
        "type": type,
        "typingUsers": List<String>.from(typingUsers.map((x) => x)),
      };
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
