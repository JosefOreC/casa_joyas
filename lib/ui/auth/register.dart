import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _numeroController = TextEditingController();

  void _register() async {
    if (!mounted) return;
    final authLogic = Provider.of<AuthLogic>(context, listen: false);

    try {
      await authLogic.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nombreController.text.trim(),
        _numeroController.text.trim().isEmpty ? null : _numeroController.text.trim(),
      );
      
      if (authLogic.isAuthenticated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registro exitoso. ¡Bienvenido Cliente!')),
        );
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de registro: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authLogic = Provider.of<AuthLogic>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            TextField(
              controller: _numeroController,
              decoration: InputDecoration(labelText: 'Número (Opcional)'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            if (authLogic.isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _register,
                child: Text('Registrarse'),
              ),
          ],
        ),
      ),
    );
  }
}