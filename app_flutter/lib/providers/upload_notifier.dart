import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UploadStatus { idle, uploading, success, error }

class UploadState {
  final UploadStatus status;
  final String? message;

  UploadState({required this.status, this.message});
}

class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier() : super(UploadState(status: UploadStatus.idle));

  Future<void> uploadText(String text) async {
    try {
      state = UploadState(status: UploadStatus.uploading);
      Uint8List data = Uint8List.fromList(text.codeUnits);
      String fileName = 'text_${DateTime.now().millisecondsSinceEpoch}.txt';

      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putData(data);
      await uploadTask.whenComplete(() {});

      await _retryFindDocument(fileName);
    } catch (e) {
      state = UploadState(status: UploadStatus.error, message: e.toString());
    }
  }

  Future<void> uploadFile({File? file, Uint8List? fileBytes, required String fileName}) async {
    try {
      state = UploadState(status: UploadStatus.uploading);

      String storageFileName = 'file_${DateTime.now().millisecondsSinceEpoch}_${fileName}';
      Reference storageRef = FirebaseStorage.instance.ref().child(storageFileName);

      if (file != null) {
        UploadTask uploadTask = storageRef.putFile(file);
        await uploadTask.whenComplete(() {});
      } else if (fileBytes != null) {
        UploadTask uploadTask = storageRef.putData(fileBytes);
        await uploadTask.whenComplete(() {});
      }

      await _retryFindDocument(storageFileName);
    } catch (e) {
      state = UploadState(status: UploadStatus.error, message: e.toString());
    }
  }

  Future<void> _retryFindDocument(String fileName) async {
    int maxRetries = 10;
    int delaySeconds = 2;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      await Future.delayed(Duration(seconds: delaySeconds));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('processedFiles')
          .where('fileName', isEqualTo: fileName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;

        FirebaseFirestore.instance
            .collection('processedFiles')
            .doc(docId)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            var data = snapshot.data();
            if (data != null && data.containsKey('ai_output')) {
              state = UploadState(status: UploadStatus.success, message: data['ai_output']);
            }
          }
        });
        return;
      }
    }

    state = UploadState(status: UploadStatus.error, message: 'No se encontró el documento en Firestore.');
  }
}

final uploadNotifierProvider = StateNotifierProvider<UploadNotifier, UploadState>(
      (ref) => UploadNotifier(),
);