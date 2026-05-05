import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constans/Colors.dart';
import 'core/constans/app_text_theme.dart';
import 'core/storage/token.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/logic/auth_bloc.dart';
import 'features/auth/presentation/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final bool isLoggedIn = await tokenStorage.hasToken();

  runApp(IzifyApp(isLoggedIn: isLoggedIn));
}

class IzifyApp extends StatelessWidget {
  final bool isLoggedIn;

  const IzifyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Izify POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.base100,
        textTheme: AppTextTheme.textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.base200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.base300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
      home: BlocProvider(
        create: (context) => AuthBloc(repository: AuthRepository()),
        child: const LoginScreen(),
      ),
    );
  }
}
