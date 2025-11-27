import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/logica/products/jewelry_search_logic.dart';

class JewelrySearchScreen extends StatefulWidget {
  const JewelrySearchScreen({super.key});

  @override
  State<JewelrySearchScreen> createState() => _JewelrySearchScreenState();
}

class _JewelrySearchScreenState extends State<JewelrySearchScreen> {
  final ImagePicker _picker = ImagePicker();
  final JewelrySearchLogic _searchLogic = JewelrySearchLogic();

  File? _imageFile;
  bool _isUploading = false;

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Comprimir un poco para ahorrar espacio
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadAndSubmit() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor tome una foto primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authLogic = Provider.of<AuthLogic>(context, listen: false);
    final userId = authLogic.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe iniciar sesión para enviar solicitudes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final requestId = await _searchLogic.createSearchRequest(
        imageFile: _imageFile!,
        userId: userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Solicitud enviada con éxito! Le notificaremos cuando la joya esté disponible.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        // Volver a la pantalla anterior
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar solicitud: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Joya por Foto'),
        backgroundColor: const Color.fromARGB(255, 47, 1, 214),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instrucciones
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Instrucciones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Tome una foto clara de la joya que busca\n'
                      '2. Asegúrese de que la imagen tenga buena iluminación\n'
                      '3. Envíe la solicitud\n'
                      '4. Le notificaremos si tenemos la joya en stock',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Vista previa de la foto
            if (_imageFile != null)
              Card(
                elevation: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _imageFile!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay foto capturada',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Botón para tomar foto
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _takePicture,
              icon: const Icon(Icons.camera_alt),
              label: Text(_imageFile == null ? 'Tomar Foto' : 'Tomar Otra Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 16),

            // Botón para enviar
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadAndSubmit,
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(_isUploading ? 'Enviando...' : 'Enviar Solicitud'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 47, 1, 214),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
