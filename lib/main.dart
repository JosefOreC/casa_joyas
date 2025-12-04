import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/firebase_options.dart';
import 'package:casa_joyas/ui/splash/splash_screen.dart';
import 'package:casa_joyas/core/theme/app_theme.dart';
import 'package:casa_joyas/core/theme/theme_provider.dart';

import 'package:casa_joyas/modelo/database/crud_user.dart';
import 'package:casa_joyas/modelo/database/crud_joya.dart';
import 'package:casa_joyas/modelo/database/crud_order.dart';
import 'package:casa_joyas/modelo/database/crud_sale.dart';
import 'package:casa_joyas/modelo/database/crud_notification.dart';

import 'package:casa_joyas/modelo/database/firebase/crud_user.dart';
import 'package:casa_joyas/modelo/database/firebase/crud_joya.dart';
import 'package:casa_joyas/modelo/database/firebase/crud_order.dart';
import 'package:casa_joyas/modelo/database/firebase/crud_sale.dart';
import 'package:casa_joyas/modelo/database/firebase/crud_notification.dart';

import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/logica/products/user_logic.dart';
import 'package:casa_joyas/logica/products/joya_logic.dart';
import 'package:casa_joyas/logica/products/order_logic.dart';
import 'package:casa_joyas/logica/products/sale_logic.dart';
import 'package:casa_joyas/logica/products/notification_logic.dart';
import 'package:casa_joyas/modelo/database/shopping_cart_interface.dart';
import 'package:casa_joyas/modelo/database/firebase/shopping_cart_data.dart';
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<UserCRUDLogic>(create: (_) => FirebaseUserCRUDLogic()),
        Provider<JoyaCRUDLogic>(create: (_) => FirebaseJoyaCRUDLogic()),
        Provider<OrderCRUDLogic>(create: (_) => FirebaseOrderCRUDLogic()),
        Provider<SaleCRUDLogic>(create: (_) => FirebaseSaleCRUDLogic()),
        Provider<CartPersistenceLogic>(
          create: (_) => FirebaseCartPersistenceLogic(),
        ),
        Provider<NotificationCRUDLogic>(
          create: (_) => FirebaseNotificationCRUDLogic(),
        ),

        ChangeNotifierProvider<AuthLogic>(
          create: (context) =>
              AuthLogic(Provider.of<UserCRUDLogic>(context, listen: false)),
        ),
        ChangeNotifierProvider<UserLogic>(
          create: (context) =>
              UserLogic(Provider.of<UserCRUDLogic>(context, listen: false)),
        ),
        ChangeNotifierProvider<JoyaLogic>(
          create: (context) =>
              JoyaLogic(Provider.of<JoyaCRUDLogic>(context, listen: false)),
        ),
        ChangeNotifierProvider<NotificationLogic>(
          create: (context) => NotificationLogic(
            Provider.of<NotificationCRUDLogic>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<OrderLogic>(
          create: (context) => OrderLogic(
            Provider.of<OrderCRUDLogic>(context, listen: false),
            Provider.of<NotificationLogic>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<SaleLogic>(
          create: (context) =>
              SaleLogic(Provider.of<SaleCRUDLogic>(context, listen: false)),
        ),
        ChangeNotifierProvider<ShoppingCartLogic>(
          create: (context) => ShoppingCartLogic(
            Provider.of<OrderLogic>(context, listen: false),
            Provider.of<SaleLogic>(context, listen: false),
            Provider.of<AuthLogic>(context, listen: false),
            Provider.of<CartPersistenceLogic>(context, listen: false),
            Provider.of<JoyaLogic>(context, listen: false),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'CASA DE LAS JOYAS',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
