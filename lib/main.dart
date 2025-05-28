import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fozo_customer_app/utils/helper/shared_preferences_helper.dart';
import 'package:fozo_customer_app/views/splash.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'provider/home_provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Keep splash screen while initializing stuff
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Simulate some async initialization (e.g., loading user data)
  await Future.delayed(
      Duration(seconds: 2)); // Replace this with your real init

  // Remove splash screen when ready
  FlutterNativeSplash.remove();

  WidgetsFlutterBinding.ensureInitialized();

  // // Request all necessary app permissions (e.g., storage, location, etc.)
  // await AppPermissions.requestAllPermissions();

  // Initialize SharedPreferences to persist user data locally
  await SharedPreferencesHelper.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => FozoHomeProvider(),
        ),
        // ChangeNotifierProvider(
        //   create: (context) => BagProvider(),
        // ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // Base design dimensions
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // home: LoginScreen(),

            // // Determine the home screen based on login status
            home: Splash(), // Otherwise, show EntryScreen (login/signup)
          );
        },
      ),
    );
  }
}
