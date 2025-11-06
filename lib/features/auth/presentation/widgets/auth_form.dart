import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/di/di.dart';
import 'package:med_just/core/routes/routers.dart';
import 'package:med_just/features/auth/presentation/controller/auth_bloc.dart';
import 'package:med_just/features/auth/presentation/controller/auth_state.dart';
import '../../../../core/utils/year_mapping.dart'; // Import year mapping utility

class AuthForm extends StatefulWidget {
  final bool isLogin;
  String? selectedYearId; // Store the selected yearId

  final Function(
    String email,
    String password,
    String? name,
    String? phone,
    String? uninumber,
    String? userId,
    String? yearId, // Add yearId parameter
  )
  onSubmit;
  final bool isLoading;

  AuthForm({
    super.key,
    required this.isLogin,
    required this.onSubmit,
    this.isLoading = false,
    this.selectedYearId,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _uninumberController = TextEditingController();
  String? _selectedYearId; // Store the selected yearId

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!widget.isLogin && _selectedYearId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your academic year')),
        );
        return;
      }

      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        widget.isLogin ? null : _nameController.text.trim(),
        widget.isLogin ? null : _phoneController.text.trim(),
        widget.isLogin ? null : _uninumberController.text.trim(),
        widget.isLogin ? null : null, // userId is optional
        widget.isLogin ? null : _selectedYearId, // Pass yearId
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final logoHeight = screenHeight * 0.18;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/spalsh-logo.png',
                height: logoHeight,
                width: logoHeight,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            !widget.isLogin
                ? Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium,
                )
                : Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
            const SizedBox(height: 32),
            if (!widget.isLogin)
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
            if (!widget.isLogin) const SizedBox(height: 16),

            // Phone field (only for registration)
            if (!widget.isLogin)
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
            if (!widget.isLogin) const SizedBox(height: 16),

            // University Number field (only for registration)
            if (!widget.isLogin)
              TextFormField(
                controller: _uninumberController,
                decoration: InputDecoration(
                  labelText: 'University Number',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your university number';
                  }
                  return null;
                },
              ),
            if (!widget.isLogin) const SizedBox(height: 16),

            // Academic Year dropdown (only for registration)
            if (!widget.isLogin)
              DropdownButtonFormField<String>(
                value: _selectedYearId, // Current selected value
                decoration: InputDecoration(
                  labelText: 'Academic Year',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items:
                    yearMapping.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key, // Use the key (yearId) as the value
                        child: Text(entry.value), // Display the year name
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedYearId = value; // Update the selected yearId
                    print(
                      'Selected Year ID: $_selectedYearId',
                    ); // Debug statement
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your academic year';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password field
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password field (only for registration)
            if (!widget.isLogin)
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            if (!widget.isLogin) const SizedBox(height: 16),

            // Name field (only for registration)
            if (!widget.isLogin) const SizedBox(height: 16),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : _submitForm,
                child:
                    widget.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(widget.isLogin ? 'Login' : 'Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
