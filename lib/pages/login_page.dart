import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await _authService.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  _buildHeader(isDark),
                  const SizedBox(height: 60),
                  _buildEmailField(isDark),
                  const SizedBox(height: 20),
                  _buildPasswordField(isDark),
                  const SizedBox(height: 12),
                  _buildForgotPassword(),
                  const SizedBox(height: 32),
                  _buildLoginButton(),
                  const SizedBox(height: 24),
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF0F3460),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.mosque,
            color: Colors.white,
            size: 60,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Connexion',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F3460),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bienvenue! Connectez-vous à votre compte',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(bool isDark) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F3460),
      ),
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: isDark ? Colors.grey[400] : const Color(0xFF0F3460),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0F3460), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre email';
        }
        if (!value.contains('@')) {
          return 'Veuillez entrer un email valide';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F3460),
      ),
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: isDark ? Colors.grey[400] : const Color(0xFF0F3460),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: isDark ? Colors.grey[400] : const Color(0xFF0F3460),
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0F3460), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre mot de passe';
        }
        if (value.length < 6) {
          return 'Le mot de passe doit contenir au moins 6 caractères';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
          );
        },
        child: const Text(
          'Mot de passe oublié?',
          style: TextStyle(
            color: Color(0xFF0F3460),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F3460),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Se connecter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas de compte? ',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            );
          },
          child: const Text(
            'S\'inscrire',
            style: TextStyle(
              color: Color(0xFF0F3460),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}