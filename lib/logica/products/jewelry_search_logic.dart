import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:casa_joyas/services/image_upload_service.dart';

class JewelrySearchLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();

  /// Crea una solicitud de búsqueda de joya por foto
  ///
  /// [imageFile] - Archivo de imagen capturado
  /// [userId] - ID del usuario que hace la solicitud
  ///
  /// Retorna el ID del documento creado
  Future<String> createSearchRequest({
    required File imageFile,
    required String userId,
  }) async {
    try {
      // 1. Subir imagen a Firebase Storage
      final imageUrl = await _imageUploadService.uploadJewelrySearchImage(
        imageFile: imageFile,
        userId: userId,
      );

      // 2. Crear documento en Firestore
      final docRef = await _firestore.collection('solicitudes').add({
        'foto': imageUrl,
        'user_id': userId,
        'fecha': FieldValue.serverTimestamp(),
        'estado': 'pendiente', // Estados: pendiente, procesada, completada
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear solicitud: $e');
    }
  }
}
