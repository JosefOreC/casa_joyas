import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/products/joya_logic.dart';
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
import 'package:casa_joyas/modelo/products/joya.dart';
import 'package:casa_joyas/ui/shop/joya_detail_ui.dart';
import 'package:casa_joyas/core/theme/app_colors.dart';

class CatalogoJoyasScreen extends StatefulWidget {
  const CatalogoJoyasScreen({super.key});

  @override
  State<CatalogoJoyasScreen> createState() => _CatalogoJoyasScreenState();
}

class _CatalogoJoyasScreenState extends State<CatalogoJoyasScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int _visibleItems = 10;
  bool _isLoadingMore = false;

  String _selectedTipo = 'Todos';
  String _selectedMaterial = 'Todos';
  String _sortBy = 'Nombre (A-Z)';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _visibleItems += 10;
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshJoyas() async {
    final joyaLogic = Provider.of<JoyaLogic>(context, listen: false);
    await joyaLogic.fetchJoyas();
    setState(() {
      _visibleItems = 10;
    });
  }

  void _addShopCart(BuildContext context, Joya joya) async {
    final cartLogic = Provider.of<ShoppingCartLogic>(context, listen: false);

    if (joya.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lo siento, este producto no cuenta con stock.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        int cantidad = 1;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(joya.nombre),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      joya.imageUrl.isNotEmpty
                          ? joya.imageUrl
                          : 'https://via.placeholder.com/150',
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Cantidad disponible: ${joya.stock}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (cantidad > 1) setStateDialog(() => cantidad--);
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$cantidad', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        onPressed: () {
                          if (cantidad < joya.stock) {
                            setStateDialog(() => cantidad++);
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // <-- Hacemos el callback ASÍNCRONO
                    try {
                      // CORRECCIÓN CLAVE: Pasamos la variable 'cantidad'
                      await (cartLogic.addItem(joya, cantidad: cantidad)
                          as Future<void>);

                      // Si no hubo excepción de stock:
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Agregaste $cantidad ${joya.nombre}(s) al carrito.',
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      // Capturamos el error de stock lanzado por ShoppingCartLogic
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error: ${e.toString().replaceAll('Exception: ', '')}',
                            ),
                          ),
                        );
                        // No cerramos el diálogo si hay error para que el usuario pueda corregir la cantidad
                      }
                    }
                  },
                  child: const Text('Confirmar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Joya> _filterAndSort(List<Joya> joyas) {
    String query = _searchController.text.toLowerCase();

    var filtered = joyas.where((joya) {
      final matchName = joya.nombre.toLowerCase().contains(query);
      final matchTipo =
          _selectedTipo.toLowerCase() == 'todos' ||
          joya.tipo.toLowerCase() == _selectedTipo.toLowerCase();
      final matchMaterial =
          _selectedMaterial.toLowerCase() == 'todos' ||
          joya.material.toLowerCase() == _selectedMaterial.toLowerCase();
      return matchName && matchTipo && matchMaterial;
    }).toList();

    switch (_sortBy) {
      case 'Precio (menor a mayor)':
        filtered.sort((a, b) => a.precio.compareTo(b.precio));
        break;
      case 'Precio (mayor a menor)':
        filtered.sort((a, b) => b.precio.compareTo(a.precio));
        break;
      case 'Nombre (Z-A)':
        filtered.sort((a, b) => b.nombre.compareTo(a.nombre));
        break;
      default:
        filtered.sort((a, b) => a.nombre.compareTo(b.nombre));
    }

    return filtered.take(_visibleItems).toList();
  }

  @override
  Widget build(BuildContext context) {
    final joyaLogic = Provider.of<JoyaLogic>(context);
    final joyas = joyaLogic.joyas;

    final tipos = [
      'Todos',
      ...{
        for (var j in joyas)
          if (j.tipo.isNotEmpty) j.tipo.toUpperCase(),
      },
    ];
    final materiales = [
      'Todos',
      ...{for (var j in joyas) j.material.toUpperCase()},
    ];

    final Map<String, String> tipoImages = {};
    for (var tipo in tipos) {
      if (tipo == 'Todos') continue;
      final joyaConImagen = joyas.firstWhere(
        (j) =>
            j.tipo.toLowerCase() == tipo.toLowerCase() && j.imageUrl.isNotEmpty,
        orElse: () => Joya(
          id: '',
          nombre: '',
          descripcion: '',
          precio: 0,
          stock: 0,
          imageUrl: '',
          tipo: tipo,
          material: '',
        ),
      );
      tipoImages[tipo] = joyaConImagen.imageUrl.isNotEmpty
          ? joyaConImagen.imageUrl
          : 'https://cdn-icons-png.flaticon.com/512/565/565547.png';
    }

    final joyasFiltradas = _filterAndSort(joyas);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshJoyas,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          children: [
            // Buscador
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar joya por nombre...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),

            // Categorías
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: tipos.map((tipo) {
                  final img = tipo == 'Todos'
                      ? 'https://cdn-icons-png.flaticon.com/512/709/709496.png'
                      : tipoImages[tipo] ??
                            'https://cdn-icons-png.flaticon.com/512/565/565547.png';
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTipo = tipo),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(8),
                      width: 80,
                      decoration: BoxDecoration(
                        color: _selectedTipo == tipo
                            ? AppColors.goldPrimary.withOpacity(0.2)
                            : AppColors.lightGray.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedTipo == tipo
                              ? AppColors.goldPrimary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              img,
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tipo,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            //filtros
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedMaterial,
                    decoration: const InputDecoration(labelText: 'Material'),
                    items: materiales
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedMaterial = value!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _sortBy,
                    decoration: const InputDecoration(labelText: 'Ordenar por'),
                    items:
                        const [
                              'Nombre (A-Z)',
                              'Nombre (Z-A)',
                              'Precio (menor a mayor)',
                              'Precio (mayor a menor)',
                            ]
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => _sortBy = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: joyasFiltradas.length,
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final joya = joyasFiltradas[index];
                return _buildJoyaCard(joya);
              },
            ),

            if (_isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoyaCard(Joya joya) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => JoyaDetailScreen(joya: joya)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
              blurRadius: isDark ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with gradient overlay
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      joya.imageUrl.isNotEmpty
                          ? joya.imageUrl
                          : 'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  // Stock badge
                  if (joya.stock < 5)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: joya.stock == 0
                              ? AppColors.error
                              : AppColors.warning,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          joya.stock == 0
                              ? 'AGOTADO'
                              : '¡Quedan ${joya.stock} uds!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      joya.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'S/. ${joya.precio.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.goldPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${joya.stock} uds',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.goldPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add_shopping_cart_rounded),
                            color: AppColors.goldPrimary,
                            iconSize: 20,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            onPressed: () => _addShopCart(context, joya),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
