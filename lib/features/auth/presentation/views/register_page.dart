import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/year_mapping.dart';
import '../widgets/auth_form.dart';
import '../controller/auth_bloc.dart';
import '../controller/auth_event.dart';
import '../controller/auth_state.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated) {
            // Save user locally in Hive
            final userBox = Hive.box('userBox');
            await userBox.put('user', state.user.toJson());
            Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  AuthForm(
                    isLogin: false,
                    onSubmit: _handleRegister,
                    isLoading: state is AuthLoading,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppConstants.loginRoute,
                      );
                    },
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  dynamic _handleRegister(
    String email,
    String password,
    String? name,
    String? phone,
    String? uninumber,
    String? userId,
    String? yearId,
  ) {
    if (yearId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your academic year')),
      );
      return null;
    }

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        email: email,
        password: password,
        name: name ?? '',
        phone: phone ?? '',
        uninumber: uninumber ?? '',
        userId: userId ?? '',
        yearId: yearId,
      ),
    );
    return null;
  }
}
