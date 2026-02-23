import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirebaseFirestore? _firestore;

  bool get supported => !Platform.isLinux;

  FirestoreService() {
    if (supported) {
      _firestore = FirebaseFirestore.instance;
    }
  }

  Future<void> saveTransaction(Map<String, dynamic> data) async {
    if (!supported) return;
    await _firestore!.collection("transaction").add(data);
  }
}

