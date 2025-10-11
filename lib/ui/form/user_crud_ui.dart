import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/modelo/products/user.dart';
import 'package:casa_joyas/logica/products/user_logic.dart'; 

class UserCRUDScreen extends StatelessWidget {
  const UserCRUDScreen({super.key});

  void _mostrarDialogoEditar(BuildContext context, UserLogic userLogic, User user) {
    UserRole? rolSeleccionado = user.rol;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Rol de ${user.nombre}'),
          content: DropdownButtonFormField<UserRole>(
            value: rolSeleccionado,
            items: UserRole.values
                .map((rol) => DropdownMenuItem(
                      value: rol,
                      child: Text(rol.name.toUpperCase()),
                    ))
                .toList(),
            onChanged: (value) {
              rolSeleccionado = value;
            },
            decoration: const InputDecoration(labelText: 'Rol'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (rolSeleccionado != null) {
                  final userActualizado = user.copyWith(rol: rolSeleccionado!);
                  await userLogic.updateUser(userActualizado);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userLogic = Provider.of<UserLogic>(context);

    if (userLogic.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin. de Usuarios'),
        backgroundColor: Colors.blueGrey,
      ),
      body: userLogic.users.isEmpty
          ? const Center(child: Text('No hay usuarios registrados.'))
          : ListView.builder(
              itemCount: userLogic.users.length,
              itemBuilder: (context, index) {
                final user = userLogic.users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(user.nombre),
                    subtitle: Text('Email: ${user.email}\nRol: ${user.rol.name.toUpperCase()}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _mostrarDialogoEditar(context, userLogic, user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => userLogic.deleteUser(user.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
