import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube una foto de perfil a Firebase Storage
  /// Retorna la URL de descarga
  Future<String> uploadProfilePhoto(File imageFile, String userId) async {
    try {
      // Crear nombre único con timestamp para evitar problemas de caché
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Referencia al archivo en Storage
      final ref = _storage.ref().child('users/$userId/$fileName');

      // Metadata opcional para especificar el tipo de archivo
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      // Subir el archivo con metadata
      await ref.putFile(imageFile, metadata);

      // Obtener URL de descarga después de la subida exitosa
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir la foto: $e');
    }
  }

  /// Elimina la foto de perfil del usuario
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile_photo.jpg');
      await ref.delete();
    } catch (e) {
      // Si el archivo no existe, no hacer nada
      if (!e.toString().contains('object-not-found')) {
        throw Exception('Error al eliminar la foto: $e');
      }
    }
  }

  /// Obtiene la URL de la foto de perfil si existe
  Future<String?> getProfilePhotoUrl(String userId) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile_photo.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      // Si no existe la foto, retornar null
      return null;
    }
  }
}
