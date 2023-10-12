import 'dart:convert';

class DomainUser {
  final String id;
  final int? agoraId;
  final String displayName;
  final String email;
  final String photoUrl;
  final List<String> conversations;

  DomainUser({
    required this.id,
    this.agoraId,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.conversations,
  });

  DomainUser copyWith({
    String? id,
    int? agoraId,
    String? displayName,
    String? email,
    String? photoUrl,
    List<String>? conversations,
  }) =>
      DomainUser(
        id: id ?? this.id,
        agoraId: agoraId ?? this.agoraId,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        conversations: conversations ?? this.conversations,
      );

  factory DomainUser.fromRawJson(String str) =>
      DomainUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DomainUser.fromJson(Map<String, dynamic> json) => DomainUser(
        id: json["id"],
        agoraId: json["agoraId"],
        displayName: json["displayName"],
        email: json["email"],
        photoUrl: json["photoUrl"],
        conversations: json["conversations"] != null
            ? List<String>.from(json["conversations"].map((x) => x))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "agoraId": agoraId,
        "displayName": displayName,
        "email": email,
        "photoUrl": photoUrl,
        "conversations": List<dynamic>.from(conversations.map((x) => x)),
      };
}
