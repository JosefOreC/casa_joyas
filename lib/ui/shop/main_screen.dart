import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/modelo/products/user.dart';
import 'package:casa_joyas/ui/shop/admin_dashboard.dart';
import 'package:casa_joyas/ui/shop/client_home.dart';
import 'package:casa_joyas/ui/auth/login.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
   
    Provider.of<AuthLogic>(context, listen: false).checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    
    final authLogic = Provider.of<AuthLogic>(context);

    if (authLogic.isLoading) {
      
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authLogic.isAuthenticated || authLogic.currentUser == null) {
      
      return LoginScreen();
    }


    final rol = authLogic.currentUser!.rol;
    
    if (rol == UserRole.administrador || rol == UserRole.empleado) {
      return const AdminDashboard();
    } else {
    
      return const ClientHome();
    }
  }
}