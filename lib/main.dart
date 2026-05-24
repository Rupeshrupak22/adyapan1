import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/app_state.dart';
import 'features/login_screen.dart';

void main() {
  // Ensure Flutter engine bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Force light system status bar style with white background
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const AdyapanApp(),
    ),
  );
}

class AdyapanApp extends StatelessWidget {
  const AdyapanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adyapan Smart Learning Ecosystem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AdyapanTheme.blueAccent,
          background: AdyapanTheme.bgDark,
        ),
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Outfit',
          bodyColor: AdyapanTheme.textMain,
          displayColor: AdyapanTheme.textMain,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
