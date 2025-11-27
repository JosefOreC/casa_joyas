import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube una imagen a Firebase Storage y retorna la URL de descarga
  ///
  /// [imageFile] - Archivo de imagen a subir
  /// [userId] - ID del usuario (para organizar por carpetas)
  ///
  /// Retorna la URL de descarga de la imagen
  Future<String> uploadJewelrySearchImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      // Crear nombre único para el archivo usando timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'jewelry_search_${userId}_$timestamp.jpg';

      // Referencia al path en Storage
      final storageRef = _storage.ref().child('solicitudes/$userId/$fileName');

      // Metadata opcional
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Subir archivo
      final uploadTask = await storageRef.putFile(imageFile, metadata);

      // Obtener URL de descarga
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }
}
