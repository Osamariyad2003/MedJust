import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/routes/routers.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/auth_form.dart';
import '../controller/auth_bloc.dart';
import '../controller/auth_event.dart';
import '../controller/auth_state.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated && state.user != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(Routers.homeRoute);
            });
          } else if (state is AuthError) {
            // Show error message
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuthForm(
                  isLogin: true,
                  onSubmit: _handleLogin,
                  isLoading: state is AuthLoading,
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(Routers.registerRoute);
                  },
                  child: Text('Don\'t have an account? Register'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  dynamic _handleLogin(
    String email,
    String password,
    String? name,
    String? phone,
    String? uninumber,
    String? userId,
    String? yearId,
  ) {
    context.read<AuthBloc>().add(
      AuthLoginRequested(email: email, password: password),
    );
    return null;
  }
}
