import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/products/joya_logic.dart';
import 'package:casa_joyas/modelo/products/joya.dart';

class CatalogoJoyasScreen extends StatefulWidget {
  const CatalogoJoyasScreen({super.key});

  @override
  State<CatalogoJoyasScreen> createState() => _CatalogoJoyasScreenState();
}

class _CatalogoJoyasScreenState extends State<CatalogoJoyasScreen> {
  int _currentPage = 0;
  final int _itemsPerPage = 6;

  @override
  Widget build(BuildContext context) {
    final joyaLogic = Provider.of<JoyaLogic>(context);

    if (joyaLogic.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final joyas = joyaLogic.joyas;
    final totalPages = (joyas.length / _itemsPerPage).ceil();

    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage > joyas.length)
        ? joyas.length
        : startIndex + _itemsPerPage;

    final joyasPagina = joyas.sublist(startIndex, endIndex);

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: joyasPagina.length,
            itemBuilder: (context, index) {
              final joya = joyasPagina[index];
              return _buildJoyaCard(joya);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
                child: const Text('Anterior'),
              ),
              const SizedBox(width: 16),
              Text('Página ${_currentPage + 1} de $totalPages'),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _currentPage < totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
                child: const Text('Siguiente'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJoyaCard(Joya joya) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                joya.imageUrl.isNotEmpty ? joya.imageUrl : 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(joya.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'S/. ${joya.precio.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.pinkAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
