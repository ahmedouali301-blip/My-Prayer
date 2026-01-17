import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await _authService.resetPassword(_emailController.text.trim());

    setState(() => _isLoading = false);

    if (error == null) {
      setState(() => _emailSent = true);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF0F3460),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _emailSent ? _buildSuccessView(isDark) : _buildFormView(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          _buildHeader(isDark),
          const SizedBox(height: 60),
          _buildEmailField(isDark),
          const SizedBox(height: 32),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 60,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Email envoyé!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F3460),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Nous avons envoyé un lien de réinitialisation à',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F3460),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Veuillez vérifier votre boîte de réception et suivre les instructions.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F3460),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: const Text(
            'Retour à la connexion',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF0F3460).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_reset,
            color: Color(0xFF0F3460),
            size: 50,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Mot de passe oublié?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F3460),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Pas de souci! Entrez votre email et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            height: 1.5,
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

  Widget _buildResetButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleResetPassword,
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
              'Envoyer le lien',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}