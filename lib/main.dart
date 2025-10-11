import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/firebase_options.dart';
import 'package:casa_joyas/ui/shop/main_screen.dart'; 

import 'package:casa_joyas/modelo/database/crud_user.dart';
import 'package:casa_joyas/modelo/database/crud_joya.dart';
import 'package:casa_joyas/modelo/database/crud_order.dart';
import 'package:casa_joyas/modelo/database/crud_sale.dart';

import 'package:casa_joyas/modelo/database/firebase/crud_user.dart';
import 'package:casa_joyas/modelo/database/firebase/crud_joya.dart';
import 'package:casa_joyas/modelo/database/firebase/crud_order.dart';
import 'package:casa_joyas/modelo/database/firebase/crud_sale.dart';

import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/logica/products/user_logic.dart';
import 'package:casa_joyas/logica/products/joya_logic.dart';
import 'package:casa_joyas/logica/products/order_logic.dart';
import 'package:casa_joyas/logica/products/sale_logic.dart';
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserCRUDLogic>(create: (_) => FirebaseUserCRUDLogic()),
        Provider<JoyaCRUDLogic>(create: (_) => FirebaseJoyaCRUDLogic()),
        Provider<OrderCRUDLogic>(create: (_) => FirebaseOrderCRUDLogic()),
        Provider<SaleCRUDLogic>(create: (_) => FirebaseSaleCRUDLogic()),
        
        ChangeNotifierProvider<AuthLogic>(
          create: (context) => AuthLogic(
            Provider.of<UserCRUDLogic>(context, listen: false), 
          ),
        ),
        ChangeNotifierProvider<UserLogic>(
          create: (context) => UserLogic(
            Provider.of<UserCRUDLogic>(context, listen: false), 
          ),
        ),
        ChangeNotifierProvider<JoyaLogic>(
          create: (context) => JoyaLogic(
            Provider.of<JoyaCRUDLogic>(context, listen: false), 
          ),
        ),
        ChangeNotifierProvider<OrderLogic>(
          create: (context) => OrderLogic(
            Provider.of<OrderCRUDLogic>(context, listen: false), 
          ),
        ),
        ChangeNotifierProvider<SaleLogic>(
          create: (context) => SaleLogic(
            Provider.of<SaleCRUDLogic>(context, listen: false), 
          ),
        ),
        ChangeNotifierProvider<ShoppingCartLogic>(
          create: (context) => ShoppingCartLogic(
            Provider.of<OrderLogic>(context, listen: false),
            Provider.of<SaleLogic>(context, listen: false), 
            Provider.of<AuthLogic>(context, listen: false), 
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Mi Tienda Online',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MainScreen(), 
      ),
    );
  }
}