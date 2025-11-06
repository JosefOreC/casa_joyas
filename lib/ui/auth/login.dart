import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/ui/auth/register.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final authLogic = Provider.of<AuthLogic>(context, listen: false);
    var email = _emailController.text.trim();
    var password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete todos los campos para iniciar sesión'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      await authLogic.signIn(email, password);
      if (authLogic.isAuthenticated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión exitoso. ¡Bienvenido!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de inicio de sesión: ${e.toString()}')),
        );
      }
    }
  }

  void _loginWithGoogle() async {
    final authLogic = Provider.of<AuthLogic>(context, listen: false);

    try {
      await authLogic.signInWithGoogle();
      if (authLogic.isAuthenticated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión con Google exitoso. ¡Bienvenido!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de inicio de sesión con Google: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authLogic = Provider.of<AuthLogic>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF), // azul claro
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo o nombre de la tienda
              Text(
                'CASA DE LAS JOYAS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 32),

              // Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Contraseña
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Botón de login
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _login,
                  child: authLogic.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loginWithGoogle,
                  label: const Text(
                    'Iniciar sesión con Google',
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta? '),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const RegisterScreen()));
                    },
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
