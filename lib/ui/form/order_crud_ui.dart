import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/modelo/products/order.dart';
import 'package:casa_joyas/modelo/products/user.dart';
import 'package:casa_joyas/logica/products/order_logic.dart';
import 'package:casa_joyas/logica/products/user_logic.dart';

class OrderCRUDScreen extends StatefulWidget {
  const OrderCRUDScreen({super.key});

  @override
  State<OrderCRUDScreen> createState() => _OrderCRUDScreenState();
}

class _OrderCRUDScreenState extends State<OrderCRUDScreen> {
  final List<String> _estados = const [
    'Pendiente',
    'Procesando',
    'Enviada',
    'Entregada',
    'Cancelada',
  ];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filtros de fecha
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _useAllOrders =
      false; // Si es true, muestra todas las órdenes sin filtro de fecha

  @override
  void initState() {
    super.initState();
    // Cargar órdenes de hoy al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    final orderLogic = Provider.of<OrderLogic>(context, listen: false);
    if (_useAllOrders) {
      orderLogic.fetchOrders();
    } else {
      orderLogic.fetchOrdersByDateRange(_startDate, _endDate);
    }
  }

  // Obtener información del usuario por ID
  User? _getUserById(UserLogic userLogic, String userId) {
    try {
      return userLogic.users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Filtrar órdenes por búsqueda
  List<Order> _filterOrders(List<Order> orders, UserLogic userLogic) {
    if (_searchQuery.isEmpty) {
      return orders;
    }

    final query = _searchQuery.toLowerCase();
    return orders.where((order) {
      // Buscar por código de orden
      final matchesOrderId = order.id.toLowerCase().contains(query);

      // Buscar por nombre o email del cliente
      final user = _getUserById(userLogic, order.userId);
      final matchesUserName =
          user?.nombre.toLowerCase().contains(query) ?? false;
      final matchesUserEmail =
          user?.email.toLowerCase().contains(query) ?? false;

      return matchesOrderId || matchesUserName || matchesUserEmail;
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _useAllOrders = false;
      });
      _loadOrders();
    }
  }

  void _mostrarDialogoDetalle(
    BuildContext context,
    OrderLogic orderLogic,
    UserLogic userLogic,
    Order order,
  ) {
    String? estadoSeleccionado = order.estado;
    final user = _getUserById(userLogic, order.userId);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalle de Orden #${order.id.substring(0, 8)}...'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Información del Cliente
                const Text(
                  'CLIENTE:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text('Nombre: ${user?.nombre ?? "Desconocido"}'),
                Text('Email: ${user?.email ?? "N/A"}'),
                if (user?.numero != null) Text('Teléfono: ${user!.numero}'),
                const Divider(height: 20),

                // Información de la Orden
                const Text(
                  'ORDEN:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: S/. ${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Fecha: ${order.fecha.toLocal().toString().split(' ')[0]}',
                ),
                Text(
                  'ID Orden: ${order.id}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Divider(height: 20),

                // Items de la Orden
                const Text(
                  'ITEMS:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.joyaNombre} (x${item.cantidad})'),
                              Text(
                                'S/. ${item.precioUnitario.toStringAsFixed(2)} c/u',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              if (item.especificaciones != null &&
                                  item.especificaciones!.isNotEmpty)
                                Text(
                                  'Personalización: "${item.especificaciones}"',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.blueGrey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 20),

                // Cambiar Estado
                DropdownButtonFormField<String>(
                  value: estadoSeleccionado,
                  items: _estados
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    estadoSeleccionado = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Estado de la Orden',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (estadoSeleccionado != null &&
                    estadoSeleccionado != order.estado) {
                  final orderActualizada = order.copyWith(
                    estado: estadoSeleccionado,
                  );
                  await orderLogic.updateOrder(orderActualizada);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Estado actualizado a: $estadoSeleccionado',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Guardar Estado'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderLogic = Provider.of<OrderLogic>(context);
    final userLogic = Provider.of<UserLogic>(context);

    if (orderLogic.isLoading || userLogic.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filteredOrders = _filterOrders(orderLogic.orders, userLogic);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de Órdenes'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro de fecha
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.orange[50],
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _useAllOrders
                            ? 'Mostrando todas las órdenes'
                            : 'Desde: ${_startDate.day}/${_startDate.month}/${_startDate.year} - Hasta: ${_endDate.day}/${_endDate.month}/${_endDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDateRange,
                        icon: const Icon(Icons.date_range),
                        label: const Text('Cambiar Rango'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _startDate = DateTime.now();
                            _endDate = DateTime.now();
                            _useAllOrders = false;
                          });
                          _loadOrders();
                        },
                        icon: const Icon(Icons.today),
                        label: const Text('Hoy'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _useAllOrders = true;
                          });
                          _loadOrders();
                        },
                        icon: const Icon(Icons.all_inclusive),
                        label: const Text('Todas'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _useAllOrders
                              ? Colors.orange
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por código, cliente o email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Contador de resultados
          if (_searchQuery.isNotEmpty || !_useAllOrders)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${filteredOrders.length} orden(es) encontrada(s)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

          // Lista de órdenes
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty ? Icons.inbox : Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No hay órdenes en este rango de fechas.'
                              : 'No se encontraron órdenes.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final user = _getUserById(userLogic, order.userId);

                      // Color del estado
                      Color estadoColor;
                      switch (order.estado) {
                        case 'Pendiente':
                          estadoColor = Colors.orange;
                          break;
                        case 'Procesando':
                          estadoColor = Colors.blue;
                          break;
                        case 'Enviada':
                          estadoColor = Colors.purple;
                          break;
                        case 'Entregada':
                          estadoColor = Colors.green;
                          break;
                        case 'Cancelada':
                          estadoColor = Colors.red;
                          break;
                        default:
                          estadoColor = Colors.grey;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 16,
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: estadoColor.withOpacity(0.2),
                            child: Icon(Icons.shopping_bag, color: estadoColor),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Orden #${order.id.substring(0, 8)}...',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: estadoColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  order.estado,
                                  style: TextStyle(
                                    color: estadoColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      user?.nombre ?? 'Cliente Desconocido',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      user?.email ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total: S/. ${order.total.toStringAsFixed(2)} | ${order.fecha.toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.visibility,
                              color: Colors.blue,
                            ),
                            onPressed: () => _mostrarDialogoDetalle(
                              context,
                              orderLogic,
                              userLogic,
                              order,
                            ),
                            tooltip: 'Ver detalles',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
