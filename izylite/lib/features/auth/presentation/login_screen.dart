import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/constans/Colors.dart';
import '../../../core/presentation/widgets/custom_button.dart';
import '../../../core/presentation/widgets/custom_input.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../products/data/product_repository.dart';
import '../../sales/data/sales_repository.dart';
import '../logic/auth_bloc.dart';
import '../logic/auth_state_events.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa tu usuario y contraseña'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      LoginSubmitted(username: username, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/svgs/izyfi_logo.svg', height: 100),

              const SizedBox(height: 32),

              Text(
                'Bienvenido a Izify',
                style: Theme.of(context).textTheme.displayMedium,
              ),

              const SizedBox(height: 32),

              CustomInput(
                label: '',
                hint: 'Nombre de Usuario',
                controller: _usernameController,
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
                textInputAction: TextInputAction.next,
              ),

              CustomInput(
                label: '',
                hint: 'Contraseña',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.primary,
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitLogin(),
              ),

              const SizedBox(height: 32),

              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiRepositoryProvider(
                          providers: [
                            RepositoryProvider(
                              create: (context) => SalesRepository(),
                            ),
                            RepositoryProvider(
                              create: (context) => ProductsRepository(),
                            ),
                          ],
                          child: const DashboardScreen(),
                        ),
                      ),
                    );
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return CustomButton(
                    isLoading: state is AuthLoading,
                    onPressed: state is AuthLoading ? null : _submitLogin,
                    child: const Text('Iniciar Sesión'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
