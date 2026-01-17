import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _isChangingPassword = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }
  }
  
  Future<void> _updateDisplayName() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _authService.updateDisplayName(_nameController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nom mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditingName = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _updateEmail() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre mot de passe actuel'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Ré-authentifier l'utilisateur
      final user = FirebaseAuth.instance.currentUser;
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: _currentPasswordController.text,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Mettre à jour l'email
      await user.updateEmail(_emailController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditingEmail = false;
          _currentPasswordController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authService.getErrorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Ré-authentifier l'utilisateur
      final user = FirebaseAuth.instance.currentUser;
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: _currentPasswordController.text,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Changer le mot de passe
      await user.updatePassword(_newPasswordController.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe changé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isChangingPassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authService.getErrorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? '
          'Cette action est irréversible et toutes vos données seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    // Demander le mot de passe pour confirmation
    final password = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Entrez votre mot de passe pour confirmer :'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text(
                'Confirmer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    
    if (password == null || password.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Ré-authentifier l'utilisateur
      final user = FirebaseAuth.instance.currentUser;
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Supprimer le compte
      await _authService.deleteAccount();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authService.getErrorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildProfileAvatar(user),
                      const SizedBox(height: 32),
                      _buildNameSection(isDark),
                      const SizedBox(height: 20),
                      _buildEmailSection(isDark),
                      const SizedBox(height: 20),
                      _buildPasswordSection(isDark),
                      const SizedBox(height: 32),
                      _buildLogoutButton(isDark),
                      const SizedBox(height: 32),
                      _buildDeleteAccountButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B4965),
            const Color(0xFF2C6E8F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Mon Profil',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
  
  Widget _buildProfileAvatar(User? user) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B4965),
            const Color(0xFF2C6E8F),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4965).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          user?.displayName?.isNotEmpty == true
              ? user!.displayName![0].toUpperCase()
              : user?.email?[0].toUpperCase() ?? 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildNameSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: const Color(0xFF1B4965),
              ),
              const SizedBox(width: 12),
              const Text(
                'Nom complet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!_isEditingName)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => setState(() => _isEditingName = true),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isEditingName) ...[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Entrez votre nom',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditingName = false;
                        _loadUserData();
                      });
                    },
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateDisplayName,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4965),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ] else
            Text(
              _nameController.text.isEmpty ? 'Non renseigné' : _nameController.text,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildEmailSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: const Color(0xFF1B4965),
              ),
              const SizedBox(width: 12),
              const Text(
                'Adresse email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!_isEditingEmail)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => setState(() => _isEditingEmail = true),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isEditingEmail) ...[
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Nouvel email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'email est requis';
                }
                if (!value.contains('@')) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(
                hintText: 'Mot de passe actuel',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditingEmail = false;
                        _currentPasswordController.clear();
                        _loadUserData();
                      });
                    },
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4965),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ] else
            Text(
              _emailController.text,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildPasswordSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: const Color(0xFF1B4965),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mot de passe',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!_isChangingPassword)
                TextButton(
                  onPressed: () => setState(() => _isChangingPassword = true),
                  child: const Text('Modifier'),
                ),
            ],
          ),
          if (_isChangingPassword) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(
                hintText: 'Mot de passe actuel',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                hintText: 'Nouveau mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Le mot de passe doit contenir au moins 6 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                hintText: 'Confirmer le nouveau mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isChangingPassword = false;
                        _currentPasswordController.clear();
                        _newPasswordController.clear();
                        _confirmPasswordController.clear();
                      });
                    },
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4965),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Changer'),
                  ),
                ),
              ],
            ),
          ] else
            Text(
              '••••••••',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLogoutButton(bool isDark) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Déconnexion'),
              content: const Text('Voulez-vous vraiment vous déconnecter?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Déconnexion',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await _authService.signOut();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Se déconnecter'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDeleteAccountButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            'Zone dangereuse',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'La suppression de votre compte est irréversible',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _deleteAccount,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Supprimer mon compte'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}