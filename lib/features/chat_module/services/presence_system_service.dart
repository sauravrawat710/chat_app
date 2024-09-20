import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PresenceStatus {
  final bool online;
  final int lastSeen;

  PresenceStatus({required this.online, required this.lastSeen});
}

class PresenceSystemService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userStatusDatabaseRef =
      FirebaseDatabase.instance.ref("/status");

  void monitorUserPresence() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DatabaseReference connectedRef =
          FirebaseDatabase.instance.ref(".info/connected");

      connectedRef.onValue.listen((event) {
        if (event.snapshot.value == true) {
          _userStatusDatabaseRef.child(currentUser.uid).update({
            'online': true,
            'last_seen': DateTime.now().millisecondsSinceEpoch,
          });

          _userStatusDatabaseRef.child(currentUser.uid).onDisconnect().update({
            'online': false,
            'last_seen': DateTime.now().millisecondsSinceEpoch,
          });
        }
      });
    }
  }

  // Method to get user status (online/offline) and last seen
  Stream<PresenceStatus?> getUserStatus(String? userId) async* {
    if (userId != null) {
      DatabaseReference userStatusRef = _userStatusDatabaseRef.child(userId);

      yield* userStatusRef.onValue.asyncMap((event) async {
        if (event.snapshot.value != null) {
          Map<String, dynamic>? data =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          return PresenceStatus(
            online: data['online'],
            lastSeen: data['last_seen'],
          );
        } else {
          return null;
        }
      });
    }
  }
}
