import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await _authService.registerWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 40),
                  _buildFullNameField(isDark),
                  const SizedBox(height: 20),
                  _buildEmailField(isDark),
                  const SizedBox(height: 20),
                  _buildPasswordField(isDark),
                  const SizedBox(height: 20),
                  _buildConfirmPasswordField(isDark),
                  const SizedBox(height: 20),
                  _buildTermsCheckbox(isDark),
                  const SizedBox(height: 32),
                  _buildRegisterButton(),
                  const SizedBox(height: 24),
                  _buildLoginLink(),
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
        Text(
          'Créer un compte',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F3460),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rejoignez-nous pour commencer votre voyage spirituel',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFullNameField(bool isDark) {
    return TextFormField(
      controller: _fullNameController,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F3460),
      ),
      decoration: InputDecoration(
        labelText: 'Nom complet',
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        prefixIcon: Icon(
          Icons.person_outline,
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
          return 'Veuillez entrer votre nom';
        }
        if (value.length < 2) {
          return 'Le nom doit contenir au moins 2 caractères';
        }
        return null;
      },
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
        if (!value.contains('@') || !value.contains('.')) {
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
          return 'Veuillez entrer un mot de passe';
        }
        if (value.length < 6) {
          return 'Le mot de passe doit contenir au moins 6 caractères';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(bool isDark) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F3460),
      ),
      decoration: InputDecoration(
        labelText: 'Confirmer le mot de passe',
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: isDark ? Colors.grey[400] : const Color(0xFF0F3460),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: isDark ? Colors.grey[400] : const Color(0xFF0F3460),
          ),
          onPressed: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
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
          return 'Veuillez confirmer votre mot de passe';
        }
        if (value != _passwordController.text) {
          return 'Les mots de passe ne correspondent pas';
        }
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox(bool isDark) {
    return Row(
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: (value) {
            setState(() => _acceptedTerms = value ?? false);
          },
          activeColor: const Color(0xFF0F3460),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _acceptedTerms = !_acceptedTerms);
            },
            child: Text(
              'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleRegister,
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
              'S\'inscrire',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous avez déjà un compte? ',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Se connecter',
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