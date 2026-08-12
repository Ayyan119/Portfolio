import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadFile({
    required Uint8List bytes,
    required String path,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('$path/$fileName');
      final uploadTask = await ref.putData(bytes);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to upload image to Firebase Storage: $e';
    }
  }
}
