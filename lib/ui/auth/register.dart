import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          const SnackBar(content: Text('Registro exitoso. ¡Bienvenido Cliente!')),
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

  void _registerWithGoogle() async {
    if (!mounted) return;
    final authLogic = Provider.of<AuthLogic>(context, listen: false);

    try {
      await authLogic.signInWithGoogle();

      if (authLogic.isAuthenticated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro/Inicio con Google exitoso. ¡Bienvenido!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error con Google: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authLogic = Provider.of<AuthLogic>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            TextField(
              controller: _numeroController,
              decoration: const InputDecoration(labelText: 'Número (Opcional)'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            if (authLogic.isLoading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Registrarse'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _registerWithGoogle,
                icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
                label: const Text('Registrarse con Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
