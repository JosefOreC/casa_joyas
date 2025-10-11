import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/modelo/products/joya.dart';
import 'package:casa_joyas/logica/products/joya_logic.dart'; 

class JoyaCRUDScreen extends StatefulWidget {
  const JoyaCRUDScreen({super.key});

  @override
  State<JoyaCRUDScreen> createState() => _JoyaCRUDScreenState();
}

class _JoyaCRUDScreenState extends State<JoyaCRUDScreen> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _idSeleccionado;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _descripcionController.clear();
    _precioController.clear();
    _stockController.clear();
    _imageUrlController.clear();
    setState(() {
      _idSeleccionado = null;
    });
  }

  void _editarJoya(Joya joya) {
    setState(() {
      _idSeleccionado = joya.id;
      _nombreController.text = joya.nombre;
      _descripcionController.text = joya.descripcion;
      _precioController.text = joya.precio.toString();
      _stockController.text = joya.stock.toString();
      _imageUrlController.text = joya.imageUrl;
    });
  }

  void _guardarJoya(JoyaLogic joyaLogic) async {
    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final precio = double.tryParse(_precioController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final imageUrl = _imageUrlController.text.trim();

    if (nombre.isEmpty || descripcion.isEmpty || precio <= 0 || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos y verifique Precio/Stock.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final nuevaJoya = Joya(
      id: _idSeleccionado ?? '',
      nombre: nombre,
      descripcion: descripcion,
      precio: precio,
      stock: stock,
      imageUrl: imageUrl,
    );

    try {
      if (_idSeleccionado == null) {
        await joyaLogic.addJoya(nuevaJoya);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joya agregada correctamente.'), backgroundColor: Colors.green));
      } else {
        await joyaLogic.updateJoya(nuevaJoya);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joya actualizada correctamente.'), backgroundColor: Colors.green));
      }
      _limpiarCampos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.redAccent));
    }
  }

  void _eliminarJoya(JoyaLogic joyaLogic, String id) async {
    await joyaLogic.deleteJoya(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joya eliminada.'), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_idSeleccionado == null ? 'Crear' : 'Editar'} Joya'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: _descripcionController, decoration: const InputDecoration(labelText: 'Descripción')),
            TextField(controller: _precioController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio')),
            TextField(controller: _stockController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock')),
            TextField(controller: _imageUrlController, decoration: const InputDecoration(labelText: 'URL Imagen')),
            
            const SizedBox(height: 16),
            
            Consumer<JoyaLogic>(
              builder: (context, joyaLogic, child) {
                return ElevatedButton(
                  onPressed: joyaLogic.isLoading ? null : () => _guardarJoya(joyaLogic),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  child: Text(_idSeleccionado == null ? 'Agregar Joya' : 'Actualizar Joya'),
                );
              },
            ),

            const SizedBox(height: 16),
            
            Expanded(
              child: Consumer<JoyaLogic>(
                builder: (context, joyaLogic, child) {
                  if (joyaLogic.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (joyaLogic.joyas.isEmpty) {
                    return const Center(child: Text('No hay joyas registradas.'));
                  }
                  return ListView.builder(
                    itemCount: joyaLogic.joyas.length,
                    itemBuilder: (context, index) {
                      final joya = joyaLogic.joyas[index];
                      return Card(
                        child: ListTile(
                          title: Text(joya.nombre),
                          subtitle: Text('Precio: S/. ${joya.precio.toStringAsFixed(2)} | Stock: ${joya.stock}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editarJoya(joya),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _eliminarJoya(joyaLogic, joya.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}